# Setup Scripts - Fixes Applied

Summary of changes made to ensure setup scripts work correctly with SageMaker Unified Studio.


---

## Fix 1: Create SageMaker Unified Studio (V2) Domains

**Problem:** Scripts were creating DataZone V1 domains instead of SageMaker Unified Studio (V2) domains. Users saw "Upgrade your domain to Amazon SageMaker Unified Studio" message in the console.

**Impact:** V1 domains don't have full SageMaker Unified Studio integration.

### Files Changed:

**`setup-scripts/datazone-lab-stack.yaml`** (line 120)
```yaml
# Added DomainVersion: V2
DataZoneDomain:
  Type: AWS::DataZone::Domain
  Properties:
    Name: !Ref DomainName
    Description: Bedrock Agents Lab workshop domain for SageMaker Unified Studio
    DomainExecutionRole: !GetAtt DataZoneDomainExecutionRole.Arn
    DomainVersion: V2  # <-- ADDED
```

**`setup-scripts/setup-datazone.sh`** (line 134)
```bash
# Added --domain-version V2
aws datazone create-domain \
    --region "$REGION" \
    --name "$DOMAIN_NAME" \
    --description "Bedrock Agents Lab workshop domain" \
    --domain-version V2 \  # <-- ADDED
    --output json
```

---



## Fix 2: Expanded IAM Permissions for SageMaker Unified Studio V2

**Problem:** Users encountered `AccessDeniedException` when trying to:
- Create project memberships (`datazone:CreateProjectMembership`)
- Access project profiles (`ram:GetResourceShareAssociations`)
- Create projects within domains
- Use SageMaker Unified Studio features

**Root Cause:** SageMaker Unified Studio V2 requires significantly more permissions than V1 DataZone, including:
- Full DataZone access (not just list operations)
- AWS RAM (Resource Access Manager) for project profiles
- IAM role operations for service roles
- S3 access for blueprints
- Full SageMaker access

### Files Changed:

**`setup-scripts/setup-bedrock-lab-org.sh`** - Updated PERMISSIONS_POLICY:
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
      "Sid": "DataZoneFullAccess",
      "Effect": "Allow",
      "Action": ["datazone:*"],
      "Resource": "*"
    },
    {
      "Sid": "RAMForProjectProfiles",
      "Effect": "Allow",
      "Action": [
        "ram:GetResourceShareAssociations",
        "ram:GetResourceShares",
        "ram:ListResources",
        "ram:ListResourceSharePermissions"
      ],
      "Resource": "*"
    },
    {
      "Sid": "IAMForServiceRoles",
      "Effect": "Allow",
      "Action": [
        "iam:GetRole",
        "iam:PassRole",
        "iam:ListRoles",
        "iam:CreateServiceLinkedRole"
      ],
      "Resource": "*"
    },
    {
      "Sid": "S3ForBlueprints",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SageMakerUnifiedStudio",
      "Effect": "Allow",
      "Action": ["sagemaker:*"],
      "Resource": "*"
    }
  ]
}
```

**`Lab_4_SageMaker_Setup/setup-iam.sh`** - Same policy document applied

**`setup-scripts/datazone-lab-stack.yaml`** - BedrockLabPolicy updated with same permissions

### New Permissions Added:

| Permission | Purpose |
|------------|---------|
| `datazone:*` | Full DataZone access (was limited to list operations) |
| `ram:GetResourceShareAssociations` | Required for project profiles |
| `ram:GetResourceShares` | Required for project profiles |
| `ram:ListResources` | Required for project profiles |
| `ram:ListResourceSharePermissions` | Required for project profiles |
| `iam:GetRole` | Service role operations |
| `iam:PassRole` | Pass roles to services |
| `iam:ListRoles` | List available roles |
| `iam:CreateServiceLinkedRole` | Create service-linked roles |
| `s3:GetObject/ListBucket/GetBucketLocation` | Access blueprint configurations |
| `sagemaker:*` | Full SageMaker access for Unified Studio |

---

## User Membership

Workshop users must be added to projects. With the `BedrockAgentsLabPolicy` attached (which includes `datazone:*`), users can add themselves.

### Option A: Self-Service via Console (Recommended)

Workshop users can add themselves after logging in:

1. Navigate to **Amazon DataZone** in the AWS Console
2. Click on the domain: `bedrock-lab-domain`
3. Go to **Projects** in the left sidebar
4. Find and click on `bedrock-lab-project`
5. Click **Join project** or **Request membership**
6. Select **PROJECT_CONTRIBUTOR** role

If "Join project" isn't visible, use the CLI method below.

### Option B: Self-Service via CloudShell

Users can add themselves using AWS CloudShell:

```bash
# Get your own identity
MY_ARN=$(aws sts get-caller-identity --query Arn --output text)
echo "Your ARN: $MY_ARN"

