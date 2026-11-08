# Universal Agent Instructions (`agentic-workstation-optimizer`)

This repository contains the **Universal Agentic Workstation, Network & QA Automation Optimizer v2.0 (`agentic-workstation-optimizer`)** skill, subagent (`network-doctor`), and automation scripts, compatible with **Google Antigravity, Claude Code, OpenCode, Cursor, OpenAI Codex CLI, Windsurf, and GitHub Copilot**.

## Quick Activation Runbook for All AI Agents

1. **Primary Skill Specification:** Read [SKILL.md](./SKILL.md) for the complete diagnostic and optimization workflow.
2. **Diagnostic Step (Always Run First):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/diagnose-network-ai.ps1 -SaveReport
   ```
3. **Optimization Step (Enterprise-Safe by Default, Auto-Backs Up First):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/optimize-workstation.ps1
   ```
4. **1-Click Rollback (If Requested):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/backup-and-rollback.ps1 -Action Rollback
   ```
5. **Router / Gateway Reference (Optional / With Permission):**
   Read [references/router-optimization.md](./references/router-optimization.md) when inspecting or tuning local ONT/Mesh routers (`160MHz` 5GHz bandwidth, dedicated `5G` SSID split, disabling `NAT Session Limit`).
6. **Cross-Agent Installation:**
   Run `powershell -ExecutionPolicy Bypass -File ./install.ps1` to install this skill and subagent globally across Antigravity, Claude Code, OpenCode, Codex, and Cursor on the current machine.
