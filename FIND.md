# Find Available Claude Models in AWS Bedrock

Run this in AWS CloudShell to find all available Claude models for the workshop.

## Quick Command

```bash
cat << 'EOF' | bash
# Find available Claude models in AWS Bedrock
# Region from CONFIG.txt: us-west-2

REGION="us-west-2"

echo "=== Available Claude Models in $REGION ==="
echo ""

# List all Anthropic foundation models
aws bedrock list-foundation-models \
    --region "$REGION" \
    --by-provider anthropic \
    --query 'modelSummaries[*].{ModelId:modelId,Name:modelName,Status:modelLifecycle.status}' \
    --output table

echo ""
echo "=== On-Demand Inference Profiles (Claude) ==="
echo ""

# List inference profiles for cross-region inference
aws bedrock list-inference-profiles \
    --region "$REGION" \
    --query 'inferenceProfileSummaries[?contains(inferenceProfileName, `Claude`)].{ProfileId:inferenceProfileId,Name:inferenceProfileName,Status:status}' \
    --output table 2>/dev/null || echo "No inference profiles found or not available in this region"

echo ""
echo "=== Current CONFIG.txt Model ==="
echo "MODEL_ID=anthropic.claude-3-5-sonnet-20241022-v2:0"
echo ""
echo "To use a different model, update MODEL_ID in CONFIG.txt"
EOF
```

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

## Individual Commands

### List Foundation Models
```bash
aws bedrock list-foundation-models \
    --region us-west-2 \
    --by-provider anthropic \
    --output table
```

### List with Model IDs Only
```bash
aws bedrock list-foundation-models \
    --region us-west-2 \
    --by-provider anthropic \
    --query 'modelSummaries[*].modelId' \
    --output text
```

### Test Single Model (Converse API - works for all Claude versions)
```bash
# Test the model configured in CONFIG.txt using Converse API
aws bedrock-runtime converse \
    --region us-west-2 \
    --model-id anthropic.claude-3-5-sonnet-20241022-v2:0 \
    --messages '[{"role":"user","content":[{"text":"Hello! Please respond with a brief greeting."}]}]' \
    --inference-config '{"maxTokens":100}' \
    --query 'output.message.content[0].text' \
    --output text
```

### Test Single Model (invoke-model - Claude 3.x only)
```bash
# Alternative: invoke-model with Messages API (Claude 3.x models only)
aws bedrock-runtime invoke-model \
    --region us-west-2 \
    --model-id anthropic.claude-3-5-sonnet-20241022-v2:0 \
    --content-type "application/json" \
    --accept "application/json" \
    --body '{"anthropic_version":"bedrock-2023-05-31","max_tokens":100,"messages":[{"role":"user","content":"Hello!"}]}' \
    /tmp/test-response.json && cat /tmp/test-response.json | jq '.content[0].text'
```

### Check What Models Are Enabled
```bash
# View your model access requests and status
aws bedrock list-foundation-model-agreement-offers \
    --region us-west-2 \
    --query 'modelAccessOffers[?contains(modelId, `anthropic`)].{Model:modelId,Status:agreementStatus}' \
    --output table 2>/dev/null || echo "Use Bedrock Console to check model access status"
```

### Enable Model Access (Console)
If a model shows "NO ACCESS", enable it via:
1. Go to AWS Console > Amazon Bedrock > Model access
2. Click "Manage model access"
3. Select the Claude models you need
4. Submit request (most are instant for on-demand)

## Enable Claude 4 Model Access via CLI

For Anthropic models, you must first submit a use case form (one-time per account), then create a model agreement.

