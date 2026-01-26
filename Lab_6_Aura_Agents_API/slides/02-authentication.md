# Authentication Flow

## OAuth2 Client Credentials

The API uses OAuth2 for machine-to-machine authentication.

## Two-Step Process

**Step 1: Get Access Token**
```
POST https://api.neo4j.io/oauth/token
Authorization: Basic {client_id:client_secret}
Body: grant_type=client_credentials
→ { access_token, expires_in: 3600 }
```

**Step 2: Call Agent**
```
POST {agent_endpoint}/invoke
Authorization: Bearer {access_token}
Body: { input: "your question" }
→ { content, status, usage }
```

## Key Points

- Tokens expire in 1 hour
- Cache tokens until expiry
- Refresh automatically when needed

---

[← Previous](01-intro.md) | [Next: Getting Credentials →](03-credentials.md)
