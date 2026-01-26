# Getting Your Credentials

## Step 1: Create API Key

1. Log in to [console.neo4j.io](https://console.neo4j.io)
2. Click your **profile icon** → **Settings**
3. Go to **API keys** tab
4. Click **Create API Key**
5. Save both:
   - **Client ID** (shown always)
   - **Client Secret** (shown once!)

## Step 2: Get Agent Endpoint

1. Navigate to your agent in Aura Console
2. Click on your agent to open details
3. Click **Copy endpoint**
4. URL format:
   ```
   https://api.neo4j.io/v2beta1/organizations/.../agents/.../invoke
   ```

## Step 3: Enable External Access

Ensure **External endpoint** is enabled in your agent's settings.

---

[← Previous](03-oauth2.md) | [Next: Calling the Agent →](05-calling-agent.md)
