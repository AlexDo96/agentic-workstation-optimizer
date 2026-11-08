---
name: network-ai-optimizer
description: >-
  Universal AI Agent Skill (Antigravity, Claude Code, OpenCode, Cursor, Codex,
  Windsurf, Copilot) to diagnose, unlock, and optimize Windows network throughput
  (LAN/Wi-Fi adapters, TCP/IP stack, buffers, power saving, throttling), audit
  Cloud AI API streaming latency (Anthropic, OpenAI, Gemini, OpenRouter), tune
  router/gateway Wi-Fi 6 160MHz settings, and accelerate Local AI / Agentic CLI
  workloads (GPU HAGS, Power Plan, Ollama Flash Attention & KV Cache, Git/uv/pip).
  Includes an Enterprise-Safe mode for company workstations.
---

# Universal Network & AI Workstation Optimizer (`network-ai-optimizer`)

This skill provides a systematic, verifiable workflow for **any AI Coding Agent** (Google Antigravity, Claude Code, OpenCode, Cursor, OpenAI Codex CLI, Windsurf, GitHub Copilot) to diagnose network bottlenecks, unlock hardware/OS bandwidth limits on Windows workstations (often boosting speeds 2x–3x from ~200 Mbps to 700–1000 Mbps), eliminate SSE token-streaming lag to Cloud AI APIs, optimize Local LLM execution (Ollama / LM Studio / vLLM / CUDA), and safely inspect or tune router/gateway configurations.

---

## 1. Operating Modes (Determine Context First)

Before making changes, determine whether the user is on a **Company/Enterprise Workstation** or a **Home/Personal PC**:

1. **Enterprise / Office Mode (Default for Company PCs - No Gaming):**
   - **Focus:** Maximum network throughput for Cloud AI coding agents (Claude Code, Cursor, OpenCode, Codex, Antigravity), AI model/wheel downloads, Git/Docker, local LLM inference (Ollama/CUDA), and workstation responsiveness.
   - **Safety Rules:**
     - **DO NOT** modify corporate router/firewall settings without explicit confirmation and credentials.
     - **DO NOT** alter corporate VPNs, Domain Group Policies, or static IP/DNS settings if the machine is joined to an Active Directory domain or uses an internal corporate DNS server.
     - Focus 100% on unlocking Windows OS network throttling (`NetworkThrottlingIndex`), NIC hardware buffers (`Receive/Transmit Buffers`), disabling NIC power-saving (`EEE`, `ULP`, `Green Ethernet`), enabling `TCPNoDelay` (for instant SSE token streaming), and tuning GPU/CPU/AI/Git/Python parameters.
2. **Home / Personal Mode (Full Max):**
   - Includes all workstation + AI optimizations above, plus optional router/ONT inspection and tuning via browser (`192.168.1.1` / Default Gateway): 5GHz `160MHz` channel width, dedicated `5G` SSID creation, disabling `NAT Session Limit`, enabling `UPnP`, and binding `DHCP Static IP`.

---

## 2. Step-by-Step Execution Workflow

### Step 1: Run the Comprehensive Diagnostic Script
Run the bundled read-only diagnostic script to establish a baseline before changing anything:
- Script: [diagnose-network-ai.ps1](./scripts/diagnose-network-ai.ps1)

```powershell
powershell -ExecutionPolicy Bypass -File "<path-to-skill>/scripts/diagnose-network-ai.ps1"
```

**What to analyze from the output:**
1. **Active Adapter & Link Speed:** Is it `1 Gbps` (Ethernet) or Wi-Fi (`802.11ax/ac`)? What chip vendor (Intel, Realtek, Broadcom, MediaTek)?
2. **OS & NIC Bottleneck Indicators:**
   - `NetworkThrottlingIndex = 10` (Windows default caps background/multimedia packet processing to 10 packets/ms).
   - `ReceiveBuffers` / `TransmitBuffers` set to low defaults (`256` / `512` instead of `1024` / `2048`).
   - Power saving active on NIC: `Energy Efficient Ethernet (EEE) = On`, `Ultra Low Power Mode (ULP) = Enabled`, `Green Ethernet = Enabled`, or `Interrupt Moderation = Adaptive/Enabled`.
   - Background VPN/Tunneling processes intercepting traffic (`Cloudflare WARP`, `ProtonVPN`, `Zscaler`, `FortiClient`).
3. **Cloud AI API Handshake & Throughput Analysis:**
   - Inspect DNS lookup, TCP connect, and TLS handshake latency to `api.anthropic.com`, `api.openai.com`, `generativelanguage.googleapis.com`, `openrouter.ai`, and `api.github.com`.
   - Inspect single-stream download throughput from Cloudflare CDN (`speed.cloudflare.com`).
