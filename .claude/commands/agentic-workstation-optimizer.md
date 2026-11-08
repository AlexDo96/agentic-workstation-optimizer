---
description: Diagnose and unlock Windows network throughput, Corporate Cloud AI API latency, 55k QA Automation ports, WSL2 Mirrored networking, router Wi-Fi 6 160MHz settings, and Local AI workstation performance (with Time-Machine Backup & Rollback).
---

Please execute the **Universal Agentic Workstation, Network & QA Automation Optimizer (`agentic-workstation-optimizer`)** workflow:

1. **Read the Main Skill Runbook:**
   Read `SKILL.md` (located in the repository root, `.agents/skills/agentic-workstation-optimizer/SKILL.md`, `~/.claude/skills/agentic-workstation-optimizer/SKILL.md`, or `~/.gemini/config/skills/agentic-workstation-optimizer/SKILL.md`).
2. **Determine Context (Enterprise/Company vs. Home):**
   - If running on a **Company / Office Workstation**, strictly follow **Enterprise-Safe Mode** (do not alter corporate DNS, Active Directory, VPNs, or router/firewalls without explicit authorization; focus 100% on unlocking Windows OS packet throttling, NIC hardware buffers, Corporate AI Proxy Piercer `ipv4first` + `schannel`, 55k Ephemeral Ports for Playwright/QA/MCP, WSL2 Mirrored Networking, and GPU HAGS / Ollama).
3. **Run Diagnostics & Generate Scorecard First:**
   Execute `powershell -ExecutionPolicy Bypass -File "<skill-dir>/scripts/diagnose-network-ai.ps1" -SaveReport` and present a clear summary of detected bottlenecks.
4. **Apply Optimizations & Verify (Auto-Backs Up First):**
   Execute `powershell -ExecutionPolicy Bypass -File "<skill-dir>/scripts/optimize-workstation.ps1"` (and provide the elevated PowerShell Admin block if UAC elevation is needed), then re-verify all parameters.

User request / context: $ARGUMENTS
