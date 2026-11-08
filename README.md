# Agentic Workstation Optimizer (`agentic-workstation-optimizer`)

**English** | [Đọc bản Tiếng Việt](./README.vi.md)

A set of PowerShell scripts and AI Agent skill definitions (for Google Antigravity, Claude Code, OpenCode, Cursor, OpenAI Codex CLI, Windsurf, and GitHub Copilot) to diagnose and optimize Windows hardware, software, network speed, gaming frame pacing, corporate Cloud AI API connectivity, automated testing (Playwright, Appium, API tests), WSL2 networking, and local LLM resource usage (Ollama, GPU).

Designed to work safely on both **Company (Office) PCs** (`-Mode Work`) and **Home Gaming / AI PCs** (`-Mode All`), with automatic backup and 1-command rollback.

---

## Why I built this

Out of the box, Windows 10 and 11 configure CPU scheduling, power management, file system I/O, and network adapters for power saving and legacy compatibility rather than low latency or heavy developer/gaming workloads:
- **Hardware & OS bottlenecks:** Default Windows power plans park CPU cores and throttle background compilers/containers; `svchost.exe` splits into dozens of separate processes on 16GB–64GB RAM machines; NTFS updates `LastAccess` timestamps and legacy 8.3 short names on every file read across `node_modules` or `.venv`; and background `GameDVR` screen recording + Windows Update P2P uploads consume GPU/CPU cycles and bandwidth during games or builds.
- **Network throttling on fast fiber connections:** A 10-packet-per-millisecond multimedia cap (`NetworkThrottlingIndex`), small 256/512 NIC buffers, and Ethernet sleep states (`EEE`/`ULP`) often cap a 700–1000 Mbps fiber connection at ~200–250 Mbps and cause ping spikes in games.
- **Slow AI API calls or SSL errors on corporate networks:** Office networks frequently have partial IPv6 setups without external IPv6 routing, causing Node.js tools (Claude Code, OpenCode, MCP servers) to wait for IPv6 timeouts before falling back to IPv4 (adding 0.5–1.5s to requests). Corporate SSL inspection firewalls (Zscaler, Fortinet) also break Git and Node.js unless they are configured to trust the Windows certificate store.
- **AI responses freezing mid-stream over VPN:** Corporate VPN tunnels reduce maximum packet size (MTU) below 1500 bytes. When large packets are dropped, long streaming responses from Claude or OpenAI can hang.
- **Port exhaustion during parallel E2E / API test runs:** Windows only allocates ~16,000 dynamic ephemeral ports by default and holds closed connections in `TIME_WAIT` for 120 seconds, which quickly runs out during parallel Playwright, Appium, or API load tests.
- **WSL2 / Docker losing internet on VPN** or holding onto gigabytes of RAM, plus **idle Ollama models and orphaned WebDriver processes** (`chromedriver`, `geckodriver`, `msedgedriver`) occupying GPU VRAM and system RAM.

This repository brings all of these hardware, software, network, gaming, and AI optimizations together into clear scripts, backed by an automatic snapshot before any change is made.

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

## What it optimizes

### 1. Hardware Performance: CPU, GPU, RAM & SSD Storage
- **CPU Power & Scheduler:** Unlocks and activates the Windows `Ultimate Performance` power plan (or `High performance`), sets AC minimum/maximum processor state to `100%` to prevent core parking/downclocking stutters, sets `Win32PrioritySeparation = 38` (`0x26`) for responsive foreground apps and games while keeping background builds running smoothly, and disables background CPU power throttling (`PowerThrottlingOff = 1`) for Docker, WSL2, and compilers.
- **GPU & Gaming Frame Pacing:** Enables Hardware-Accelerated GPU Scheduling (`HAGS / HwSchMode = 2`), enables DirectX Windowed Flip Model (`SwapEffectUpgradeEnable=1;`) to reduce input latency in borderless windowed games, enables Windows Auto Game Mode, disables background `GameDVR` recording overhead (`GameDVR_Enabled = 0`), and configures the Windows Multimedia Class Scheduler (`MMCSS Tasks\Games`) to `GPU Priority = 8`, `Priority = 6`, and `Scheduling Category = High`.
- **RAM Consolidation & Active Memory Trim:** Sets `SvcHostSplitThresholdInKB` to match your total physical RAM so Windows consolidates dozens of separate `svchost.exe` processes. Includes `scripts/free-ai-resources.ps1`, which calls the native Win32 `EmptyWorkingSet` API (`psapi.dll`) to trim unused working-set pages from idle background apps back to free physical RAM.
- **SSD & File System I/O:** Enables Win32 long paths (`LongPathsEnabled = 1`), disables NTFS `LastAccess` timestamp writes (`disablelastaccess = 1`), disables legacy 8.3 short filename creation (`8dot3name set 1`) for faster operations on `node_modules` / `.venv` / game folders, and ensures SSD TRIM (`DisableDeleteNotify = 0`) is enabled.

### 2. Windows Software, UI Responsiveness & Background Cleanup
- Reduces desktop menu delay (`MenuShowDelay = 10` ms instead of 400 ms).
- Disables unnecessary background wakeups from Microsoft Store apps (`GlobalUserDisabled = 1`).
- Disables Windows Update Delivery Optimization P2P uploads (`DODownloadMode = 0`) so background peer uploads never cause ping spikes during games or video calls.
- Cleans duplicate `MicrosoftEdgeAutoLaunch_*` startup entries and clears stale files in `%TEMP%`.

