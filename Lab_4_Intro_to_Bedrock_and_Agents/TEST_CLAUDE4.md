# Claude 4 Model Testing

Tests all Claude 4 model ID variations. Copy and paste into AWS CloudShell.

## Model ID Variations

| Prefix | Description |
|--------|-------------|
| `anthropic.` | Base model ID (direct on-demand) |
| `us.anthropic.` | US cross-region inference |
| `eu.anthropic.` | EU cross-region inference |
| `apac.anthropic.` | APAC cross-region inference |
| `global.anthropic.` | Global cross-region inference (worldwide) |

```bash
cat << 'EOF' | bash
#!/bin/bash

REGION="${AWS_REGION:-us-west-2}"

echo "Claude 4 Model Testing"
echo "Region: $REGION"
echo "=============================================="

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
        echo "  [--] $model_id"
        return 1
    fi
}

# Claude 4 base models
CLAUDE4_MODELS=(
    "claude-sonnet-4-20250514-v1:0"
    "claude-haiku-4-5-20251001-v1:0"
    "claude-sonnet-4-5-20250929-v1:0"
    "claude-opus-4-1-20250805-v1:0"
    "claude-opus-4-5-20251101-v1:0"
)

# Prefixes to test
PREFIXES=(
    "anthropic."
    "us.anthropic."
    "eu.anthropic."
    "apac.anthropic."
    "global.anthropic."
)

echo ""
echo "--- Testing all Claude 4 model ID variations ---"
echo ""

WORKING_MODELS=()

for prefix in "${PREFIXES[@]}"; do
    echo "Prefix: $prefix"
    for model in "${CLAUDE4_MODELS[@]}"; do
        full_id="${prefix}${model}"
        if test_model "$full_id"; then
            WORKING_MODELS+=("$full_id")
        fi
    done
    echo ""
done

echo "=============================================="
echo "WORKING CLAUDE 4 MODELS"
echo "=============================================="
echo ""
if [ ${#WORKING_MODELS[@]} -eq 0 ]; then
    echo "No Claude 4 models are accessible."
    echo "Enable model access in AWS Console > Bedrock > Model access"
else
    echo "Add one of these to your CONFIG.txt:"
    echo ""
    for m in "${WORKING_MODELS[@]}"; do
        echo "MODEL_ID=$m"
    done
fi

echo ""
echo "=============================================="
echo "QUICK COPY - First working model:"
echo "=============================================="
if [ ${#WORKING_MODELS[@]} -gt 0 ]; then
    echo ""
    echo "MODEL_ID=${WORKING_MODELS[0]}"
fi
EOF
```
