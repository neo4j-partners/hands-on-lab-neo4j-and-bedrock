#!/bin/bash
# 01-get-identity.sh
# Gets current AWS identity and exports POLICY_SOURCE_ARN for use in other scripts

set -e

echo "Getting AWS caller identity..."

# Get identity and export ARN
export POLICY_SOURCE_ARN=$(aws sts get-caller-identity --query 'Arn' --output text)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

cat <<EOF

========================================
AWS Identity Information
========================================
Account ID: ${AWS_ACCOUNT_ID}
ARN:        ${POLICY_SOURCE_ARN}
========================================

Environment variables set:
  POLICY_SOURCE_ARN=${POLICY_SOURCE_ARN}
  AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}

To use in current shell, run:
  source 01-get-identity.sh

EOF

# Write to env file for other scripts to source
cat <<EOF > .env-identity
export POLICY_SOURCE_ARN="${POLICY_SOURCE_ARN}"
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID}"
EOF

echo "Identity saved to .env-identity"