4. **Local AI & Agentic Tooling Readiness:**
   - Active Power Scheme (`Balanced` vs. `High performance`).
   - GPU status via `nvidia-smi`, VRAM usage, and `HwSchMode` (Hardware-Accelerated GPU Scheduling: `1` = Off, `2` = On).
   - `OLLAMA_FLASH_ATTENTION`, `OLLAMA_KV_CACHE_TYPE`, and `OLLAMA_NUM_PARALLEL`.
   - `Win32 LongPathsEnabled` and Git `core.longpaths` / `http.postBuffer` for large multi-agent repo operations.
   - Duplicate/bloat startup entries in `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run` (such as multiple `MicrosoftEdgeAutoLaunch_*` keys).

---

### Step 2: Unlock Workstation Network, Cloud AI Streaming & Local AI Performance
Apply user-level optimizations directly, and run (or provide to the user if UAC elevation is required) the optimization script:
- Script: [optimize-workstation.ps1](./scripts/optimize-workstation.ps1)

#### A. Non-Admin Optimizations (Agent can run directly):
1. **Power Plan:** Switch from `Balanced` to `High performance` (`powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c`).
2. **Local AI / LLM Environment Variables (User Scope):**
   - `OLLAMA_FLASH_ATTENTION = 1` (Accelerates token generation and reduces VRAM usage).
   - `OLLAMA_KV_CACHE_TYPE = q8_0` (Quantizes KV cache to 8-bit, nearly halving context VRAM usage with negligible quality loss).
   - `OLLAMA_NUM_PARALLEL = 2` (Allows concurrent subagent/embedding requests without blocking).
3. **Agentic CLI Tooling Resilience (Git / Python `uv` & `pip`):**
   - `git config --global core.longpaths true` & `git config --global http.postBuffer 524288000` (500MB buffer prevents Git RPC/HTTP2 disconnects when cloning or pushing large repos).
   - `UV_HTTP_TIMEOUT = 120` & `PIP_DEFAULT_TIMEOUT = 120` (Prevents timeouts when downloading multi-gigabyte PyTorch/CUDA wheels).
4. **Startup & Temp Cleanup (HKCU):**
   - Remove duplicate `MicrosoftEdgeAutoLaunch_*` registry keys in `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run`.
   - Disable background DVR capture (`GameDVR_Enabled = 0`, `AppCaptureEnabled = 0`) that wastes GPU encode/VRAM resources.
   - Clean `%TEMP%` directory and flush DNS cache (`ipconfig /flushdns`).

#### B. Admin-Level Hardware & OS Unlock (Run via elevated PowerShell):
If the current shell lacks Administrator privileges (`Access is denied` on `HKLM` or `Set-NetAdapterAdvancedProperty`), either run [optimize-workstation.ps1](./scripts/optimize-workstation.ps1) in an elevated prompt or give the user the command block to run in **PowerShell (Admin)**:

- **OS Network Stack Unlock:**
  - `NetworkThrottlingIndex = 0xffffffff` (Disables Windows packet throttling completely).
  - `SystemResponsiveness = 0` (Dedicates 100% of scheduling priority to active foreground workloads).
  - `NonBestEffortLimit = 0` (Unlocks the 20% QoS reserved bandwidth limit).
  - `TCPNoDelay = 1` & `TcpAckFrequency = 1` on the active NIC interface (Disables Nagle's algorithm so SSE token streams from Claude/OpenAI/Gemini and MCP tool calls are acknowledged and rendered immediately without 200ms buffering).
- **NIC Hardware Unlock (Auto-detects Intel, Realtek, Broadcom, MediaTek):**
  - Maxes out `*ReceiveBuffers` and `*TransmitBuffers` (up to `2048` or `1024` fallback).
  - Disables `EEELinkAdvertisement` / `*EEE` / `AdvancedEEE` / `GreenEthernet`.
  - Disables `ULPMode` (Ultra Low Power Mode) and `ReduceSpeedOnPowerDown`.
  - Sets `ITR` (Interrupt Moderation Rate) to `0` (`Off`) for instant CPU packet notification.
- **Workstation / AI System Unlock:**
  - Enables **HAGS** (`HwSchMode = 2` in `HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers`).
  - Enables **`LongPathsEnabled = 1`** in `HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem`.

---

### Step 3: Verify Workstation Improvements
After applying Step 2 (and after a reboot if `HwSchMode` or `NetworkThrottlingIndex` was changed):
1. Re-run [diagnose-network-ai.ps1](./scripts/diagnose-network-ai.ps1) to confirm all values reflect the unlocked state (`ReceiveBuffers = 2048`, `EEELinkAdvertisement = Off`, `HwSchMode = 2`, etc.).
2. Compare before/after download throughput and Cloud AI API latency.

---

### Step 4: Router / Gateway Inspection & Tuning (Optional / With Permission)
If the user still experiences high loaded latency (Bufferbloat), Wi-Fi throttling on laptops/mobile devices, or Mesh backhaul bottlenecks — **and has permission + credentials to access the gateway** — inspect the router web UI (typically `https://192.168.1.1` or the detected Default Gateway IP).

See the detailed guide in [references/router-optimization.md](./references/router-optimization.md).
