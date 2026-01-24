# Simple SageMaker Studio (Classic)

A simple CloudFormation template for SageMaker AI Studio with Bedrock access. No DataZone, no SSO complexity - just JupyterLab.

## Quick Start

```bash
./deploy.sh deploy
```

Then:
1. Go to AWS Console > SageMaker > Studio
2. Select domain `workshop-studio`
3. Select user `workshop-user`
4. Click **Open Studio**

## What You Get

- SageMaker Studio domain with IAM auth (uses your AWS credentials)
- Pre-configured user profile
- Execution role with:
  - Full Bedrock access
  - Full SageMaker access
  - S3 read/write
- VPC with NAT gateway for internet access

## Commands

```bash
./deploy.sh deploy   # Deploy everything
./deploy.sh outputs  # Show outputs
./deploy.sh status   # Check stack status
./deploy.sh delete   # Tear down
```

## Using Bedrock in Notebooks

```python
import boto3

bedrock = boto3.client('bedrock-runtime')

response = bedrock.converse(
    modelId='anthropic.claude-3-5-sonnet-20241022-v2:0',
    messages=[{'role': 'user', 'content': [{'text': 'Hello!'}]}]
)

print(response['output']['message']['content'][0]['text'])
```

## Comparison: Classic vs Unified Studio

| Feature | Classic Studio | Unified Studio |
|---------|----------------|----------------|
| Setup time | ~10 min | ~30+ min |
| Auth | IAM (your credentials) | IAM Identity Center (SSO) |
| Jupyter | Yes | Yes |
| Bedrock | Yes | Yes |
| DataZone/Governance | No | Yes |
| Project Profiles | No | Yes |
| Complexity | Low | High |

**Use Classic** when you just need notebooks.
**Use Unified Studio** when you need data governance, catalogs, and collaboration features.