```bash
cat << 'EOF' | bash
# Enable Claude 4 model access via CLI
# Reference: https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html

REGION="us-west-2"

# Model to enable (change as needed)
MODEL_ID="anthropic.claude-sonnet-4-20250514-v1:0"

echo "=============================================="
echo "  Enabling Model Access for: $MODEL_ID"
echo "=============================================="
echo ""

# Step 1: Check current availability
echo "Step 1: Checking current model availability..."
aws bedrock get-foundation-model-availability \
    --region "$REGION" \
    --model-id "$MODEL_ID" 2>&1

echo ""

# Step 2: Submit Anthropic use case form (one-time per account)
echo "Step 2: Submitting Anthropic use case form (required once per account)..."

# Create the use case form data
FORM_DATA=$(cat << 'FORM'
{
  "companyName": "Workshop Demo",
  "companyWebsite": "https://aws.amazon.com",
  "intendedUsers": "0",
  "industryOption": "Technology",
  "otherIndustryOption": "",
  "useCases": "AWS Workshop - Learning and evaluation of Claude models for building AI agents with Neo4j and Bedrock"
}
FORM
)

# Base64 encode the form data
ENCODED_FORM=$(echo "$FORM_DATA" | base64 | tr -d '\n')

aws bedrock put-use-case-for-model-access \
    --region "$REGION" \
    --form-data "$ENCODED_FORM" 2>&1 || echo "(May already be submitted - continuing...)"

echo ""

# Step 3: Get offer token for the model
echo "Step 3: Getting model agreement offers..."
OFFER_RESPONSE=$(aws bedrock list-foundation-model-agreement-offers \
    --region "$REGION" \
    --model-id "$MODEL_ID" \
    --output json 2>&1)

if echo "$OFFER_RESPONSE" | grep -q "offerToken"; then
    OFFER_TOKEN=$(echo "$OFFER_RESPONSE" | jq -r '.offers[0].offerToken')
    echo "   Found offer token: ${OFFER_TOKEN:0:50}..."

    # Step 4: Create the model agreement
    echo ""
    echo "Step 4: Creating model agreement..."
    aws bedrock create-foundation-model-agreement \
        --region "$REGION" \
        --model-id "$MODEL_ID" \
        --offer-token "$OFFER_TOKEN" 2>&1
else
    echo "   No offers found or error: $OFFER_RESPONSE"
fi

echo ""

# Step 5: Verify access
echo "Step 5: Verifying model access..."
aws bedrock get-foundation-model-availability \
    --region "$REGION" \
    --model-id "$MODEL_ID"

echo ""

# Step 6: Test the model
echo "Step 6: Testing model invocation..."
RESULT=$(aws bedrock-runtime converse \
    --region "$REGION" \
    --model-id "$MODEL_ID" \
    --messages '[{"role":"user","content":[{"text":"Say hello in 3 words"}]}]' \
    --inference-config '{"maxTokens":50}' \
    --output json 2>&1)

if echo "$RESULT" | grep -q "output"; then
    RESPONSE=$(echo "$RESULT" | jq -r '.output.message.content[0].text')
    echo "   SUCCESS! Response: $RESPONSE"
else
    echo "   Test failed: $RESULT"
fi

echo ""
echo "=============================================="
EOF
```

## Enable Multiple Claude Models at Once

```bash
cat << 'EOF' | bash
# Enable multiple Claude models at once
REGION="us-west-2"

# Claude 4 models to enable
MODELS=(
    "anthropic.claude-sonnet-4-20250514-v1:0"
    "anthropic.claude-haiku-4-5-20251001-v1:0"
    "anthropic.claude-3-5-sonnet-20241022-v2:0"
    "anthropic.claude-3-5-haiku-20241022-v1:0"
)

# First submit the Anthropic use case form (one-time)
echo "Submitting Anthropic use case form..."
FORM_DATA='{"companyName":"Workshop","companyWebsite":"https://aws.amazon.com","intendedUsers":"0","industryOption":"Technology","otherIndustryOption":"","useCases":"AWS Workshop - AI agents with Neo4j and Bedrock"}'
ENCODED_FORM=$(echo "$FORM_DATA" | base64 | tr -d '\n')
aws bedrock put-use-case-for-model-access --region "$REGION" --form-data "$ENCODED_FORM" 2>/dev/null || true

echo ""
echo "Enabling models..."
echo ""

for MODEL_ID in "${MODELS[@]}"; do
    echo -n "Enabling $MODEL_ID ... "

    # Get offer token
    OFFER_TOKEN=$(aws bedrock list-foundation-model-agreement-offers \
        --region "$REGION" \
        --model-id "$MODEL_ID" \
        --query 'offers[0].offerToken' \
        --output text 2>/dev/null)

    if [ -n "$OFFER_TOKEN" ] && [ "$OFFER_TOKEN" != "None" ]; then
        # Create agreement
        aws bedrock create-foundation-model-agreement \
            --region "$REGION" \
            --model-id "$MODEL_ID" \
            --offer-token "$OFFER_TOKEN" 2>/dev/null

        # Verify
        STATUS=$(aws bedrock get-foundation-model-availability \
            --region "$REGION" \
            --model-id "$MODEL_ID" \
            --query 'agreementAvailability.status' \
            --output text 2>/dev/null)

        if [ "$STATUS" = "AVAILABLE" ]; then
            echo "ENABLED"
        else
            echo "Status: $STATUS"
        fi
    else
        echo "No offer available"
    fi
done

echo ""
echo "Done! Re-run the test script to verify access."
EOF
```

## Original Notebook Model (Before CONFIG.txt)

The notebook originally used these models with inference profile ARNs:
- **haiku**: `anthropic.claude-3-5-haiku-20241022-v1:0`
- **sonnet**: `anthropic.claude-3-5-sonnet-20241022-v2:0`
- **sonnet4**: `anthropic.claude-sonnet-4-20250514-v1:0`
- **sonnet45**: `anthropic.claude-sonnet-4-5-20250929-v1:0`

Currently working models in your account:
- `anthropic.claude-3-sonnet-20240229-v1:0` (Claude 3 Sonnet)
- `anthropic.claude-3-haiku-20240307-v1:0` (Claude 3 Haiku)
- `us.anthropic.claude-3-haiku-20240307-v1:0` (inference profile)
- `us.anthropic.claude-3-sonnet-20240229-v1:0` (inference profile)
