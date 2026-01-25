#!/bin/bash
# setup-bedrock-lab-org.sh
# Run from Org Root to setup Bedrock Lab in member accounts
#
# Usage:
#   ./setup-bedrock-lab-org.sh 123456789012                    # Single account
#   ./setup-bedrock-lab-org.sh 123456789012 234567890123       # Multiple accounts
#   ./setup-bedrock-lab-org.sh --file accounts.txt             # From file (one account ID per line)
#   ./setup-bedrock-lab-org.sh --check 123456789012            # Check status
#   ./setup-bedrock-lab-org.sh --cleanup 123456789012          # Remove resources
#   ./setup-bedrock-lab-org.sh --list                          # List org accounts

set -e

ROLE_NAME="BedrockLabRole"
POLICY_NAME="BedrockAgentsLabPolicy"
REGION="${AWS_REGION:-us-west-2}"

# Role that org root assumes into member accounts
# This is auto-created when you create accounts via Organizations
ORG_ACCESS_ROLE="${ORG_ACCESS_ROLE:-OrganizationAccountAccessRole}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Save original credentials at script start
ORIG_AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
ORIG_AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
ORIG_AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN:-}"

# Trust policy - allows SageMaker and Bedrock to assume this role
TRUST_POLICY='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "sagemaker.amazonaws.com",
          "bedrock.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}'

# Permissions policy - comprehensive for SageMaker Unified Studio V2
PERMISSIONS_POLICY='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "InferenceProfileManagement",
      "Effect": "Allow",
      "Action": [
        "sts:GetCallerIdentity",
        "bedrock:ListInferenceProfiles",
        "bedrock:GetInferenceProfile",
        "bedrock:CreateInferenceProfile",
        "bedrock:DeleteInferenceProfile",
        "bedrock:ListTagsForResource",
        "bedrock:TagResource"
      ],
      "Resource": "*"
    },
    {
      "Sid": "BedrockModelInvocation",
      "Effect": "Allow",
      "Action": [
        "bedrock-runtime:Converse",
        "bedrock-runtime:ConverseStream",
        "bedrock-runtime:InvokeModel",
        "bedrock-runtime:InvokeModelWithResponseStream"
      ],
      "Resource": [
        "arn:aws:bedrock:*::foundation-model/anthropic.*",
        "arn:aws:bedrock:*:*:inference-profile/*",
        "arn:aws:bedrock:*:*:application-inference-profile/*"
      ]
    },
    {
      "Sid": "RAMForProjectProfiles",
      "Effect": "Allow",
      "Action": [
        "ram:GetResourceShareAssociations",
        "ram:GetResourceShares",
        "ram:ListResources",
        "ram:ListResourceSharePermissions"
      ],
      "Resource": "*"
    },
    {
      "Sid": "IAMForServiceRoles",
      "Effect": "Allow",
      "Action": [
        "iam:GetRole",
        "iam:PassRole",
        "iam:ListRoles",
        "iam:CreateServiceLinkedRole"
      ],
      "Resource": "*"
    },
    {
      "Sid": "S3ForBlueprints",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SageMakerUnifiedStudio",
      "Effect": "Allow",
      "Action": [
        "sagemaker:*"
      ],
      "Resource": "*"
    }
  ]
}'

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      Bedrock Lab Setup - Organization Root Admin           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_help() {
    print_header
    echo -e "${YELLOW}USAGE:${NC}"
    echo "  $0 <ACCOUNT_ID> [ACCOUNT_ID...]     Setup one or more accounts"
    echo "  $0 --file <FILE>                    Setup accounts from file"
    echo "  $0 --check <ACCOUNT_ID>             Check setup status"
    echo "  $0 --cleanup <ACCOUNT_ID>           Remove lab resources"
    echo "  $0 --list                           List all org member accounts"
    echo ""
    echo -e "${YELLOW}EXAMPLES:${NC}"
    echo "  $0 123456789012                     # Setup single account"
    echo "  $0 123456789012 234567890123        # Setup multiple accounts"
    echo "  $0 --file workshop-accounts.txt    # Setup from file"
    echo "  $0 --cleanup 123456789012           # Cleanup after workshop"
    echo ""
    echo -e "${YELLOW}ENVIRONMENT VARIABLES:${NC}"
    echo "  AWS_REGION          Region for Bedrock (default: us-west-2)"
    echo "  ORG_ACCESS_ROLE     Role to assume (default: OrganizationAccountAccessRole)"
    echo ""
}

