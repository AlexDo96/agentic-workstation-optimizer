# Agentic Workstation Optimizer (`agentic-workstation-optimizer`)

**English** | [Đọc bản Tiếng Việt](./README.vi.md)

A collection of PowerShell scripts and AI Agent skill definitions (for Google Antigravity, Claude Code, OpenCode, Cursor, OpenAI Codex CLI, Windsurf, and GitHub Copilot) to diagnose and fix Windows network throttling, corporate proxy/VPN latency for Cloud AI APIs, port exhaustion in automated testing (Playwright, Appium, API tests), WSL2 networking issues, and local LLM resource usage (Ollama, GPU).

---

## Why I built this

On Windows, default OS and network adapter settings are often tuned for power saving or legacy compatibility (such as a 10-packet-per-millisecond multimedia throttling cap, small 256/512 NIC buffers, and Ethernet sleep states). On a fast fiber connection, these defaults can bottleneck a 700–1000 Mbps link down to ~200–250 Mbps.

In addition, when working daily with AI coding agents (Claude Code, Cursor, OpenCode, Ollama) and running automated test suites (Playwright, Appium, API testing)—especially on corporate networks—several common issues tend to slow things down:
- **Slow AI API calls or SSL errors on corporate networks:** Many office networks have partial IPv6 configurations without external IPv6 routing, causing Node.js tools to wait for IPv6 timeouts before falling back to IPv4 (adding 0.5–1.5s to requests). Corporate firewalls (Zscaler, Fortinet) also perform SSL inspection, which breaks Git and Node.js unless they are configured to trust the Windows certificate store.
- **AI responses freezing mid-stream over VPN:** Corporate VPN tunnels reduce the maximum packet size (MTU) below 1500 bytes. When large packets are dropped silently, long streaming responses from Claude or OpenAI can hang.
- **Port exhaustion during parallel E2E / API test runs:** Windows only allocates ~16,000 dynamic ephemeral ports by default and holds closed connections in `TIME_WAIT` for 120 seconds. Running parallel Playwright tests, load tests, or multiple local MCP servers can quickly exhaust available ports.
- **WSL2 and Docker losing internet access when a corporate VPN connects**, or holding onto gigabytes of RAM even when idle.
- **Leftover background processes occupying RAM and GPU VRAM:** After running local models in Ollama or browser tests, loaded model weights and orphaned WebDriver binaries (`chromedriver`, `geckodriver`, `msedgedriver`) often stay in memory.

This repository packages the diagnostics and fixes for all of these issues into straightforward scripts, backed by an automatic **backup and 1-click rollback** mechanism so you can safely revert any change.

---

## Installation

Requirements: Windows 10/11 and PowerShell.

Clone the repository and run `install.ps1` to copy the skill, slash command, and subagent files into your local AI agent configuration folders:

