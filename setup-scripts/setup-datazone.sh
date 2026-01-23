#!/bin/bash
# setup-datazone.sh
# Creates DataZone domain and project for SageMaker Unified Studio workshop
#
# Usage:
#   ./setup-datazone.sh                              # Create domain and project
#   ./setup-datazone.sh --add-user USER_ID           # Add IAM user to project
#   ./setup-datazone.sh --add-role ROLE_ARN          # Add IAM role to project
#   ./setup-datazone.sh --status                     # Check setup status
#   ./setup-datazone.sh --cleanup                    # Delete domain and project
#   ./setup-datazone.sh --list-users                 # List project members

set -e

DOMAIN_NAME="${DATAZONE_DOMAIN_NAME:-bedrock-lab-domain}"
PROJECT_NAME="${DATAZONE_PROJECT_NAME:-bedrock-lab-project}"
REGION="${AWS_REGION:-us-west-2}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        DataZone / SageMaker Unified Studio Setup           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_help() {
    print_header
    echo -e "${YELLOW}DESCRIPTION:${NC}"
    echo "  Creates a DataZone domain and project for SageMaker Unified Studio."
    echo "  This enables workshop attendees to use Bedrock with inference profiles."
    echo ""
    echo -e "${YELLOW}USAGE:${NC}"
    echo "  $0                              Create domain and project"
    echo "  $0 --add-user USER_ID           Add IAM user to project (as contributor)"
    echo "  $0 --add-role ROLE_ARN          Add IAM role to project (as contributor)"
    echo "  $0 --status                     Check current setup status"
    echo "  $0 --list-users                 List project members"
    echo "  $0 --cleanup                    Delete domain and project"
    echo "  $0 --help                       Show this help"
    echo ""
    echo -e "${YELLOW}ENVIRONMENT VARIABLES:${NC}"
    echo "  AWS_REGION              Region (default: us-west-2)"
    echo "  DATAZONE_DOMAIN_NAME    Domain name (default: bedrock-lab-domain)"
    echo "  DATAZONE_PROJECT_NAME   Project name (default: bedrock-lab-project)"
    echo ""
    echo -e "${YELLOW}EXAMPLES:${NC}"
    echo "  $0                                           # Initial setup"
    echo "  $0 --add-user user/workshop-user-1           # Add IAM user"
    echo "  $0 --add-role arn:aws:iam::123456789012:role/WorkshopRole"
    echo ""
    echo -e "${YELLOW}WORKFLOW:${NC}"
    echo "  1. Run this script to create domain/project"
    echo "  2. Add workshop attendees with --add-user or --add-role"
    echo "  3. Run setup-bedrock-lab-org.sh to create inference profiles"
    echo "  4. Attendees can now access Unified Studio"
    echo ""
}

get_account_id() {
    aws sts get-caller-identity --query Account --output text 2>/dev/null
}

# Check if domain exists and get its ID
get_domain_id() {
    aws datazone list-domains \
        --region "$REGION" \
        --query "items[?name=='${DOMAIN_NAME}'].id" \
        --output text 2>/dev/null | head -1
}

# Check if project exists and get its ID
get_project_id() {
    local domain_id="$1"
    aws datazone list-projects \
        --domain-identifier "$domain_id" \
        --region "$REGION" \
        --query "items[?name=='${PROJECT_NAME}'].id" \
        --output text 2>/dev/null | head -1
}

# Create the domain execution role
create_domain_execution_role() {
    local account_id=$(get_account_id)
    local role_name="AmazonDataZoneDomainExecutionRole"
    local role_arn="arn:aws:iam::${account_id}:role/service-role/${role_name}"

    echo -e "${YELLOW}[1/4] Checking Domain Execution Role${NC}"

    if aws iam get-role --role-name "service-role/${role_name}" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Role already exists: ${role_name}"
        echo "$role_arn"
        return 0
    fi

    # Check without service-role prefix
    if aws iam get-role --role-name "${role_name}" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Role already exists: ${role_name}"
        echo "arn:aws:iam::${account_id}:role/${role_name}"
        return 0
    fi

    echo -e "  ${CYAN}ℹ${NC} Role will be created automatically by DataZone"
    echo ""
    return 0
}

