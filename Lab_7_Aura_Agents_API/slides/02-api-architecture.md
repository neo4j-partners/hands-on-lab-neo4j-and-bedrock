# API Architecture

## The Request Flow

```
Your Application
    │
    ▼
┌─────────────────────────┐
│  1. Get Access Token    │
│  POST /oauth/token      │
└─────────────────────────┘
    │
    ▼
┌─────────────────────────┐
│  2. Call Agent          │
│  POST /agents/.../invoke│
└─────────────────────────┘
    │
    ▼
┌─────────────────────────┐
│  3. Parse Response      │
│  Extract text/tools     │
└─────────────────────────┘
```

## Key Endpoints

| Endpoint | Purpose |
|----------|---------|
| `api.neo4j.io/oauth/token` | Get access token |
| `api.neo4j.io/.../invoke` | Call the agent |

---

[← Previous](01-intro.md) | [Next: OAuth2 Authentication →](03-oauth2.md)
