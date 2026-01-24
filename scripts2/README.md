# SageMaker Unified Studio CloudFormation Templates

CloudFormation templates to deploy an AWS SageMaker Unified Studio domain with VPC infrastructure, broad workshop permissions, and an "All Capabilities" project profile.

## Prerequisites

- [Rain](https://github.com/aws-cloudformation/rain) CLI installed
- AWS credentials configured
- IAM Identity Center enabled (optional, for SSO)

## Templates

| File | Description |
|------|-------------|
| `sagemaker-unified-studio-vpc.yaml` | VPC with 3 AZs, NAT gateways, VPC endpoints |
| `sagemaker-unified-studio-domain.yaml` | DataZone V2 domain with broad workshop IAM roles |
| `sagemaker-unified-studio-project-profile.yaml` | All Capabilities project profile |
| `setup-inference-profiles.sh` | Creates Bedrock inference profiles with secret sauce tags |

## Quick Start

```bash
# 1. Deploy CloudFormation (VPC, Domain, Project Profile)
./deploy.sh cfn

# 2. Create a project in SageMaker Unified Studio (via console)
#    Go to the Portal URL from outputs

# 3. Set up inference profiles
./deploy.sh inference

# Show all outputs
./deploy.sh outputs

# Tear down CloudFormation only
./deploy.sh delete-cfn

# Tear down everything (inference profiles + CloudFormation)
./deploy.sh delete
```

## Deploy Commands

| Command | Description |
|---------|-------------|
| `./deploy.sh cfn` | Deploy CloudFormation only (VPC, Domain, Project Profile) |
| `./deploy.sh deploy` | Same as `cfn` with reminder for inference setup |
| `./deploy.sh inference` | Set up Bedrock inference profiles |
| `./deploy.sh status` | Show stack and inference profile status |
| `./deploy.sh outputs` | Show all stack outputs and inference profiles |
| `./deploy.sh delete-cfn` | Delete CloudFormation stacks only |
| `./deploy.sh delete` | Delete everything (inference profiles + CloudFormation) |

## Inference Profiles (The Secret Sauce)

Bedrock inference profiles require special tags to be visible in SageMaker Unified Studio:

```
AmazonBedrockManaged=true    ← THE KEY!
AmazonDataZoneProject=xxx
AmazonDataZoneDomain=dzd-xxx
```

### Available Models (January 2026)

| Model | ID | Description |
|-------|-----|-------------|
| `haiku` | claude-3-5-haiku-20241022 | Fast, cheap - good for testing |
| `sonnet` | claude-3-5-sonnet-20241022-v2 | Balanced |
| `sonnet4` | claude-sonnet-4-20250514 | Capable |
| `sonnet45` | claude-sonnet-4-5-20250929 | Recommended |
| `opus` | claude-opus-4-5-20251101 | Most intelligent |

### Inference Profile Commands

```bash
# Create all profiles
./setup-inference-profiles.sh

# Create specific model
./setup-inference-profiles.sh sonnet

# Test a profile
./setup-inference-profiles.sh --test haiku

# List profiles
./setup-inference-profiles.sh --list

# Delete all
./setup-inference-profiles.sh --delete-all
```

### Using in Notebooks

After creating profiles, copy the output to your notebook:

```python
MODEL = "sonnet"
INFERENCE_PROFILE_ARN = "arn:aws:bedrock:us-west-2:123456789:application-inference-profile/xxx"
```

Or source the generated env file:

```bash
source .inference-profile-sonnet.env
```

## What Gets Created

### VPC
- VPC (10.0.0.0/16)
- 3 public subnets + 3 private subnets
- Internet Gateway + 3 NAT Gateways
- VPC Endpoints: S3, STS, CloudWatch Logs, DataZone, SageMaker, Bedrock, Glue, Athena, Lake Formation

### IAM Roles (Workshop-Broad Permissions)

| Role | Purpose | Key Policies |
|------|---------|--------------|
| `AmazonSageMakerDomainExecution-*` | Domain execution | SageMaker, Bedrock, S3, Glue, Athena Full Access |
| `AmazonSageMakerDomainService-*` | Domain service | SageMaker, Bedrock Full Access |
| `AmazonSageMakerProvisioning-*` | Blueprint provisioning | **AdministratorAccess** |
| `AmazonSageMakerManageAccess-*` | Redshift/Lakehouse | Redshift, LakeFormation, S3 Full Access |
| `WorkshopParticipant-*` | Participant role | All major service full access |

### Workshop Lab Policy

Comprehensive policy attached to all roles with permissions for:
- **Bedrock**: Full access + inference profiles
- **DataZone**: Full access
- **SageMaker**: Full access
- **S3/Glue/Athena**: Full access
- **Redshift/EMR/LakeFormation**: Full access
- **Lambda/Step Functions**: Full access
- **CloudFormation/IAM**: Create roles and stacks
- **Secrets Manager/KMS**: Read/write secrets
- **CodeCommit/CodeBuild**: Full access
- **CloudWatch/SNS/SQS**: Full access

### Project Profile
All capabilities enabled:
- MLExperiments
- Workflows
- LakehouseCatalog
- EmrOnEc2
- Tooling
- RedshiftServerless
- LakeHouseDatabase
- EmrServerless
- AmazonBedrockGenerativeAI

### Inference Profiles
Application inference profiles for (January 2026):
- Claude 3.5 Haiku
- Claude 3.5 Sonnet v2
- Claude Sonnet 4
- Claude Sonnet 4.5
- Claude Opus 4.5 (newest)

## Outputs

After deployment:

```bash
./deploy.sh outputs
```

Key outputs:
- `DomainPortalUrl` - URL to access SageMaker Unified Studio
- `WorkshopParticipantRoleArn` - Role ARN for workshop participants
- `WorkshopLabPolicyArn` - Policy ARN with all permissions

## Security Note

These templates use **intentionally broad permissions** for workshop/lab environments. For production use, restrict permissions following the principle of least privilege.

## Technical Notes

- **IAM Policy Version `2012-10-17`**: This is the IAM policy language version (not a date). It's the current and only version of the AWS IAM policy language specification.
- **DomainVersion: V2**: Required for SageMaker Unified Studio (vs V1 for legacy DataZone).
- **IdcInstanceArn**: Optional parameter added for explicit IAM Identity Center instance specification.