# Assume role into member account and export credentials
assume_role_into_account() {
    local account_id="$1"
    local role_arn="arn:aws:iam::${account_id}:role/${ORG_ACCESS_ROLE}"
    
    echo -e "${CYAN}Assuming role into account ${account_id}...${NC}"
    
    local creds=$(aws sts assume-role \
        --role-arn "$role_arn" \
        --role-session-name "BedrockLabSetup" \
        --query 'Credentials' \
        --output json 2>&1)
    
    if echo "$creds" | grep -q "AccessKeyId"; then
        export AWS_ACCESS_KEY_ID=$(echo "$creds" | python3 -c "import sys,json; print(json.load(sys.stdin)['AccessKeyId'])")
        export AWS_SECRET_ACCESS_KEY=$(echo "$creds" | python3 -c "import sys,json; print(json.load(sys.stdin)['SecretAccessKey'])")
        export AWS_SESSION_TOKEN=$(echo "$creds" | python3 -c "import sys,json; print(json.load(sys.stdin)['SessionToken'])")
        echo -e "  ${GREEN}✓${NC} Assumed role successfully"
        return 0
    else
        echo -e "  ${RED}✗${NC} Failed to assume role"
        echo "    Error: $creds"
        echo ""
        echo "    Make sure:"
        echo "    - Account $account_id exists in your organization"
        echo "    - Role '$ORG_ACCESS_ROLE' exists in the account"
        echo "    - You're running this from the org management account"
        return 1
    fi
}

# Clear assumed role credentials and restore original
clear_assumed_role() {
    if [ -n "$ORIG_AWS_ACCESS_KEY_ID" ]; then
        export AWS_ACCESS_KEY_ID="$ORIG_AWS_ACCESS_KEY_ID"
        export AWS_SECRET_ACCESS_KEY="$ORIG_AWS_SECRET_ACCESS_KEY"
        export AWS_SESSION_TOKEN="$ORIG_AWS_SESSION_TOKEN"
    else
        unset AWS_ACCESS_KEY_ID
        unset AWS_SECRET_ACCESS_KEY
        unset AWS_SESSION_TOKEN
    fi
}

# List all accounts in the organization
list_org_accounts() {
    print_header
    echo -e "${YELLOW}Member Accounts in Organization:${NC}"
    echo ""
    
    aws organizations list-accounts \
        --query "Accounts[?Status=='ACTIVE'].{ID:Id,Email:Email,Name:Name}" \
        --output table
    
    echo ""
    echo -e "${GREEN}Tip:${NC} Copy account IDs to use with this script"
}

create_role() {
    local account_id="$1"
    echo -e "${YELLOW}[1/3] Creating IAM Role: ${ROLE_NAME}${NC}"
    
    if aws iam get-role --role-name "$ROLE_NAME" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Role already exists"
        return 0
    fi
    
    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document "$TRUST_POLICY" \
        --description "Role for Bedrock Agents Lab workshop attendees" \
        --output text > /dev/null
    
    echo -e "  ${GREEN}✓${NC} Role created"
}

create_policy() {
    local account_id="$1"
    echo -e "${YELLOW}[2/3] Creating IAM Policy: ${POLICY_NAME}${NC}"
    
    local policy_arn="arn:aws:iam::${account_id}:policy/${POLICY_NAME}"
    
    if aws iam get-policy --policy-arn "$policy_arn" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Policy already exists"
        return 0
    fi
    
    aws iam create-policy \
        --policy-name "$POLICY_NAME" \
        --policy-document "$PERMISSIONS_POLICY" \
        --description "Permissions for Bedrock Agents Lab" \
        --output text > /dev/null
    
    echo -e "  ${GREEN}✓${NC} Policy created"
}

attach_policy() {
    local account_id="$1"
    echo -e "${YELLOW}[3/3] Attaching policy to role${NC}"
    
    local policy_arn="arn:aws:iam::${account_id}:policy/${POLICY_NAME}"
    
    if aws iam list-attached-role-policies --role-name "$ROLE_NAME" 2>/dev/null | grep -q "$POLICY_NAME"; then
        echo -e "  ${GREEN}✓${NC} Policy already attached"
        return 0
    fi
    
    aws iam attach-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-arn "$policy_arn"
    
    echo -e "  ${GREEN}✓${NC} Policy attached"
}

