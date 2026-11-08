# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-11-08

### Added
- **Hardware & Software Optimization (`scripts/optimize-workstation.ps1`):**
  - Unlocks and activates the Windows `Ultimate Performance` power scheme (`e9a42b02-d5df-448d-aa00-03f14749eb61`, fallback to `High performance`) with `100%` AC minimum/maximum processor state.
  - Configures foreground CPU scheduling (`Win32PrioritySeparation = 38` / `0x26`) and disables background power throttling (`PowerThrottlingOff = 1`).
  - Consolidates `svchost.exe` service processes (`SvcHostSplitThresholdInKB`) to match installed physical RAM.
  - Enables DirectX Windowed Flip Model (`SwapEffectUpgradeEnable=1;`), Auto Game Mode, disables background `GameDVR` screen recording, and sets `MMCSS Tasks\Games` priority (`GPU Priority = 8`, `Priority = 6`).
  - Disables legacy NTFS 8.3 short filename creation (`8dot3name set 1`) and verifies SSD TRIM (`DisableDeleteNotify = 0`).
  - Reduces UI menu delay (`MenuShowDelay = 10`), disables background Microsoft Store app wakeups, and disables Windows Update P2P uploads (`DODownloadMode = 0`).
- **Execution Modes (`-Mode All | Work | Gaming`):**
  - `-Mode All` (Default): Full optimization for home PCs (Hardware, Software, Gaming, Network, Testing & AI).
  - `-Mode Work`: Safe optimization for company/office PCs (skips gaming registry tweaks and never touches corporate DNS, Active Directory, or VPN profiles).
  - `-Mode Gaming`: Dedicated mode for low-latency gaming and frame pacing.
- **Physical RAM Working-Set Trim (`scripts/free-ai-resources.ps1`):**
  - Calls native Win32 `EmptyWorkingSet` (`psapi.dll`) across idle background processes to reclaim physical system RAM alongside unloading idle Ollama models and closing orphaned WebDriver processes.
- **Real-world Benchmarks & Evidence:**
  - Added before/after Speedtest screenshots (`assets/`) and PowerShell verification logs to `README.md` and `README.vi.md`.
- **Open-Source Governance & CI:**
  - Added `LICENSE` (MIT), `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`, `package.json`, and GitHub Actions syntax/smoke-test workflow (`.github/workflows/ci.yml`).

## [2.0.0] - 2026-11-07

### Changed
- Renamed project from `network-ai-optimizer` to `agentic-workstation-optimizer` to reflect expanded scope across networking, corporate Cloud AI connectivity, QA automation, WSL2, and local AI.
- Rewrote all English and Vietnamese documentation in a straightforward developer tone.

### Added
- Automatic system state snapshot and 1-command rollback (`scripts/backup-and-rollback.ps1`).
- Corporate network compatibility: IPv4 DNS priority for Node.js (`--dns-result-order=ipv4first`), Windows SChannel SSL trust (`NODE_USE_SYSTEM_CA=1`, `git http.sslBackend=schannel`), and non-fragmented VPN MTU probing.
- Ephemeral port expansion (`MaxUserPort = 65534`, `TcpTimedWaitDelay = 30`) for parallel Playwright, Appium, and API test suites.
- WSL2 Mirrored Networking and gradual RAM reclaim configuration (`scripts/optimize-wsl2.ps1`).
- Dedicated `network-doctor` subagent for Claude Code, Google Antigravity, and OpenCode.

## [1.0.0] - 2026-11-07

### Added
- Initial release with Windows TCP stack unthrottling (`NetworkThrottlingIndex`), NIC hardware buffer tuning (`2048`), power-saving sleep state disabling (`EEE`, `ULP`, `ITR`), Cloud AI latency diagnostics, and universal multi-agent installer (`install.ps1`).
