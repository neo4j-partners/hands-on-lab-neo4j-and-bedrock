# IAM Permissions for Neo4j + Bedrock Workshop

## Account Admin: One-Time Setup Required

**Before workshop participants can use Anthropic Claude models**, an account admin must enable model access. This is a one-time setup per AWS account.

### Option 1: AWS Console

1. Sign in to AWS Console with admin credentials
2. Go to **Amazon Bedrock → Model catalog**
3. Select any **Anthropic Claude model**
4. Complete the **use case form** (company name, website, intended use)
5. Submit - access is granted immediately

### Option 2: AWS CLI

```bash
aws bedrock put-use-case-for-model-access \
  --region us-west-2 \
  --form-data $(echo -n '{
    "companyName": "Your Company",
    "companyWebsite": "https://yourcompany.com",
    "intendedUsers": "Workshop participants",
    "industryOption": "Technology",
    "useCases": "Educational workshop on building AI agents with Bedrock"
  }' | base64)
```

Requires admin permissions: `bedrock:PutUseCaseForModelAccess`, `aws-marketplace:Subscribe`, `aws-marketplace:ViewSubscriptions`

### Automated Setup

The script `scripts3/setup-workshop-aws-permissions.sh` has been updated to automatically add Bedrock and Marketplace permissions to SageMaker execution roles. However, the Anthropic use case form submission still requires manual admin action (Option 1 or 2 above).

---

## SageMaker Execution Role Permissions

**The script `scripts3/setup-workshop-aws-permissions.sh` automatically adds these permissions** to all SageMaker execution roles it finds. The CLI commands below are for manual setup or troubleshooting only.

### Required Permissions

| Permission | Purpose | Used In |
|------------|---------|---------|
| `bedrock:ListFoundationModels` | List available models | Lab 4 |
| `bedrock:GetFoundationModel` | Get model details | Lab 4 |
| `bedrock-runtime:Converse` | Call Bedrock models (Converse API) | Lab 4, Lab 5 |
| `bedrock-runtime:InvokeModel` | Call Bedrock models (non-streaming) | Lab 4, embeddings |
| `bedrock-runtime:InvokeModelWithResponseStream` | Call Bedrock models (streaming) | Lab 5 MCP agents |
| `aws-marketplace:ViewSubscriptions` | View model subscriptions | First model invocation |
| `aws-marketplace:Subscribe` | Subscribe to models | First model invocation |

### Manual Setup (if script not used)

Run these in **AWS CloudShell** only if you didn't use the setup script.

### 1. Add Bedrock Permissions

```bash
aws iam put-role-policy \
    --role-name SageMakerExecutionRole-Neo4jWorkshop \
    --policy-name BedrockAccess \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "bedrock:ListFoundationModels",
                    "bedrock:GetFoundationModel",
                    "bedrock-runtime:Converse",
                    "bedrock-runtime:ConverseStream",
                    "bedrock-runtime:InvokeModel",
                    "bedrock-runtime:InvokeModelWithResponseStream"
                ],
                "Resource": "*"
            }
        ]
    }'
```

### 2. Add Marketplace Permissions

```bash
aws iam put-role-policy \
    --role-name SageMakerExecutionRole-Neo4jWorkshop \
    --policy-name MarketplaceAccess \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "aws-marketplace:ViewSubscriptions",
                    "aws-marketplace:Subscribe"
                ],
                "Resource": "*"
            }
        ]
    }'
```

### Verify Permissions Added

```bash
aws iam list-role-policies --role-name SageMakerExecutionRole-Neo4jWorkshop
```

### View Policy Details

```bash
aws iam get-role-policy \
    --role-name SageMakerExecutionRole-Neo4jWorkshop \
    --policy-name BedrockAccess

aws iam get-role-policy \
    --role-name SageMakerExecutionRole-Neo4jWorkshop \
    --policy-name MarketplaceAccess
```

## Notes

- Replace `SageMakerExecutionRole-Neo4jWorkshop` with your actual role name if different
- Find your role name in: SageMaker Console > Domain > User > Execution role
- Changes take effect immediately (no restart needed)
