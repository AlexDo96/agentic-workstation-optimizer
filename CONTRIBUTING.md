# Contributing to Agentic Workstation Optimizer

Thank you for your interest in contributing to `agentic-workstation-optimizer`.

## Core Principles

1. **Every change must be reversible:**
   If you add a new registry key, environment variable, or network adapter property in `scripts/optimize-workstation.ps1`, you **must** also add its original state capture and restoration logic to `scripts/backup-and-rollback.ps1`.
2. **Corporate Network Safety (`-Mode Work`):**
   Never modify DNS servers, Active Directory policies, firewall rules, or VPN profiles in `-Mode Work`. Optimizations in `-Mode Work` must be safe to run on managed enterprise laptops and desktops.
3. **Clear, Straightforward Documentation:**
   Write comments, console output, and documentation (`README.md`, `README.vi.md`, `SKILL.md`) in a clear, practical engineer tone. Avoid marketing buzzwords or exaggerated claims.
4. **Bilingual Parity:**
   Keep `README.md` (English) and `README.vi.md` (Vietnamese) synchronized when adding new features or flags.

## Testing Changes Locally

Before opening a Pull Request:

1. **Run the read-only diagnostic script:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\diagnose-network-ai.ps1 -SaveReport
   ```
2. **Test Backup & Optimization:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\optimize-workstation.ps1 -Mode Work
   ```
3. **Test Rollback:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\backup-and-rollback.ps1 -Action Rollback
   ```
4. **Test the Multi-Agent Installer:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1 -Scope Workspace -TargetWorkspace .
   ```
