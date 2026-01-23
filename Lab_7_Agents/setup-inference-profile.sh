#!/bin/bash
# setup-inference-profile.sh
# Creates application inference profiles for SageMaker Unified Studio
#
# THE SECRET SAUCE: AmazonBedrockManaged=true tag is required!
#
# Usage:
#   ./setup-inference-profile.sh                    # Interactive model selection
#   ./setup-inference-profile.sh sonnet             # Create Sonnet profile
#   ./setup-inference-profile.sh haiku              # Create Haiku profile
#   ./setup-inference-profile.sh --all              # Create profiles for all models
#   ./setup-inference-profile.sh --test sonnet      # Create and test a profile
#   ./setup-inference-profile.sh --list             # List existing profiles
#   ./setup-inference-profile.sh --delete sonnet    # Delete specific profile
#   ./setup-inference-profile.sh --delete-all       # Delete all lab profiles

set -e

REGION="${AWS_REGION:-us-west-2}"

# DataZone tags (auto-detected or set manually)
DATAZONE_PROJECT_ID="${DATAZONE_PROJECT_ID:-}"
DATAZONE_DOMAIN_ID="${DATAZONE_DOMAIN_ID:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

get_model_info() {
    local model_key="$1"
    local account_id=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

    case "$model_key" in
        haiku|haiku35)
            echo "us.anthropic.claude-3-5-haiku-20241022-v1:0|Claude 3.5 Haiku|fast and cheap"
            ;;
        sonnet|sonnet35)
            echo "us.anthropic.claude-3-5-sonnet-20241022-v2:0|Claude 3.5 Sonnet v2|balanced"
            ;;
        sonnet4)
            echo "us.anthropic.claude-sonnet-4-20250514-v1:0|Claude Sonnet 4|latest"
            ;;
        sonnet45)
            echo "us.anthropic.claude-sonnet-4-5-20250929-v1:0|Claude Sonnet 4.5|most capable"
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
        echo "langgraph-lab-${model_key}"
    fi
}

show_help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     SageMaker Unified Studio - Inference Profile Setup     ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}SECRET SAUCE:${NC} Adds 'AmazonBedrockManaged=true' tag for Studio access"
    echo ""
    echo -e "${YELLOW}MODELS AVAILABLE:${NC}"
    echo "  haiku       Claude 3.5 Haiku      (fast, cheap - good for testing)"
    echo "  sonnet      Claude 3.5 Sonnet v2  (balanced - recommended)"
    echo "  sonnet4     Claude Sonnet 4       (latest)"
    echo "  sonnet45    Claude Sonnet 4.5     (most capable)"
    echo ""
    echo -e "${YELLOW}COMMANDS:${NC}"
    echo "  $0                        Interactive model selection"
    echo "  $0 <model>                Create profile for specific model"
    echo "  $0 --all                  Create profiles for ALL models"
    echo "  $0 --test <model>         Create profile and run quick test"
    echo "  $0 --list                 List existing profiles"
    echo "  $0 --delete <model>       Delete specific model's profile"
    echo "  $0 --delete-all           Delete all lab profiles"
    echo "  $0 --detect               Show detected DataZone IDs"
    echo ""
    echo -e "${YELLOW}EXAMPLES:${NC}"
    echo "  $0 haiku                  # Quick test with Haiku"
    echo "  $0 sonnet                 # Production use with Sonnet"
    echo "  $0 --test haiku           # Create and verify Haiku works"
    echo "  $0 --all                  # Create all profiles at once"
    echo ""
}

detect_datazone_ids() {
    local silent="${1:-}"

    [ -z "$silent" ] && echo "Detecting DataZone IDs from Bedrock IDE exports..." >&2

    local project_id=""
    local domain_id=""

    for dir in ../amazon-bedrock-ide-app-export-* ./amazon-bedrock-ide-app-export-*; do
        if [ -d "$dir" ]; then
            local stack_file=$(ls "$dir"/amazon-bedrock-ide-app-stack-*.json 2>/dev/null | head -1)
            if [ -f "$stack_file" ]; then
                project_id=$(grep -o '"bedrockServiceRoleArn"[^,]*' "$stack_file" 2>/dev/null | \
                    grep -o 'AmazonBedrockServiceRole-[^-]*' | \
                    sed 's/AmazonBedrockServiceRole-//' | head -1)
                domain_id=$(grep -o 'dzd-[a-z0-9]*' "$stack_file" 2>/dev/null | head -1)
                if [ -n "$project_id" ] && [ -n "$domain_id" ]; then
                    [ -z "$silent" ] && echo "Found in: $stack_file" >&2
                    break
                fi
            fi
        fi
    done

    if [ -n "$project_id" ] && [ -n "$domain_id" ]; then
        if [ -z "$silent" ]; then
            echo ""
            echo "export DATAZONE_PROJECT_ID=\"$project_id\""
            echo "export DATAZONE_DOMAIN_ID=\"$domain_id\""
            echo ""
            echo -e "${GREEN}To use: eval \$($0 --detect)${NC}" >&2
        fi
        DATAZONE_PROJECT_ID="$project_id"
        DATAZONE_DOMAIN_ID="$domain_id"
        return 0
    else
        [ -z "$silent" ] && echo -e "${RED}Could not auto-detect DataZone IDs.${NC}" >&2
        [ -z "$silent" ] && echo "Make sure you have a Bedrock IDE export folder nearby." >&2
        return 1
    fi
}

