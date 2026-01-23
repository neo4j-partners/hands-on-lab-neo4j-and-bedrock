# Setup Scripts for Bedrock Agents Lab

Scripts for workshop organizers to provision AWS accounts for the Bedrock Agents Lab.

## Overview

| Script | Purpose |
|--------|---------|
| `setup-datazone.sh` | Create DataZone domain and project (CLI) |
| `setup-bedrock-lab-org.sh` | Provision multiple accounts from org root |
| `datazone-lab-stack.yaml` | CloudFormation template for full setup |

## Quick Start

### Option 1: CloudFormation (Recommended for single account)

```bash
aws cloudformation create-stack \
  --stack-name bedrock-agents-lab \
  --template-body file://datazone-lab-stack.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-west-2
```

This creates:
- DataZone domain and project
- IAM roles and policies
- Inference profiles (haiku, sonnet, sonnet4, sonnet45)

### Option 2: Shell Scripts (For multiple accounts)

```bash
# Step 1: Create DataZone domain/project
./setup-datazone.sh

# Step 2: Add users
./setup-datazone.sh --add-user user/workshop-user-1

# Step 3: Provision accounts from org root
./setup-bedrock-lab-org.sh 123456789012 234567890123
```

## Script Details

### setup-datazone.sh

Creates DataZone domain and project for SageMaker Unified Studio.

```bash
# Create domain and project
./setup-datazone.sh

# Check status
./setup-datazone.sh --status

# Add workshop attendees
./setup-datazone.sh --add-user user/USERNAME
./setup-datazone.sh --add-role arn:aws:iam::123456789012:role/RoleName

# List members
./setup-datazone.sh --list-users

# Cleanup
./setup-datazone.sh --cleanup
```

**Environment Variables:**
- `AWS_REGION` - Region (default: us-west-2)
- `DATAZONE_DOMAIN_NAME` - Domain name (default: bedrock-lab-domain)
- `DATAZONE_PROJECT_NAME` - Project name (default: bedrock-lab-project)

### setup-bedrock-lab-org.sh

Run from AWS Organizations management account to provision member accounts.

```bash
# Setup single account
./setup-bedrock-lab-org.sh 123456789012

# Setup multiple accounts
./setup-bedrock-lab-org.sh 123456789012 234567890123 345678901234

# Setup from file (one account ID per line)
./setup-bedrock-lab-org.sh --file workshop-accounts.txt

# Check account status
./setup-bedrock-lab-org.sh --check 123456789012

# List org accounts
./setup-bedrock-lab-org.sh --list

# Cleanup after workshop
./setup-bedrock-lab-org.sh --cleanup 123456789012
```

**What it creates in each account:**
- `BedrockLabRole` - IAM role for workshop attendees
- `BedrockAgentsLabPolicy` - Permissions for Bedrock and DataZone
- Inference profiles with proper tags for Unified Studio

**Environment Variables:**
- `AWS_REGION` - Region (default: us-west-2)
- `ORG_ACCESS_ROLE` - Role to assume into member accounts (default: OrganizationAccountAccessRole)

### datazone-lab-stack.yaml

CloudFormation template for complete setup.

**Parameters:**
| Parameter | Default | Description |
|-----------|---------|-------------|
| `DomainName` | bedrock-lab-domain | DataZone domain name |
| `ProjectName` | bedrock-lab-project | DataZone project name |
| `CreateInferenceProfiles` | true | Whether to create inference profiles |

**Resources Created:**
- `DataZoneDomainExecutionRole` - Required for DataZone
- `BedrockLabRole` - Workshop attendee role
- `BedrockAgentsLabPolicy` - Permissions policy
- `DataZoneDomain` - DataZone domain
- `DataZoneProject` - DataZone project
- Lambda function to create inference profiles (optional)

**Deploy:**
```bash
aws cloudformation create-stack \
  --stack-name bedrock-agents-lab \
  --template-body file://datazone-lab-stack.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-west-2

# With custom parameters
aws cloudformation create-stack \
  --stack-name bedrock-agents-lab \
  --template-body file://datazone-lab-stack.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters \
    ParameterKey=DomainName,ParameterValue=my-workshop-domain \
    ParameterKey=ProjectName,ParameterValue=my-workshop-project \
  --region us-west-2
```

**Check status:**
```bash
aws cloudformation describe-stacks \
  --stack-name bedrock-agents-lab \
  --query 'Stacks[0].Outputs' \
  --region us-west-2
```

**Delete:**
```bash
aws cloudformation delete-stack \
  --stack-name bedrock-agents-lab \
  --region us-west-2
```

## Workflow for Workshop Organizers

### Before the Workshop

1. **Create DataZone/Unified Studio** (choose one method):

   **CloudFormation:**
   ```bash
   aws cloudformation create-stack \
     --stack-name bedrock-agents-lab \
     --template-body file://datazone-lab-stack.yaml \
     --capabilities CAPABILITY_NAMED_IAM
   ```

   **CLI:**
   ```bash
   ./setup-datazone.sh
   ```

2. **Add attendees to the project:**
   ```bash
   ./setup-datazone.sh --add-user user/attendee-1
   ./setup-datazone.sh --add-user user/attendee-2
   ```

3. **Verify setup:**
   ```bash
   ./setup-datazone.sh --status
   ```

### After the Workshop

```bash
# CloudFormation
aws cloudformation delete-stack --stack-name bedrock-agents-lab

# CLI
./setup-datazone.sh --cleanup
./setup-bedrock-lab-org.sh --cleanup 123456789012
```

## Troubleshooting

### Domain creation fails
- Ensure you have `datazone:CreateDomain` permission
- Check if domain name is unique in the region

### Inference profiles not visible in Unified Studio
- Verify `AmazonBedrockManaged=true` tag is set
- Verify `AmazonDataZoneDomain` and `AmazonDataZoneProject` tags match

### setup-inference-profile.sh fails with "DataZone IDs not detected"
The inference profile script in `Lab_4_SageMaker_Setup/` requires DataZone to be set up first. Profiles created without DataZone tags won't be visible in SageMaker Unified Studio.

**Fix:** Run one of these setup options first:
```bash
# Option 1: CloudFormation
aws cloudformation create-stack \
  --stack-name bedrock-agents-lab \
  --template-body file://datazone-lab-stack.yaml \
  --capabilities CAPABILITY_NAMED_IAM

# Option 2: CLI
./setup-datazone.sh
```

### Can't assume role into member account
- Verify `OrganizationAccountAccessRole` exists in member account
- Ensure you're running from the org management account

### Model not available
- Some models may not be available in all regions
- Check Bedrock model access in the AWS console
