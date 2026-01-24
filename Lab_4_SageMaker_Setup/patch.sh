#!/bin/bash
# patch.sh - Fix Bedrock permissions for SageMaker Unified Studio notebooks
#
# Usage:
#   Upload to CloudShell and run:
#   chmod +x patch.sh && ./patch.sh

REGION="${AWS_REGION:-us-west-2}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
POLICY_NAME="BedrockAgentsLabPolicy"
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"
WORKING_FILE="/tmp/working_profiles.txt"

rm -f "$WORKING_FILE"
touch "$WORKING_FILE"

echo "==========================================================================================================="
echo "                           BEDROCK NOTEBOOK SETUP - PATCH SCRIPT"
echo "==========================================================================================================="
echo ""
echo "Account: $ACCOUNT_ID"
echo "Region:  $REGION"
echo ""

# ============================================
# STEP A: Update IAM Policy with all permissions
# ============================================
echo "=== A. Updating IAM Policy ==="

cat > /tmp/bedrock-policy.json << 'POLICY'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BedrockFullAccess",
      "Effect": "Allow",
      "Action": [
        "bedrock:*",
        "bedrock-runtime:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "MarketplaceForBedrock",
      "Effect": "Allow",
      "Action": [
        "aws-marketplace:ViewSubscriptions",
        "aws-marketplace:Subscribe",
        "aws-marketplace:Unsubscribe"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DataZoneFullAccess",
      "Effect": "Allow",
      "Action": ["datazone:*"],
      "Resource": "*"
    },
    {
      "Sid": "RAMForProjectProfiles",
      "Effect": "Allow",
      "Action": ["ram:*"],
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
      "Action": ["s3:GetObject", "s3:ListBucket", "s3:GetBucketLocation"],
      "Resource": "*"
    },
    {
      "Sid": "SageMakerUnifiedStudio",
      "Effect": "Allow",
      "Action": ["sagemaker:*"],
      "Resource": "*"
    },
    {
      "Sid": "STS",
      "Effect": "Allow",
      "Action": ["sts:GetCallerIdentity"],
      "Resource": "*"
    }
  ]
}
POLICY

# Check if policy exists, create or update
if aws iam get-policy --policy-arn "$POLICY_ARN" &>/dev/null; then
    echo "   Updating existing policy..."
    # Delete old versions if at limit (max 5)
    OLD_VERSIONS=$(aws iam list-policy-versions --policy-arn "$POLICY_ARN" --query "Versions[?IsDefaultVersion==\`false\`].VersionId" --output text)
    for v in $OLD_VERSIONS; do
        aws iam delete-policy-version --policy-arn "$POLICY_ARN" --version-id "$v" 2>/dev/null || true
    done
    aws iam create-policy-version --policy-arn "$POLICY_ARN" --policy-document file:///tmp/bedrock-policy.json --set-as-default >/dev/null
    echo "   ✓ Policy updated"
else
    echo "   Creating new policy..."
    aws iam create-policy --policy-name "$POLICY_NAME" --policy-document file:///tmp/bedrock-policy.json >/dev/null
    echo "   ✓ Policy created"
fi
rm /tmp/bedrock-policy.json

# ============================================
# STEP B: Attach policy to all DataZone roles
# ============================================
echo ""
echo "=== B. Attaching Policy to Notebook Roles ==="

# Find all datazone_usr_role_* roles
DATAZONE_ROLES=$(aws iam list-roles --query "Roles[?starts_with(RoleName, 'datazone_usr_role_')].RoleName" --output text)

if [ -n "$DATAZONE_ROLES" ]; then
    for role in $DATAZONE_ROLES; do
        echo -n "   Attaching to $role ... "
        if aws iam attach-role-policy --role-name "$role" --policy-arn "$POLICY_ARN" 2>/dev/null; then
            echo "✓"
        else
            echo "✓ (already attached)"
        fi
    done
else
    echo "   No datazone_usr_role_* roles found"
fi

