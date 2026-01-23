#!/bin/bash
# setup-iam.sh
# Creates IAM policy for Bedrock Agents Lab and optionally attaches to a role
#
# Usage:
#   ./setup-iam.sh                          # Create policy only
#   ./setup-iam.sh --attach ROLE_NAME       # Create and attach to role
#   ./setup-iam.sh --list-roles             # List SageMaker execution roles
#   ./setup-iam.sh --check ROLE_NAME        # Check if role has required permissions
#   ./setup-iam.sh --delete                 # Delete the lab policy

set -e

POLICY_NAME="BedrockAgentsLabPolicy"
POLICY_DESCRIPTION="IAM policy for Bedrock Agents Lab - inference profiles, model invocation, and DataZone detection"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# The complete IAM policy for this lab - comprehensive for SageMaker Unified Studio V2
POLICY_DOCUMENT='{
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
      "Sid": "DataZoneFullAccess",
      "Effect": "Allow",
      "Action": [
        "datazone:*"
      ],
      "Resource": "*"
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

show_help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          Bedrock Agents Lab - IAM Setup Script             ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Creates IAM policy with permissions for:${NC}"
    echo "  - Inference profile management (create, delete, list, tag)"
    echo "  - Bedrock model invocation (Converse, InvokeModel)"
    echo "  - DataZone auto-detection (list domains/projects)"
    echo ""
    echo -e "${YELLOW}COMMANDS:${NC}"
    echo "  $0                          Create policy only"
    echo "  $0 --attach ROLE_NAME       Create policy and attach to role"
    echo "  $0 --list-roles             List SageMaker/DataZone execution roles"
    echo "  $0 --check ROLE_NAME        Check if role has required permissions"
    echo "  $0 --delete                 Delete the lab policy"
    echo "  $0 --show-policy            Display the policy JSON"
    echo "  $0 --help                   Show this help"
    echo ""
    echo -e "${YELLOW}EXAMPLES:${NC}"
    echo "  $0 --list-roles"
    echo "  $0 --attach AmazonSageMaker-ExecutionRole-20240101T123456"
    echo "  $0 --check datazone_usr_role_abc123"
    echo ""
}

show_policy() {
    echo -e "${BLUE}IAM Policy: ${POLICY_NAME}${NC}"
    echo ""
    echo "$POLICY_DOCUMENT" | python3 -m json.tool
}

get_account_id() {
    aws sts get-caller-identity --query Account --output text 2>/dev/null
}

get_policy_arn() {
    local account_id=$(get_account_id)
    echo "arn:aws:iam::${account_id}:policy/${POLICY_NAME}"
}

policy_exists() {
    local policy_arn=$(get_policy_arn)
    aws iam get-policy --policy-arn "$policy_arn" &>/dev/null
    return $?
}

list_roles() {
    echo -e "${BLUE}SageMaker and DataZone Execution Roles:${NC}"
    echo ""

    echo -e "${YELLOW}SageMaker Execution Roles:${NC}"
    aws iam list-roles \
        --query "Roles[?contains(RoleName, 'SageMaker') || contains(RoleName, 'sagemaker')].{Name:RoleName,Created:CreateDate}" \
        --output table 2>/dev/null || echo "  (none found)"

    echo ""
    echo -e "${YELLOW}DataZone Roles:${NC}"
    aws iam list-roles \
        --query "Roles[?contains(RoleName, 'datazone') || contains(RoleName, 'DataZone')].{Name:RoleName,Created:CreateDate}" \
        --output table 2>/dev/null || echo "  (none found)"

    echo ""
    echo -e "${GREEN}Tip:${NC} Use the role name with --attach or --check"
}

check_role() {
    local role_name="$1"

    if [ -z "$role_name" ]; then
        echo -e "${RED}Error: Role name required${NC}"
        echo "Usage: $0 --check ROLE_NAME"
        exit 1
    fi

    echo -e "${BLUE}Checking permissions for role: ${role_name}${NC}"
    echo ""

    # Check if role exists
    if ! aws iam get-role --role-name "$role_name" &>/dev/null; then
        echo -e "${RED}Error: Role '$role_name' not found${NC}"
        exit 1
    fi

    # Check for our policy
    local policy_arn=$(get_policy_arn)
    local has_lab_policy=false

    if aws iam list-attached-role-policies --role-name "$role_name" \
        --query "AttachedPolicies[?PolicyArn=='${policy_arn}']" --output text 2>/dev/null | grep -q .; then
        has_lab_policy=true
    fi

    # Check for AmazonBedrockFullAccess
    local has_bedrock_full=false
    if aws iam list-attached-role-policies --role-name "$role_name" \
        --query "AttachedPolicies[?PolicyName=='AmazonBedrockFullAccess']" --output text 2>/dev/null | grep -q .; then
        has_bedrock_full=true
    fi

    echo -e "${YELLOW}Attached Policies:${NC}"
    aws iam list-attached-role-policies --role-name "$role_name" \
        --query "AttachedPolicies[].PolicyName" --output table 2>/dev/null

    echo ""
    echo -e "${YELLOW}Inline Policies:${NC}"
    aws iam list-role-policies --role-name "$role_name" \
        --query "PolicyNames" --output table 2>/dev/null || echo "  (none)"

    echo ""
    echo -e "${YELLOW}Assessment:${NC}"

    if [ "$has_lab_policy" = true ]; then
        echo -e "  ${GREEN}✓${NC} Has ${POLICY_NAME}"
    else
        echo -e "  ${RED}✗${NC} Missing ${POLICY_NAME}"
    fi

    if [ "$has_bedrock_full" = true ]; then
        echo -e "  ${GREEN}✓${NC} Has AmazonBedrockFullAccess (covers all Bedrock permissions)"
    fi

    if [ "$has_lab_policy" = false ] && [ "$has_bedrock_full" = false ]; then
        echo ""
        echo -e "${YELLOW}Recommendation:${NC} Run: $0 --attach $role_name"
    elif [ "$has_lab_policy" = true ] || [ "$has_bedrock_full" = true ]; then
        echo ""
        echo -e "${GREEN}Role appears to have required permissions.${NC}"
    fi
}

