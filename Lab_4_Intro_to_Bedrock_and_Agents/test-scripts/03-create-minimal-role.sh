#!/bin/bash
# 03-create-minimal-role.sh
# Creates a minimal IAM role with only the permissions needed for Lab 4
# Use this to verify the documented permissions are complete

set -e

ROLE_NAME="${ROLE_NAME:-Lab4-MinimalTest-Role}"
POLICY_NAME="Lab4MinimalPermissions"

# Source identity if available
if [ -f ".env-identity" ]; then
    source .env-identity
fi

if [ -z "$AWS_ACCOUNT_ID" ]; then
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
fi

cat <<EOF
========================================
Creating Minimal Test Role for Lab 4
========================================
Role Name:  ${ROLE_NAME}
Account ID: ${AWS_ACCOUNT_ID}
========================================

EOF

# Check if role already exists
if aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
    echo "Role ${ROLE_NAME} already exists."
    read -p "Delete and recreate? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo "Deleting existing role..."
        aws iam delete-role-policy --role-name "$ROLE_NAME" --policy-name "$POLICY_NAME" 2>/dev/null || true
        aws iam delete-role --role-name "$ROLE_NAME"
        echo "Deleted."
    else
        echo "Exiting without changes."
        exit 0
    fi
fi

echo "Creating IAM role: ${ROLE_NAME}"
aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document file://trust-policy.json \
    --description "Minimal permissions test for Lab 4 notebooks"

echo "Attaching permissions policy..."
aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name "$POLICY_NAME" \
    --policy-document file://lab4-minimal-policy.json

ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"

cat <<EOF

========================================
Role Created Successfully
========================================
Role ARN: ${ROLE_ARN}

Next steps:
1. Create a SageMaker user profile with this role:

   aws sagemaker create-user-profile \\
       --domain-id YOUR_DOMAIN_ID \\
       --user-profile-name lab4-tester \\
       --user-settings '{
           "ExecutionRole": "${ROLE_ARN}"
       }'

2. Open SageMaker Studio with the lab4-tester profile
3. Run the Lab 4 notebooks
4. If any permission errors occur, that permission is missing from IAM_PERMS.md

To delete this role later:
   ./04-cleanup-minimal-role.sh

========================================
EOF