# Create DataZone domain
create_domain() {
    echo -e "${YELLOW}[2/4] Creating DataZone Domain${NC}"

    local existing_id=$(get_domain_id)
    if [ -n "$existing_id" ] && [ "$existing_id" != "None" ]; then
        echo -e "  ${GREEN}✓${NC} Domain already exists: ${DOMAIN_NAME}"
        echo -e "  ID: ${existing_id}"
        DOMAIN_ID="$existing_id"
        return 0
    fi

    echo "  Creating domain: ${DOMAIN_NAME}..."

    local result=$(aws datazone create-domain \
        --region "$REGION" \
        --name "$DOMAIN_NAME" \
        --description "Bedrock Agents Lab workshop domain" \
        --domain-version V2 \
        --output json 2>&1)

    if echo "$result" | grep -q '"id"'; then
        DOMAIN_ID=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
        echo -e "  ${GREEN}✓${NC} Domain created: ${DOMAIN_ID}"

        # Wait for domain to be available
        echo "  Waiting for domain to become available..."
        local status="CREATING"
        local attempts=0
        while [ "$status" == "CREATING" ] && [ $attempts -lt 60 ]; do
            sleep 10
            status=$(aws datazone get-domain \
                --region "$REGION" \
                --identifier "$DOMAIN_ID" \
                --query 'status' \
                --output text 2>/dev/null)
            ((attempts++))
            echo -n "."
        done
        echo ""

        if [ "$status" == "AVAILABLE" ]; then
            echo -e "  ${GREEN}✓${NC} Domain is available"
        else
            echo -e "  ${YELLOW}⚠${NC} Domain status: $status (may still be initializing)"
        fi
    else
        echo -e "  ${RED}✗${NC} Failed to create domain"
        echo "$result"
        return 1
    fi
}

# Create DataZone project
create_project() {
    echo -e "${YELLOW}[3/4] Creating DataZone Project${NC}"

    if [ -z "$DOMAIN_ID" ]; then
        DOMAIN_ID=$(get_domain_id)
    fi

    if [ -z "$DOMAIN_ID" ] || [ "$DOMAIN_ID" == "None" ]; then
        echo -e "  ${RED}✗${NC} No domain found. Create domain first."
        return 1
    fi

    local existing_id=$(get_project_id "$DOMAIN_ID")
    if [ -n "$existing_id" ] && [ "$existing_id" != "None" ]; then
        echo -e "  ${GREEN}✓${NC} Project already exists: ${PROJECT_NAME}"
        echo -e "  ID: ${existing_id}"
        PROJECT_ID="$existing_id"
        return 0
    fi

    echo "  Creating project: ${PROJECT_NAME}..."

    local result=$(aws datazone create-project \
        --region "$REGION" \
        --domain-identifier "$DOMAIN_ID" \
        --name "$PROJECT_NAME" \
        --description "Bedrock Agents Lab workshop project" \
        --output json 2>&1)

    if echo "$result" | grep -q '"id"'; then
        PROJECT_ID=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
        echo -e "  ${GREEN}✓${NC} Project created: ${PROJECT_ID}"
    else
        echo -e "  ${RED}✗${NC} Failed to create project"
        echo "$result"
        return 1
    fi
}

