# Lab 4 Permission Test Scripts

Scripts to test and validate IAM permissions needed for Lab 4 notebooks.

## Quick Start (CloudShell)

1. Upload and extract this directory to CloudShell
2. Make scripts executable:
   ```bash
   chmod +x *.sh
   ```
3. Run the permission test:
   ```bash
   ./01-get-identity.sh
   ./02-test-permissions.sh
   ```
4. Download `permission-test-results.txt`

## Scripts

| Script | Purpose |
|--------|---------|
| `01-get-identity.sh` | Gets AWS identity, exports `POLICY_SOURCE_ARN` |
| `02-test-permissions.sh` | Tests all required permissions via IAM Policy Simulator |
| `03-create-minimal-role.sh` | Creates a test role with only documented permissions |
| `04-cleanup-minimal-role.sh` | Deletes the test role |

## Policy Files

| File | Purpose |
|------|---------|
| `trust-policy.json` | Trust policy for SageMaker to assume the role |
| `lab4-minimal-policy.json` | Minimal permissions needed for Lab 4 |

## Testing Workflow

### Method 1: Policy Simulator (Quick)
```bash
source ./01-get-identity.sh
./02-test-permissions.sh
```

Results saved to `permission-test-results.txt`.

### Method 2: Create Minimal Role (Thorough)
```bash
source ./01-get-identity.sh
./03-create-minimal-role.sh

# Then create SageMaker user profile with the new role
# Run the notebooks
# If they work, permissions are complete

./04-cleanup-minimal-role.sh
```

## Required Permissions to Run These Scripts

The user running these scripts needs:
- `sts:GetCallerIdentity` - Get current identity
- `iam:SimulatePrincipalPolicy` - Test permissions (Method 1)
- `iam:CreateRole`, `iam:PutRolePolicy`, `iam:DeleteRole`, `iam:DeleteRolePolicy` - Create test role (Method 2)
