# Fix IAM Permissions for SageMaker Bedrock Access

If your SageMaker notebook gets `AccessDeniedException` when calling Bedrock, add these permissions to your execution role.

## Find Your Role Name

```bash
# List SageMaker execution roles
aws iam list-roles \
  --query "Roles[?contains(RoleName, 'SageMaker') && contains(RoleName, 'Execution')].RoleName" \
  --output text

# Or find roles with 'Workshop' in the name
aws iam list-roles \
  --query "Roles[?contains(RoleName, 'Workshop')].RoleName" \
  --output text
```

Set your role name:
```bash
ROLE_NAME="SageMakerExecutionRole-Neo4jWorkshop"
```

## Add Bedrock Permissions

**Error:** `not authorized to perform: bedrock:ListFoundationModels`

```bash
aws iam put-role-policy \
  --role-name $ROLE_NAME \
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
          "bedrock-runtime:InvokeModel",
          "bedrock-runtime:InvokeModelWithResponseStream"
        ],
        "Resource": "*"
      }
    ]
  }'
```

## Add Marketplace Permissions

**Error:** `Model access is denied due to IAM user or service role is not authorized to perform the required AWS Marketplace actions`

```bash
aws iam put-role-policy \
  --role-name $ROLE_NAME \
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

## Verify Permissions

```bash
# Check policies were added
aws iam get-role-policy --role-name $ROLE_NAME --policy-name BedrockAccess
aws iam get-role-policy --role-name $ROLE_NAME --policy-name MarketplaceAccess

# Get account ID and role ARN
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

# Simulate permissions
aws iam simulate-principal-policy \
  --policy-source-arn $ROLE_ARN \
  --action-names bedrock:ListFoundationModels aws-marketplace:ViewSubscriptions \
  --query 'EvaluationResults[].{Action:EvalActionName,Decision:EvalDecision}'
```

Wait ~2 minutes for permissions to propagate before retrying the notebook.
