#!/bin/bash
# 04-cleanup-minimal-role.sh
# Removes the minimal test role created by 03-create-minimal-role.sh

set -e

ROLE_NAME="${ROLE_NAME:-Lab4-MinimalTest-Role}"
POLICY_NAME="Lab4MinimalPermissions"

cat <<EOF
========================================
Cleaning Up Minimal Test Role
========================================
Role Name: ${ROLE_NAME}
========================================

EOF

# Check if role exists
if ! aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
    echo "Role ${ROLE_NAME} does not exist. Nothing to clean up."
    exit 0
fi

echo "Deleting inline policy..."
aws iam delete-role-policy --role-name "$ROLE_NAME" --policy-name "$POLICY_NAME" 2>/dev/null || echo "No inline policy found."

echo "Deleting role..."
aws iam delete-role --role-name "$ROLE_NAME"

cat <<EOF

========================================
Cleanup Complete
========================================
Role ${ROLE_NAME} has been deleted.
========================================
EOF
