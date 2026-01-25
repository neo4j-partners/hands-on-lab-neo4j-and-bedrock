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
echo "For the workshop notebooks, use INFERENCE PROFILES (not foundation models):"
echo ""
echo "  MODEL_ID     = us.anthropic.claude-3-5-sonnet-...  (inference profile)"
echo "  BASE_MODEL_ID = anthropic.claude-3-5-sonnet-...    (foundation model)"
echo ""
echo "Example for Claude 3.5 Sonnet:"
echo "  MODEL_ID     = us.anthropic.claude-3-5-sonnet-20241022-v2:0"
echo "  BASE_MODEL_ID = anthropic.claude-3-5-sonnet-20241022-v2:0"
echo ""
echo "To enable models: AWS Console > Bedrock > Model access > Manage"
echo ""
EOF
```

## Test Models Without Marketplace Permissions

These models are available immediately with just Bedrock IAM permissions (no Marketplace subscription needed).
Good alternatives if you don't have Claude access.

```bash
cat << 'EOF' | bash
# Test Amazon, Mistral, and OpenAI models (no Marketplace permissions required)
# Focus on higher-quality LLM models suitable for Cypher generation

REGION="us-west-2"

echo "=============================================="
echo "  Testing No-Marketplace LLM Models in $REGION"
echo "  (Higher quality models for Cypher generation)"
echo "=============================================="
echo ""

# Define the models to test (higher quality LLMs only, no micro/lite/multimodal)
MODELS=(
    # Amazon Nova - Pro and Premier (higher quality)
    "amazon.nova-pro-v1:0"

    # Mistral AI - Large models
    "mistral.mistral-large-2402-v1:0"
    "mistral.mistral-large-2407-v1:0"
    "mistral.mixtral-8x7b-instruct-v0:1"

    # OpenAI OSS models
    "openai.gpt-oss-120b-1:0"
    "openai.gpt-oss-20b-1:0"
)

echo "=== Testing Foundation Models ==="
echo ""

for MODEL_ID in "${MODELS[@]}"; do
    echo -n "Testing: $MODEL_ID ... "

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
            echo "NO ACCESS"
        elif echo "$RESULT" | grep -q "ValidationException"; then
            echo "VALIDATION ERROR (model may not be in region)"
        elif echo "$RESULT" | grep -q "ThrottlingException"; then
            echo "THROTTLED (have access, try again)"
        elif echo "$RESULT" | grep -q "ResourceNotFoundException"; then
            echo "NOT FOUND in region"
        else
            echo "FAILED: $(echo $RESULT | head -c 60)"
        fi
    fi
done

echo ""
echo "=== Testing Cross-Region Inference Profiles ==="
echo ""

# Test Nova Premier (cross-region only) and other profiles
PROFILES=(
    "us.amazon.nova-premier-v1:0"
    "us.amazon.nova-pro-v1:0"
    "us.meta.llama3-3-70b-instruct-v1:0"
    "us.meta.llama3-1-70b-instruct-v1:0"
)

for PROFILE_ID in "${PROFILES[@]}"; do
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

echo ""
echo "=============================================="
echo "  Summary - No Marketplace Models"
echo "=============================================="
echo ""
echo "These models work WITHOUT aws-marketplace permissions."
echo "Best for Cypher generation (in order of quality):"
echo ""
echo "  1. amazon.nova-pro-v1:0           (Amazon's best, good reasoning)"
echo "  2. us.amazon.nova-premier-v1:0    (Highest quality, cross-region)"
echo "  3. mistral.mistral-large-2407-v1:0 (Latest Mistral Large)"
echo "  4. us.meta.llama3-3-70b-instruct-v1:0 (Llama 3.3, cross-region)"
echo ""
echo "Example notebook config (no BASE_MODEL_ID needed):"
echo "  MODEL_ID = \"amazon.nova-pro-v1:0\""
echo ""
EOF
```

## Test Embedding Model Access

```bash
cat << 'EOF' | bash
# Test which embedding models you have access to
# Region from CONFIG.txt: us-west-2

REGION="us-west-2"

echo "=============================================="
echo "  Testing Embedding Model Access in $REGION"
echo "=============================================="
echo ""

# Get list of embedding model IDs
MODELS=$(aws bedrock list-foundation-models \
    --region "$REGION" \
    --by-output-modality EMBEDDING \
    --query 'modelSummaries[*].modelId' \
    --output text | tr '\t' '\n')

for MODEL_ID in $MODELS; do
    echo -n "Testing: $MODEL_ID ... "

    # Determine the correct request format based on provider
    if [[ "$MODEL_ID" == amazon.titan-embed* ]]; then
        BODY='{"inputText":"test"}'
    elif [[ "$MODEL_ID" == cohere.embed* ]]; then
        BODY='{"texts":["test"],"input_type":"search_document"}'
    else
        BODY='{"inputText":"test"}'
    fi

    RESULT=$(aws bedrock-runtime invoke-model \
        --region "$REGION" \
        --model-id "$MODEL_ID" \
        --content-type "application/json" \
        --body "$BODY" \
        /dev/stdout 2>&1)

    if [ $? -eq 0 ] && echo "$RESULT" | grep -q "embedding"; then
        echo "ACCESS GRANTED"
    else
        if echo "$RESULT" | grep -q "AccessDeniedException"; then
            echo "NO ACCESS (enable in Bedrock Console)"
        elif echo "$RESULT" | grep -q "ValidationException"; then
            echo "VALIDATION ERROR"
        elif echo "$RESULT" | grep -q "ThrottlingException"; then
            echo "THROTTLED (have access, try again)"
        else
            echo "FAILED"
        fi
    fi
done

echo ""
echo "=============================================="
echo "  Embedding Model Summary"
echo "=============================================="
echo ""
echo "Recommended for the workshop:"
echo "  amazon.titan-embed-text-v2:0  (1024 dimensions, best quality)"
echo "  amazon.titan-embed-text-v1    (1536 dimensions, legacy)"
echo ""
echo "To enable models: AWS Console > Bedrock > Model access > Manage"
echo ""
EOF
```