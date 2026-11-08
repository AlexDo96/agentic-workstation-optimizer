---
name: network-ai-optimizer
description: >-
  Diagnose, unlock, and optimize Windows network throughput (LAN/Wi-Fi adapters,
  TCP/IP stack, buffers, power saving, throttling), audit router/gateway latency
  and Wi-Fi 6/5GHz settings, and tune workstation hardware (GPU HAGS, Power Plan,
  Ollama Flash Attention & KV Cache, startup cleanup) for high-speed AI workloads
  and ultra-low-latency networking. Includes an Enterprise-Safe mode for company
  workstations.
---

# Network & AI Workstation Optimizer (`network-ai-optimizer`)

This skill provides a systematic, verifiable workflow to diagnose network bottlenecks, unlock hardware/OS bandwidth limits on Windows workstations (often boosting speeds 2x–3x from ~200 Mbps to 700–1000 Mbps), optimize local AI execution (Ollama / CUDA / LLM inference), and safely inspect or tune router/gateway configurations.

---

## 1. Operating Modes (Determine Context First)

Before making changes, determine whether the user is on a **Company/Enterprise Workstation** or a **Home/Personal PC**:

1. **Enterprise / Office Mode (Default for Company PCs - No Gaming):**
   - **Focus:** Maximum network throughput for AI model downloads, cloud APIs, Git/Docker, local LLM inference (Ollama/CUDA), and workstation responsiveness.
   - **Safety Rules:**
     - **DO NOT** modify corporate router/firewall settings without explicit confirmation and credentials.
     - **DO NOT** alter corporate VPNs, Domain Group Policies, or static IP/DNS settings if the machine is joined to an Active Directory domain or uses an internal corporate DNS server.
     - Focus 100% on unlocking Windows OS network throttling (`NetworkThrottlingIndex`), NIC hardware buffers (`Receive/Transmit Buffers`), disabling NIC power-saving (`EEE`, `ULP`, `Green Ethernet`), enabling `TCPNoDelay`, and tuning GPU/CPU/AI parameters.
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
2. **Bottleneck Indicators:**
   - `NetworkThrottlingIndex = 10` (Windows default caps multimedia/background packet processing to 10 packets/ms).
   - `ReceiveBuffers` / `TransmitBuffers` set to low defaults (`256` / `512` instead of `1024` / `2048`).
   - Power saving active on NIC: `Energy Efficient Ethernet (EEE) = On`, `Ultra Low Power Mode (ULP) = Enabled`, `Green Ethernet = Enabled`, or `Interrupt Moderation = Adaptive/Enabled`.
   - Background VPN/Tunneling processes intercepting traffic (`Cloudflare WARP`, `ProtonVPN`, corporate VPNs).
3. **Latency & Hop Analysis:**
   - Ping to Default Gateway (e.g., `192.168.1.1`): `<1ms` indicates direct wired connection; `2ms–5ms` indicates wireless Mesh backhaul or switch congestion.
   - Ping to Domestic vs. International (`8.8.8.8`, `1.1.1.1`) and single-stream download speed from Cloudflare CDN.
4. **AI & Workstation Readiness:**
   - Active Power Scheme (`Balanced` vs. `High performance`).
   - GPU status via `nvidia-smi`, VRAM usage, and `HwSchMode` (Hardware-Accelerated GPU Scheduling: `1` = Off, `2` = On).
   - `OLLAMA_FLASH_ATTENTION` and `OLLAMA_KV_CACHE_TYPE` environment variables.
   - Duplicate/bloat startup entries in `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run` (such as multiple `MicrosoftEdgeAutoLaunch_*` keys).

---

### Step 2: Unlock Workstation Network & AI Performance
Apply user-level optimizations directly, and run (or provide to the user if UAC elevation is required) the elevated optimization script:
- Script: [optimize-workstation.ps1](./scripts/optimize-workstation.ps1)

