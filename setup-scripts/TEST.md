# Verification Tests for Workshop Setup

Run these AWS CLI commands in CloudShell to verify the account provisioning completed successfully.

---

## 1. Check Your Identity

Verify you're in the correct account and have the expected permissions.

```bash
# Who am I?
aws sts get-caller-identity

# Expected: Shows your account ID, user ARN, and user ID
```

---

## 2. Verify DataZone Domain

Check that the DataZone domain exists and is V2 (SageMaker Unified Studio).

```bash
# List all domains
aws datazone list-domains --output table

# Get domain details (replace DOMAIN_ID or use the command below)
DOMAIN_ID=$(aws datazone list-domains --query "items[?name=='bedrock-lab-domain'].id" --output text)
echo "Domain ID: $DOMAIN_ID"

# Check domain status and version
aws datazone get-domain --identifier $DOMAIN_ID --query '{Name:name, Id:id, Status:status, PortalUrl:portalUrl}' --output table
```

**Expected:**
- Status: `AVAILABLE`
- Domain ID starts with `dzd_`
- Portal URL: `https://{domain-id}.datazone.{region}.on.aws`

---

## 3. Verify DataZone Project

Check that the workshop project exists within the domain.

```bash
# List projects in domain
aws datazone list-projects --domain-identifier $DOMAIN_ID --output table

# Get project ID
PROJECT_ID=$(aws datazone list-projects --domain-identifier $DOMAIN_ID --query "items[?name=='bedrock-lab-project'].id" --output text)
echo "Project ID: $PROJECT_ID"

# Get project details
aws datazone get-project --domain-identifier $DOMAIN_ID --identifier $PROJECT_ID --query '{Name:name, Id:id, Status:status}' --output table
```

**Expected:**
- Project named `bedrock-lab-project`
- Status: `ACTIVE`

---

## 4. Verify IAM Policy

Check that the BedrockAgentsLabPolicy exists and has correct permissions.

```bash
# Get account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Check if policy exists
aws iam get-policy --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/BedrockAgentsLabPolicy" --query 'Policy.{Name:PolicyName, Arn:Arn, Created:CreateDate}' --output table

# View policy document
aws iam get-policy-version \
    --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/BedrockAgentsLabPolicy" \
    --version-id v1 \
    --query 'PolicyVersion.Document' --output json | python3 -m json.tool
```

**Expected permissions in policy:**
- `bedrock:*InferenceProfile*`
- `bedrock-runtime:Converse*`
- `bedrock-runtime:InvokeModel*`
- `datazone:*`
- `ram:*`
- `sagemaker:*`

---

## 5. Verify Inference Profiles

Check that inference profiles were created with correct tags.

```bash
# List all application inference profiles
aws bedrock list-inference-profiles --type-equals APPLICATION --output table

# List profiles with details
aws bedrock list-inference-profiles --type-equals APPLICATION \
    --query 'inferenceProfileSummaries[].{Name:inferenceProfileName, Arn:inferenceProfileArn, Status:status}' \
    --output table
```

**Expected profiles:**
- `{domain_id} {project_id} haiku`
- `{domain_id} {project_id} sonnet`
- `{domain_id} {project_id} sonnet4`
- `{domain_id} {project_id} sonnet45`

### Check Profile Tags

Verify the critical tags are set (required for SageMaker Unified Studio visibility):

```bash
# Get first profile ARN
PROFILE_ARN=$(aws bedrock list-inference-profiles --type-equals APPLICATION --query 'inferenceProfileSummaries[0].inferenceProfileArn' --output text)

# Check tags
aws bedrock list-tags-for-resource --resource-arn "$PROFILE_ARN" --output table
```

**Expected tags:**
- `AmazonBedrockManaged` = `true` (CRITICAL)
- `AmazonDataZoneDomain` = `{domain_id}`
- `AmazonDataZoneProject` = `{project_id}`

---

## 6. Verify Project Membership

Check who has access to the project.

```bash
# List project members
aws datazone list-project-memberships \
    --domain-identifier $DOMAIN_ID \
    --project-identifier $PROJECT_ID \
    --output table
```

**Expected:** At least the admin user/role should be listed.

---

## 7. Test Bedrock Model Access

Verify you can invoke Bedrock models through inference profiles.

```bash
# Get a profile ARN (haiku for quick test)
HAIKU_ARN=$(aws bedrock list-inference-profiles --type-equals APPLICATION \
    --query "inferenceProfileSummaries[?contains(inferenceProfileName, 'haiku')].inferenceProfileArn" \
    --output text | head -1)

echo "Testing profile: $HAIKU_ARN"

# Quick invocation test
aws bedrock-runtime converse \
    --model-id "$HAIKU_ARN" \
    --messages '[{"role":"user","content":[{"text":"Say hello in exactly 3 words"}]}]' \
    --query 'output.message.content[0].text' \
    --output text
```

**Expected:** A response from the model (e.g., "Hello to you!")

---

## 8. Verify Portal Access

Get the portal URL and test access.

```bash
# Print portal URL
echo "Portal URL: https://${DOMAIN_ID}.datazone.${AWS_REGION:-us-west-2}.on.aws"

# Or get from domain details
aws datazone get-domain --identifier $DOMAIN_ID --query 'portalUrl' --output text
```

