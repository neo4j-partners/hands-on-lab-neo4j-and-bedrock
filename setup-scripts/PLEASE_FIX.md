# Setup Scripts - What Works & What's Missing

## Summary

The setup scripts successfully create the infrastructure, but **workshop users cannot access the project** because they're not automatically added as members. Only the admin role that created the project can add members.

---

## What's Working ✓

| Component | Status | Notes |
|-----------|--------|-------|
| DataZone Domain | ✓ | Created as V2, status AVAILABLE |
| DataZone Project | ✓ | Created successfully |
| Inference Profiles | ✓ | 4 profiles with correct tags |
| AmazonBedrockManaged tag | ✓ | Profiles visible in Unified Studio |
| BedrockAgentsLabPolicy | ✓ | Policy created with correct permissions |
| Model Invocation | ✓ | Users can call Bedrock models |

---

## What's NOT Working ✗

### 1. Users Cannot Access the Project

**Symptom:** Workshop users see:
> "You are not yet a member of this project and do not have permission to view it."

**Cause:** The `datazone:CreateProjectMembership` permission only allows users to add *others* to a project if they're already a project owner/admin. Workshop users are not project members, so they can't add themselves.

**Error when trying to self-add:**
```
AccessDeniedException: User is not permitted to perform operation: CreateProjectMembership
```

### 2. Project Profiles Cannot Be Created

**Symptom:** Users cannot create project profiles in the console.

**Cause:** Project profile creation requires domain-level admin permissions and is typically done via Console by the domain owner, not via API.

---

## Root Cause

The setup scripts run as `OrganizationAccountAccessRole` (admin), which becomes the **sole project owner**. Workshop users are created separately and are **not added to the project**.

The `BedrockAgentsLabPolicy` grants `datazone:*` but DataZone has additional authorization logic beyond IAM - you must be a **project member** to access project resources, regardless of IAM permissions.

---

## Required Fix

### Option A: Add Users During Setup (Recommended)

The `setup-bedrock-lab-org.sh` script needs to add the workshop user to the project after creating it.

**Add to setup-bedrock-lab-org.sh after project creation:**

```bash
# After creating domain and project, add the workshop user
# Get the workshop user ARN (adjust pattern as needed)
WORKSHOP_USER=$(aws iam list-users --query "Users[?contains(UserName, 'canoe') || contains(UserName, 'workshop')].Arn" --output text | head -1)

if [ -n "$WORKSHOP_USER" ]; then
    echo "Adding workshop user to project: $WORKSHOP_USER"
    aws datazone create-project-membership \
        --region "$REGION" \
        --domain-identifier "$DOMAIN_ID" \
        --project-identifier "$PROJECT_ID" \
        --member "userIdentifier=$WORKSHOP_USER" \
        --designation PROJECT_CONTRIBUTOR
fi
```

### Option B: Admin Manually Adds Users

After running setup, an admin must run (as OrganizationAccountAccessRole):

```bash
# Variables
REGION="us-west-2"
DOMAIN_ID="dzd-cc7xnqe1w4ue8g"
PROJECT_ID="c60igfgwewctxs"
USER_ARN="arn:aws:iam::471112939879:user/perfect-canoe-11166"

# Add user to project
aws datazone create-project-membership \
    --region $REGION \
    --domain-identifier $DOMAIN_ID \
    --project-identifier $PROJECT_ID \
    --member "userIdentifier=$USER_ARN" \
    --designation PROJECT_CONTRIBUTOR
```

### Option C: Make User a Project Owner

To allow users to manage their own membership:

```bash
aws datazone create-project-membership \
    --region $REGION \
    --domain-identifier $DOMAIN_ID \
    --project-identifier $PROJECT_ID \
    --member "userIdentifier=$USER_ARN" \
    --designation PROJECT_OWNER
```

---

## Immediate Workaround

**For the current test account**, an admin needs to run this command (must be run as the role that created the project, likely via assuming OrganizationAccountAccessRole):

```bash
# Run from an admin session (OrganizationAccountAccessRole)
aws datazone create-project-membership \
    --region us-west-2 \
    --domain-identifier dzd-cc7xnqe1w4ue8g \
    --project-identifier c60igfgwewctxs \
    --member "userIdentifier=arn:aws:iam::471112939879:user/perfect-canoe-11166" \
    --designation PROJECT_CONTRIBUTOR
```

---

## Scripts That Need Updates

### 1. `setup-scripts/setup-bedrock-lab-org.sh`

Add logic to:
- Detect workshop users in the account
- Add them to the project after creation

### 2. `setup-scripts/setup-datazone.sh`

The `--add-user` option exists but:
- Requires the user ARN/name to be known in advance
- Must be run by an admin with project owner permissions

**Consider adding:** `--add-all-users` flag that adds all IAM users (or users matching a pattern) to the project automatically.

---

## Testing Checklist

After fixing, verify:

- [ ] Workshop user can access the portal URL
- [ ] Workshop user can see and enter the project
- [ ] Workshop user can see inference profiles
- [ ] Workshop user can create notebooks/spaces (if project profiles exist)

---

## Questions for Workshop Organizers

1. **How are workshop users created?**
   - If usernames follow a pattern (e.g., `workshop-*`, `*-canoe-*`), we can auto-detect and add them.

2. **When are users created relative to setup?**
   - If users exist before setup runs → add them during setup
   - If users are created after setup → need a separate "add users" step

3. **Should users be PROJECT_OWNER or PROJECT_CONTRIBUTOR?**
   - OWNER: Can add other members, manage project settings
   - CONTRIBUTOR: Can use the project but not manage it