```powershell
git clone https://github.com/AlexDo96/agentic-workstation-optimizer.git
cd agentic-workstation-optimizer
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### How to use in your AI Agent / IDE

| AI Agent / IDE | How to run |
| :--- | :--- |
| **Claude Code CLI** | Type `/agentic-workstation-optimizer` or ask `@network-doctor` |
| **OpenCode CLI** | Type `/agentic-workstation-optimizer` or call the `network-doctor` agent |
| **Google Antigravity** | Ask the agent to use the `agentic-workstation-optimizer` skill or `network-doctor` subagent |
| **OpenAI Codex CLI** | Ask Codex to run the `agentic-workstation-optimizer` skill |
| **Cursor IDE** | Mention `@agentic-workstation-optimizer` in chat |
| **Windsurf / Copilot** | Open the repo; the assistant reads `AGENTS.md` automatically |

---

## What it does

### 1. Windows Network Stack & NIC Hardware Tuning
- Removes the default Windows packet throttling cap (`NetworkThrottlingIndex = 0xffffffff`, `SystemResponsiveness = 0`) and unlocks the 20% QoS reserved bandwidth limit (`NonBestEffortLimit = 0`).
- Detects the active network adapter (Intel, Realtek, Broadcom, MediaTek) and increases hardware `ReceiveBuffers` and `TransmitBuffers` from `256/512` to `2048`.
- Disables adapter power-saving states (`Energy Efficient Ethernet - EEE`, `Ultra Low Power Mode - ULP`, `Green Ethernet`) that introduce latency spikes.
- Enables `TCPNoDelay = 1` and `TcpAckFrequency = 1` (disables Nagle's 200ms packet buffering) for more responsive streaming and low-latency connections.

### 2. Corporate Network & Cloud AI Compatibility (Safe for Office PCs)
- **IPv4 priority for Node.js (`NODE_OPTIONS=--dns-result-order=ipv4first`):** Prevents Node.js tools (Claude Code, OpenCode, Playwright, MCP servers) from stalling on broken corporate IPv6 routes.
- **Windows Certificate Store integration:** Sets `NODE_USE_SYSTEM_CA=1` and `git config --global http.sslBackend schannel` so Git and Node.js work cleanly behind corporate SSL inspection proxies without disabling TLS verification.
- **MTU ceiling check:** Tests non-fragmented packet sizes (`ping -f -l`) to detect VPN tunnel overhead that could stall long streaming responses.
- *Note:* The script never alters your corporate DNS servers, Active Directory settings, or VPN profiles.

### 3. QA Automation (Playwright, Appium, API Testing) & Developer Tooling
- **Expands ephemeral port range:** Increases `MaxUserPort` to `65534` (~55,535 dynamic ports) and lowers `TcpTimedWaitDelay` from 120s to 30s to prevent port exhaustion during parallel E2E and API test suites.
- **Reduces file system overhead on large repos:** Enables `LongPathsEnabled = 1` (fixes 260-character path errors) and disables NTFS `LastAccess` timestamp updates (`disablelastaccess = 1`) for faster reads across `node_modules`, `.venv`, and `.git`.
- **Git & Python network resilience:** Sets `git http.postBuffer = 500MB` and increases `UV_HTTP_TIMEOUT` / `PIP_DEFAULT_TIMEOUT` to 120s for large package downloads.

### 4. Local AI (Ollama / GPU) & Memory Cleanup
- Switches Windows to the `High Performance` power plan and enables Hardware-Accelerated GPU Scheduling (`HAGS / HwSchMode = 2`).
- Sets `OLLAMA_FLASH_ATTENTION = 1` and 8-bit KV cache quantization (`OLLAMA_KV_CACHE_TYPE = q8_0`), cutting context VRAM usage by roughly half.
- **Frees GPU VRAM and closes leftover test drivers (`scripts/free-ai-resources.ps1`):** Stops idle Ollama models still sitting in GPU memory (`ollama stop`) and closes leftover WebDriver processes (`chromedriver`, `geckodriver`, `msedgedriver`) left behind after test runs.

### 5. WSL2 & Docker Desktop Networking (`scripts/optimize-wsl2.ps1`)
- Configures `~/.wslconfig` on Windows 11 with `networkingMode=mirrored`, `dnsTunneling=true`, and `autoProxy=true` so WSL2 and Docker share the host network directly and stay connected when corporate VPNs are active.
- Enables `autoMemoryReclaim=gradual` and `sparseVhd=true` so WSL2 releases unused RAM and disk space back to Windows.

### 6. Automatic Backup & Rollback (`scripts/backup-and-rollback.ps1`)
- Before `optimize-workstation.ps1` changes any setting, it saves your current registry values, NIC properties, environment variables, and Git config to `backups/latest-snapshot.json`.
- You can restore all settings back to their original values at any time with a single command.

---

## Running the scripts directly in PowerShell

You can also run the scripts manually in **PowerShell (Admin)** without an AI agent:

```powershell
# 1. Run read-only diagnostics and save a summary table to BENCHMARK_REPORT.md
powershell -ExecutionPolicy Bypass -File .\scripts\diagnose-network-ai.ps1 -SaveReport

# 2. Apply optimizations (automatically saves a backup snapshot first)
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-workstation.ps1

# 3. Unload idle Ollama models from VRAM and close leftover WebDriver processes
powershell -ExecutionPolicy Bypass -File .\scripts\free-ai-resources.ps1

# 4. Configure WSL2 Mirrored Networking and automatic RAM reclaim
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-wsl2.ps1

# 5. Revert all changes back to your original system state
powershell -ExecutionPolicy Bypass -File .\scripts\backup-and-rollback.ps1 -Action Rollback
```

---

## Real-world test results

Measured on a home fiber connection before and after applying the workstation optimizations and configuring a dedicated 5GHz (`160MHz`) Wi-Fi channel (documented in `references/router-optimization.md`):
- **Desktop PC (Ethernet via Wi-Fi 6 Mesh node):** Download speed increased from `~220 Mbps` to **`794.68 Mbps`**, idle ping dropped to `5 ms` (Google DNS `8.8.8.8` ping dropped from `31 ms` to `26 ms`).
- **Mobile phone (connected to dedicated 5GHz `160MHz` SSID):** Speed increased from `287 Mbps` to **`403 Mbps download / 417 Mbps upload`**, `6 ms` ping, `1 ms` jitter.