### 3. Network Stack & NIC Hardware Tuning
- Removes the default Windows packet throttling cap (`NetworkThrottlingIndex = 0xffffffff`, `SystemResponsiveness = 0`) and unlocks the 20% QoS reserved bandwidth limit (`NonBestEffortLimit = 0`).
- Detects the active network adapter (Intel, Realtek, Broadcom, MediaTek) and increases hardware `ReceiveBuffers` and `TransmitBuffers` from `256/512` to `2048`.
- Disables adapter power-saving states (`Energy Efficient Ethernet - EEE`, `Ultra Low Power Mode - ULP`, `Green Ethernet`) and interrupt moderation (`ITR = Off`).
- Enables `TCPNoDelay = 1` and `TcpAckFrequency = 1` (disables Nagle's 200ms packet buffering) for lower latency in online games and faster AI streaming.

### 4. Corporate Network & Cloud AI Compatibility (`-Mode Work` Safe)
- **IPv4 priority for Node.js (`NODE_OPTIONS=--dns-result-order=ipv4first`):** Prevents Node.js tools (Claude Code, OpenCode, Playwright, MCP servers) from stalling on broken corporate IPv6 routes.
- **Windows Certificate Store integration:** Sets `NODE_USE_SYSTEM_CA=1` and `git config --global http.sslBackend schannel` so Git and Node.js work cleanly behind corporate SSL inspection proxies without disabling TLS verification.
- **MTU ceiling check:** Tests non-fragmented packet sizes (`ping -f -l`) to detect VPN tunnel overhead that could stall long streaming responses.
- *Safety guarantee:* Never changes corporate DNS servers, Active Directory settings, or VPN profiles.

### 5. QA Automation (Playwright, Appium, API Testing) & Developer Tooling
- **Expands ephemeral port range:** Increases `MaxUserPort` to `65534` (~55,535 dynamic ports) and lowers `TcpTimedWaitDelay` from 120s to 30s to prevent port exhaustion during parallel E2E and API test suites.
- **Git & Python network resilience:** Sets `git http.postBuffer = 500MB` and increases `UV_HTTP_TIMEOUT` / `PIP_DEFAULT_TIMEOUT` to 120s for large package downloads.

### 6. Local AI (Ollama / GPU), WSL2 & Memory Cleanup
- Sets `OLLAMA_FLASH_ATTENTION = 1` and 8-bit KV cache quantization (`OLLAMA_KV_CACHE_TYPE = q8_0`), cutting context VRAM usage by roughly half.
- **Frees GPU VRAM, closes leftover test drivers, and trims RAM (`scripts/free-ai-resources.ps1`):** Stops idle Ollama models sitting in GPU memory (`ollama stop`), closes orphaned WebDriver processes (`chromedriver`, `geckodriver`, `msedgedriver`), and trims background process working sets.
- **WSL2 Mirrored Networking & RAM Reclaim (`scripts/optimize-wsl2.ps1`):** Configures `~/.wslconfig` with `networkingMode=mirrored`, `dnsTunneling=true`, `autoProxy=true`, and `autoMemoryReclaim=gradual` so WSL2/Docker stays connected on corporate VPNs and returns unused RAM to Windows.

### 7. Automatic Backup & Rollback (`scripts/backup-and-rollback.ps1`)
- Before `optimize-workstation.ps1` changes any setting, it saves your current registry values, power plan, NIC properties, environment variables, and Git config to `backups/latest-snapshot.json`.
- You can restore all settings back to their original values at any time with a single command.

---

## Running the scripts directly in PowerShell

You can run the scripts manually in **PowerShell (Admin)** without an AI agent, choosing the mode that fits your PC:

```powershell
# 1. Run read-only diagnostics and save a summary table to BENCHMARK_REPORT.md
powershell -ExecutionPolicy Bypass -File .\scripts\diagnose-network-ai.ps1 -SaveReport

# 2A. Optimize a HOME PC (All: Hardware, Software, Gaming, Network & AI)
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-workstation.ps1 -Mode All

# 2B. Optimize a COMPANY / OFFICE PC (Work & AI only; skips gaming tweaks, safe for corporate networks)
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-workstation.ps1 -Mode Work

# 2C. Optimize for GAMING only
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-workstation.ps1 -Mode Gaming

# 3. Free GPU VRAM (idle Ollama models), close leftover WebDrivers, and trim idle System RAM
powershell -ExecutionPolicy Bypass -File .\scripts\free-ai-resources.ps1

# 4. Configure WSL2 Mirrored Networking and automatic RAM reclaim
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-wsl2.ps1

# 5. Revert all changes back to your original system state
powershell -ExecutionPolicy Bypass -File .\scripts\backup-and-rollback.ps1 -Action Rollback
```

---

## Real-world test results

Measured on an Intel Core i5-8600K / 16GB RAM / RTX 3060 (12GB VRAM) workstation before and after applying the optimizations:
- **Desktop PC (Ethernet via Wi-Fi 6 Mesh node):** Download speed increased from `~220 Mbps` to **`794.68 Mbps`**, idle gateway ping dropped to `5 ms` (Google DNS `8.8.8.8` ping dropped from `31 ms` to `26 ms`).
- **Mobile phone (connected to dedicated 5GHz `160MHz` SSID):** Speed increased from `287 Mbps` to **`403 Mbps download / 417 Mbps upload`**, `6 ms` ping, `1 ms` jitter.
- **System RAM & VRAM recovery (`free-ai-resources.ps1`):** Reclaimed `~800 MB – 1.5 GB` of idle background working-set RAM within 2 seconds without closing active applications.
