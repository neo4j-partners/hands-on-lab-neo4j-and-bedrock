#!/bin/bash
# setup-inference-profiles.sh
# Creates application inference profiles for SageMaker Unified Studio
#
# THE SECRET SAUCE: AmazonBedrockManaged=true tag is required!
#
# Usage:
#   ./setup-inference-profiles.sh                    # Create all profiles
#   ./setup-inference-profiles.sh --list             # List existing profiles
#   ./setup-inference-profiles.sh --delete-all       # Delete all profiles
#   ./setup-inference-profiles.sh --test             # Create and test profiles

set -e

REGION="${AWS_REGION:-us-west-2}"
STACK_DOMAIN="sagemaker-unified-studio-domain"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Model definitions - EXACT format from setup-inference-profile.sh
# Updated January 2026 with latest model IDs
get_model_info() {
    local model_key="$1"

    case "$model_key" in
        haiku|haiku35)
            echo "us.anthropic.claude-3-5-haiku-20241022-v1:0|Claude 3.5 Haiku|fast and cheap"
            ;;
        sonnet|sonnet35)
            echo "us.anthropic.claude-3-5-sonnet-20241022-v2:0|Claude 3.5 Sonnet v2|balanced"
            ;;
        sonnet4)
            echo "us.anthropic.claude-sonnet-4-20250514-v1:0|Claude Sonnet 4|capable"
            ;;
        sonnet45)
            echo "us.anthropic.claude-sonnet-4-5-20250929-v1:0|Claude Sonnet 4.5|recommended"
            ;;
        opus|opus45)
            echo "us.anthropic.claude-opus-4-5-20251101-v1:0|Claude Opus 4.5|most intelligent"
            ;;
        *)
            echo ""
            ;;
    esac
}

get_model_arn() {
    local model_key="$1"
    local account_id=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
    local model_info=$(get_model_info "$model_key")
    local model_id=$(echo "$model_info" | cut -d'|' -f1)

    if [ -n "$model_id" ]; then
        echo "arn:aws:bedrock:${REGION}:${account_id}:inference-profile/${model_id}"
    fi
}

get_profile_name() {
    local model_key="$1"
    if [ -n "$DATAZONE_PROJECT_ID" ] && [ -n "$DATAZONE_DOMAIN_ID" ]; then
        echo "${DATAZONE_DOMAIN_ID} ${DATAZONE_PROJECT_ID} ${model_key}"
    else
        echo "workshop-${model_key}"
    fi
}

