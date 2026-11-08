# Agent Instructions (`agentic-workstation-optimizer`)

This repository contains the `agentic-workstation-optimizer` skill, the `network-doctor` subagent, and PowerShell scripts for diagnosing and optimizing Windows network performance, corporate AI API connectivity, automated testing port limits, WSL2 networking, and local LLM settings.

## Workflow for AI Assistants

1. **Read the Full Guide:** See [SKILL.md](./SKILL.md) for details on each setting.
2. **Run Diagnostics First (Read-Only):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/diagnose-network-ai.ps1 -SaveReport
   ```
3. **Apply Optimizations (Automatically backs up original settings first):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/optimize-workstation.ps1
   ```
4. **Revert to Original Settings (If requested):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/backup-and-rollback.ps1 -Action Rollback
   ```
5. **Free GPU VRAM & Close Leftover Test Drivers:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/free-ai-resources.ps1
   ```
6. **Router Configuration Guide (Optional, Home Networks Only):**
   See [references/router-optimization.md](./references/router-optimization.md).
