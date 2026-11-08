<div align="center">

# 🚀 Bộ Tối Ưu Hóa Mạng & Máy Trạm AI Toàn Diện (`network-ai-optimizer`)

**Bộ Kỹ Năng (Skill) AI Đa Nền Tảng & Script Tự Động Hóa PowerShell dành cho Google Antigravity, Claude Code, OpenCode, Cursor, OpenAI Codex CLI, Windsurf và GitHub Copilot.**

[![English](https://img.shields.io/badge/Language-English-blue?style=for-the-badge)](./README.md)
[![Tiếng Việt](https://img.shields.io/badge/Ngôn_ngữ-Tiếng_Việt-red?style=for-the-badge)](./README.vi.md)

[🌐 **Read in English**](./README.md) | [🇻🇳 **Đọc bản Tiếng Việt**](./README.vi.md)

</div>

---

Bộ công cụ giúp tự động chẩn đoán điểm nghẽn mạng, **mở khóa 100% giới hạn băng thông của hệ điều hành Windows & phần cứng Card mạng** (thường giúp tăng tốc độ từ mức bị bóp ~200 Mbps lên thẳng **700–1000 Mbps**), loại bỏ độ trễ khi truyền tải luồng chữ (SSE token streaming) tới các Cloud AI API (`Anthropic Claude`, `OpenAI`, `Gemini`, `OpenRouter`), tăng tốc chạy mô hình AI cục bộ (`Ollama`, `LM Studio`, `vLLM`, `CUDA`, `HAGS`), và tinh chỉnh Modem/Router Wi-Fi 6 (`160MHz`).

Tích hợp sẵn **Chế độ An toàn cho Công ty (Enterprise-Safe Mode)** dành riêng cho máy tính văn phòng: chỉ mở khóa ngăn xếp mạng Windows, bộ đệm phần cứng Card mạng, nguồn điện, công cụ Git/Python và thông số AI mà **tuyệt đối không can thiệp** vào DNS nội bộ, Active Directory, VPN công ty hay Tường lửa/Router của doanh nghiệp.

---

## 🤖 Ma Trận Hỗ Trợ Tự Động Trên Các AI Coding Agents

Repository này được thiết kế chuẩn hóa để tự động nhận diện trên mọi công cụ lập trình AI phổ biến hiện nay, kèm theo trình cài đặt tự động 1 chạm (`install.ps1`):

| AI Agent / IDE | File Nhận Diện Trong Repo | Đường Dẫn Cài Đặt Toàn Cục (qua `install.ps1`) | Cách Kích Hoạt |
| :--- | :--- | :--- | :--- |
| **Google Antigravity** | `SKILL.md` / `AGENTS.md` | `~/.gemini/config/skills/network-ai-optimizer/` | Nhắn AI dùng skill `network-ai-optimizer` |
| **Claude Code CLI** | `CLAUDE.md` / `.claude/commands/` | `~/.claude/skills/` & `~/.claude/commands/` | Gõ `/network-ai-optimizer` hoặc nhắn trong chat |
| **OpenCode CLI** | `AGENTS.md` / `SKILL.md` | `~/.config/opencode/skills/` & `commands/` | Gõ `/network-ai-optimizer` hoặc nhắn trong chat |
| **OpenAI Codex CLI** | `AGENTS.md` / `SKILL.md` | `~/.codex/skills/network-ai-optimizer/` | Nhắn Codex chạy `network-ai-optimizer` |
| **Cursor IDE** | `.cursor/rules/network-ai-optimizer.mdc` | `.cursor/rules/network-ai-optimizer.mdc` | Gõ `@network-ai-optimizer` hoặc nhắn Agent |
| **Windsurf / Copilot** | `AGENTS.md` | Workspace `AGENTS.md` | Nhắn trong Cascade / Copilot Chat |

---

## 📦 Cài Đặt Tự Động Chỉ Với 1 Lệnh

Clone repository về máy và chạy **`install.ps1`** để tự động đăng ký Skill vào tất cả các công cụ **Antigravity, Claude Code, OpenCode, Codex và Cursor** trên máy của bạn:

```powershell
git clone https://github.com/AlexDo96/network-ai-optimizer.git
cd network-ai-optimizer
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

---

## ✨ Các Hạng Mục Tối Ưu Hóa Chi Tiết

### 1. Mở Khóa Phần Cứng Card Mạng & Ngăn Xếp TCP/IP Windows
- **Gỡ bỏ trần giới hạn gói tin của Windows:** Đẩy `NetworkThrottlingIndex = 0xffffffff` (xóa bỏ mức trần mặc định 10 gói tin/mili-giây của Windows), đặt `SystemResponsiveness = 0`, và mở khóa 20% băng thông dự trữ QoS (`NonBestEffortLimit = 0`).
- **Tăng Kịch Trần Bộ Đệm Phần Cứng & Tắt Chế Độ Ngủ Card Mạng:** Tự động nhận diện chip mạng Intel / Realtek / Broadcom / MediaTek, nâng `ReceiveBuffers` & `TransmitBuffers` từ mức thấp `256/512` lên kịch trần **`2048`**, tắt hoàn toàn chế độ tiết kiệm điện gây trễ gói tin (`Energy Efficient Ethernet - EEE`, `Ultra Low Power Mode - ULP`, `Green Ethernet`), và đặt `Interrupt Moderation Rate (ITR) = Off`.
- **Truyền Tải Token Cloud AI Tức Thì (`TCPNoDelay`):** Bật `TCPNoDelay = 1` & `TcpAckFrequency = 1` (tắt thuật toán gom gói 200ms của Nagle), giúp luồng phản hồi SSE từ Claude, OpenAI, Gemini và các lời gọi MCP hiển thị ngay lập tức.

### 2. Tăng Tốc Kết Nối Cloud AI API & Công Cụ CLI (`Git`, `uv`, `pip`)
- **Đo Kiểm Độ Trễ Cloud AI Thực Tế:** Đo thời gian phân giải DNS, kết nối TCP và bắt tay TLS trực tiếp tới `api.anthropic.com`, `api.openai.com`, `generativelanguage.googleapis.com`, `openrouter.ai`, và `api.github.com`.
- **Phát Hiện Tiến Trình VPN / Proxy Gây Nghẽn:** Tự động phát hiện các phần mềm chạy ngầm (`Cloudflare WARP`, VPN, biến môi trường Proxy) làm giảm tốc độ mạng.
- **Tối Ưu Git & Python (`uv`/`pip`):** Tự động bật `git config --global core.longpaths true`, nâng bộ đệm `http.postBuffer = 500MB`, tăng thời gian chờ `UV_HTTP_TIMEOUT = 120` / `PIP_DEFAULT_TIMEOUT = 120`, và bật `LongPathsEnabled = 1` trên Windows để không bao giờ bị lỗi đường dẫn dài hơn 260 ký tự hay đứt kết nối khi tải thư viện AI nặng.

### 3. Tăng Tốc Máy Trạm Chạy Local AI / LLM
- **GPU HAGS & Nguồn Hiệu Năng Cao:** Kích hoạt chế độ nguồn `High Performance` cho CPU và bật **Hardware-Accelerated GPU Scheduling (`HwSchMode = 2`)** cho card đồ họa NVIDIA.
- **Tăng Tốc Phần Cứng Cho Ollama:** Tự động cấu hình `OLLAMA_FLASH_ATTENTION = 1`, nén bộ nhớ ngữ cảnh 8-bit `OLLAMA_KV_CACHE_TYPE = q8_0` (tiết kiệm ~50% dung lượng VRAM khi nạp tài liệu/code dài mà không giảm chất lượng), và đặt `OLLAMA_NUM_PARALLEL = 2`.
- **Dọn Rác Khởi Động & Giải Phóng VRAM:** Tự động xóa các khóa khởi động rác trùng lặp `MicrosoftEdgeAutoLaunch_*`, tắt tiến trình quay màn hình chạy ngầm `GameDVR` gây tốn VRAM, và dọn sạch `%TEMP%`.

### 4. Cẩm Nang Tối Ưu Modem / Router Wi-Fi 6 (`160MHz`) & Mesh
- Tài liệu hướng dẫn chi tiết (`references/router-optimization.md`) cách phát hiện mô hình cầu nối Mesh không dây (Wireless Backhaul) so với cắm dây trực tiếp, mở khóa độ rộng kênh **5GHz `160MHz`**, tạo **Mạng Wi-Fi 5GHz Độc Lập (`SSID Index 2`)** cho điện thoại/laptop mà không làm rớt mạng các thiết bị IoT 2.4GHz sẵn có trong nhà, và tắt bộ đếm `NAT Session Limit` gây quá tải CPU của Modem.

---

## 📊 Kết Quả Thực Tế Sau Khi Tối Ưu (Benchmark)
- **Tốc độ trên PC (LAN / Mesh Backhaul):** Từ `220 Mbps` ➔ Vọt lên **`794.68 Mbps`** (`Ping 5ms`, Google DNS `26ms`)
- **Tốc độ trên Điện thoại (Wi-Fi 6 `160MHz` sóng 5G riêng):** Từ `287 Mbps` ➔ Vọt lên **`403 Mbps Download / 417 Mbps Upload`** (`Ping 6ms`, `Jitter 1ms`)
