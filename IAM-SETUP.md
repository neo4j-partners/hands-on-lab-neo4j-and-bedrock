# IAM Setup for Bedrock Agents Lab

This document describes all IAM permissions required to run this lab, including the setup script and notebooks.

## Table of Contents

- [Setup Script Overview](#setup-script-overview)
- [Quick Start](#quick-start)
- [Automated IAM Setup](#automated-iam-setup)
- [Permissions Overview](#permissions-overview)
- [Setup Script Permissions](#setup-script-permissions)
- [Notebook Permissions](#notebook-permissions)
- [Combined IAM Policy](#combined-iam-policy)
- [Model ID Reference](#model-id-reference)
- [SageMaker Studio Setup](#sagemaker-studio-setup)
- [SageMaker Unified Studio (DataZone)](#sagemaker-unified-studio-datazone)
- [Troubleshooting](#troubleshooting)
- [ARN Reference](#arn-reference)
- [Sources](#sources)

---

## Setup Script Overview

The `setup-inference-profile.sh` script creates **application inference profiles** for use with SageMaker Unified Studio. This is required because Unified Studio's permissions boundary blocks direct foundation model calls—you must route requests through a tagged inference profile.

### What the Script Does

1. **Auto-detects DataZone IDs** - Finds your SageMaker Unified Studio domain and project
2. **Creates inference profiles** - Wraps a foundation model in an application inference profile
3. **Applies required tags** - Adds `AmazonBedrockManaged=true` (the "secret sauce" for Unified Studio access)
4. **Outputs configuration** - Provides the ARN to paste into notebooks

### AWS CLI Commands Used

| Command | Purpose | IAM Permission Required |
|---------|---------|------------------------|
| `aws sts get-caller-identity` | Get AWS account ID for ARN construction | `sts:GetCallerIdentity` |
| `aws datazone list-domains` | Find DataZone domains for auto-detection | `datazone:ListDomains` |
| `aws datazone list-projects` | Find DataZone projects for auto-detection | `datazone:ListProjects` |
| `aws bedrock list-inference-profiles` | Check for existing profiles | `bedrock:ListInferenceProfiles` |
| `aws bedrock get-inference-profile` | Get profile details (name, status) | `bedrock:GetInferenceProfile` |
| `aws bedrock create-inference-profile` | Create new application inference profile | `bedrock:CreateInferenceProfile` |
| `aws bedrock delete-inference-profile` | Delete profiles (`--delete` flag) | `bedrock:DeleteInferenceProfile` |
| `aws bedrock list-tags-for-resource` | Verify `AmazonBedrockManaged` tag exists | `bedrock:ListTagsForResource` |
| `aws bedrock-runtime converse` | Test profile works (`--test` flag) | `bedrock-runtime:Converse` |

### Why Each Permission is Needed

| Permission | Why It's Needed |
|------------|-----------------|
| `sts:GetCallerIdentity` | Constructs the inference profile ARN which includes your account ID |
| `datazone:ListDomains` | Auto-detects which DataZone domain you're in (for proper tagging) |
| `datazone:ListProjects` | Auto-detects which project to associate the profile with |
| `bedrock:ListInferenceProfiles` | Checks if a profile already exists before creating |
| `bedrock:GetInferenceProfile` | Retrieves profile name for display and status checking |
| `bedrock:CreateInferenceProfile` | Creates the application inference profile with `copyFrom` pointing to a system inference profile |
| `bedrock:DeleteInferenceProfile` | Allows cleanup of old profiles with `--delete` flag |
| `bedrock:ListTagsForResource` | Verifies the `AmazonBedrockManaged=true` tag was applied correctly |
| `bedrock:TagResource` | Applies tags during profile creation (DataZone IDs, `AmazonBedrockManaged`) |
| `bedrock-runtime:Converse` | Tests the profile actually works with `--test` flag |

### Script Usage

```bash
# Interactive model selection
./setup-inference-profile.sh

# Create specific model profile
./setup-inference-profile.sh haiku      # Claude 3.5 Haiku (fast, cheap)
./setup-inference-profile.sh sonnet     # Claude 3.5 Sonnet v2 (balanced)
./setup-inference-profile.sh sonnet4    # Claude Sonnet 4
./setup-inference-profile.sh sonnet45   # Claude Sonnet 4.5

# Create and test
./setup-inference-profile.sh --test haiku

# List existing profiles
./setup-inference-profile.sh --list

# Delete a profile
./setup-inference-profile.sh --delete haiku

# Create all profiles
./setup-inference-profile.sh --all
```

### Example Output

```
✓ Auto-detected DataZone IDs
  Domain:  dzd-abc123xyz
  Project: 9f8e7d6c5b4a

Creating Inference Profile
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Model:   Claude 3.5 Haiku (fast and cheap)
Name:    dzd-abc123xyz 9f8e7d6c5b4a haiku
Region:  us-west-2

Tags (SECRET SAUCE):
  AmazonBedrockManaged: true  ← THE KEY!
  AmazonDataZoneProject: 9f8e7d6c5b4a
  AmazonDataZoneDomain:  dzd-abc123xyz
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Created successfully!

╔════════════════════════════════════════════════════════════╗
║              COPY THIS TO YOUR NOTEBOOK                    ║
╚════════════════════════════════════════════════════════════╝

MODEL = "haiku"
INFERENCE_PROFILE_ARN = "arn:aws:bedrock:us-west-2:123456789012:application-inference-profile/abc123def456"
```

---

## Quick Start

### Option 1: Automated Setup (Recommended)

Use the `setup-iam.sh` script to create and attach the IAM policy:

```bash
# List available SageMaker/DataZone roles
./setup-iam.sh --list-roles

# Create policy and attach to your role
./setup-iam.sh --attach YOUR_ROLE_NAME

# Then create an inference profile
./setup-inference-profile.sh haiku
```

### Option 2: Manual Setup

For basic lab functionality, manually attach this policy to your IAM role:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BedrockInvokeModels",
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ],
      "Resource": [
        "arn:aws:bedrock:*::foundation-model/anthropic.*",
        "arn:aws:bedrock:*:*:inference-profile/*",
        "arn:aws:bedrock:*:*:application-inference-profile/*"
      ]
    }
  ]
}
```

---

## Automated IAM Setup

The `setup-iam.sh` script automates IAM policy creation and attachment.

### Script Commands

```bash
# Show help
./setup-iam.sh --help

# Create the policy only (doesn't attach)
./setup-iam.sh

# List SageMaker and DataZone execution roles
./setup-iam.sh --list-roles

# Create policy and attach to a role
./setup-iam.sh --attach ROLE_NAME

# Check if a role has required permissions
./setup-iam.sh --check ROLE_NAME

# Display the policy JSON
./setup-iam.sh --show-policy

# Delete the policy (detaches from all roles first)
./setup-iam.sh --delete
```

### What the Script Creates

The script creates a policy named `BedrockAgentsLabPolicy` with three statement blocks:

| Statement | Permissions | Purpose |
|-----------|-------------|---------|
| `InferenceProfileManagement` | sts:GetCallerIdentity, bedrock:*InferenceProfile*, bedrock:*Tags* | Create/manage inference profiles |
| `BedrockModelInvocation` | bedrock-runtime:Converse*, bedrock-runtime:InvokeModel* | Run the notebooks |
| `DataZoneAutoDetect` | datazone:ListDomains, datazone:ListProjects | Auto-detect DataZone IDs |

### Example Usage

```bash
# 1. Find your SageMaker execution role
./setup-iam.sh --list-roles

# Output:
# SageMaker Execution Roles:
# | Name                                          | Created    |
# | AmazonSageMaker-ExecutionRole-20240115T093045 | 2024-01-15 |

# 2. Attach the policy
./setup-iam.sh --attach AmazonSageMaker-ExecutionRole-20240115T093045

# 3. Verify
./setup-iam.sh --check AmazonSageMaker-ExecutionRole-20240115T093045
```

---

## Permissions Overview

| Component | AWS Service | Purpose |
|-----------|-------------|---------|
| `setup-iam.sh` | IAM | Create/attach IAM policy |
| `setup-inference-profile.sh` | Bedrock, STS, DataZone | Create/manage inference profiles |
| `minimal_langgraph_agent.ipynb` | Bedrock Runtime | Invoke Claude models |
| `neo4j_langgraph_mcp_agent.ipynb` | Bedrock Runtime | Invoke Claude + MCP Gateway |
| `neo4j_strands_mcp_agent.ipynb` | Bedrock Runtime | Invoke Claude + MCP Gateway |

**Note:** MCP Gateway notebooks authenticate to the gateway using Bearer tokens over HTTPS, not IAM. Gateway credentials come from `.mcp-credentials.json`.

---

## Setup Script Permissions

The `setup-inference-profile.sh` script requires these permissions:

| Action | Purpose |
|--------|---------|
| `sts:GetCallerIdentity` | Get AWS account ID |
| `bedrock:ListInferenceProfiles` | List existing profiles |
| `bedrock:GetInferenceProfile` | Get profile details |
| `bedrock:CreateInferenceProfile` | Create new profiles |
| `bedrock:DeleteInferenceProfile` | Delete profiles (`--delete` flag) |
| `bedrock:ListTagsForResource` | Check tags on profiles |
| `bedrock:TagResource` | Apply tags when creating |
| `bedrock-runtime:Converse` | Test profiles (`--test` flag) |
| `datazone:ListDomains` | Auto-detect DataZone domain (optional) |
| `datazone:ListProjects` | Auto-detect DataZone project (optional) |

### Minimal Policy for Setup Script

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "InferenceProfileManagement",
      "Effect": "Allow",
      "Action": [
        "sts:GetCallerIdentity",
        "bedrock:ListInferenceProfiles",
        "bedrock:GetInferenceProfile",
        "bedrock:CreateInferenceProfile",
        "bedrock:DeleteInferenceProfile",
        "bedrock:ListTagsForResource",
        "bedrock:TagResource"
      ],
      "Resource": "*"
    },
    {
      "Sid": "TestProfile",
      "Effect": "Allow",
      "Action": "bedrock-runtime:Converse",
      "Resource": [
        "arn:aws:bedrock:*::foundation-model/anthropic.*",
        "arn:aws:bedrock:*:*:inference-profile/*",
        "arn:aws:bedrock:*:*:application-inference-profile/*"
      ]
    },
    {
      "Sid": "DataZoneAutoDetect",
      "Effect": "Allow",
      "Action": [
        "datazone:ListDomains",
        "datazone:ListProjects"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Notebook Permissions

All notebooks invoke Claude models through inference profiles:

| Notebook | API Used | IAM Action |
|----------|----------|------------|
| `minimal_langgraph_agent.ipynb` | Converse API | `bedrock-runtime:Converse` |
| `neo4j_langgraph_mcp_agent.ipynb` | Converse API | `bedrock-runtime:Converse` |
| `neo4j_strands_mcp_agent.ipynb` | InvokeModel API | `bedrock-runtime:InvokeModel` |

### Minimal Policy for Notebooks

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BedrockModelInvocation",
      "Effect": "Allow",
      "Action": [
        "bedrock-runtime:Converse",
        "bedrock-runtime:ConverseStream",
        "bedrock-runtime:InvokeModel",
        "bedrock-runtime:InvokeModelWithResponseStream"
      ],
      "Resource": [
        "arn:aws:bedrock:*::foundation-model/anthropic.*",
        "arn:aws:bedrock:*:*:inference-profile/*",
        "arn:aws:bedrock:*:*:application-inference-profile/*"
      ]
    }
  ]
}
```

**Important:** The Converse API internally requires `bedrock:InvokeModel` permission. Denying InvokeModel also denies Converse.

---

## Combined IAM Policy

This comprehensive policy covers the setup script and all notebooks:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "InferenceProfileManagement",
      "Effect": "Allow",
      "Action": [
        "sts:GetCallerIdentity",
        "bedrock:ListInferenceProfiles",
        "bedrock:GetInferenceProfile",
        "bedrock:CreateInferenceProfile",
        "bedrock:DeleteInferenceProfile",
        "bedrock:ListTagsForResource",
        "bedrock:TagResource"
      ],
      "Resource": "*"
    },
    {
      "Sid": "BedrockModelInvocation",
      "Effect": "Allow",
      "Action": [
        "bedrock-runtime:Converse",
        "bedrock-runtime:ConverseStream",
        "bedrock-runtime:InvokeModel",
        "bedrock-runtime:InvokeModelWithResponseStream"
      ],
      "Resource": [
        "arn:aws:bedrock:*::foundation-model/anthropic.*",
        "arn:aws:bedrock:*:*:inference-profile/*",
        "arn:aws:bedrock:*:*:application-inference-profile/*"
      ]
    },
    {
      "Sid": "DataZoneAutoDetect",
      "Effect": "Allow",
      "Action": [
        "datazone:ListDomains",
        "datazone:ListProjects"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Model ID Reference

### Base Model IDs

These work with standard `foundation-model` permissions:

| Model | Model ID |
|-------|----------|
| Claude 3.5 Haiku | `anthropic.claude-3-5-haiku-20241022-v1:0` |
| Claude 3.5 Sonnet v2 | `anthropic.claude-3-5-sonnet-20241022-v2:0` |
| Claude Sonnet 4 | `anthropic.claude-sonnet-4-20250514-v1:0` |
| Claude Sonnet 4.5 | `anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Claude Haiku 4.5 | `anthropic.claude-haiku-4-5-20251001-v1:0` |
| Claude Opus 4.5 | `anthropic.claude-opus-4-5-20251101-v1:0` |

### Cross-Region Inference Profiles

| Format | Example | IAM Resource ARN |
|--------|---------|------------------|
| `us.anthropic.claude-*` | `us.anthropic.claude-sonnet-4-20250514-v1:0` | `arn:aws:bedrock:REGION:ACCOUNT:inference-profile/us.anthropic.*` |
| `eu.anthropic.claude-*` | `eu.anthropic.claude-sonnet-4-5-20250929-v1:0` | `arn:aws:bedrock:REGION:ACCOUNT:inference-profile/eu.anthropic.*` |

### Script Model Keys

The `setup-inference-profile.sh` script uses these shortcuts:

| Key | Model |
|-----|-------|
| `haiku` | Claude 3.5 Haiku |
| `sonnet` | Claude 3.5 Sonnet v2 |
| `sonnet4` | Claude Sonnet 4 |
| `sonnet45` | Claude Sonnet 4.5 |

---

## SageMaker Studio Setup

### Option 1: Modify Existing Execution Role

1. Go to **IAM Console** > **Roles**
2. Find your SageMaker execution role (e.g., `AmazonSageMaker-ExecutionRole-*`)
3. Click **Add permissions** > **Create inline policy**
4. Use the [Combined IAM Policy](#combined-iam-policy) above
5. Name it `BedrockLabAccess` and create

### Option 2: Use AWS Managed Policy

Attach the managed policy **AmazonBedrockFullAccess**:

```bash
aws iam attach-role-policy \
  --role-name YOUR_SAGEMAKER_EXECUTION_ROLE \
  --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess
```

### Trust Relationship (if required)

Some setups require Bedrock in the trust relationship:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "sagemaker.amazonaws.com",
          "bedrock.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

---

## SageMaker Unified Studio (DataZone)

SageMaker Unified Studio enforces that Bedrock access goes through **tagged inference profiles** for governance. Direct foundation model calls are blocked by the permissions boundary.

### The Constraint

The `SageMakerStudioProjectUserRolePermissionsBoundary` has conditions:

```json
{
  "Action": ["bedrock:InvokeModel"],
  "Condition": {
    "Null": {
      "bedrock:InferenceProfileArn": "false"
    }
  }
}
```

This means: **You must use an inference profile**, not direct model IDs.

### The Solution: Tagged Inference Profiles

The `setup-inference-profile.sh` script creates application inference profiles with the **required tag**:

```
AmazonBedrockManaged=true
```

This tag is the "secret sauce" that allows SageMaker Unified Studio to access the profiles.

### Creating Profiles for Unified Studio

```bash
# From CLI (not from notebook - permissions boundary blocks this)
./setup-inference-profile.sh haiku

# The script auto-detects DataZone IDs and applies required tags
```

### Using Inference Profiles in Code

```python
from langchain_aws import ChatBedrockConverse

# Use the full ARN (not model ID)
MODEL_ARN = "arn:aws:bedrock:us-west-2:123456789012:application-inference-profile/abc123"

llm = ChatBedrockConverse(
    model=MODEL_ARN,
    provider="anthropic",  # Required when using ARN
    region_name="us-west-2",
    temperature=0,
    # Bypass bedrock:GetInferenceProfile permission requirement
    base_model_id="anthropic.claude-3-5-haiku-20241022-v1:0",
)
```

**Note:** The `base_model_id` parameter tells langchain-aws which model is used, avoiding the `bedrock:GetInferenceProfile` API call that SageMaker Unified Studio roles may lack.

---

## Troubleshooting

### Error: AccessDeniedException on GetInferenceProfile

**Problem:**
```
AccessDeniedException: User is not authorized to perform: bedrock:GetInferenceProfile
```

**Cause:** The `langchain-aws` library calls `bedrock:GetInferenceProfile` to resolve the base model when using an inference profile ARN.

**Solution 1: Add IAM Permission**

```json
{
  "Sid": "BedrockGetInferenceProfile",
  "Effect": "Allow",
  "Action": "bedrock:GetInferenceProfile",
  "Resource": [
    "arn:aws:bedrock:*:*:inference-profile/*",
    "arn:aws:bedrock:*:*:application-inference-profile/*"
  ]
}
```

**Solution 2: Bypass the API Call**

Provide `base_model_id` to skip the GetInferenceProfile call:

```python
llm = ChatBedrockConverse(
    model=INFERENCE_PROFILE_ARN,
    provider="anthropic",
    region_name="us-west-2",
    base_model_id="anthropic.claude-3-5-haiku-20241022-v1:0",  # Bypasses GetInferenceProfile
)
```

### Error: AccessDeniedException on InvokeModel

**Problem:**
```
AccessDeniedException: User is not authorized to perform: bedrock:InvokeModel
on resource: arn:aws:bedrock:us-west-2:123456789012:application-inference-profile/...
```

**Solutions:**
1. Add `application-inference-profile/*` to IAM policy resource
2. Ensure `AmazonBedrockManaged=true` tag is on the profile (for Unified Studio)
3. Verify the profile was created with `setup-inference-profile.sh`

### Error: ResourceNotFoundException

**Problem:**
```
ResourceNotFoundException: Could not resolve the foundation model
```

**Solutions:**
1. Verify model ID spelling and version
2. Check model availability in your region
3. Ensure model access is enabled (some regions require explicit enablement)

### Verifying Permissions

```bash
# Check current identity
aws sts get-caller-identity

# List inference profiles
aws bedrock list-inference-profiles --region us-west-2 --type-equals APPLICATION

# Test model invocation
aws bedrock-runtime converse \
  --model-id "arn:aws:bedrock:us-west-2:123456789012:application-inference-profile/abc123" \
  --region us-west-2 \
  --messages '[{"role":"user","content":[{"text":"Hello"}]}]' \
  --inference-config '{"maxTokens":50}'
```

---

## ARN Reference

| Resource Type | ARN Format |
|---------------|------------|
| Foundation Model | `arn:aws:bedrock:REGION::foundation-model/MODEL_ID` |
| System Inference Profile | `arn:aws:bedrock:REGION:ACCOUNT:inference-profile/PROFILE_ID` |
| Application Inference Profile | `arn:aws:bedrock:REGION:ACCOUNT:application-inference-profile/PROFILE_ID` |

**Notes:**
- Foundation models have no account ID in the ARN (uses `::` double colon)
- System inference profiles are AWS-managed (e.g., `us.anthropic.claude-*` for cross-region)
- Application inference profiles are user-created via CLI, SDK, or Bedrock IDE

---

## Sources

- [Identity-based policy examples for Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/security_iam_id-based-policy-examples.html)
- [Actions, resources, and condition keys for Amazon Bedrock](https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonbedrock.html)
- [How Amazon Bedrock works with IAM](https://docs.aws.amazon.com/bedrock/latest/userguide/security_iam_service-with-iam.html)
- [AWS managed policies for Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/security-iam-awsmanpol.html)
- [Prerequisites for inference profiles](https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-prereq.html)
- [Create an application inference profile](https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-create.html)
- [CreateInferenceProfile API Reference](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_CreateInferenceProfile.html)
- [Converse API Reference](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html)
- [InvokeModel API Reference](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_InvokeModel.html)
- [Simplified model access in Amazon Bedrock](https://aws.amazon.com/blogs/security/simplified-amazon-bedrock-model-access/)
- [Implementing least privilege access for Amazon Bedrock](https://aws.amazon.com/blogs/security/implementing-least-privilege-access-for-amazon-bedrock/)
- [Configure fine-grained access to Amazon Bedrock models using SageMaker Unified Studio](https://aws.amazon.com/blogs/machine-learning/configure-fine-grained-access-to-amazon-bedrock-models-using-amazon-sagemaker-unified-studio/)
- [Actions, resources, and condition keys for Amazon DataZone](https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazondatazone.html)