**Manual verification:** Open the URL in a browser and confirm you can:
1. See the domain
2. Access the project
3. See inference profiles in the Bedrock section

---

## Quick All-in-One Test

Copy and paste this entire block into CloudShell:

```bash
bash << 'EOF'
echo "=== Workshop Setup Verification ==="
echo ""

# Set region - CHANGE THIS if your workshop uses a different region
REGION="us-west-2"
echo "Region: $REGION"
echo ""

# Identity
echo "1. Identity:"
aws sts get-caller-identity --query '{Account:Account, User:Arn}' --output table

# Domain
echo ""
echo "2. DataZone Domain:"
DOMAIN_ID=$(aws datazone list-domains --region $REGION --query "items[?name=='bedrock-lab-domain'].id" --output text)
if [ -n "$DOMAIN_ID" ] && [ "$DOMAIN_ID" != "None" ]; then
    echo "   ✓ Domain found: $DOMAIN_ID"
    STATUS=$(aws datazone get-domain --region $REGION --identifier $DOMAIN_ID --query 'status' --output text)
    echo "   Status: $STATUS"
else
    echo "   ✗ Domain NOT found"
fi

# Project
echo ""
echo "3. DataZone Project:"
PROJECT_ID=$(aws datazone list-projects --region $REGION --domain-identifier $DOMAIN_ID --query "items[?name=='bedrock-lab-project'].id" --output text 2>/dev/null)
if [ -n "$PROJECT_ID" ] && [ "$PROJECT_ID" != "None" ]; then
    echo "   ✓ Project found: $PROJECT_ID"
else
    echo "   ✗ Project NOT found"
fi

# Inference Profiles
echo ""
echo "4. Inference Profiles:"
PROFILE_COUNT=$(aws bedrock list-inference-profiles --region $REGION --type-equals APPLICATION --query 'length(inferenceProfileSummaries)' --output text)
echo "   Found: $PROFILE_COUNT profiles"
aws bedrock list-inference-profiles --region $REGION --type-equals APPLICATION \
    --query 'inferenceProfileSummaries[].inferenceProfileName' --output text | tr '\t' '\n' | while read name; do
    echo "   - $name"
done

# Tags check
echo ""
echo "5. Profile Tags:"
PROFILE_ARN=$(aws bedrock list-inference-profiles --region $REGION --type-equals APPLICATION --query 'inferenceProfileSummaries[0].inferenceProfileArn' --output text)
if [ -n "$PROFILE_ARN" ] && [ "$PROFILE_ARN" != "None" ]; then
    MANAGED=$(aws bedrock list-tags-for-resource --region $REGION --resource-arn "$PROFILE_ARN" --query "tags[?key=='AmazonBedrockManaged'].value" --output text)
    if [ "$MANAGED" == "true" ]; then
        echo "   ✓ AmazonBedrockManaged=true"
    else
        echo "   ✗ AmazonBedrockManaged tag missing or incorrect"
    fi
fi

# Model test
echo ""
echo "6. Model Invocation Test:"
HAIKU_ARN=$(aws bedrock list-inference-profiles --region $REGION --type-equals APPLICATION \
    --query "inferenceProfileSummaries[?contains(inferenceProfileName, 'haiku')].inferenceProfileArn" \
    --output text | head -1)
if [ -n "$HAIKU_ARN" ] && [ "$HAIKU_ARN" != "None" ]; then
    RESPONSE=$(aws bedrock-runtime converse --region $REGION \
        --model-id "$HAIKU_ARN" \
        --messages '[{"role":"user","content":[{"text":"Say OK"}]}]' \
        --query 'output.message.content[0].text' \
        --output text 2>&1)
    if [[ "$RESPONSE" == *"OK"* ]] || [[ "$RESPONSE" == *"ok"* ]] || [[ ! "$RESPONSE" == *"error"* ]]; then
        echo "   ✓ Model responded: $RESPONSE"
    else
        echo "   ✗ Model error: $RESPONSE"
    fi
else
    echo "   ✗ No haiku profile found"
fi

echo ""
echo "=== Portal URL ==="
echo "https://${DOMAIN_ID}.datazone.${REGION}.on.aws"
echo ""
EOF
```

---

## Troubleshooting

### Domain not found
```bash
# Check all domains in region
aws datazone list-domains --query 'items[].{Name:name, Id:id, Status:status}' --output table

# Try different region
aws datazone list-domains --region us-east-1 --output table
```

### Inference profiles not visible in Unified Studio
```bash
# Check tags - must have AmazonBedrockManaged=true
aws bedrock list-tags-for-resource --resource-arn "$PROFILE_ARN"

# If missing, profiles need to be recreated with correct tags
```

### Permission denied errors
```bash
# Check attached policies
aws iam list-attached-user-policies --user-name $(aws sts get-caller-identity --query 'Arn' --output text | awk -F'/' '{print $NF}')

# Check if BedrockAgentsLabPolicy is attached
```

### Cannot add self to project
```bash
# Verify you have datazone:CreateProjectMembership permission
aws iam simulate-principal-policy \
    --policy-source-arn $(aws sts get-caller-identity --query Arn --output text) \
    --action-names datazone:CreateProjectMembership \
    --query 'EvaluationResults[0].EvalDecision'
```