detect_datazone_from_stack() {
    echo "Detecting DataZone IDs from CloudFormation stack..." >&2

    # Get domain ID from stack output
    local domain_id=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_DOMAIN" \
        --query "Stacks[0].Outputs[?OutputKey=='DomainId'].OutputValue" \
        --output text 2>/dev/null)

    if [ -z "$domain_id" ] || [ "$domain_id" == "None" ]; then
        echo -e "${RED}Domain stack not found. Deploy domain first.${NC}" >&2
        return 1
    fi

    DATAZONE_DOMAIN_ID="$domain_id"
    echo -e "  Domain: ${GREEN}${domain_id}${NC}" >&2

    # Get first project in the domain
    local projects_json=$(aws datazone list-projects \
        --domain-identifier "$domain_id" \
        --region "${REGION}" \
        --output json 2>/dev/null)

    if [ -z "$projects_json" ]; then
        echo -e "${YELLOW}No projects found yet. Create a project first.${NC}" >&2
        return 1
    fi

    # Filter out admin and governance projects
    local project_id=$(echo "$projects_json" | python3 -c "
import sys, json
items = json.load(sys.stdin).get('items', [])
filtered = [p for p in items if 'admin-project' not in p.get('name','') and 'Governance' not in p.get('name','')]
if filtered:
    print(filtered[0]['id'])
" 2>/dev/null)

    if [ -n "$project_id" ]; then
        DATAZONE_PROJECT_ID="$project_id"
        echo -e "  Project: ${GREEN}${project_id}${NC}" >&2
        return 0
    fi

    echo -e "${YELLOW}No user projects found. Using domain-only naming.${NC}" >&2
    return 1
}

detect_datazone_from_cli() {
    echo "Detecting DataZone IDs from AWS CLI..." >&2

    # Get list of domains
    local domains_json=$(aws datazone list-domains --region "${REGION}" --output json 2>/dev/null)
    if [ -z "$domains_json" ] || [ "$(echo "$domains_json" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('items',[])))" 2>/dev/null)" == "0" ]; then
        echo -e "${RED}No DataZone domains found in ${REGION}${NC}" >&2
        return 1
    fi

    local domain_count=$(echo "$domains_json" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('items',[])))")
    local domain_id=""

    if [ "$domain_count" == "1" ]; then
        domain_id=$(echo "$domains_json" | python3 -c "import sys,json; print(json.load(sys.stdin)['items'][0]['id'])")
        local domain_name=$(echo "$domains_json" | python3 -c "import sys,json; print(json.load(sys.stdin)['items'][0]['name'])")
        echo -e "  Domain: ${GREEN}${domain_name}${NC} (${domain_id})" >&2
    else
        echo -e "${YELLOW}Multiple DataZone domains found:${NC}" >&2
        echo "$domains_json" | python3 -c "
import sys, json
items = json.load(sys.stdin)['items']
for i, item in enumerate(items, 1):
    print(f\"  {i}) {item['name']} ({item['id']})\")" >&2

        read -p "Select domain [1-${domain_count}]: " choice
        domain_id=$(echo "$domains_json" | python3 -c "import sys,json; print(json.load(sys.stdin)['items'][int(${choice})-1]['id'])")
    fi

    DATAZONE_DOMAIN_ID="$domain_id"

    # Get list of projects in the domain
    local projects_json=$(aws datazone list-projects --domain-identifier "$domain_id" --region "${REGION}" --output json 2>/dev/null)
    if [ -z "$projects_json" ] || [ "$(echo "$projects_json" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('items',[])))" 2>/dev/null)" == "0" ]; then
        echo -e "${YELLOW}No projects found in domain ${domain_id}${NC}" >&2
        return 1
    fi

    # Filter out admin and governance projects
    local filtered_projects=$(echo "$projects_json" | python3 -c "
import sys, json
items = json.load(sys.stdin)['items']
filtered = [p for p in items if 'admin-project' not in p['name'] and 'Governance' not in p['name']]
print(json.dumps({'items': filtered}))")

    local project_count=$(echo "$filtered_projects" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('items',[])))")
    local project_id=""

    if [ "$project_count" == "0" ]; then
        echo -e "${YELLOW}No user projects found (only admin/governance projects exist)${NC}" >&2
        return 1
    elif [ "$project_count" == "1" ]; then
        project_id=$(echo "$filtered_projects" | python3 -c "import sys,json; print(json.load(sys.stdin)['items'][0]['id'])")
        local project_name=$(echo "$filtered_projects" | python3 -c "import sys,json; print(json.load(sys.stdin)['items'][0]['name'])")
        echo -e "  Project: ${GREEN}${project_name}${NC} (${project_id})" >&2
    else
        echo -e "${YELLOW}Multiple projects found:${NC}" >&2
        echo "$filtered_projects" | python3 -c "
import sys, json
items = json.load(sys.stdin)['items']
for i, item in enumerate(items, 1):
    print(f\"  {i}) {item['name']} ({item['id']})\")" >&2

        read -p "Select project [1-${project_count}]: " choice
        project_id=$(echo "$filtered_projects" | python3 -c "import sys,json; print(json.load(sys.stdin)['items'][int(${choice})-1]['id'])")
    fi

    if [ -n "$project_id" ] && [ -n "$domain_id" ]; then
        DATAZONE_PROJECT_ID="$project_id"
        echo -e "${GREEN}✓ DataZone IDs detected${NC}" >&2
        return 0
    fi

    return 1
}

auto_detect_datazone() {
    if [ -z "$DATAZONE_PROJECT_ID" ] || [ -z "$DATAZONE_DOMAIN_ID" ]; then
        # Try stack first, then CLI
        detect_datazone_from_stack 2>/dev/null || detect_datazone_from_cli || true

        if [ -n "$DATAZONE_PROJECT_ID" ] && [ -n "$DATAZONE_DOMAIN_ID" ]; then
            echo -e "${GREEN}✓ DataZone IDs detected${NC}"
            echo "  Domain:  $DATAZONE_DOMAIN_ID"
            echo "  Project: $DATAZONE_PROJECT_ID"
        else
            echo -e "${YELLOW}WARNING: DataZone IDs not fully detected${NC}"
            echo "Profiles will be created but may not be visible in SageMaker Unified Studio."
            echo ""
            echo "To fix: Create a project in SageMaker Unified Studio first, then re-run this script."
        fi
    fi
}

list_profiles() {
    echo -e "${BLUE}Application Inference Profiles in ${REGION}:${NC}"
    echo ""

    aws bedrock list-inference-profiles \
        --region "${REGION}" \
        --type-equals APPLICATION \
        --query 'inferenceProfileSummaries[].{Name:inferenceProfileName,ARN:inferenceProfileArn,Status:status}' \
        --output table 2>/dev/null || echo "No profiles found"

    echo ""
    echo -e "${YELLOW}Profiles with AmazonBedrockManaged=true (visible in Studio):${NC}"

    local profiles=$(aws bedrock list-inference-profiles \
        --region "${REGION}" \
        --type-equals APPLICATION \
        --query 'inferenceProfileSummaries[].inferenceProfileArn' \
        --output text 2>/dev/null)

    if [ -z "$profiles" ]; then
        echo "  (none)"
        return
    fi

    for arn in $profiles; do
        local managed=$(aws bedrock list-tags-for-resource \
            --resource-arn "$arn" \
            --region "${REGION}" \
            --query "tags[?key=='AmazonBedrockManaged'].value" \
            --output text 2>/dev/null)

        local name=$(aws bedrock get-inference-profile \
            --inference-profile-identifier "$arn" \
            --region "${REGION}" \
            --query 'inferenceProfileName' \
            --output text 2>/dev/null)

        if [ "$managed" == "true" ]; then
            echo -e "  ${GREEN}✓${NC} $name"
        else
            echo -e "  ${RED}✗${NC} $name (missing AmazonBedrockManaged tag)"
        fi
    done
}

create_profile() {
    local model_key="${1:-sonnet}"
    local model_arn=$(get_model_arn "$model_key")
    local model_info=$(get_model_info "$model_key")
    local model_name=$(echo "$model_info" | cut -d'|' -f2)
    local model_desc=$(echo "$model_info" | cut -d'|' -f3)

    if [ -z "$model_arn" ]; then
        echo -e "${RED}Error: Unknown model '${model_key}'${NC}"
        echo "Available models: haiku, sonnet, sonnet4, sonnet45"
        return 1
    fi

    local profile_name=$(get_profile_name "$model_key")
    local description="Workshop profile for ${model_key}"

    echo ""
    echo -e "${BLUE}Creating Inference Profile${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Model:   ${GREEN}${model_name}${NC} (${model_desc})"
    echo -e "Name:    ${profile_name}"
    echo -e "Region:  ${REGION}"

    if [ -n "$DATAZONE_PROJECT_ID" ]; then
        echo ""
        echo -e "${YELLOW}Tags (SECRET SAUCE):${NC}"
        echo "  AmazonBedrockManaged: true  ← THE KEY!"
        echo "  AmazonDataZoneProject: ${DATAZONE_PROJECT_ID}"
        echo "  AmazonDataZoneDomain:  ${DATAZONE_DOMAIN_ID}"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Check if profile already exists
    local existing=$(aws bedrock list-inference-profiles \
        --region "${REGION}" \
        --type-equals APPLICATION \
        --query "inferenceProfileSummaries[?inferenceProfileName=='${profile_name}'].inferenceProfileArn" \
        --output text 2>/dev/null || echo "")

    if [ -n "$existing" ] && [ "$existing" != "None" ]; then
        echo ""
        echo -e "${YELLOW}Profile already exists:${NC} ${existing}"
        output_config "$existing" "$model_key"
        return 0
    fi

    # Build tags - EXACT format from setup-inference-profile.sh
    local tags="key=Purpose,value=Workshop key=Model,value=${model_key}"

    if [ -n "$DATAZONE_PROJECT_ID" ]; then
        tags="$tags key=AmazonDataZoneProject,value=${DATAZONE_PROJECT_ID}"
    fi

    if [ -n "$DATAZONE_DOMAIN_ID" ]; then
        tags="$tags key=AmazonDataZoneDomain,value=${DATAZONE_DOMAIN_ID}"
    fi

    # THE SECRET SAUCE!
    if [ -n "$DATAZONE_PROJECT_ID" ] && [ -n "$DATAZONE_DOMAIN_ID" ]; then
        tags="$tags key=AmazonBedrockManaged,value=true"
    fi

    local result=$(aws bedrock create-inference-profile \
        --region "${REGION}" \
        --inference-profile-name "${profile_name}" \
        --model-source "copyFrom=${model_arn}" \
        --description "${description}" \
        --tags $tags \
        --output json 2>&1)

    if echo "$result" | grep -q "inferenceProfileArn"; then
        local profile_arn=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('inferenceProfileArn',''))")
        local status=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status',''))")

        echo ""
        echo -e "${GREEN}✓ Created successfully!${NC}"
        echo -e "Status: ${status}"
        output_config "$profile_arn" "$model_key"
    else
        echo -e "${RED}Error creating profile:${NC}"
        echo "$result"
        return 1
    fi
}

output_config() {
    local arn="$1"
    local model_key="${2:-unknown}"

    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              COPY THIS TO YOUR NOTEBOOK                    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "MODEL = \"${model_key}\""
    echo "INFERENCE_PROFILE_ARN = \"${arn}\""
    echo ""

    # Save to config file
    cat > ".inference-profile-${model_key}.env" << EOF
# Generated by setup-inference-profiles.sh
# Model: ${model_key}
MODEL="${model_key}"
INFERENCE_PROFILE_ARN="${arn}"
AWS_REGION="${REGION}"
EOF
    echo -e "Config saved to: ${GREEN}.inference-profile-${model_key}.env${NC}"
}

test_profile() {
    local model_key="${1:-haiku}"
    local profile_name=$(get_profile_name "$model_key")

    # First create the profile
    create_profile "$model_key"

    # Get the ARN
    local arn=$(aws bedrock list-inference-profiles \
        --region "${REGION}" \
        --type-equals APPLICATION \
        --query "inferenceProfileSummaries[?inferenceProfileName=='${profile_name}'].inferenceProfileArn" \
        --output text 2>/dev/null)

    if [ -z "$arn" ] || [ "$arn" == "None" ]; then
        echo -e "${RED}✗ Profile not found for testing${NC}"
        return 1
    fi

    echo ""
    echo -e "${BLUE}Testing profile...${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Test with a simple invoke
    local test_result=$(aws bedrock-runtime converse \
        --region "${REGION}" \
        --model-id "${arn}" \
        --messages '[{"role":"user","content":[{"text":"Say hello in 3 words"}]}]' \
        --inference-config '{"maxTokens":50}' \
        --output json 2>&1)

    if echo "$test_result" | grep -q "output"; then
        local response=$(echo "$test_result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['output']['message']['content'][0]['text'])" 2>/dev/null)
        echo -e "${GREEN}✓ SUCCESS!${NC}"
        echo -e "Response: ${response}"
        echo ""
        echo -e "${GREEN}Profile is working and ready for use in SageMaker Studio!${NC}"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "$test_result" | head -5
        return 1
    fi
}

delete_profile() {
    local model_key="$1"
    local profile_name=$(get_profile_name "$model_key")

    echo "Looking for profile: ${profile_name}..."

    local arn=$(aws bedrock list-inference-profiles \
        --region "${REGION}" \
        --type-equals APPLICATION \
        --query "inferenceProfileSummaries[?inferenceProfileName=='${profile_name}'].inferenceProfileArn" \
        --output text 2>/dev/null)

    if [ -z "$arn" ] || [ "$arn" == "None" ]; then
        echo -e "${YELLOW}Profile '${profile_name}' not found.${NC}"
        return 0
    fi

    echo "Deleting profile: ${arn}"
    aws bedrock delete-inference-profile \
        --region "${REGION}" \
        --inference-profile-identifier "${arn}"

    echo -e "${GREEN}✓ Deleted successfully.${NC}"

    # Remove config file
    rm -f ".inference-profile-${model_key}.env" 2>/dev/null || true
}

delete_all_profiles() {
    echo -e "${YELLOW}Deleting all workshop profiles...${NC}"

    for model in haiku sonnet sonnet4 sonnet45 opus; do
        delete_profile "$model" 2>/dev/null || true
    done

    echo -e "${GREEN}✓ Done${NC}"
}

create_all_profiles() {
    echo -e "${BLUE}Creating profiles for all models...${NC}"
    echo ""

    for model in haiku sonnet sonnet4 sonnet45 opus; do
        echo -e "${YELLOW}━━━ ${model} ━━━${NC}"
        create_profile "$model"
        echo ""
    done

    echo -e "${GREEN}✓ All profiles created!${NC}"
    echo ""
    list_profiles
}

show_help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     SageMaker Unified Studio - Inference Profile Setup     ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}SECRET SAUCE:${NC} Adds 'AmazonBedrockManaged=true' tag for Studio access"
    echo ""
    echo -e "${YELLOW}MODELS AVAILABLE (January 2026):${NC}"
    echo "  haiku       Claude 3.5 Haiku      (fast, cheap - good for testing)"
    echo "  sonnet      Claude 3.5 Sonnet v2  (balanced)"
    echo "  sonnet4     Claude Sonnet 4       (capable)"
    echo "  sonnet45    Claude Sonnet 4.5     (recommended)"
    echo "  opus        Claude Opus 4.5       (most intelligent)"
    echo ""
    echo -e "${YELLOW}COMMANDS:${NC}"
    echo "  $0                        Create ALL profiles (default)"
    echo "  $0 <model>                Create profile for specific model"
    echo "  $0 --list                 List existing profiles"
    echo "  $0 --test [model]         Create and test profile (default: haiku)"
    echo "  $0 --delete <model>       Delete specific profile"
    echo "  $0 --delete-all           Delete all workshop profiles"
    echo "  $0 --help                 Show this help"
    echo ""
}

# Main
case "${1:-}" in
    --help|-h)
        show_help
        ;;
    --list|-l)
        list_profiles
        ;;
    --delete|-d)
        auto_detect_datazone
        if [ -n "$2" ]; then
            delete_profile "$2"
        else
            echo "Usage: $0 --delete <model>"
            echo "Models: haiku, sonnet, sonnet4, sonnet45"
        fi
        ;;
    --delete-all)
        auto_detect_datazone
        delete_all_profiles
        ;;
    --test|-t)
        auto_detect_datazone
        test_profile "${2:-haiku}"
        ;;
    "")
        auto_detect_datazone
        create_all_profiles
        ;;
    *)
        auto_detect_datazone
        create_profile "$1"
        ;;
esac
