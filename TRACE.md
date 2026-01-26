# Tracing and Testing IAM Permissions for Lab 4

This guide helps you verify the exact IAM permissions needed to run the Lab 4 notebooks.

## Method 1: IAM Policy Simulator (No Role Changes Required)

Test if your current role/user has the required permissions without actually running the notebooks.

### Step 1: Get Your Current Identity

```bash
aws sts get-caller-identity
```

Note the ARN - you'll use this as the `--policy-source-arn`.

### Step 2: Test Bedrock Permissions

Test the specific model from CONFIG.txt (`us.anthropic.claude-3-sonnet-20240229-v1:0`):

```bash
# Test ListFoundationModels (needed by test_bedrock_permissions.ipynb)
aws iam simulate-principal-policy \
    --policy-source-arn "arn:aws:iam::637423635065:user/unusual-moon-69887" \
    --action-names "bedrock:ListFoundationModels" \
    --resource-arns "*"

# Test Converse API (used by both notebooks)
aws iam simulate-principal-policy \
    --policy-source-arn "arn:aws:iam::637423635065:user/unusual-moon-69887" \
    --action-names "bedrock-runtime:Converse" \
    --resource-arns "arn:aws:bedrock:us-west-2::foundation-model/us.anthropic.claude-3-sonnet-20240229-v1:0"

# Test all Bedrock permissions at once
aws iam simulate-principal-policy \
    --policy-source-arn "arn:aws:iam::637423635065:user/unusual-moon-69887" \
    --action-names \
        "bedrock:ListFoundationModels" \
        "bedrock:GetFoundationModel" \
        "bedrock-runtime:Converse" \
        "bedrock-runtime:InvokeModel" \
    --resource-arns "*"
```

### Step 3: Test Marketplace Permissions

```bash
aws iam simulate-principal-policy \
    --policy-source-arn "arn:aws:iam::637423635065:user/unusual-moon-69887" \
    --action-names \
        "aws-marketplace:ViewSubscriptions" \
        "aws-marketplace:Subscribe" \
    --resource-arns "*"
```

### Interpreting Results

Look for `EvalDecision` in the output:
- `"allowed"` - Permission granted
- `"implicitDeny"` - No policy grants this permission
- `"explicitDeny"` - A policy explicitly denies this

---

## Method 2: Create Minimal Test Role and Run Notebooks

This creates a role with ONLY the documented permissions so you can verify nothing is missing.

### Step 1: Create the Trust Policy

Save as `trust-policy.json`:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "sagemaker.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

### Step 2: Create the Minimal Permissions Policy

Save as `lab4-minimal-policy.json`:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "BedrockAccess",
            "Effect": "Allow",
            "Action": [
                "bedrock:ListFoundationModels",
                "bedrock:GetFoundationModel",
                "bedrock-runtime:Converse",
                "bedrock-runtime:InvokeModel"
            ],
            "Resource": "*"
        },
        {
            "Sid": "MarketplaceAccess",
            "Effect": "Allow",
            "Action": [
                "aws-marketplace:ViewSubscriptions",
                "aws-marketplace:Subscribe"
            ],
            "Resource": "*"
        }
    ]
}
```

### Step 3: Create the Test Role

```bash
# Create the role
aws iam create-role \
    --role-name Lab4-MinimalTest-Role \
    --assume-role-policy-document file://trust-policy.json \
    --description "Minimal permissions test for Lab 4 notebooks"

# Attach the inline policy
aws iam put-role-policy \
    --role-name Lab4-MinimalTest-Role \
    --policy-name Lab4MinimalPermissions \
    --policy-document file://lab4-minimal-policy.json
```

### Step 4: Create a SageMaker User Profile with the Test Role

```bash
# List existing domains
aws sagemaker list-domains

# Create a new user profile with the minimal role (replace DOMAIN_ID)
aws sagemaker create-user-profile \
    --domain-id YOUR_DOMAIN_ID \
    --user-profile-name lab4-permission-tester \
    --user-settings '{
        "ExecutionRole": "arn:aws:iam::637423635065:role/Lab4-MinimalTest-Role"
    }'