create_policy() {
    local policy_arn=$(get_policy_arn)

    echo -e "${BLUE}Creating IAM Policy${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Name: ${GREEN}${POLICY_NAME}${NC}"
    echo ""

    # Check if policy already exists
    if policy_exists; then
        echo -e "${YELLOW}Policy already exists:${NC} ${policy_arn}"
        echo ""
        echo -e "${GREEN}✓ Policy ready to use${NC}"
        return 0
    fi

    # Create the policy
    echo "Creating policy..."
    local result=$(aws iam create-policy \
        --policy-name "$POLICY_NAME" \
        --policy-document "$POLICY_DOCUMENT" \
        --description "$POLICY_DESCRIPTION" \
        --output json 2>&1)

    if echo "$result" | grep -q "PolicyArn"; then
        local created_arn=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['Policy']['Arn'])")
        echo ""
        echo -e "${GREEN}✓ Policy created successfully!${NC}"
        echo -e "ARN: ${created_arn}"
    else
        echo -e "${RED}Error creating policy:${NC}"
        echo "$result"
        exit 1
    fi
}

attach_policy() {
    local role_name="$1"

    if [ -z "$role_name" ]; then
        echo -e "${RED}Error: Role name required${NC}"
        echo "Usage: $0 --attach ROLE_NAME"
        echo ""
        echo "List available roles with: $0 --list-roles"
        exit 1
    fi

    # Check if role exists
    if ! aws iam get-role --role-name "$role_name" &>/dev/null; then
        echo -e "${RED}Error: Role '$role_name' not found${NC}"
        echo ""
        echo "List available roles with: $0 --list-roles"
        exit 1
    fi

    # Create policy if it doesn't exist
    create_policy

    local policy_arn=$(get_policy_arn)

    echo ""
    echo -e "${BLUE}Attaching Policy to Role${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Role:   ${GREEN}${role_name}${NC}"
    echo -e "Policy: ${POLICY_NAME}"
    echo ""

    # Check if already attached
    if aws iam list-attached-role-policies --role-name "$role_name" \
        --query "AttachedPolicies[?PolicyArn=='${policy_arn}']" --output text 2>/dev/null | grep -q .; then
        echo -e "${YELLOW}Policy already attached to role.${NC}"
        echo -e "${GREEN}✓ Ready to use${NC}"
        return 0
    fi

    # Attach the policy
    aws iam attach-role-policy \
        --role-name "$role_name" \
        --policy-arn "$policy_arn"

    echo -e "${GREEN}✓ Policy attached successfully!${NC}"
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    SETUP COMPLETE                          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "The role '$role_name' now has permissions for:"
    echo "  - Creating and managing inference profiles"
    echo "  - Invoking Bedrock models (Converse, InvokeModel)"
    echo "  - Auto-detecting DataZone domains and projects"
    echo ""
    echo -e "${GREEN}Next step:${NC} Run ./setup-inference-profile.sh to create an inference profile"
}

delete_policy() {
    local policy_arn=$(get_policy_arn)

    echo -e "${BLUE}Deleting IAM Policy${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Policy: ${POLICY_NAME}"
    echo ""

    if ! policy_exists; then
        echo -e "${YELLOW}Policy does not exist.${NC}"
        return 0
    fi

    # Check for attached roles
    local attached_roles=$(aws iam list-entities-for-policy \
        --policy-arn "$policy_arn" \
        --query "PolicyRoles[].RoleName" \
        --output text 2>/dev/null)

    if [ -n "$attached_roles" ] && [ "$attached_roles" != "None" ]; then
        echo -e "${YELLOW}Detaching policy from roles:${NC}"
        for role in $attached_roles; do
            echo "  - $role"
            aws iam detach-role-policy \
                --role-name "$role" \
                --policy-arn "$policy_arn" 2>/dev/null || true
        done
        echo ""
    fi

    # Delete the policy
    aws iam delete-policy --policy-arn "$policy_arn"

    echo -e "${GREEN}✓ Policy deleted successfully.${NC}"
}

# Main
case "${1:-}" in
    --help|-h)
        show_help
        ;;
    --show-policy|-p)
        show_policy
        ;;
    --list-roles|-l)
        list_roles
        ;;
    --check|-c)
        check_role "$2"
        ;;
    --attach|-a)
        attach_policy "$2"
        ;;
    --delete|-d)
        delete_policy
        ;;
    "")
        create_policy
        echo ""
        echo -e "${YELLOW}To attach this policy to a role:${NC}"
        echo "  $0 --attach ROLE_NAME"
        echo ""
        echo -e "${YELLOW}To list available roles:${NC}"
        echo "  $0 --list-roles"
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        echo "Run '$0 --help' for usage"
        exit 1
        ;;
esac
