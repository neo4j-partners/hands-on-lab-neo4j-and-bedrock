# TEST2: Project Membership & Access Diagnostics

The basic infrastructure is working. This tests project membership and access issues.

---

## Quick Diagnostic

Copy and paste into CloudShell:

```bash
bash << 'EOF'
echo "=== Project Access Diagnostics ==="
echo ""

REGION="us-west-2"
DOMAIN_NAME="bedrock-lab-domain"
PROJECT_NAME="bedrock-lab-project"

# Get IDs
DOMAIN_ID=$(aws datazone list-domains --region $REGION --query "items[?name=='${DOMAIN_NAME}'].id" --output text)
PROJECT_ID=$(aws datazone list-projects --region $REGION --domain-identifier $DOMAIN_ID --query "items[?name=='${PROJECT_NAME}'].id" --output text)
MY_ARN=$(aws sts get-caller-identity --query Arn --output text)
MY_USER=$(echo $MY_ARN | awk -F'/' '{print $NF}')
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "Your Identity: $MY_ARN"
echo "Domain ID: $DOMAIN_ID"
echo "Project ID: $PROJECT_ID"
echo ""

# 1. Check project membership
echo "1. Project Membership:"
MEMBERS=$(aws datazone list-project-memberships --region $REGION \
    --domain-identifier $DOMAIN_ID \
    --project-identifier $PROJECT_ID \
    --output json 2>&1)

if echo "$MEMBERS" | grep -q "AccessDeniedException"; then
    echo "   ✗ Cannot list members (no permission)"
else
    echo "   Current members:"
    echo "$MEMBERS" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for m in data.get('members', []):
    designation = m.get('designation', 'unknown')
    user_id = m.get('member', {}).get('userIdentifier', 'unknown')
    print(f'   - {user_id} ({designation})')
" 2>/dev/null || echo "   (none or error parsing)"

    # Check if current user is a member
    if echo "$MEMBERS" | grep -q "$MY_ARN"; then
        echo "   ✓ You ARE a member"
    elif echo "$MEMBERS" | grep -q "$MY_USER"; then
        echo "   ✓ You ARE a member (by username)"
    else
        echo "   ✗ You are NOT a member"
    fi
fi

# 2. Check IAM policy attachment
echo ""
echo "2. IAM Policy Check:"
POLICIES=$(aws iam list-attached-user-policies --user-name $MY_USER --query 'AttachedPolicies[].PolicyName' --output text 2>&1)
if echo "$POLICIES" | grep -q "BedrockAgentsLabPolicy"; then
    echo "   ✓ BedrockAgentsLabPolicy attached"
else
    echo "   ✗ BedrockAgentsLabPolicy NOT attached"
    echo "   Attached policies: $POLICIES"
fi

# 3. Check DataZone permissions
echo ""
echo "3. DataZone Permissions Test:"
# Try to list domains (basic permission)
if aws datazone list-domains --region $REGION --query 'items[0].id' --output text &>/dev/null; then
    echo "   ✓ Can list domains"
else
    echo "   ✗ Cannot list domains"
fi

# Try to get project details
if aws datazone get-project --region $REGION --domain-identifier $DOMAIN_ID --identifier $PROJECT_ID --query 'name' --output text &>/dev/null; then
    echo "   ✓ Can get project details"
else
    echo "   ✗ Cannot get project details"
fi

# 4. Check project profiles
echo ""
echo "4. Project Profiles:"
PROFILES=$(aws datazone list-project-profiles --region $REGION --domain-identifier $DOMAIN_ID --output json 2>&1)
if echo "$PROFILES" | grep -q "AccessDeniedException"; then
    echo "   ✗ Cannot list project profiles (no permission)"
elif echo "$PROFILES" | grep -q "items"; then
    COUNT=$(echo "$PROFILES" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('items', [])))" 2>/dev/null)
    echo "   Found $COUNT project profile(s)"
    echo "$PROFILES" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for p in data.get('items', []):
    name = p.get('name', 'unknown')
    status = p.get('status', 'unknown')
    print(f'   - {name} ({status})')
" 2>/dev/null
else
    echo "   No project profiles found"
fi

# 5. Check environment profiles (blueprints)
echo ""
echo "5. Environment Profiles (Blueprints):"
ENV_PROFILES=$(aws datazone list-environment-profiles --region $REGION --domain-identifier $DOMAIN_ID --output json 2>&1)
if echo "$ENV_PROFILES" | grep -q "AccessDeniedException"; then
    echo "   ✗ Cannot list environment profiles"
elif echo "$ENV_PROFILES" | grep -q "items"; then
    echo "$ENV_PROFILES" | python3 -c "
import sys, json
data = json.load(sys.stdin)
items = data.get('items', [])
print(f'   Found {len(items)} environment profile(s)')
for p in items:
    name = p.get('name', 'unknown')
    print(f'   - {name}')
" 2>/dev/null
else
    echo "   No environment profiles found"
fi

# 6. Summary and recommended actions
echo ""
echo "=== Recommended Actions ==="

# Check if user needs to be added to project
if ! echo "$MEMBERS" | grep -q "$MY_ARN" && ! echo "$MEMBERS" | grep -q "$MY_USER"; then
    echo ""
    echo "ACTION 1: Add yourself to the project"
    echo "Run this command:"
    echo ""
    echo "aws datazone create-project-membership \\"
    echo "    --region $REGION \\"
    echo "    --domain-identifier $DOMAIN_ID \\"
    echo "    --project-identifier $PROJECT_ID \\"
    echo "    --member \"userIdentifier=$MY_ARN\" \\"
    echo "    --designation PROJECT_CONTRIBUTOR"
fi

echo ""
echo "ACTION 2: If project profiles are missing, an admin must create one via Console:"
echo "  1. Go to: https://${DOMAIN_ID}.datazone.${REGION}.on.aws"
echo "  2. Navigate to: Administration > Project profiles"
echo "  3. Create a profile with 'Data analytics and AI-ML' blueprint"
echo ""

EOF
```

