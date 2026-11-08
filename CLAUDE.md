# Claude Code Project & Skill Instructions (`network-ai-optimizer`)

When operating in this repository or executing `/network-ai-optimizer`:
- Read [SKILL.md](./SKILL.md) for the full multi-step runbook.
- Run `./scripts/diagnose-network-ai.ps1` first to inspect NIC hardware buffers, Windows `NetworkThrottlingIndex`, Cloud AI API handshake latency (`api.anthropic.com`, `api.openai.com`, `generativelanguage.googleapis.com`, `openrouter.ai`), GPU HAGS, and Ollama AI flags.
- Run `./scripts/optimize-workstation.ps1` to unlock maximum workstation throughput and AI performance.
- Respect **Enterprise-Safe Mode** on company machines (never modify corporate DNS, AD policies, VPNs, or company routers without explicit authorization).
