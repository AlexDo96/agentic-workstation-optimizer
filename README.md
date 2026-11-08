# 🚀 Network & AI Workstation Optimizer (`network-ai-optimizer`)

An Antigravity AI Agent Skill and PowerShell Automation Suite that diagnoses network bottlenecks, unlocks Windows OS & NIC hardware throughput limits (boosting typical throttled speeds from ~200 Mbps to **700–1000 Mbps**), reduces loaded ping (Bufferbloat), and tunes Windows workstations for high-speed Local AI / LLM inference (Ollama, CUDA, HAGS).

Includes an **Enterprise-Safe Mode** specifically designed for company workstations (optimizes local OS network stack, NIC buffers, power, and AI parameters without touching corporate DNS, Active Directory, VPNs, or company firewalls).

---

## ✨ Key Capabilities

1. **Comprehensive Network & AI Diagnostics (`scripts/diagnose-network-ai.ps1`)**
   - Audits active LAN/Wi-Fi adapters, hardware link speeds, and NIC driver properties (`Receive/Transmit Buffers`, `EEE`, `ULP`, `Interrupt Moderation`).
   - Detects Windows OS packet throttling (`NetworkThrottlingIndex`), QoS limits, and Nagle's algorithm (`TCPNoDelay`).
   - Identifies background VPN/Tunneling processes (`Cloudflare WARP`, VPN clients) intercepting traffic.
   - Measures gateway hop latency, international DNS ping, and single-stream CDN download throughput.
   - Audits GPU status (`nvidia-smi`), Hardware-Accelerated GPU Scheduling (`HAGS`), Power Plan, and Ollama acceleration flags.

2. **Workstation Network & AI Hardware Unlock (`scripts/optimize-workstation.ps1`)**
   - **OS Network Stack:** Unlocks `NetworkThrottlingIndex = 0xffffffff`, `SystemResponsiveness = 0`, `NonBestEffortLimit = 0`, and enables `TCPNoDelay = 1` + `TcpAckFrequency = 1`.
   - **NIC Hardware Tuning:** Auto-detects Intel/Realtek adapters, expands `ReceiveBuffers` & `TransmitBuffers` to `2048`, disables power-saving sleep states (`Energy Efficient Ethernet`, `Ultra Low Power Mode`, `Green Ethernet`), and optimizes interrupt moderation (`ITR`).
   - **AI & GPU Tuning:** Switches to `High Performance` power scheme, enables GPU **HAGS (`HwSchMode = 2`)**, enables **`LongPathsEnabled = 1`** (for Python/Node/HuggingFace), and configures **`OLLAMA_FLASH_ATTENTION=1`** + **`OLLAMA_KV_CACHE_TYPE=q8_0`** (saves ~50% context VRAM).
   - **System Cleanup:** Removes duplicate `MicrosoftEdgeAutoLaunch_*` startup bloat, disables background `GameDVR` screen-capture overhead, and flushes `%TEMP%` & DNS cache.

3. **Router / Gateway & Wi-Fi 6 Mesh Optimization Guide (`references/router-optimization.md`)**
   - Step-by-step runbook for identifying Wireless Mesh Backhaul vs. Wired ONT topology.
   - Unlocking **5GHz `160MHz`** channel width on Wi-Fi 6 routers.
   - Zero-downtime **Pure-5GHz SSID creation** (`SSID Index 2`) so mobile devices and laptops lock onto 5GHz without disconnecting existing 2.4GHz IoT devices.
   - Disabling CPU-draining `NAT Session Limit` counters and configuring `UPnP` & `Static DHCP`.

---

## 📦 Installation (Antigravity Skill)

Clone this repository directly into your Antigravity Global Skills directory or your project's `.agents/skills/` folder:

### Option 1: Install Globally (Available in all workspaces on your PC)
```powershell
git clone https://github.com/AlexDo96/network-ai-optimizer.git "$HOME\.gemini\config\skills\network-ai-optimizer"
```

### Option 2: Install in a Project Workspace
```powershell
git clone https://github.com/AlexDo96/network-ai-optimizer.git ".agents/skills/network-ai-optimizer"
```

---

## 🛠️ Usage

### With Antigravity Agent
Simply ask the agent in chat:
> *"Use the `network-ai-optimizer` skill to diagnose and unlock max network speed and AI performance on my workstation (Enterprise Safe mode)."*

### Standalone PowerShell Execution
You can also run the scripts directly from **PowerShell (Admin)**:

```powershell
# 1. Run read-only diagnostics
powershell -ExecutionPolicy Bypass -File .\scripts\diagnose-network-ai.ps1

# 2. Apply full Workstation Network & AI optimizations
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-workstation.ps1
```

---

## 📊 Real-World Benchmark Results
- **PC Wired/Mesh Throughput:** `220 Mbps` ➔ **`794.68 Mbps`** (`Ping 5ms`, Google DNS `26ms`)
- **Mobile Wi-Fi 6 (`160MHz` Dedicated 5G SSID):** `287 Mbps` ➔ **`403 Mbps Down / 417 Mbps Up`** (`Ping 6ms`, `Jitter 1ms`)
