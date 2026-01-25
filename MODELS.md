# AWS Bedrock Model Access Guide

> **Updated January 2025**: AWS changed model access so most models are now enabled by default with the correct IAM permissions. No manual "request access" step needed for many providers.

## Quick Reference

### Models Available Immediately (No Marketplace Permissions Required)

These providers **don't require AWS Marketplace permissions** - just standard Bedrock IAM permissions:

| Provider | Models | Notes |
|----------|--------|-------|
| **Amazon** | Nova (Micro, Lite, Pro, Premier, Canvas, Reel, Sonic), Titan Embeddings, Titan Image | First-party, always available |
| **Meta** | Llama 3, 3.1, 3.2, 3.3, Llama 4 | Open source models |
| **Mistral AI** | Mistral 7B, Mixtral, Mistral Large, Ministral, Magistral | Open weights |
| **DeepSeek** | DeepSeek-R1, DeepSeek-V3.1 | |
| **Qwen** | Qwen3 (32B, 235B, Coder, VL) | Alibaba models |
| **OpenAI** | GPT OSS models | Open source variants |
| **Google** | Gemma 3 (4B, 12B, 27B) | Open weights |
| **NVIDIA** | Nemotron Nano | |

### Models Requiring AWS Marketplace Permissions

These providers require `aws-marketplace:Subscribe` and `aws-marketplace:ViewSubscriptions` permissions:

| Provider | Models | Additional Requirements |
|----------|--------|------------------------|
| **Anthropic** | Claude 3, 3.5, 4, Haiku, Sonnet, Opus | **One-time use case form** per account |
| **AI21 Labs** | Jamba 1.5 | |
| **Cohere** | Command R/R+, Embed v3/v4, Rerank | |
| **Stability AI** | Stable Diffusion, Image services | |
| **TwelveLabs** | Marengo Embed, Pegasus | |
| **Writer** | Palmyra X4, X5 | |
| **Luma AI** | Ray v2 | |

---

## LLM Models for the Workshop

### Recommended: Models Available in us-west-2

#### No Marketplace Permissions Needed

```
# Amazon Nova (recommended for quick testing)
amazon.nova-micro-v1:0          # Fast, text only
amazon.nova-lite-v1:0           # Multimodal
amazon.nova-pro-v1:0            # Best quality

# Meta Llama
meta.llama3-70b-instruct-v1:0   # Llama 3
meta.llama3-1-70b-instruct-v1:0 # Llama 3.1 (cross-region only)

# Mistral
mistral.mistral-7b-instruct-v0:2
mistral.mixtral-8x7b-instruct-v0:1
mistral.mistral-large-2407-v1:0
```

#### Require Marketplace Permissions + Anthropic Use Case Form

```
# Claude 3 (older, widely available)
anthropic.claude-3-sonnet-20240229-v1:0    # Good balance
anthropic.claude-3-haiku-20240307-v1:0     # Fast & cheap

# Claude 3.5
anthropic.claude-3-5-sonnet-20241022-v2:0  # Best for coding
anthropic.claude-3-5-haiku-20241022-v1:0   # Fast

# Claude 4+ (cross-region inference profiles only)
us.anthropic.claude-sonnet-4-20250514-v1:0
us.anthropic.claude-sonnet-4-5-20250929-v1:0
us.anthropic.claude-opus-4-5-20251101-v1:0
```

---

## Embedding Models

### No Marketplace Permissions Needed

```
# Amazon Titan (recommended)
amazon.titan-embed-text-v2:0     # 1024 dims, best quality, us-west-2
amazon.titan-embed-text-v1       # 1536 dims, legacy

# Amazon Titan Multimodal
amazon.titan-embed-image-v1      # Text + Image embeddings

# Amazon Nova Multimodal (newest)
amazon.nova-2-multimodal-embeddings-v1:0   # Text, Image, Audio, Video
```

### Require Marketplace Permissions

```
# Cohere (high quality)
cohere.embed-english-v3          # English only, 1024 dims
cohere.embed-multilingual-v3     # 100+ languages
cohere.embed-v4:0                # Latest, multimodal

# TwelveLabs (video/multimodal)
twelvelabs.marengo-embed-3-0-v1:0
```

---

## How to Enable Models

### For Models Without Marketplace Requirements

Just ensure your IAM role has Bedrock permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "bedrock:InvokeModel",
                "bedrock:InvokeModelWithResponseStream"
            ],
            "Resource": "arn:aws:bedrock:*::foundation-model/*"
        }
    ]
}
```

### For Models With Marketplace Requirements

1. Add AWS Marketplace permissions to your IAM role:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "aws-marketplace:Subscribe",
                "aws-marketplace:Unsubscribe",
                "aws-marketplace:ViewSubscriptions"
            ],
            "Resource": "*"
        }
    ]
}
```

2. **For Anthropic models only**: Submit use case form (one-time per account)
   - Go to AWS Console > Bedrock > Model catalog > Select any Claude model
   - Fill out the use case form
   - Access granted immediately

### For Cross-Region Inference Profiles

When using inference profiles (e.g., `us.anthropic.claude-*`), configure both:

```python
MODEL_ID = "us.anthropic.claude-3-sonnet-20240229-v1:0"      # Inference profile
BASE_MODEL_ID = "anthropic.claude-3-sonnet-20240229-v1:0"   # Base model
```

---

## Workshop Configuration

For this workshop, update your notebook configuration based on what you have access to:

### If You Have Claude Access

```python
# Claude 3 Sonnet (widely available)
MODEL_ID = "us.anthropic.claude-3-sonnet-20240229-v1:0"
BASE_MODEL_ID = "anthropic.claude-3-sonnet-20240229-v1:0"

# Or Claude 3.5 Sonnet (if enabled)
MODEL_ID = "us.anthropic.claude-3-5-sonnet-20241022-v2:0"
BASE_MODEL_ID = "anthropic.claude-3-5-sonnet-20241022-v2:0"
```

### If You Don't Have Claude Access (No Marketplace Permissions)

```python
# Amazon Nova Pro (good quality, no extra permissions)
MODEL_ID = "amazon.nova-pro-v1:0"
BASE_MODEL_ID = None  # Not needed for Amazon models

# Or Meta Llama 3
MODEL_ID = "meta.llama3-70b-instruct-v1:0"
BASE_MODEL_ID = None
```

### Embedding Model

```python
# Amazon Titan (no extra permissions needed)
EMBEDDING_MODEL_ID = "amazon.titan-embed-text-v2:0"
```

---

## Troubleshooting

### AccessDeniedException with Marketplace Error

```
AccessDeniedException: ... not authorized to perform aws-marketplace:ViewSubscriptions
```

**Cause**: Using a model that requires Marketplace permissions (Anthropic, Cohere, etc.)

**Fix**: Either:
1. Add Marketplace permissions to your IAM role, OR
2. Switch to a model that doesn't require them (Amazon, Meta, Mistral, etc.)

### ValidationException

```
ValidationException: ...
```

**Cause**: Usually means the model requires a different API (e.g., Claude 4+ requires Converse API)

**Fix**: Ensure you're using `ChatBedrockConverse` (not `ChatBedrock`) for newer models

### Model Not Found

**Cause**: Model not available in your region

**Fix**: Check the supported regions table above, or use cross-region inference profiles

---

## References

- [AWS Bedrock Model Access Documentation](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html)
- [Supported Foundation Models](https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html)
- [Cross-Region Inference Profiles](https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-support.html)