# Get domain and project IDs
DOMAIN_ID=$(aws datazone list-domains --query "items[?name=='bedrock-lab-domain'].id" --output text)
PROJECT_ID=$(aws datazone list-projects --domain-identifier $DOMAIN_ID --query "items[?name=='bedrock-lab-project'].id" --output text)

# Add yourself to the project
aws datazone create-project-membership \
    --domain-identifier $DOMAIN_ID \
    --project-identifier $PROJECT_ID \
    --member "userIdentifier=$MY_ARN" \
    --designation PROJECT_CONTRIBUTOR
```

### Option C: Admin Adds User via CLI

If users don't have permissions, an admin can add them:

```bash
# Get domain and project IDs
DOMAIN_ID=$(aws datazone list-domains --query "items[?name=='bedrock-lab-domain'].id" --output text)
PROJECT_ID=$(aws datazone list-projects --domain-identifier $DOMAIN_ID --query "items[?name=='bedrock-lab-project'].id" --output text)

# Add user (replace with actual user ARN or path)
aws datazone create-project-membership \
    --domain-identifier $DOMAIN_ID \
    --project-identifier $PROJECT_ID \
    --member "userIdentifier=arn:aws:iam::123456789012:user/workshop-user-abc123" \
    --designation PROJECT_CONTRIBUTOR
```

### Verify Membership

```bash
aws datazone list-project-memberships \
    --domain-identifier $DOMAIN_ID \
    --project-identifier $PROJECT_ID \
    --output table
```

---

## Automate User Membership

For workshop organizers who need to add multiple users programmatically. These scripts help automate the process of granting project access to workshop participants.

### Batch Add Users from File

**Use case:** You have a list of usernames or ARNs provided by your workshop platform or registration system.

**How it works:** The script reads a text file containing one user identifier per line. Each user is added to the DataZone project as a PROJECT_CONTRIBUTOR. The script skips empty lines and comments (lines starting with `#`).

Create a file `workshop-users.txt` with one user per line:
```
user/workshop-user-1
user/workshop-user-2
arn:aws:iam::123456789012:user/custom-user
# Lines starting with # are ignored
```

Run this script to add all users:
```bash
#!/bin/bash
# add-workshop-users.sh

USERS_FILE="${1:-workshop-users.txt}"
DOMAIN_NAME="${DATAZONE_DOMAIN_NAME:-bedrock-lab-domain}"
PROJECT_NAME="${DATAZONE_PROJECT_NAME:-bedrock-lab-project}"

# Get IDs
DOMAIN_ID=$(aws datazone list-domains --query "items[?name=='${DOMAIN_NAME}'].id" --output text)
PROJECT_ID=$(aws datazone list-projects --domain-identifier $DOMAIN_ID --query "items[?name=='${PROJECT_NAME}'].id" --output text)

echo "Domain: $DOMAIN_ID"
echo "Project: $PROJECT_ID"
echo ""

while IFS= read -r user || [ -n "$user" ]; do
    # Skip empty lines and comments
    [[ -z "$user" || "$user" =~ ^# ]] && continue
    user=$(echo "$user" | xargs)  # trim whitespace

    echo -n "Adding $user... "
    if aws datazone create-project-membership \
        --domain-identifier $DOMAIN_ID \
        --project-identifier $PROJECT_ID \
        --member "userIdentifier=${user}" \
        --designation PROJECT_CONTRIBUTOR 2>/dev/null; then
        echo "OK"
    else
        echo "FAILED"
    fi
done < "$USERS_FILE"
```

Usage:
```bash
chmod +x add-workshop-users.sh
./add-workshop-users.sh workshop-users.txt
```

### Add All IAM Users Matching a Pattern

**Use case:** Your workshop platform automatically creates IAM users with a consistent naming convention (e.g., `workshop-user-1`, `workshop-user-2`, or `lab-participant-abc123`).

**How it works:** The script queries IAM for all users whose username contains the specified pattern, then adds each matching user to the DataZone project. This is useful when you don't have a pre-made list but know the naming pattern used by your workshop platform.

