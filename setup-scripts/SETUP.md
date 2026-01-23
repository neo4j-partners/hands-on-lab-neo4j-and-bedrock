# Setup Scripts - Background and Usage

This document explains the evolution of the setup scripts and what each one does.

## The Problem: Original Script Gaps

The original `setup-bedrock-lab-org.sh` script had several gaps that prevented it from working correctly with SageMaker Unified Studio:

### Missing Features

| Gap | Impact | Fix Applied |
|-----|--------|-------------|
| **Missing `sonnet45` model** | Couldn't use Claude Sonnet 4.5 | Added to model list |
| **Missing `AmazonBedrockManaged=true` tag** | Profiles invisible in Unified Studio | Added to all profiles |
| **Missing DataZone tags** | Profiles not associated with project | Added `AmazonDataZoneDomain` and `AmazonDataZoneProject` tags |
| **No DataZone auto-detection** | Tags couldn't be set correctly | Added `detect_datazone()` function |
| **No DataZone/Unified Studio setup** | Required manual console setup | Created new scripts |

### The "Secret Sauce"

SageMaker Unified Studio requires inference profiles to have specific tags to be visible and usable:

```
AmazonBedrockManaged=true          ← Required for Unified Studio access
AmazonDataZoneDomain={domain_id}   ← Associates with DataZone domain
AmazonDataZoneProject={project_id} ← Associates with DataZone project
```

Without these tags, profiles created via CLI are invisible in Unified Studio, even though they work fine via API.

### The Chicken-and-Egg Problem

The original script couldn't set DataZone tags because:
1. Script runs to provision new accounts
2. DataZone doesn't exist yet in those accounts
3. Profiles created without DataZone tags
4. Later, Unified Studio is configured
5. Existing profiles aren't visible (wrong tags)

**Solution:** Create DataZone first, then create profiles with proper tags.

## Current Scripts

### 1. setup-datazone.sh (NEW)

Creates DataZone domain and project for SageMaker Unified Studio.

**What it does:**
- Creates DataZone domain (`bedrock-lab-domain`)
- Creates DataZone project (`bedrock-lab-project`)
- Adds workshop attendees to the project
- Outputs portal URL and configuration

**Commands:**
```bash
./setup-datazone.sh                    # Create domain and project
./setup-datazone.sh --status           # Check setup status
./setup-datazone.sh --add-user USER    # Add IAM user to project
./setup-datazone.sh --add-role ROLE    # Add IAM role to project
./setup-datazone.sh --list-users       # List project members
./setup-datazone.sh --cleanup          # Delete everything
```

**When to use:** Before running `setup-bedrock-lab-org.sh` if you need Unified Studio.

### 2. setup-bedrock-lab-org.sh (UPDATED)

Provisions multiple AWS accounts from the organization management account.

**What it does:**
- Assumes role into member accounts
- Creates `BedrockLabRole` with trust policy for SageMaker/Bedrock
- Creates `BedrockAgentsLabPolicy` with all required permissions
- Auto-detects DataZone (if exists) and sets proper tags
- Creates inference profiles for all Claude models

**Updates made:**
- Added `sonnet45` model (Claude Sonnet 4.5)
- Added `AmazonBedrockManaged=true` tag to all profiles
- Added DataZone auto-detection
- Added DataZone tags when domain/project found
- Uses DataZone-style naming when detected

**Commands:**
```bash
./setup-bedrock-lab-org.sh 123456789012              # Single account
./setup-bedrock-lab-org.sh 123456789012 234567890123 # Multiple accounts
./setup-bedrock-lab-org.sh --file accounts.txt      # From file
./setup-bedrock-lab-org.sh --check 123456789012     # Check status
./setup-bedrock-lab-org.sh --cleanup 123456789012   # Cleanup
./setup-bedrock-lab-org.sh --list                   # List org accounts
```

**When to use:** After DataZone is set up, to provision multiple workshop accounts.

### 3. datazone-lab-stack.yaml (NEW)

CloudFormation template for complete single-account setup.

**What it creates:**
- `AmazonDataZoneDomainExecutionRole` - Required for DataZone
- `BedrockLabRole` - Workshop attendee role
- `BedrockAgentsLabPolicy` - All required permissions
- DataZone domain and project
- Lambda function to create inference profiles with all tags

**Deploy:**
```bash
aws cloudformation create-stack \
  --stack-name bedrock-agents-lab \
  --template-body file://datazone-lab-stack.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-west-2
```

**When to use:** Single account setup where you want everything automated.

## Recommended Workflows

### Workshop with Multiple Accounts (Organizations)

```bash
# 1. In each member account, set up DataZone first
./setup-datazone.sh

# 2. From org management account, provision all accounts
./setup-bedrock-lab-org.sh 111111111111 222222222222 333333333333

# 3. Add attendees to each account's project
./setup-datazone.sh --add-user user/attendee-1
```

### Single Account Workshop

```bash
# Option A: CloudFormation (one command)
aws cloudformation create-stack \
  --stack-name bedrock-agents-lab \
  --template-body file://datazone-lab-stack.yaml \
  --capabilities CAPABILITY_NAMED_IAM

# Option B: CLI scripts
./setup-datazone.sh
./setup-datazone.sh --add-user user/attendee-1
# Then attendees run setup-inference-profile.sh from Unified Studio
```

### Existing Unified Studio Environment

If DataZone/Unified Studio already exists:

```bash
# Just run the org script - it will auto-detect DataZone
./setup-bedrock-lab-org.sh 123456789012
```

## Comparison: Before and After

### Before (Original Script)

```bash
# Created profiles like this:
aws bedrock create-inference-profile \
  --inference-profile-name "langgraph-lab-haiku" \
  --tags "key=Purpose,value=BedrockLab" "key=Model,value=haiku"
  # ❌ Missing AmazonBedrockManaged=true
  # ❌ Missing DataZone tags
  # ❌ Missing sonnet45
```

**Result:** Profiles worked via API but were invisible in Unified Studio.

### After (Updated Script)

```bash
# Now creates profiles like this:
aws bedrock create-inference-profile \
  --inference-profile-name "dzd-abc123 proj-xyz789 haiku" \
  --tags "key=Purpose,value=BedrockLab" \
         "key=Model,value=haiku" \
         "key=AmazonBedrockManaged,value=true" \
         "key=AmazonDataZoneDomain,value=dzd-abc123" \
         "key=AmazonDataZoneProject,value=proj-xyz789"
  # ✅ Has AmazonBedrockManaged=true
  # ✅ Has DataZone tags
  # ✅ Uses DataZone-style naming
  # ✅ Includes sonnet45
```

**Result:** Profiles are visible and usable in SageMaker Unified Studio.

## Files Changed

| File | Change |
|------|--------|
| `setup-bedrock-lab-org.sh` | Added sonnet45, DataZone detection, proper tags |
| `setup-datazone.sh` | **NEW** - Creates DataZone domain/project |
| `datazone-lab-stack.yaml` | **NEW** - CloudFormation for full setup |
| `README.md` | **NEW** - Documentation for all scripts |
| `SETUP.md` | **NEW** - This file |
