# IAM Permissions for Neo4j + Bedrock Workshop

Additional permissions needed for your SageMaker execution role beyond the default.

## Required Permissions

| Permission | Purpose | Used In |
|------------|---------|---------|
| `bedrock:InvokeModel` | Call Bedrock models (non-streaming) | Lab 4, embeddings |
| `bedrock:InvokeModelWithResponseStream` | Call Bedrock models (streaming) | Lab 5 MCP agents |

## AWS CLI Commands

Run these in **AWS CloudShell** to add permissions to your SageMaker role.

### Add Bedrock Permissions

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
                    "bedrock:InvokeModel",
                    "bedrock:InvokeModelWithResponseStream"
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
```

## Notes

- Replace `SageMakerExecutionRole-Neo4jWorkshop` with your actual role name if different
- Find your role name in: SageMaker Console > Domain > User > Execution role
- Changes take effect immediately (no restart needed)