#### A. Non-Admin Optimizations (Agent can run directly in standard/bypass shell):
1. **Power Plan:** Switch from `Balanced` to `High performance` (`powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c`).
2. **AI / LLM Environment Variables (User Scope):**
   - `OLLAMA_FLASH_ATTENTION = 1` (Accelerates token generation and reduces VRAM usage on modern GPUs).
   - `OLLAMA_KV_CACHE_TYPE = q8_0` (Quantizes KV cache to 8-bit, nearly halving context VRAM usage with negligible quality loss).
3. **Startup & Temp Cleanup (HKCU):**
   - Remove duplicate `MicrosoftEdgeAutoLaunch_*` registry keys in `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run`.
   - Disable background DVR capture (`GameDVR_Enabled = 0`, `AppCaptureEnabled = 0`) that wastes GPU encode/VRAM resources.
   - Clean `%TEMP%` directory.

#### B. Admin-Level Hardware & OS Unlock (Run via elevated PowerShell):
If the current shell lacks Administrator privileges (`Access is denied` on `HKLM` or `Set-NetAdapterAdvancedProperty`), either run [optimize-workstation.ps1](./scripts/optimize-workstation.ps1) in an elevated prompt or give the user a single one-liner to paste into **PowerShell (Admin)**:

- **OS Network Stack Unlock:**
  - `NetworkThrottlingIndex = 0xffffffff` (Disables Windows packet throttling completely).
  - `SystemResponsiveness = 0` (Dedicates 100% of scheduling priority to active foreground workloads).
  - `NonBestEffortLimit = 0` (Unlocks the 20% QoS reserved bandwidth limit).
  - `TCPNoDelay = 1` & `TcpAckFrequency = 1` on the active NIC interface (Disables Nagle's algorithm so packets are transmitted immediately without 200ms buffering).
- **NIC Hardware Unlock (Auto-detects supported properties across Intel, Realtek, etc.):**
  - Maxes out `*ReceiveBuffers` and `*TransmitBuffers` (up to `2048` or highest supported value).
  - Disables `EEELinkAdvertisement` / `*EEE` (Energy Efficient Ethernet).
  - Disables `ULPMode` (Ultra Low Power Mode) and `ReduceSpeedOnPowerDown`.
  - Sets `ITR` (Interrupt Moderation Rate) to `0` (`Off`) for instant CPU packet notification (note: on heavy multi-core enterprise servers where CPU utilization is >90%, leave Interrupt Moderation on `Low` or `Adaptive` if preferred).
- **Workstation / AI System Unlock:**
  - Enables **HAGS** (`HwSchMode = 2` in `HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers`) so the GPU manages its own VRAM scheduling directly.
  - Enables **`LongPathsEnabled = 1`** in `HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem` to prevent Python `pip`, `venv`, `node_modules`, and HuggingFace cache path length errors on Windows.

---

### Step 3: Verify Workstation Improvements
After applying Step 2 (and after a reboot if `HwSchMode` or `NetworkThrottlingIndex` was changed):
1. Re-run [diagnose-network-ai.ps1](./scripts/diagnose-network-ai.ps1) to confirm all values reflect the unlocked state (`ReceiveBuffers = 2048`, `EEELinkAdvertisement = Off`, `HwSchMode = 2`, etc.).
2. Compare before/after download throughput and ping latency.

---

### Step 4: Router / Gateway Inspection & Tuning (Optional / With Permission)
If the user still experiences high loaded latency (Bufferbloat), Wi-Fi throttling on laptops/mobile devices, or Mesh backhaul bottlenecks — **and has permission + credentials to access the gateway** — inspect the router web UI (typically `https://192.168.1.1` or the detected Default Gateway IP).

See the detailed guide in [references/router-optimization.md](./references/router-optimization.md) for:
1. Detecting **Wireless Mesh Backhaul** vs. Wired Ethernet Backhaul.
2. Unlocking **5GHz Channel Bandwidth to `160MHz`** (`20/40/80/160MHz`).
3. Creating a **Dedicated Pure-5GHz SSID** (e.g., `<NetworkName> 5G` on `SSID Index 2` with `BandSteering` disabled) while leaving `SSID Index 1` untouched so existing IoT/office devices never disconnect.
4. Disabling performance-draining **`NAT Session Limit`** counters on GPON ONTs.
5. Reserving a **Static DHCP Lease** for the workstation MAC address.