---

## Manual Checks

### Check if you're a project member

```bash
REGION="us-west-2"
DOMAIN_ID=$(aws datazone list-domains --region $REGION --query "items[?name=='bedrock-lab-domain'].id" --output text)
PROJECT_ID=$(aws datazone list-projects --region $REGION --domain-identifier $DOMAIN_ID --query "items[?name=='bedrock-lab-project'].id" --output text)

aws datazone list-project-memberships \
    --region $REGION \
    --domain-identifier $DOMAIN_ID \
    --project-identifier $PROJECT_ID \
    --output table
```

### Add yourself to the project

```bash
MY_ARN=$(aws sts get-caller-identity --query Arn --output text)

aws datazone create-project-membership \
    --region $REGION \
    --domain-identifier $DOMAIN_ID \
    --project-identifier $PROJECT_ID \
    --member "userIdentifier=$MY_ARN" \
    --designation PROJECT_CONTRIBUTOR
```

### Check project profiles exist

```bash
aws datazone list-project-profiles \
    --region $REGION \
    --domain-identifier $DOMAIN_ID \
    --output table
```

### Check environment profiles (blueprints)

```bash
aws datazone list-environment-profiles \
    --region $REGION \
    --domain-identifier $DOMAIN_ID \
    --output table
```

---

## Common Issues

### "You are not yet a member of this project"

**Cause:** Your IAM user/role is not added to the DataZone project.

**Fix:** Add yourself using the command above, or have an admin (OrganizationAccountAccessRole) add you.

### "Cannot create project profile"

**Cause:** Project profiles in SageMaker Unified Studio V2 require:
- Environment profiles (blueprints) to be available
- Proper IAM roles for the domain
- Often must be created by domain admin via Console

**Fix:** An admin needs to create the project profile via the AWS Console:
1. Open the portal URL
2. Go to Administration → Project profiles
3. Create a new profile with appropriate blueprints

### No environment profiles found

**Cause:** The DataZone domain may not have blueprints enabled or configured.

**Fix:** This is typically set up during domain creation. For V2 domains, blueprints should be auto-configured, but may require additional setup via Console.

---

## Portal Access Test

After running the fixes, test portal access:

1. Open: `https://{DOMAIN_ID}.datazone.us-west-2.on.aws`
2. You should see the project listed
3. Click on the project
4. You should be able to access it without the "not a member" error

---

## Full Reset (If All Else Fails)

If the domain/project are misconfigured, it may be easier to delete and recreate:

```bash
# WARNING: This deletes everything!
cd setup-scripts
./setup-datazone.sh --cleanup

# Wait a few minutes for deletion to complete, then:
./setup-datazone.sh

# Then re-run inference profile creation
./setup-bedrock-lab-org.sh $ACCOUNT_ID
```