# Also attach to any SageMaker execution roles
SAGEMAKER_ROLES=$(aws iam list-roles --query "Roles[?contains(RoleName, 'SageMaker') || contains(RoleName, 'sagemaker')].RoleName" --output text)
if [ -n "$SAGEMAKER_ROLES" ]; then
    echo ""
    echo "   Also attaching to SageMaker roles..."
    for role in $SAGEMAKER_ROLES; do
        echo -n "   Attaching to $role ... "
        aws iam attach-role-policy --role-name "$role" --policy-arn "$POLICY_ARN" 2>/dev/null && echo "✓" || echo "✓ (already attached or no permission)"
    done
fi

# ============================================
# STEP C: Find and test inference profiles
# ============================================
echo ""
echo "=== C. Finding Working Inference Profiles ==="
echo ""

aws bedrock list-inference-profiles --region $REGION --type-equals APPLICATION \
    --query "inferenceProfileSummaries[?contains(inferenceProfileName, 'haiku') || contains(inferenceProfileName, 'sonnet') || contains(inferenceProfileName, 'claude')].[inferenceProfileArn,inferenceProfileName]" \
    --output text | while read ARN NAME; do

    if [ -z "$ARN" ] || [ "$ARN" == "None" ]; then
        continue
    fi

    echo -n "   Testing: $NAME ... "

    RESULT=$(aws bedrock-runtime converse --region $REGION \
        --model-id "$ARN" \
        --messages '[{"role":"user","content":[{"text":"Say OK"}]}]' \
        --query 'output.message.content[0].text' \
        --output text 2>&1)

    if [[ "$RESULT" == *"AccessDenied"* ]] || [[ "$RESULT" == *"error"* ]] || [[ "$RESULT" == *"Error"* ]]; then
        echo "✗ FAILED"
    else
        echo "✓ WORKS"
        echo "$ARN|$NAME" >> "$WORKING_FILE"
    fi
done

# ============================================
# STEP D: Show results
# ============================================
echo ""
echo "==========================================================================================================="
echo "                                    WORKING INFERENCE PROFILES"
echo "==========================================================================================================="
echo ""

if [ -s "$WORKING_FILE" ]; then
    printf "%-90s | %s\n" "ARN" "Name"
    printf "%-90s-+-%s\n" "$(printf '%0.s-' {1..90})" "$(printf '%0.s-' {1..50})"
    while IFS='|' read -r arn name; do
        printf "%-90s | %s\n" "$arn" "$name"
    done < "$WORKING_FILE"

    # Find sonnet4 specifically (preferred), fall back to first working
    SONNET4_ARN=$(grep "sonnet4" "$WORKING_FILE" | grep -v "sonnet45" | head -1 | cut -d'|' -f1)
    SONNET4_NAME=$(grep "sonnet4" "$WORKING_FILE" | grep -v "sonnet45" | head -1 | cut -d'|' -f2)

    if [ -z "$SONNET4_ARN" ]; then
        # Fall back to first working profile
        SONNET4_ARN=$(head -1 "$WORKING_FILE" | cut -d'|' -f1)
        SONNET4_NAME=$(head -1 "$WORKING_FILE" | cut -d'|' -f2)
    fi

    # Determine MODEL nickname from profile name
    if [[ "$SONNET4_NAME" == *"sonnet45"* ]]; then
        MODEL_NICKNAME="sonnet45"
    elif [[ "$SONNET4_NAME" == *"sonnet4"* ]]; then
        MODEL_NICKNAME="sonnet4"
    elif [[ "$SONNET4_NAME" == *"sonnet"* ]]; then
        MODEL_NICKNAME="sonnet"
    elif [[ "$SONNET4_NAME" == *"haiku"* ]]; then
        MODEL_NICKNAME="haiku"
    else
        MODEL_NICKNAME="sonnet4"
    fi

    echo ""
    echo "==========================================================================================================="
    echo "                                    COPY THESE TO YOUR NOTEBOOK"
    echo "==========================================================================================================="
    echo ""
    echo "MODEL = \"$MODEL_NICKNAME\""
    echo "INFERENCE_PROFILE_ARN = \"$SONNET4_ARN\""
    echo ""
else
    echo "No working profiles found!"
    echo ""
    echo "You may need to enable model access in the Bedrock Console:"
    echo "  https://${REGION}.console.aws.amazon.com/bedrock/home?region=${REGION}#/modelaccess"
fi

rm -f "$WORKING_FILE"

echo ""
echo "Done!"
echo ""