setup_account() {
    local account_id="$1"
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Setting up account: ${account_id}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Assume role into the account
    if ! assume_role_into_account "$account_id"; then
        return 1
    fi
    
    # Verify we're in the right account
    local current_account=$(aws sts get-caller-identity --query Account --output text)
    if [ "$current_account" != "$account_id" ]; then
        echo -e "${RED}✗ Account mismatch! Expected $account_id, got $current_account${NC}"
        clear_assumed_role
        return 1
    fi
    
    # Create resources
    create_role "$account_id"
    create_policy "$account_id"
    attach_policy "$account_id"
    
    # Clear credentials
    clear_assumed_role
    
    echo ""
    echo -e "${GREEN}✓ Account ${account_id} setup complete!${NC}"
    echo -e "  Role ARN: arn:aws:iam::${account_id}:role/${ROLE_NAME}"
    
    return 0
}

check_account() {
    local account_id="$1"
    
    print_header
    echo -e "${YELLOW}Checking setup for account: ${account_id}${NC}"
    echo ""
    
    if ! assume_role_into_account "$account_id"; then
        return 1
    fi
    
    # Check role
    if aws iam get-role --role-name "$ROLE_NAME" &>/dev/null; then
        echo -e "${GREEN}✓${NC} Role exists: $ROLE_NAME"
    else
        echo -e "${RED}✗${NC} Role missing: $ROLE_NAME"
    fi
    
    # Check policy
    local policy_arn="arn:aws:iam::${account_id}:policy/${POLICY_NAME}"
    if aws iam get-policy --policy-arn "$policy_arn" &>/dev/null; then
        echo -e "${GREEN}✓${NC} Policy exists: $POLICY_NAME"
    else
        echo -e "${RED}✗${NC} Policy missing: $POLICY_NAME"
    fi
    
    # Check if policy attached
    if aws iam list-attached-role-policies --role-name "$ROLE_NAME" 2>/dev/null | grep -q "$POLICY_NAME"; then
        echo -e "${GREEN}✓${NC} Policy attached to role"
    else
        echo -e "${RED}✗${NC} Policy not attached to role"
    fi

    clear_assumed_role
}

cleanup_account() {
    local account_id="$1"
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  Cleaning up account: ${account_id}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if ! assume_role_into_account "$account_id"; then
        return 1
    fi
    
    local policy_arn="arn:aws:iam::${account_id}:policy/${POLICY_NAME}"

    # Detach policy
    echo -e "${YELLOW}Detaching policy...${NC}"
    aws iam detach-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-arn "$policy_arn" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Detached"
    
    # Delete policy
    echo -e "${YELLOW}Deleting policy...${NC}"
    aws iam delete-policy --policy-arn "$policy_arn" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Deleted policy"
    
    # Delete role
    echo -e "${YELLOW}Deleting role...${NC}"
    aws iam delete-role --role-name "$ROLE_NAME" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Deleted role"
    
    clear_assumed_role
    
    echo ""
    echo -e "${GREEN}✓ Account ${account_id} cleanup complete${NC}"
}

# Main
case "${1:-}" in
    --help|-h)
        show_help
        ;;
    --list|-l)
        list_org_accounts
        ;;
    --check|-c)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Account ID required${NC}"
            echo "Usage: $0 --check <ACCOUNT_ID>"
            exit 1
        fi
        check_account "$2"
        ;;
    --cleanup|--clean|--delete)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Account ID required${NC}"
            echo "Usage: $0 --cleanup <ACCOUNT_ID>"
            exit 1
        fi
        shift
        for account_id in "$@"; do
            cleanup_account "$account_id"
        done
        ;;
    --file|-f)
        if [ -z "$2" ] || [ ! -f "$2" ]; then
            echo -e "${RED}Error: Valid file required${NC}"
            echo "Usage: $0 --file <FILE>"
            exit 1
        fi
        print_header
        echo "Region: $REGION"
        echo "Reading accounts from: $2"
        
        success=0
        failed=0
        while IFS= read -r account_id || [ -n "$account_id" ]; do
            # Skip empty lines and comments
            [[ -z "$account_id" || "$account_id" =~ ^# ]] && continue
            
            if setup_account "$account_id"; then
                ((success++))
            else
                ((failed++))
            fi
        done < "$2"
        
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}Summary: ${success} succeeded, ${failed} failed${NC}"
        ;;
    "")
        show_help
        ;;
    *)
        # Treat all remaining args as account IDs
        print_header
        echo "Region: $REGION"
        echo "Accounts to setup: $@"
        
        success=0
        failed=0
        for account_id in "$@"; do
            if setup_account "$account_id"; then
                ((success++))
            else
                ((failed++))
            fi
        done
        
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}Summary: ${success} succeeded, ${failed} failed${NC}"
        echo ""
        echo -e "${YELLOW}Tell Ryan:${NC}"
        echo "  Role '${ROLE_NAME}' has been created in each account."
        echo "  Attendees should use this role in Labs 4-5."
        ;;
esac
