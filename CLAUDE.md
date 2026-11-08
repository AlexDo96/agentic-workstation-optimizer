# Claude Code Instructions (`agentic-workstation-optimizer`)

When working in this repository or running `/agentic-workstation-optimizer` (or `@network-doctor`):
- Read [SKILL.md](./SKILL.md) for the step-by-step workflow.
- Run `./scripts/diagnose-network-ai.ps1 -SaveReport` first to check network adapter buffers, Windows `NetworkThrottlingIndex`, ephemeral port limits, IPv6/MTU status, Cloud AI API latency (`api.anthropic.com`, `api.openai.com`, `generativelanguage.googleapis.com`, `openrouter.ai`), WSL2 networking mode, GPU HAGS, and Ollama settings.
- Run `./scripts/optimize-workstation.ps1` to save a backup snapshot and apply the workstation optimizations.
- On company machines, never modify corporate DNS, Active Directory settings, VPN profiles, or office routers without explicit permission.
