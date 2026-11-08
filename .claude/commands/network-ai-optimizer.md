---
description: Diagnose and unlock Windows network throughput, Cloud AI API latency, router Wi-Fi 6 160MHz settings, and Local AI workstation performance (Enterprise-Safe mode supported).
---

Please execute the **Network & AI Workstation Optimizer (`network-ai-optimizer`)** workflow:

1. **Read the Main Skill Runbook:**
   Read `SKILL.md` (located in the repository root, `.agents/skills/network-ai-optimizer/SKILL.md`, `~/.claude/skills/network-ai-optimizer/SKILL.md`, or `~/.gemini/config/skills/network-ai-optimizer/SKILL.md`).
2. **Determine Context (Enterprise/Company vs. Home):**
   - If running on a **Company / Office Workstation**, strictly follow **Enterprise-Safe Mode** (do not alter corporate DNS, Active Directory, VPNs, or router/firewalls without explicit authorization; focus 100% on unlocking Windows OS packet throttling, NIC hardware buffers, disabling NIC sleep states, enabling `TCPNoDelay` for Cloud AI SSE streaming, and tuning GPU HAGS / Ollama / Git / Python).
3. **Run Diagnostics First:**
   Execute `powershell -ExecutionPolicy Bypass -File "<skill-dir>/scripts/diagnose-network-ai.ps1"` and present a clear summary of detected bottlenecks.
4. **Apply Optimizations & Verify:**
   Execute `powershell -ExecutionPolicy Bypass -File "<skill-dir>/scripts/optimize-workstation.ps1"` (and provide the elevated PowerShell Admin block if UAC elevation is needed), then re-verify all parameters.

User request / context: $ARGUMENTS
