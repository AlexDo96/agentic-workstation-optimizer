---
name: agentic-workstation-optimizer
description: >-
  Diagnose and optimize Windows network throughput (NIC buffers, EEE/ULP power
  saving, TCP stack), fix corporate network/VPN latency and SSL issues for Cloud AI
  APIs (Anthropic, OpenAI, Gemini, OpenRouter), expand ephemeral ports for automated
  testing (Playwright, Appium, API tests), configure WSL2 Mirrored Networking, and
  tune Local AI settings (GPU HAGS, Ollama Flash Attention & KV Cache) with automatic
  backup and rollback.
---

# Agentic Workstation Optimizer (`agentic-workstation-optimizer`)

This skill provides a practical workflow to diagnose and fix Windows network throttling, corporate network delays when calling Cloud AI APIs, port exhaustion during parallel E2E/API test runs, WSL2 VPN connectivity issues, and local LLM memory usage. All changes are backed up automatically before being applied so they can be reverted at any time.

---

## 1. Operating Modes (Check Context First)

1. **Office / Company PC Mode (Default):**
   - **Safety Rules:**
     - Do not modify company router or firewall settings unless explicitly requested and authorized.
     - Do not change corporate DNS servers, Active Directory settings, or VPN profiles.
   - **Scope:** Tune local Windows network throttling (`NetworkThrottlingIndex`), NIC hardware buffers (`2048`), Node.js IPv4 priority (`--dns-result-order=ipv4first`), Windows Certificate Store integration (`NODE_USE_SYSTEM_CA=1`, `git http.sslBackend=schannel`), ephemeral port range (`55,535` ports for Playwright/Appium/API tests), WSL2 Mirrored Networking, and GPU HAGS / Ollama settings.
2. **Home PC Mode:**
   - Includes all workstation optimizations above, plus optional local router tuning (`192.168.1.1`) if requested: 5GHz `160MHz` channel width, dedicated 5GHz SSID setup, disabling `NAT Session Limit`, and enabling `UPnP` / Static DHCP.

---

## 2. Included Scripts (`./scripts/`)

| Script | Purpose |
| :--- | :--- |
| [diagnose-network-ai.ps1](./scripts/diagnose-network-ai.ps1) | Read-only check: NIC buffers, Windows TCP stack, ephemeral ports, IPv6 vs IPv4 routing, non-fragmented MTU size, Cloud AI API latency, CDN download speed, GPU/Ollama settings, and `-SaveReport` summary generator. |
| [optimize-workstation.ps1](./scripts/optimize-workstation.ps1) | Main optimization script: Automatically runs `backup-and-rollback.ps1` first, then applies user-level and admin-level network, testing, WSL2, and AI settings. |
| [backup-and-rollback.ps1](./scripts/backup-and-rollback.ps1) | Saves current system settings to `backups/latest-snapshot.json` (`-Action Backup`) and restores original settings (`-Action Rollback`). |
| [optimize-wsl2.ps1](./scripts/optimize-wsl2.ps1) | Updates `~/.wslconfig` with `networkingMode=mirrored`, `dnsTunneling=true`, `autoProxy=true`, and `autoMemoryReclaim=gradual` so WSL2/Docker keeps network access on corporate VPNs and releases unused RAM. |
| [free-ai-resources.ps1](./scripts/free-ai-resources.ps1) | Stops idle Ollama models sitting in GPU VRAM (`ollama stop`) and closes leftover WebDriver processes (`chromedriver`, `geckodriver`, `msedgedriver`). |

---

## 3. Execution Steps

### Step 1: Run Diagnostics
```powershell
powershell -ExecutionPolicy Bypass -File "<path-to-skill>/scripts/diagnose-network-ai.ps1" -SaveReport
```
Review the output for:
- Small NIC buffers (`256`/`512` instead of `2048`) or enabled adapter power-saving modes (`EEE`, `ULP`, `ITR`).
- Default Windows packet throttling (`NetworkThrottlingIndex = 10`).
- Broken IPv6 routing (causing Node.js / Claude Code / Playwright to wait on IPv6 timeouts before using IPv4) or reduced MTU size over VPN (`Effective Non-Fragmented MTU < 1500`).
- Default ephemeral port limits (`MaxUserPort` unset).

### Step 2: Apply Optimizations (Automatically Backs Up First)
```powershell
powershell -ExecutionPolicy Bypass -File "<path-to-skill>/scripts/optimize-workstation.ps1"
```
*(If the current terminal is not running as Administrator, the script applies all user-level settings and prints instructions to run in an elevated PowerShell window for registry and network adapter changes).*

### Step 3: Verify Results
```powershell
powershell -ExecutionPolicy Bypass -File "<path-to-skill>/scripts/diagnose-network-ai.ps1" -SaveReport
```
Compare the before and after values for the user.

### Step 4: Revert Changes (If Needed)
```powershell
powershell -ExecutionPolicy Bypass -File "<path-to-skill>/scripts/backup-and-rollback.ps1" -Action Rollback
```

### Step 5: Router / Wi-Fi 6 Configuration (Optional, Home Networks Only)
See [references/router-optimization.md](./references/router-optimization.md).
