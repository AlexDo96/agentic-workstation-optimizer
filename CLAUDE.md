# Claude Code Project & Skill Instructions (`agentic-workstation-optimizer`)

When operating in this repository or executing `/agentic-workstation-optimizer` (or delegating to `@network-doctor`):
- Read [SKILL.md](./SKILL.md) for the full multi-step runbook.
- Run `./scripts/diagnose-network-ai.ps1 -SaveReport` first to inspect NIC hardware buffers, Windows `NetworkThrottlingIndex`, 55k QA Ephemeral Ports, Corporate IPv6/MTU/SSL status, Cloud AI API handshake latency (`api.anthropic.com`, `api.openai.com`, `generativelanguage.googleapis.com`, `openrouter.ai`), WSL2 Mirrored mode, GPU HAGS, and Ollama AI flags.
- Run `./scripts/optimize-workstation.ps1` to automatically create a Time-Machine JSON snapshot and unlock maximum workstation throughput, QA Automation capacity, and AI performance.
- Respect **Enterprise-Safe Mode** on company machines (never modify corporate DNS, AD policies, VPNs, or company routers without explicit authorization).