# Output setup info
output_info() {
    echo -e "${YELLOW}[4/4] Setup Complete${NC}"
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    SETUP COMPLETE                          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}DataZone Domain:${NC}  ${DOMAIN_NAME}"
    echo -e "${GREEN}Domain ID:${NC}        ${DOMAIN_ID}"
    echo -e "${GREEN}Project:${NC}          ${PROJECT_NAME}"
    echo -e "${GREEN}Project ID:${NC}       ${PROJECT_ID}"
    echo -e "${GREEN}Region:${NC}           ${REGION}"
    echo ""
    echo -e "${YELLOW}Portal URL:${NC}"
    echo "  https://${DOMAIN_ID}.datazone.${REGION}.on.aws"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Add users:  $0 --add-user user/USERNAME"
    echo "  2. Create inference profiles: ./setup-bedrock-lab-org.sh ACCOUNT_ID"
    echo ""

    # Save config
    cat > ".datazone-config.env" << EOF
# DataZone Configuration
# Generated by setup-datazone.sh
DATAZONE_DOMAIN_ID="${DOMAIN_ID}"
DATAZONE_DOMAIN_NAME="${DOMAIN_NAME}"
DATAZONE_PROJECT_ID="${PROJECT_ID}"
DATAZONE_PROJECT_NAME="${PROJECT_NAME}"
AWS_REGION="${REGION}"
PORTAL_URL="https://${DOMAIN_ID}.datazone.${REGION}.on.aws"
EOF
    echo -e "${GREEN}Config saved to:${NC} .datazone-config.env"
}

# Add user to project
add_user_to_project() {
    local user_id="$1"
    local member_type="$2"  # IAM_USER or IAM_ROLE

    if [ -z "$user_id" ]; then
        echo -e "${RED}Error: User/Role ID required${NC}"
        echo "Usage: $0 --add-user USER_ID  or  $0 --add-role ROLE_ARN"
        exit 1
    fi

    DOMAIN_ID=$(get_domain_id)
    if [ -z "$DOMAIN_ID" ] || [ "$DOMAIN_ID" == "None" ]; then
        echo -e "${RED}Error: Domain not found. Run setup first.${NC}"
        exit 1
    fi

    PROJECT_ID=$(get_project_id "$DOMAIN_ID")
    if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" == "None" ]; then
        echo -e "${RED}Error: Project not found. Run setup first.${NC}"
        exit 1
    fi

    echo -e "${BLUE}Adding member to project${NC}"
    echo -e "  Domain:  ${DOMAIN_ID}"
    echo -e "  Project: ${PROJECT_ID}"
    echo -e "  Member:  ${user_id}"
    echo -e "  Type:    ${member_type}"
    echo ""

    local result=$(aws datazone create-project-membership \
        --region "$REGION" \
        --domain-identifier "$DOMAIN_ID" \
        --project-identifier "$PROJECT_ID" \
        --member "userIdentifier=${user_id}" \
        --designation "PROJECT_CONTRIBUTOR" \
        --output json 2>&1)

    if echo "$result" | grep -q "error\|Error\|AccessDenied"; then
        echo -e "${RED}✗ Failed to add member${NC}"
        echo "$result"
        return 1
    else
        echo -e "${GREEN}✓ Member added as PROJECT_CONTRIBUTOR${NC}"
    fi
}

# List project members
list_users() {
    DOMAIN_ID=$(get_domain_id)
    if [ -z "$DOMAIN_ID" ] || [ "$DOMAIN_ID" == "None" ]; then
        echo -e "${RED}Error: Domain not found${NC}"
        exit 1
    fi

    PROJECT_ID=$(get_project_id "$DOMAIN_ID")
    if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" == "None" ]; then
        echo -e "${RED}Error: Project not found${NC}"
        exit 1
    fi

    echo -e "${BLUE}Project Members${NC}"
    echo -e "  Domain:  ${DOMAIN_ID}"
    echo -e "  Project: ${PROJECT_ID}"
    echo ""

    aws datazone list-project-memberships \
        --region "$REGION" \
        --domain-identifier "$DOMAIN_ID" \
        --project-identifier "$PROJECT_ID" \
        --output table
}

