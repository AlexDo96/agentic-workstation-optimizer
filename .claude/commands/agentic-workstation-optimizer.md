---
description: Diagnose and optimize Windows hardware (CPU, GPU, RAM, SSD), software, gaming performance, network speed, corporate Cloud AI API connectivity, ephemeral ports for E2E/API testing, WSL2 Mirrored networking, and local AI (Ollama/GPU) settings.
---

Run the `agentic-workstation-optimizer` workflow:

1. **Read the Skill Guide:**
   Read `SKILL.md` (in the repository root, `.agents/skills/agentic-workstation-optimizer/SKILL.md`, `~/.claude/skills/agentic-workstation-optimizer/SKILL.md`, or `~/.gemini/config/skills/agentic-workstation-optimizer/SKILL.md`).
2. **Check Environment Context (`-Mode All | Work | Gaming`):**
   - On a company/office PC, use `-Mode Work` (do not alter corporate DNS servers, Active Directory settings, VPN profiles, or office routers, and skip gaming tweaks).
   - On a home PC used for both Gaming and AI/Work, use `-Mode All`.
3. **Run Diagnostics First:**
   Execute `powershell -ExecutionPolicy Bypass -File "<skill-dir>/scripts/diagnose-network-ai.ps1" -SaveReport` and summarize any bottlenecks found.
4. **Apply Optimizations (Backs up current settings automatically):**
   Execute `powershell -ExecutionPolicy Bypass -File "<skill-dir>/scripts/optimize-workstation.ps1" -Mode <All|Work|Gaming>` (and provide the elevated PowerShell Admin command if UAC elevation is required), then verify the updated settings.

User request / context: $ARGUMENTS
