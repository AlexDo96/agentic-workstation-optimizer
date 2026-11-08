<div align="center">

# 🚀 Universal Network, QA Automation & AI Workstation Optimizer v2.0 (`network-ai-optimizer`)

**A Universal AI Agent Skill, Subagent (`@network-doctor`), and PowerShell Automation Suite for Google Antigravity, Claude Code, OpenCode, Cursor, OpenAI Codex CLI, Windsurf, and GitHub Copilot.**

[![English](https://img.shields.io/badge/Language-English-blue?style=for-the-badge)](./README.md)
[![Tiếng Việt](https://img.shields.io/badge/Ngôn_ngữ-Tiếng_Việt-red?style=for-the-badge)](./README.vi.md)
[![Version](https://img.shields.io/badge/Release-v2.0-success?style=for-the-badge)](https://github.com/AlexDo96/network-ai-optimizer)

[🌐 **Read in English**](./README.md) | [🇻🇳 **Đọc bản Tiếng Việt**](./README.vi.md)

</div>

---

**`network-ai-optimizer` v2.0** is an all-in-one systems engineering toolkit designed for **AI Engineers, QA Automation Architects (Playwright / Appium / API Testing), and Power Users**.

It unlocks Windows OS & NIC hardware throughput limits (boosting typical throttled speeds from ~200 Mbps to **700–1000 Mbps**), eliminates **Corporate Proxy / IPv6 Happy-Eyeballs / VPN MTU lag** when streaming from Cloud AI APIs (`Anthropic`, `OpenAI`, `Gemini`, `OpenRouter`), expands Windows Ephemeral Ports to **55,535 ports** for massive parallel E2E test execution, enables **WSL2 Mirrored Networking** (so Linux/Docker never loses internet when corporate VPNs turn on), and accelerates Local LLM inference (`Ollama`, `CUDA`, `HAGS`) — backed by an automatic **Time-Machine Backup & 1-Click Rollback**.

---

## 🤖 Supported AI Coding Agents & Auto-Discovery Matrix

This repository includes native discovery files for all major AI coding assistants, a dedicated **`network-doctor` Subagent**, and a 1-click universal installer (`install.ps1`):

| AI Agent / IDE | Native Repo File | Global Install Path (via `install.ps1`) | How to Trigger |
| :--- | :--- | :--- | :--- |
| **Google Antigravity** | `SKILL.md` / `.agents/agents/network-doctor.md` | `~/.gemini/config/skills/` & `agents/` | Ask to use `network-ai-optimizer` or `network-doctor` |
| **Claude Code CLI** | `CLAUDE.md` / `.claude/commands/` & `agents/` | `~/.claude/skills/`, `commands/`, `agents/` | Type `/network-ai-optimizer` or delegate to `@network-doctor` |
| **OpenCode CLI** | `AGENTS.md` / `SKILL.md` | `~/.config/opencode/skills/`, `commands/`, `agents/` | Type `/network-ai-optimizer` or call `network-doctor` |
| **OpenAI Codex CLI** | `AGENTS.md` / `SKILL.md` | `~/.codex/skills/network-ai-optimizer/` | Ask Codex to run `network-ai-optimizer` |
| **Cursor IDE** | `.cursor/rules/network-ai-optimizer.mdc` | `.cursor/rules/network-ai-optimizer.mdc` | `@network-ai-optimizer` or ask Agent |
| **Windsurf / Copilot** | `AGENTS.md` | Workspace `AGENTS.md` | Ask in Cascade / Copilot Chat |

---

## 📦 1-Command Universal Installation

Clone the repository and run **`install.ps1`** to automatically register the **Skill**, **Slash Command (`/network-ai-optimizer`)**, **Subagent (`network-doctor`)**, and **Cursor Rule** across your machine:

```powershell
git clone https://github.com/AlexDo96/network-ai-optimizer.git
cd network-ai-optimizer
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

---

## 🔥 What's New in v2.0 (6 Breakthrough Modules)

### 1. 🏢 Corporate Network & Cloud AI Piercer (Enterprise-Safe)
- **Eliminates IPv6 "Happy Eyeballs" 300–1500ms API Delay:** Automatically configures `NODE_OPTIONS="--dns-result-order=ipv4first"` so Node.js-based tools (Claude Code, OpenCode, Playwright, MCP servers) never hang on broken corporate IPv6 routes before falling back to IPv4.
- **Corporate SSL/TLS Inspection Compatibility (Zscaler / Fortinet / Netskope):** Enables `NODE_USE_SYSTEM_CA=1` and `git config --global http.sslBackend schannel` so Git and Node.js use the native Windows Certificate Store & SChannel instead of failing with `UNABLE_TO_VERIFY_LEAF_SIGNATURE`.
- **VPN MTU Blackhole Detector:** Probes non-fragmented packet ceiling (`ping -f -l`) to detect when corporate VPN tunnels shrink MTU below 1500 bytes (which causes long Claude/GPT SSE code streams to freeze mid-response).

### 2. 🧪 QA Automation (Playwright / Appium / API Testing) & Multi-Agent Turbo
- **55,535 Ephemeral Ports Unlock (`MaxUserPort = 65534` & `TcpTimedWaitDelay = 30s`):** Windows defaults to only ~16,000 dynamic ports held for 120s in `TIME_WAIT`, causing port exhaustion during parallel Playwright E2E runs, Newman/k6 API load tests, and heavy local MCP server traffic. v2.0 expands the pool to 55,535 ports and cuts `TIME_WAIT` to 30s.
- **Fast NTFS I/O (`NtfsDisableLastAccessUpdate = 1`):** Stops Windows from writing timestamp updates on every file read across tens of thousands of files in `node_modules`, `.venv`, and `.git` (boosting file traversal & browser launch speed by 15–25%).

### 3. 🐧 WSL2 & Docker Desktop Mirrored Networking (`scripts/optimize-wsl2.ps1`)
- Configures `~/.wslconfig` with Windows 11 **`networkingMode=mirrored`**, **`dnsTunneling=true`**, **`autoProxy=true`**, **`autoMemoryReclaim=gradual`**, and **`sparseVhd=true`**.
- **Result:** WSL2 and Docker containers achieve 100% native LAN speed, **never lose internet connectivity when Corporate VPNs turn on**, and automatically return idle gigabytes of `vmmemWSL` RAM back to Windows.

### 4. 🛡️ Time-Machine Backup & 1-Click Rollback (`scripts/backup-and-rollback.ps1`)
- Before `optimize-workstation.ps1` modifies any parameter, it automatically saves a full JSON snapshot of your original Registry keys, NIC hardware properties, User env vars, and Git config to `backups/latest-snapshot.json`.
- **1-Click Undo for Company PCs:** Run `powershell -ExecutionPolicy Bypass -File .\scripts\backup-and-rollback.ps1 -Action Rollback` to restore 100% original factory state in 3 seconds.

### 5. 🧹 1-Click Zombie Process & GPU VRAM Cleaner (`scripts/free-ai-resources.ps1`)
- Automatically unloads idle Ollama models sitting in GPU VRAM (`ollama ps` ➔ `ollama stop`), terminates orphaned QA WebDriver processes (`chromedriver`, `geckodriver`, `msedgedriver`), and reports exact freed VRAM via `nvidia-smi`.

### 6. 🏎️ Core NIC Hardware, GPU HAGS & Wi-Fi 6 (`160MHz`) Router Unlock
- **OS & NIC Unlock:** Sets `NetworkThrottlingIndex = 0xffffffff`, `SystemResponsiveness = 0`, `TCPNoDelay = 1`, `Receive/Transmit Buffers = 2048`, and disables `Energy Efficient Ethernet (EEE)` & `Ultra Low Power Mode (ULP)`.
- **Local AI Acceleration:** Enables `High Performance` power plan, GPU **HAGS (`HwSchMode = 2`)**, `OLLAMA_FLASH_ATTENTION = 1`, and 8-bit `OLLAMA_KV_CACHE_TYPE = q8_0` (saves ~50% context VRAM).
- **Automated Markdown Scorecard:** Run `.\scripts\diagnose-network-ai.ps1 -SaveReport` to generate a complete `BENCHMARK_REPORT.md` table.

---

## 🛠️ Command Cheat Sheet (PowerShell)

```powershell
# 1. Run full diagnostics & generate BENCHMARK_REPORT.md Scorecard
powershell -ExecutionPolicy Bypass -File .\scripts\diagnose-network-ai.ps1 -SaveReport

# 2. Apply full v2.0 Optimization (automatically creates Time-Machine backup first)
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-workstation.ps1

# 3. Free stuck Ollama GPU VRAM & orphaned Playwright/Selenium WebDrivers
powershell -ExecutionPolicy Bypass -File .\scripts\free-ai-resources.ps1

# 4. Optimize WSL2 & Docker Desktop Mirrored Networking + Auto RAM Reclaim
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-wsl2.ps1

# 5. 1-Click Rollback to original system state at any time
powershell -ExecutionPolicy Bypass -File .\scripts\backup-and-rollback.ps1 -Action Rollback
```

---

## 📊 Real-World Benchmark Results
- **PC Wired/Mesh Throughput:** `220 Mbps` ➔ **`794.68 Mbps`** (`Ping 5ms`, Google DNS `26ms`)
- **Mobile Wi-Fi 6 (`160MHz` Dedicated 5G SSID):** `287 Mbps` ➔ **`403 Mbps Down / 417 Mbps Up`** (`Ping 6ms`, `Jitter 1ms`)