# Check status
check_status() {
    print_header
    echo -e "${YELLOW}Checking DataZone Status${NC}"
    echo ""

    DOMAIN_ID=$(get_domain_id)
    if [ -z "$DOMAIN_ID" ] || [ "$DOMAIN_ID" == "None" ]; then
        echo -e "${RED}✗${NC} Domain not found: ${DOMAIN_NAME}"
        echo ""
        echo "Run '$0' to create the domain and project."
        return 1
    fi

    echo -e "${GREEN}✓${NC} Domain: ${DOMAIN_NAME} (${DOMAIN_ID})"

    # Get domain status
    local domain_status=$(aws datazone get-domain \
        --region "$REGION" \
        --identifier "$DOMAIN_ID" \
        --query 'status' \
        --output text 2>/dev/null)
    echo -e "  Status: ${domain_status}"

    PROJECT_ID=$(get_project_id "$DOMAIN_ID")
    if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" == "None" ]; then
        echo -e "${RED}✗${NC} Project not found: ${PROJECT_NAME}"
        return 1
    fi

    echo -e "${GREEN}✓${NC} Project: ${PROJECT_NAME} (${PROJECT_ID})"

    echo ""
    echo -e "${YELLOW}Portal URL:${NC}"
    echo "  https://${DOMAIN_ID}.datazone.${REGION}.on.aws"

    echo ""
    echo -e "${YELLOW}Project Members:${NC}"
    aws datazone list-project-memberships \
        --region "$REGION" \
        --domain-identifier "$DOMAIN_ID" \
        --project-identifier "$PROJECT_ID" \
        --query 'members[].{Member:member.userIdentifier,Designation:designation}' \
        --output table 2>/dev/null || echo "  (none)"
}

# Cleanup
cleanup() {
    print_header
    echo -e "${RED}Cleaning up DataZone resources${NC}"
    echo ""

    DOMAIN_ID=$(get_domain_id)
    if [ -z "$DOMAIN_ID" ] || [ "$DOMAIN_ID" == "None" ]; then
        echo -e "${YELLOW}⚠${NC} Domain not found: ${DOMAIN_NAME}"
        return 0
    fi

    PROJECT_ID=$(get_project_id "$DOMAIN_ID")

    # Delete project first
    if [ -n "$PROJECT_ID" ] && [ "$PROJECT_ID" != "None" ]; then
        echo "Deleting project: ${PROJECT_NAME}..."
        aws datazone delete-project \
            --region "$REGION" \
            --domain-identifier "$DOMAIN_ID" \
            --identifier "$PROJECT_ID" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Project deleted"
    fi

    # Delete domain
    echo "Deleting domain: ${DOMAIN_NAME}..."
    echo -e "${YELLOW}Note: Domain deletion can take several minutes${NC}"

    aws datazone delete-domain \
        --region "$REGION" \
        --identifier "$DOMAIN_ID" \
        --skip-deletion-check 2>/dev/null || true

    echo -e "${GREEN}✓${NC} Domain deletion initiated"
    echo ""
    echo "Domain deletion is asynchronous. Check status with:"
    echo "  aws datazone get-domain --region $REGION --identifier $DOMAIN_ID"

    # Remove config file
    rm -f .datazone-config.env
}

# Main setup
setup() {
    print_header
    echo "Region: $REGION"
    echo "Domain: $DOMAIN_NAME"
    echo "Project: $PROJECT_NAME"
    echo ""

    create_domain_execution_role
    create_domain
    create_project
    output_info
}

# Main
case "${1:-}" in
    --help|-h)
        show_help
        ;;
    --status|-s)
        check_status
        ;;
    --add-user|-u)
        add_user_to_project "$2" "IAM_USER"
        ;;
    --add-role|-r)
        add_user_to_project "$2" "IAM_ROLE"
        ;;
    --list-users|-l)
        list_users
        ;;
    --cleanup|--delete)
        cleanup
        ;;
    "")
        setup
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        echo "Run '$0 --help' for usage"
        exit 1
        ;;
esac
