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
