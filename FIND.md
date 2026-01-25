# Find Available Claude Models in AWS Bedrock

Run this in AWS CloudShell to find all available Claude models for the workshop.

## Test Model Access and Invocation

**Note:** Claude 4+ models use the **Converse API** (not invoke-model with Messages API).

```bash
cat << 'EOF' | bash
# Test which Claude models you have access to and can invoke
# Uses the Converse API which works for all Claude models
# Region from CONFIG.txt: us-west-2

REGION="us-west-2"

echo "=============================================="
echo "  Testing Claude Model Access in $REGION"
echo "=============================================="
echo ""

# Get list of Anthropic model IDs (exclude provisioned throughput variants with :XXk suffix)
MODELS=$(aws bedrock list-foundation-models \
    --region "$REGION" \
    --by-provider anthropic \
    --query 'modelSummaries[*].modelId' \
    --output text | tr '\t' '\n' | grep -v ':[0-9]*k$')

echo "=== Testing Foundation Models (Converse API) ==="
echo ""

for MODEL_ID in $MODELS; do
    echo -n "Testing: $MODEL_ID ... "

    # Use Converse API - works for all Claude models
    RESULT=$(aws bedrock-runtime converse \
        --region "$REGION" \
        --model-id "$MODEL_ID" \
        --messages '[{"role":"user","content":[{"text":"Say hi in 3 words"}]}]' \
        --inference-config '{"maxTokens":50}' \
        --output json 2>&1)

    if [ $? -eq 0 ]; then
        RESPONSE=$(echo "$RESULT" | jq -r '.output.message.content[0].text' 2>/dev/null)
        echo "ACCESS GRANTED"
        echo "   Response: $RESPONSE"
    else
        if echo "$RESULT" | grep -q "AccessDeniedException"; then
            echo "NO ACCESS (enable in Bedrock Console)"
        elif echo "$RESULT" | grep -q "ValidationException"; then
            echo "VALIDATION ERROR"
        elif echo "$RESULT" | grep -q "ThrottlingException"; then
            echo "THROTTLED (have access, try again)"
        elif echo "$RESULT" | grep -q "ResourceNotFoundException"; then
            echo "NOT FOUND (provisioned variant)"
        else
            echo "FAILED: $(echo $RESULT | head -c 80)"
        fi
    fi
done

echo ""
echo "=== Testing Inference Profiles (Cross-Region) ==="
echo ""

# Test inference profiles
PROFILES=$(aws bedrock list-inference-profiles \
    --region "$REGION" \
    --query 'inferenceProfileSummaries[?contains(inferenceProfileName, `Claude`)].inferenceProfileId' \
    --output text 2>/dev/null)

if [ -n "$PROFILES" ]; then
    for PROFILE_ID in $PROFILES; do
        echo -n "Testing: $PROFILE_ID ... "

        RESULT=$(aws bedrock-runtime converse \
            --region "$REGION" \
            --model-id "$PROFILE_ID" \
            --messages '[{"role":"user","content":[{"text":"Say hi in 3 words"}]}]' \
            --inference-config '{"maxTokens":50}' \
            --output json 2>&1)

        if [ $? -eq 0 ]; then
            RESPONSE=$(echo "$RESULT" | jq -r '.output.message.content[0].text' 2>/dev/null)
            echo "ACCESS GRANTED"
            echo "   Response: $RESPONSE"
        else
            if echo "$RESULT" | grep -q "AccessDeniedException"; then
                echo "NO ACCESS"
            elif echo "$RESULT" | grep -q "ThrottlingException"; then
                echo "THROTTLED (have access)"
            else
                echo "FAILED"
            fi
        fi
    done
else
    echo "No Claude inference profiles found"
fi

echo ""
echo "=============================================="
echo "  Summary"
echo "=============================================="
echo ""
echo "Models marked 'ACCESS GRANTED' can be used in CONFIG.txt"
echo "To enable models: AWS Console > Bedrock > Model access > Manage"
echo ""
EOF
```