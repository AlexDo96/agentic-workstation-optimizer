# 🚀 Universal Network & AI Workstation Optimizer (`network-ai-optimizer`)

A **Universal AI Agent Skill & PowerShell Automation Suite** compatible out-of-the-box with **Google Antigravity, Claude Code, OpenCode, Cursor, OpenAI Codex CLI, Windsurf, and GitHub Copilot**.

It diagnoses network bottlenecks, unlocks Windows OS & NIC hardware throughput limits (boosting typical throttled speeds from ~200 Mbps to **700–1000 Mbps**), eliminates SSE token-streaming delay to Cloud AI APIs (`Anthropic`, `OpenAI`, `Gemini`, `OpenRouter`), optimizes Local AI / LLM inference (`Ollama`, `LM Studio`, `vLLM`, `CUDA`, `HAGS`), and tunes Wi-Fi 6 (`160MHz`) Mesh/ONT routers.

Includes a built-in **Enterprise-Safe Mode** specifically designed for company workstations (optimizes local OS network stack, NIC buffers, power, Git/Python tooling, and AI parameters without touching corporate DNS, Active Directory, VPNs, or company firewalls).

---

## 🤖 Supported AI Coding Agents & Auto-Discovery Matrix

This repository includes native discovery files for all major AI coding assistants PLUS a 1-click universal installer (`install.ps1`):

| AI Agent / IDE | Native Repo File | Global Install Path (via `install.ps1`) | How to Trigger |
| :--- | :--- | :--- | :--- |
| **Google Antigravity** | `SKILL.md` / `AGENTS.md` | `~/.gemini/config/skills/network-ai-optimizer/` | Ask to use `network-ai-optimizer` |
| **Claude Code CLI** | `CLAUDE.md` / `.claude/commands/` | `~/.claude/skills/` & `~/.claude/commands/` | Type `/network-ai-optimizer` or ask in chat |
| **OpenCode CLI** | `AGENTS.md` / `SKILL.md` | `~/.config/opencode/skills/` & `commands/` | Type `/network-ai-optimizer` or ask in chat |
| **OpenAI Codex CLI** | `AGENTS.md` / `SKILL.md` | `~/.codex/skills/network-ai-optimizer/` | Ask Codex to run `network-ai-optimizer` |
| **Cursor IDE** | `.cursor/rules/network-ai-optimizer.mdc` | `.cursor/rules/network-ai-optimizer.mdc` | `@network-ai-optimizer` or ask Agent |
| **Windsurf / Copilot** | `AGENTS.md` | Workspace `AGENTS.md` | Ask in Cascade / Copilot Chat |

---

## 📦 1-Command Universal Installation

Clone the repository and run **`install.ps1`** to automatically register the skill across **Antigravity, Claude Code, OpenCode, Codex, and Cursor** on your machine:

```powershell
git clone https://github.com/AlexDo96/network-ai-optimizer.git
cd network-ai-optimizer
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

---

## ✨ What It Optimizes

### 1. Network Hardware & Windows TCP/IP Stack Unlock
- **OS Packet Throttling Unlock:** Sets `NetworkThrottlingIndex = 0xffffffff` (removes Windows' default 10-packet/ms multimedia cap), `SystemResponsiveness = 0`, and QoS `NonBestEffortLimit = 0`.
- **NIC Hardware Buffers & Sleep Disable:** Auto-detects Intel/Realtek/Broadcom/MediaTek adapters, expands `ReceiveBuffers` & `TransmitBuffers` from `256/512` to **`2048`**, disables `Energy Efficient Ethernet (EEE)`, `Ultra Low Power Mode (ULP)`, `Green Ethernet`, and sets `Interrupt Moderation Rate (ITR) = Off`.
- **Instant Cloud AI Token Streaming (`TCPNoDelay`):** Enables `TCPNoDelay = 1` & `TcpAckFrequency = 1` (disables Nagle's 200ms buffering) so Server-Sent Events (SSE) token streams from Anthropic Claude, OpenAI, Gemini, and OpenRouter render instantaneously.

### 2. Cloud AI API & Agentic CLI Tooling Resilience
- **Cloud AI Endpoint Benchmarking:** Measures DNS lookup, TCP connect, and TLS handshake latency directly against `api.anthropic.com`, `api.openai.com`, `generativelanguage.googleapis.com`, `openrouter.ai`, and `api.github.com`.
- **VPN / Proxy Bottleneck Detection:** Detects background interceptors (`Cloudflare WARP`, VPNs, proxy vars) that degrade throughput.
- **Git & Python (`uv`/`pip`) Tuning:** Sets `git config --global core.longpaths true`, `http.postBuffer = 500MB`, `UV_HTTP_TIMEOUT = 120`, and Windows `LongPathsEnabled = 1` to prevent path-length and RPC errors in deep agentic workspaces.

### 3. Local AI / LLM Workstation Acceleration
- **GPU HAGS & Power Plan:** Activates Windows `High Performance` power scheme and enables **Hardware-Accelerated GPU Scheduling (`HwSchMode = 2`)**.
- **Ollama Hardware Acceleration:** Configures `OLLAMA_FLASH_ATTENTION = 1`, `OLLAMA_KV_CACHE_TYPE = q8_0` (saves ~50% context VRAM with 8-bit KV quantization), and `OLLAMA_NUM_PARALLEL = 2`.
- **System Cleanup:** Removes duplicate `MicrosoftEdgeAutoLaunch_*` startup keys, disables background `GameDVR` GPU capture overhead, and cleans `%TEMP%`.

### 4. Router / Gateway & Wi-Fi 6 (`160MHz`) Mesh Runbook
- Detailed guide (`references/router-optimization.md`) for identifying Wireless Mesh Backhaul vs. Wired ONT topology, unlocking **5GHz `160MHz`** channel width, creating a **Dedicated Pure-5GHz SSID** without disconnecting existing 2.4GHz IoT devices, and disabling CPU-draining `NAT Session Limit` counters.

---

## 📊 Real-World Benchmark Results
- **PC Wired/Mesh Throughput:** `220 Mbps` ➔ **`794.68 Mbps`** (`Ping 5ms`, Google DNS `26ms`)
- **Mobile Wi-Fi 6 (`160MHz` Dedicated 5G SSID):** `287 Mbps` ➔ **`403 Mbps Down / 417 Mbps Up`** (`Ping 6ms`, `Jitter 1ms`)
