# OAuth2 Authentication

## Client Credentials Flow

For machine-to-machine communication, use the **client credentials** grant type.

## Step 1: Request a Token

```http
POST https://api.neo4j.io/oauth/token
Authorization: Basic base64(client_id:client_secret)
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
```

## Step 2: Receive Token

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

## Key Points

- Tokens expire in **1 hour** (3600 seconds)
- **Cache tokens** until they expire
- **Refresh automatically** when needed

---

[← Previous](02-api-architecture.md) | [Next: Getting Credentials →](04-credentials.md)
