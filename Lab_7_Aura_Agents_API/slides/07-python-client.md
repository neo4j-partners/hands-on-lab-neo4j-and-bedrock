# Python Client

## Building a Reusable Client

```python
class AuraAgentClient:
    def __init__(self, client_id, client_secret, endpoint_url):
        self.client_id = client_id
        self.client_secret = client_secret
        self.endpoint_url = endpoint_url
        self._token = None
        self._token_expiry = None

    def _get_token(self):
        if self._token and datetime.now() < self._token_expiry:
            return self._token
        # ... fetch new token
        return self._token

    def invoke(self, question: str) -> AgentResponse:
        token = self._get_token()
        response = requests.post(
            self.endpoint_url,
            headers={"Authorization": f"Bearer {token}"},
            json={"input": question}
        )
        return AgentResponse.parse(response.json())
```

---

[← Previous](06-parsing.md) | [Next: Using the Client →](08-using-client.md)
