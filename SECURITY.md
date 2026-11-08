# Security Policy

## Scope & Design Guarantees

`agentic-workstation-optimizer` is a local PowerShell toolkit and AI agent skill bundle:
- **Zero Telemetry:** The scripts do not collect, store, or transmit any user data or analytics. Network checks in `diagnose-network-ai.ps1` only perform standard ICMP pings (`8.8.8.8` and the local default gateway) and HTTP HEAD/timing checks against official public endpoints (`api.anthropic.com`, `api.openai.com`, `generativelanguage.googleapis.com`, `openrouter.ai`, `api.github.com`, `speed.cloudflare.com`).
- **No TLS Verification Bypass:** To work behind corporate SSL inspection firewalls, the toolkit configures Git and Node.js to trust the native Windows OS Certificate Store (`http.sslBackend = schannel`, `NODE_USE_SYSTEM_CA = 1`) rather than disabling TLS verification (`NODE_TLS_REJECT_UNAUTHORIZED=0` is never used).
- **Automatic Local Snapshots:** System settings are backed up locally to `backups/latest-snapshot.json` (which is git-ignored so local machine details are never committed).

## Supported Versions

| Version | Supported |
| :--- | :--- |
| `2.1.x` | Yes |
| `< 2.0` | No |

## Reporting a Vulnerability

If you discover a security issue or an unsafe registry modification in any script, please open an issue on [GitHub Issues](https://github.com/AlexDo96/agentic-workstation-optimizer/issues) with reproduction details.