```

### Step 5: Test the Notebooks

1. Open SageMaker Studio with the `lab4-permission-tester` profile
2. Run `test_bedrock_permissions.ipynb`
3. Run `basic_langgraph_agent.ipynb`

If any step fails with `AccessDeniedException`, note the exact error - it tells you which permission is missing.

### Step 6: Cleanup

```bash
# Delete the test user profile
aws sagemaker delete-user-profile \
    --domain-id YOUR_DOMAIN_ID \
    --user-profile-name lab4-permission-tester

# Delete the test role
aws iam delete-role-policy \
    --role-name Lab4-MinimalTest-Role \
    --policy-name Lab4MinimalPermissions

aws iam delete-role \
    --role-name Lab4-MinimalTest-Role
```

---

## Method 3: Quick Python Permission Test

Run this Python script to test permissions without running the full notebooks:

```python
#!/usr/bin/env python3
"""Test minimum Bedrock permissions for Lab 4."""
import boto3
from botocore.exceptions import ClientError

REGION = "us-west-2"
MODEL_ID = "us.anthropic.claude-3-sonnet-20240229-v1:0"

def test_permission(name, test_func):
    """Test a single permission."""
    try:
        test_func()
        print(f"✓ {name}")
        return True
    except ClientError as e:
        error_code = e.response['Error']['Code']
        print(f"✗ {name}: {error_code}")
        return False

def main():
    print(f"Testing permissions for model: {MODEL_ID}")
    print(f"Region: {REGION}")
    print("-" * 50)

    bedrock = boto3.client("bedrock", region_name=REGION)
    bedrock_runtime = boto3.client("bedrock-runtime", region_name=REGION)

    results = []

    # Test 1: ListFoundationModels
    results.append(test_permission(
        "bedrock:ListFoundationModels",
        lambda: bedrock.list_foundation_models(byProvider="Anthropic")
    ))

    # Test 2: GetFoundationModel
    results.append(test_permission(
        "bedrock:GetFoundationModel",
        lambda: bedrock.get_foundation_model(modelIdentifier="anthropic.claude-3-sonnet-20240229-v1:0")
    ))

    # Test 3: Converse API
    results.append(test_permission(
        "bedrock-runtime:Converse",
        lambda: bedrock_runtime.converse(
            modelId=MODEL_ID,
            messages=[{"role": "user", "content": [{"text": "Hi"}]}],
            inferenceConfig={"maxTokens": 5}
        )
    ))

    print("-" * 50)
    passed = sum(results)
    print(f"Result: {passed}/{len(results)} permissions verified")

    if passed == len(results):
        print("\n✓ All permissions for Lab 4 are configured correctly!")
    else:
        print("\n✗ Some permissions are missing. Check IAM_PERMS.md for required permissions.")

if __name__ == "__main__":
    main()
```

Save as `test_permissions.py` and run:
```bash
python test_permissions.py
```

---

## Expected Permissions for Lab 4

| Permission | Required By | Notes |
|------------|-------------|-------|
| `bedrock:ListFoundationModels` | test_bedrock_permissions.ipynb | Lists available models |
| `bedrock:GetFoundationModel` | Optional | Model metadata |
| `bedrock-runtime:Converse` | Both notebooks | **Critical** - calls the model |
| `aws-marketplace:ViewSubscriptions` | First model call | May be needed for Anthropic models |
| `aws-marketplace:Subscribe` | First model call | May be needed for Anthropic models |

## Troubleshooting

### "AccessDeniedException" on Converse

1. Check if Anthropic use case form was submitted (admin task)
2. Verify `aws-marketplace:*` permissions are attached
3. Confirm the model ID is correct for your region

### "ValidationException" on model ID

Cross-region inference profiles use `us.anthropic.*` format. Make sure:
- You're using `us-west-2` region
- Model ID matches CONFIG.txt exactly

### Policy Simulator shows "allowed" but notebook fails

The simulator doesn't check:
- Service quotas
- Model access (Anthropic use case form)
- Resource-based policies

Run the actual notebooks with a minimal role (Method 2) for definitive testing.
