# Bedrock Model Discovery

Copy and paste this into AWS CloudShell to discover available models:

```bash
cat << 'EOF' | bash
#!/bin/bash

REGION="${AWS_REGION:-us-west-2}"

echo "Discovering Bedrock models in region: $REGION"
echo "=============================================="

# Function to list models by provider
list_models() {
    local provider="$1"
    echo ""
    echo "--- $provider ---"

    models=$(aws bedrock list-foundation-models \
        --region "$REGION" \
        --by-provider "$provider" \
        --query 'modelSummaries[?modelLifecycle.status==`ACTIVE`].[modelId,modelName]' \
        --output text 2>/dev/null)

    if [ -z "$models" ]; then
        echo "  No models found or access denied"
    else
        echo "$models" | while read -r model_id model_name; do
            echo "  $model_id"
        done
    fi
}

# List models by provider
list_models "Anthropic"
list_models "Meta"
list_models "Mistral AI"
list_models "Amazon"

echo ""
echo "=============================================="
echo "WORKING MODELS FOR TESTING"
echo "=============================================="
echo ""
echo "Copy these model IDs to use with test_model():"
echo ""

# Test each provider and show working models
test_model() {
    local model_id="$1"
    local result=$(aws bedrock-runtime converse \
        --region "$REGION" \
        --model-id "$model_id" \
        --messages '[{"role":"user","content":[{"text":"Hi"}]}]' \
        --inference-config '{"maxTokens":5}' \
        2>&1)

    if echo "$result" | grep -q '"output"'; then
        echo "  [OK] $model_id"
        return 0
    else
        return 1
    fi
}

echo "Testing Anthropic models (base model IDs)..."
for model in \
    "anthropic.claude-3-sonnet-20240229-v1:0" \
    "anthropic.claude-3-haiku-20240307-v1:0" \
    "anthropic.claude-3-5-sonnet-20241022-v2:0" \
    "anthropic.claude-3-5-haiku-20241022-v1:0" \
    "anthropic.claude-sonnet-4-20250514-v1:0" \
    "anthropic.claude-haiku-4-5-20251001-v1:0" \
    "anthropic.claude-sonnet-4-5-20250929-v1:0" \
    "anthropic.claude-opus-4-1-20250805-v1:0" \
    "anthropic.claude-opus-4-5-20251101-v1:0"
do
    test_model "$model"
done

echo ""
echo "Testing Anthropic models (US cross-region inference)..."
for model in \
    "us.anthropic.claude-3-sonnet-20240229-v1:0" \
    "us.anthropic.claude-3-haiku-20240307-v1:0" \
    "us.anthropic.claude-3-5-sonnet-20241022-v2:0" \
    "us.anthropic.claude-3-5-haiku-20241022-v1:0" \
    "us.anthropic.claude-sonnet-4-20250514-v1:0" \
    "us.anthropic.claude-haiku-4-5-20251001-v1:0" \
    "us.anthropic.claude-sonnet-4-5-20250929-v1:0" \
    "us.anthropic.claude-opus-4-1-20250805-v1:0" \
    "us.anthropic.claude-opus-4-5-20251101-v1:0"
do
    test_model "$model"
done

echo ""
echo "Testing Anthropic models (Global cross-region inference)..."
for model in \
    "global.anthropic.claude-3-sonnet-20240229-v1:0" \
    "global.anthropic.claude-3-haiku-20240307-v1:0" \
    "global.anthropic.claude-3-5-sonnet-20241022-v2:0" \
    "global.anthropic.claude-3-5-haiku-20241022-v1:0" \
    "global.anthropic.claude-sonnet-4-20250514-v1:0" \
    "global.anthropic.claude-haiku-4-5-20251001-v1:0" \
    "global.anthropic.claude-sonnet-4-5-20250929-v1:0" \
    "global.anthropic.claude-opus-4-1-20250805-v1:0" \
    "global.anthropic.claude-opus-4-5-20251101-v1:0"
do
    test_model "$model"
done

echo ""
echo "Testing Meta Llama models..."
for model in \
    "meta.llama3-8b-instruct-v1:0" \
    "meta.llama3-70b-instruct-v1:0" \
    "meta.llama3-1-8b-instruct-v1:0" \
    "meta.llama3-1-70b-instruct-v1:0" \
    "meta.llama3-2-1b-instruct-v1:0" \
    "meta.llama3-2-3b-instruct-v1:0" \
    "us.meta.llama3-2-1b-instruct-v1:0" \
    "us.meta.llama3-2-3b-instruct-v1:0"
do
    test_model "$model"
done

echo ""
echo "Testing Mistral models..."
for model in \
    "mistral.mistral-7b-instruct-v0:2" \
    "mistral.mixtral-8x7b-instruct-v0:1" \
    "mistral.mistral-large-2402-v1:0" \
    "mistral.mistral-small-2402-v1:0"
do
    test_model "$model"
done

echo ""
echo "Testing Amazon Titan models..."
for model in \
    "amazon.titan-text-express-v1" \
    "amazon.titan-text-lite-v1" \
    "amazon.titan-text-premier-v1:0"
do
    test_model "$model"
done

echo ""
echo "=============================================="
echo "Done! Use the [OK] models above with test_model()"
EOF
```
