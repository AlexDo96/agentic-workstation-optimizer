---
name: agentic-workstation-optimizer
description: >-
  Universal AI Agent Skill v2.0 (Antigravity, Claude Code, OpenCode, Cursor, Codex,
  Windsurf, Copilot) to diagnose, unlock, and optimize Windows network throughput
  (NIC buffers, EEE/ULP, TCP stack), eliminate Corporate Proxy/IPv6/MTU lag for
  Cloud AI APIs (Anthropic, OpenAI, Gemini, OpenRouter), unlock 55k Ephemeral Ports
  for QA Automation (Playwright/Appium/API Testing), tune WSL2/Docker Mirrored
  Networking, and accelerate Local AI (GPU HAGS, Ollama Flash Attention & KV Cache).
  Includes Time-Machine Backup & 1-Click Rollback.
---

# Universal Agentic Workstation, Network & QA Automation Optimizer v2.0 (`agentic-workstation-optimizer`)

This skill provides a comprehensive, enterprise-safe workflow for **any AI Coding Agent** to unlock hardware/OS bandwidth limits on Windows workstations, eliminate Cloud AI API latency, supercharge parallel E2E/API test execution, optimize WSL2/Docker networking, and accelerate Local LLM inference — complete with automatic **Time-Machine Backup & 1-Click Rollback**.

---

## 1. Operating Modes (Determine Context First)

1. **Enterprise / Office Mode (Default for Company Workstations - No Gaming):**
   - **Safety Rules:**
     - **DO NOT** modify corporate router/firewall settings without explicit authorization.
     - **DO NOT** alter corporate DNS servers, Active Directory policies, or corporate VPN connections.
   - **Focus:** Unlocking local Windows OS packet throttling (`NetworkThrottlingIndex`), NIC hardware buffers (`2048`), Corporate AI Proxy Piercer (`ipv4first` + Windows `schannel` SSL), 55,000 Ephemeral Ports for QA Automation & MCP, WSL2 Mirrored Networking, and GPU HAGS / Ollama tuning.
2. **Home / Personal Mode (Full Max):**
   - Includes all workstation optimizations above, plus optional router/ONT inspection and tuning (`192.168.1.1`): 5GHz `160MHz` channel width, dedicated Pure-`5G` SSID creation, disabling `NAT Session Limit`, and `UPnP` / Static DHCP.

---

## 2. Automation Scripts Toolkit (`./scripts/`)

| Script | Purpose |
| :--- | :--- |
| [diagnose-network-ai.ps1](./scripts/diagnose-network-ai.ps1) | Read-only audit: NIC buffers, OS stack, QA ports, Corporate IPv6/MTU Blackhole probe, Cloud AI API TLS latency, CDN speed, GPU/Ollama status, and `-SaveReport` Markdown Scorecard generator. |
| [optimize-workstation.ps1](./scripts/optimize-workstation.ps1) | Master optimizer: Automatically calls `backup-and-rollback.ps1` first, then unlocks User + Admin network, Corporate AI, QA Turbo, WSL2, and GPU/Ollama settings. |
| [backup-and-rollback.ps1](./scripts/backup-and-rollback.ps1) | **Time-Machine Safety Net:** Saves original system state to `backups/latest-snapshot.json` (`-Action Backup`) and restores 100% original state in 3 seconds (`-Action Rollback`). |
| [optimize-wsl2.ps1](./scripts/optimize-wsl2.ps1) | Configures `~/.wslconfig` with `networkingMode=mirrored`, `dnsTunneling=true`, `autoProxy=true`, and `autoMemoryReclaim=gradual` so WSL2/Docker never loses network on corporate VPNs. |
| [free-ai-resources.ps1](./scripts/free-ai-resources.ps1) | 1-click cleanup: Unloads idle Ollama models from GPU VRAM (`ollama stop`) and terminates orphaned WebDriver processes (`chromedriver`, `geckodriver`, `msedgedriver`). |

---

## 3. Step-by-Step Execution Workflow

### Step 1: Run Diagnostics & Generate Baseline Scorecard
```powershell
powershell -ExecutionPolicy Bypass -File "<path-to-skill>/scripts/diagnose-network-ai.ps1" -SaveReport
```
Inspect the output for:
- Low NIC buffers (`256`/`512` vs `2048`) or active NIC sleep states (`EEE`, `ULP`, `ITR`).
- Default OS throttling (`NetworkThrottlingIndex = 10`).
- **IPv6 Happy-Eyeballs delay** (broken IPv6 routing delaying Node.js / Claude Code / Playwright by 300–1500ms) or **VPN MTU Blackholes** (`Effective Non-Fragmented MTU < 1500`).
- **QA Port Exhaustion** (`MaxUserPort` unset / default 16k ports).

### Step 2: Apply Master Workstation Optimization (Auto-Backs Up First)
```powershell
powershell -ExecutionPolicy Bypass -File "<path-to-skill>/scripts/optimize-workstation.ps1"
```
*(If the current terminal is not elevated as Administrator, run the script once for User-scope optimizations and provide the elevated PowerShell Admin command to unlock HKLM Registry & NIC Hardware properties).*

### Step 3: Verify & Generate Post-Optimization Scorecard
```powershell
powershell -ExecutionPolicy Bypass -File "<path-to-skill>/scripts/diagnose-network-ai.ps1" -SaveReport
```
Present the **Before vs. After** comparison table to the user.

### Step 4: Instant Rollback (If Ever Needed on a Company PC)
```powershell
powershell -ExecutionPolicy Bypass -File "<path-to-skill>/scripts/backup-and-rollback.ps1" -Action Rollback
```

### Step 5: Router / Gateway Wi-Fi 6 (`160MHz`) Optimization (Optional / With Permission)
See [references/router-optimization.md](./references/router-optimization.md).
