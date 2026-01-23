# AWS Documentation MCP Server Setup for Claude Code

This guide explains how to set up the AWS Documentation MCP Server to access AWS documentation, including IAM best practices and permissions guidance, directly within Claude Code.

## Overview

The [AWS Documentation MCP Server](https://awslabs.github.io/mcp/servers/aws-documentation-mcp-server) provides AI assistants with tools to:

- **Read Documentation**: Fetch and convert AWS documentation pages to markdown format
- **Search Documentation**: Search AWS docs using the official search API
- **Get Recommendations**: Retrieve related content recommendations

This is useful for looking up IAM best practices, permissions documentation, and AWS service guides without leaving your coding environment.

## Prerequisites

1. **Install uv** (Python package manager from Astral):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. **Install Python 3.10+** (if not already installed):
   ```bash
   uv python install 3.10
   ```

## Claude Code Configuration

MCP servers are configured in `.mcp.json` at your project root (not in `.claude/settings.json`).

### Step 1: Create `.mcp.json` in your project root

```json
{
  "mcpServers": {
    "awslabs.aws-documentation-mcp-server": {
      "command": "uvx",
      "args": ["awslabs.aws-documentation-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "AWS_DOCUMENTATION_PARTITION": "aws"
      }
    }
  }
}
```

### Step 2: Enable project MCP servers in `.claude/settings.json`

```json
{
  "enableAllProjectMcpServers": true
}
```

### File Reference

| File | Purpose |
|------|---------|
| `.mcp.json` | MCP server definitions (project root) |
| `.claude/settings.json` | Claude Code settings (permissions, auto-approval) |
| `.claude/settings.local.json` | Personal permissions (not checked into git) |

### Configuration Options

| Environment Variable | Description | Default |
|---------------------|-------------|---------|
| `AWS_DOCUMENTATION_PARTITION` | Set to `aws` for global docs or `aws-cn` for China region | `aws` |
| `FASTMCP_LOG_LEVEL` | Log level (ERROR, WARN, INFO, DEBUG) | `ERROR` |
| `MCP_USER_AGENT` | Custom user agent for corporate firewalls | Browser default |

## Usage Examples

Once configured, you can ask Claude Code to:

- "Look up IAM best practices documentation"
- "Search AWS docs for IAM policy conditions"
- "Find documentation on least privilege permissions"
- "Look up S3 bucket policy examples"

## Verification

After adding the configuration:

1. Restart Claude Code
2. Run `/mcp` to verify the server is connected
3. Ask Claude to search for IAM documentation to test

## Additional Resources

- [AWS MCP Servers GitHub](https://github.com/awslabs/mcp)
- [AWS Documentation MCP Server](https://awslabs.github.io/mcp/servers/aws-documentation-mcp-server)
- [IAM Best Practices in AWS Docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

## Related: IAM Policy Autopilot

For generating IAM policies from your code (rather than just reading docs), see the [IAM Policy Autopilot MCP Server](https://github.com/awslabs/iam-policy-autopilot). This analyzes your application code and helps create baseline IAM policies.