auto_detect_datazone() {
    if [ -z "$DATAZONE_PROJECT_ID" ] || [ -z "$DATAZONE_DOMAIN_ID" ]; then
        detect_datazone_ids "silent" || true
        if [ -n "$DATAZONE_PROJECT_ID" ] && [ -n "$DATAZONE_DOMAIN_ID" ]; then
            echo -e "${GREEN}✓ Auto-detected DataZone IDs${NC}"
            echo "  Project: $DATAZONE_PROJECT_ID"
            echo "  Domain:  $DATAZONE_DOMAIN_ID"
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
        --output table

    echo ""
    echo -e "${YELLOW}Profiles with AmazonBedrockManaged=true:${NC}"

    local profiles=$(aws bedrock list-inference-profiles \
        --region "${REGION}" \
        --type-equals APPLICATION \
        --query 'inferenceProfileSummaries[].inferenceProfileArn' \
        --output text 2>/dev/null)

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
            echo -e "  ${RED}✗${NC} $name (missing tag)"
        fi
    done
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
}

delete_all_profiles() {
    echo -e "${YELLOW}Deleting all lab profiles...${NC}"

    for model in haiku sonnet sonnet4 sonnet45; do
        delete_profile "$model" 2>/dev/null || true
    done

    echo -e "${GREEN}✓ Done${NC}"
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
        exit 1
    fi

    local profile_name=$(get_profile_name "$model_key")
    local description="Lab profile for ${model_key}"

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

    # Build tags
    local tags="key=Purpose,value=LangGraphLab key=Model,value=${model_key}"

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
        --output json)

    local profile_arn=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('inferenceProfileArn',''))")
    local status=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status',''))")

    echo ""
    echo -e "${GREEN}✓ Created successfully!${NC}"
    echo -e "Status: ${status}"
    output_config "$profile_arn" "$model_key"
}

output_config() {
    local arn="$1"
    local model_key="${2:-unknown}"

    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              COPY THIS TO YOUR NOTEBOOK                    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "INFERENCE_PROFILE_ARN = \"${arn}\""
    echo ""

    # Save to config file
    cat > ".inference-profile-${model_key}.env" << EOF
# Generated by setup-inference-profile.sh
# Model: ${model_key}
INFERENCE_PROFILE_ARN="${arn}"
AWS_REGION="${REGION}"
EOF
    echo -e "Config saved to: ${GREEN}.inference-profile-${model_key}.env${NC}"
}

test_profile() {
    local model_key="${1:-sonnet}"
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

create_all_profiles() {
    echo -e "${BLUE}Creating profiles for all models...${NC}"
    echo ""

    for model in haiku sonnet sonnet4 sonnet45; do
        echo -e "${YELLOW}━━━ ${model} ━━━${NC}"
        create_profile "$model"
        echo ""
    done

    echo -e "${GREEN}✓ All profiles created!${NC}"
    list_profiles
}

interactive_menu() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Select a Model to Create Inference Profile            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "  1) haiku     - Claude 3.5 Haiku      (fast, cheap - good for testing)"
    echo "  2) sonnet    - Claude 3.5 Sonnet v2  (balanced - recommended)"
    echo "  3) sonnet4   - Claude Sonnet 4       (latest)"
    echo "  4) sonnet45  - Claude Sonnet 4.5     (most capable)"
    echo "  5) ALL       - Create all profiles"
    echo "  q) Quit"
    echo ""
    read -p "Select [1-5, q]: " choice

    case "$choice" in
        1) create_profile "haiku" ;;
        2) create_profile "sonnet" ;;
        3) create_profile "sonnet4" ;;
        4) create_profile "sonnet45" ;;
        5) create_all_profiles ;;
        q|Q) exit 0 ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac
}

# Main
auto_detect_datazone

case "${1:-}" in
    --help|-h)
        show_help
        ;;
    --list|-l)
        list_profiles
        ;;
    --delete|-d)
        if [ -n "$2" ]; then
            delete_profile "$2"
        else
            echo "Usage: $0 --delete <model>"
            echo "Models: haiku, sonnet, sonnet4, sonnet45"
        fi
        ;;
    --delete-all)
        delete_all_profiles
        ;;
    --detect)
        detect_datazone_ids
        ;;
    --test|-t)
        if [ -n "$2" ]; then
            test_profile "$2"
        else
            test_profile "haiku"  # Default to haiku for quick testing
        fi
        ;;
    --all|-a)
        create_all_profiles
        ;;
    "")
        interactive_menu
        ;;
    *)
        create_profile "$1"
        ;;
esac