Add all IAM users with names matching a pattern (e.g., `workshop-*`):
```bash
#!/bin/bash
# add-matching-users.sh

PATTERN="${1:-workshop}"
DOMAIN_ID=$(aws datazone list-domains --query "items[?name=='bedrock-lab-domain'].id" --output text)
PROJECT_ID=$(aws datazone list-projects --domain-identifier $DOMAIN_ID --query "items[?name=='bedrock-lab-project'].id" --output text)

echo "Adding users matching: *${PATTERN}*"
echo "Domain: $DOMAIN_ID | Project: $PROJECT_ID"
echo ""

aws iam list-users --query "Users[?contains(UserName, '${PATTERN}')].UserName" --output text | tr '\t' '\n' | while read username; do
    echo -n "Adding user/$username... "
    if aws datazone create-project-membership \
        --domain-identifier $DOMAIN_ID \
        --project-identifier $PROJECT_ID \
        --member "userIdentifier=user/${username}" \
        --designation PROJECT_CONTRIBUTOR 2>/dev/null; then
        echo "OK"
    else
        echo "FAILED"
    fi
done
```

Usage:
```bash
./add-matching-users.sh workshop    # Adds all users containing "workshop"
./add-matching-users.sh lab         # Adds all users containing "lab"
```

### Add Users from AWS Organizations Accounts

**Use case:** Your workshop uses AWS Organizations where each participant has their own AWS account (common with AWS Workshop Studio or Event Engine). The DataZone domain exists in a central account, and you need to grant access to users in member accounts.

**How it works:** The script iterates through a list of AWS account IDs. For each account, it assumes the `OrganizationAccountAccessRole` to list IAM users in that account, then adds each user's ARN to the DataZone project in the central account. This allows cross-account access to the shared DataZone domain and project.

**Prerequisites:**
- You must run this from the Organizations management account (or an account with permission to assume roles in member accounts)
- Member accounts must have the `OrganizationAccountAccessRole` (created by default with AWS Organizations)

For multi-account workshops using AWS Organizations:
```bash
#!/bin/bash
# add-org-account-users.sh

ACCOUNT_IDS="$@"  # Pass account IDs as arguments
DOMAIN_ID=$(aws datazone list-domains --query "items[?name=='bedrock-lab-domain'].id" --output text)
PROJECT_ID=$(aws datazone list-projects --domain-identifier $DOMAIN_ID --query "items[?name=='bedrock-lab-project'].id" --output text)

for ACCOUNT_ID in $ACCOUNT_IDS; do
    echo "Processing account: $ACCOUNT_ID"

    # Assume role in target account to list users
    CREDS=$(aws sts assume-role \
        --role-arn "arn:aws:iam::${ACCOUNT_ID}:role/OrganizationAccountAccessRole" \
        --role-session-name "AddUsers" \
        --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
        --output text)

    export AWS_ACCESS_KEY_ID=$(echo $CREDS | cut -d' ' -f1)
    export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | cut -d' ' -f2)
    export AWS_SESSION_TOKEN=$(echo $CREDS | cut -d' ' -f3)

    # List users in that account
    aws iam list-users --query 'Users[].Arn' --output text | tr '\t' '\n' | while read user_arn; do
        echo -n "  Adding $user_arn... "
        # Unset creds to use original identity for DataZone
        (
            unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
            aws datazone create-project-membership \
                --domain-identifier $DOMAIN_ID \
                --project-identifier $PROJECT_ID \
                --member "userIdentifier=${user_arn}" \
                --designation PROJECT_CONTRIBUTOR 2>/dev/null && echo "OK" || echo "FAILED"
        )
    done

    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
done
```

Usage:
```bash
./add-org-account-users.sh 111111111111 222222222222 333333333333
```

---

## Verification

After applying fixes, verify with:

```bash
# Check domain version (should show V2 or AVAILABLE status in Unified Studio)
aws datazone get-domain --identifier YOUR_DOMAIN_ID --region us-west-2

# Test inference profile creation
cd Lab_4_SageMaker_Setup
./setup-inference-profile.sh --detect  # Should show domain/project IDs
./setup-inference-profile.sh haiku     # Should succeed
./setup-inference-profile.sh --list    # Should show profile with ✓ for tags
```

---

## Known Limitations

### Project Profile Creation

SageMaker Unified Studio V2 project profiles require manual console configuration. Creating project profiles via CLI is complex and requires:
- VPC configuration (subnets, security groups)
- S3 buckets for artifacts
- KMS keys for encryption
- Multiple IAM roles with specific trust relationships

**Recommendation:** For workshop setup:
1. Create the DataZone domain and project via scripts
2. Configure project profiles manually via AWS Console:
   - Navigate to Amazon DataZone → Your Domain → Administration → Project profiles
   - Create a profile with the "Data analytics and AI-ML model development" blueprint
   - Enable JupyterLab capability
