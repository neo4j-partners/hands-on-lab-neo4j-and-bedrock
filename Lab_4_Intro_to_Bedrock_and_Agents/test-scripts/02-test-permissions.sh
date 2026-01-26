#!/bin/bash
# 02-test-permissions.sh
# Tests Bedrock and Marketplace IAM permissions using Policy Simulator
# Outputs results to permission-test-results.txt

# NOTE: Do NOT use set -e here - we expect some commands to fail

RESULTS_FILE="permission-test-results.txt"
REGION="${REGION:-us-west-2}"
MODEL_ID="${MODEL_ID:-us.anthropic.claude-3-sonnet-20240229-v1:0}"

# Source identity if available
if [ -f ".env-identity" ]; then
    source .env-identity
fi

# Check if POLICY_SOURCE_ARN is set
if [ -z "$POLICY_SOURCE_ARN" ]; then
    echo "POLICY_SOURCE_ARN not set. Running 01-get-identity.sh first..."
    source ./01-get-identity.sh
fi

cat <<EOF | tee "$RESULTS_FILE"
========================================
IAM Permission Test Results
========================================
Date:       $(date)
Identity:   ${POLICY_SOURCE_ARN}
Region:     ${REGION}
Model ID:   ${MODEL_ID}
========================================

EOF

# Function to test a permission
test_permission() {
    local action="$1"
    local resource="${2:-*}"
    local result

    echo -n "Testing ${action}... " | tee -a "$RESULTS_FILE"

    result=$(aws iam simulate-principal-policy \
        --policy-source-arn "$POLICY_SOURCE_ARN" \
        --action-names "$action" \
        --resource-arns "$resource" \
        --query 'EvaluationResults[0].EvalDecision' \
        --output text 2>&1) || result="ERROR: $?"

    if [ "$result" = "allowed" ]; then
        echo "[PASS] $result" | tee -a "$RESULTS_FILE"
        return 0
    else
        echo "[FAIL] $result" | tee -a "$RESULTS_FILE"
        return 1
    fi
}

echo "--- Bedrock Control Plane Permissions ---" | tee -a "$RESULTS_FILE"
bedrock_pass=0
bedrock_fail=0

test_permission "bedrock:ListFoundationModels" "*" && ((bedrock_pass++)) || ((bedrock_fail++))
test_permission "bedrock:GetFoundationModel" "*" && ((bedrock_pass++)) || ((bedrock_fail++))

echo "" | tee -a "$RESULTS_FILE"
echo "--- Bedrock Runtime Permissions ---" | tee -a "$RESULTS_FILE"

test_permission "bedrock-runtime:Converse" "*" && ((bedrock_pass++)) || ((bedrock_fail++))
test_permission "bedrock-runtime:ConverseStream" "*" && ((bedrock_pass++)) || ((bedrock_fail++))
test_permission "bedrock-runtime:InvokeModel" "*" && ((bedrock_pass++)) || ((bedrock_fail++))
test_permission "bedrock-runtime:InvokeModelWithResponseStream" "*" && ((bedrock_pass++)) || ((bedrock_fail++))

echo "" | tee -a "$RESULTS_FILE"
echo "--- Marketplace Permissions ---" | tee -a "$RESULTS_FILE"
marketplace_pass=0
marketplace_fail=0

test_permission "aws-marketplace:ViewSubscriptions" "*" && ((marketplace_pass++)) || ((marketplace_fail++))
test_permission "aws-marketplace:Subscribe" "*" && ((marketplace_pass++)) || ((marketplace_fail++))

echo "" | tee -a "$RESULTS_FILE"
cat <<EOF | tee -a "$RESULTS_FILE"
========================================
SUMMARY
========================================
Bedrock Permissions:     ${bedrock_pass} passed, ${bedrock_fail} failed
Marketplace Permissions: ${marketplace_pass} passed, ${marketplace_fail} failed
----------------------------------------
EOF

total_pass=$((bedrock_pass + marketplace_pass))
total_fail=$((bedrock_fail + marketplace_fail))

if [ $total_fail -eq 0 ]; then
    echo "RESULT: ALL PERMISSIONS VERIFIED" | tee -a "$RESULTS_FILE"
else
    echo "RESULT: MISSING PERMISSIONS DETECTED" | tee -a "$RESULTS_FILE"
    echo "" | tee -a "$RESULTS_FILE"
    echo "To fix, add the missing permissions from lab4-minimal-policy.json" | tee -a "$RESULTS_FILE"
    echo "to the IAM role/user: ${POLICY_SOURCE_ARN}" | tee -a "$RESULTS_FILE"
fi

echo "========================================" | tee -a "$RESULTS_FILE"
echo ""
echo "Results saved to: ${RESULTS_FILE}"
