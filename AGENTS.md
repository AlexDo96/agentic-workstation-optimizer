# Universal Agent Instructions (`network-ai-optimizer`)

This repository contains the **Universal Network & AI Workstation Optimizer (`network-ai-optimizer`)** skill and automation scripts, compatible with **Google Antigravity, Claude Code, OpenCode, Cursor, OpenAI Codex CLI, Windsurf, and GitHub Copilot**.

## Quick Activation Runbook for All AI Agents

1. **Primary Skill Specification:** Read [SKILL.md](./SKILL.md) for the complete diagnostic and optimization workflow.
2. **Diagnostic Step (Always Run First):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/diagnose-network-ai.ps1
   ```
3. **Optimization Step (Enterprise-Safe by Default):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/optimize-workstation.ps1
   ```
4. **Router / Gateway Reference (Optional / With Permission):**
   Read [references/router-optimization.md](./references/router-optimization.md) when inspecting or tuning local ONT/Mesh routers (`160MHz` 5GHz bandwidth, dedicated `5G` SSID split, disabling `NAT Session Limit`).
5. **Cross-Agent Installation:**
   Run `powershell -ExecutionPolicy Bypass -File ./install.ps1` to install this skill globally across Antigravity, Claude Code, OpenCode, Codex, and Cursor on the current machine.
