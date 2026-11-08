<div align="center">

# 🚀 Bộ Tối Ưu Hóa Mạng, QA Automation & Máy Trạm AI Toàn Diện v2.0 (`network-ai-optimizer`)

**Bộ Kỹ Năng (Skill) AI Đa Nền Tảng, Subagent (`@network-doctor`) & Script Tự Động Hóa PowerShell dành cho Google Antigravity, Claude Code, OpenCode, Cursor, OpenAI Codex CLI, Windsurf và GitHub Copilot.**

[![English](https://img.shields.io/badge/Language-English-blue?style=for-the-badge)](./README.md)
[![Tiếng Việt](https://img.shields.io/badge/Ngôn_ngữ-Tiếng_Việt-red?style=for-the-badge)](./README.vi.md)
[![Version](https://img.shields.io/badge/Phiên_bản-v2.0-success?style=for-the-badge)](https://github.com/AlexDo96/network-ai-optimizer)

[🌐 **Read in English**](./README.md) | [🇻🇳 **Đọc bản Tiếng Việt**](./README.vi.md)

</div>

---

**`network-ai-optimizer` v2.0** là bộ vũ khí kỹ thuật hệ thống toàn diện được thiết kế chuyên biệt cho **Kỹ sư AI (AI Engineers), Kỹ sư Kiểm thử Tự động (QA Automation / SDET với Playwright, Appium, API Testing) và Power Users**.

Bộ công cụ giúp mở khóa 100% giới hạn băng thông của Windows & phần cứng Card mạng (tăng tốc độ từ mức bị bóp ~200 Mbps lên thẳng **700–1000 Mbps**), loại bỏ triệt để **độ trễ Proxy công ty / lỗi IPv6 Happy-Eyeballs / nghẽn gói tin MTU khi bật VPN** đối với các Cloud AI API (`Anthropic Claude`, `OpenAI`, `Gemini`, `OpenRouter`), mở rộng dải cổng động lên **55.535 cổng Ephemeral Ports** cho chạy test E2E song song, bật **Mạng Phản Chiếu WSL2 (`Mirrored Networking`)** giúp Linux/Docker không bao giờ mất mạng khi bật VPN công ty, và tăng tốc chạy Local LLM (`Ollama`, `CUDA`, `HAGS`) — đi kèm cơ chế **Sao Lưu Time-Machine & Khôi Phục Nguyên Trạng 1-Chạm (`Rollback`)**.

---

## 🤖 Ma Trận Hỗ Trợ Tự Động Trên Các AI Coding Agents

Repository này tích hợp sẵn các file nhận diện tự nhiên cho mọi công cụ lập trình AI phổ biến, một **Subagent chuyên gia (`network-doctor`)**, và trình cài đặt tự động 1 chạm (`install.ps1`):

| AI Agent / IDE | File Nhận Diện Trong Repo | Đường Dẫn Cài Đặt Toàn Cục (qua `install.ps1`) | Cách Kích Hoạt |
| :--- | :--- | :--- | :--- |
| **Google Antigravity** | `SKILL.md` / `.agents/agents/network-doctor.md` | `~/.gemini/config/skills/` & `agents/` | Nhắn dùng skill `network-ai-optimizer` hoặc `network-doctor` |
| **Claude Code CLI** | `CLAUDE.md` / `.claude/commands/` & `agents/` | `~/.claude/skills/`, `commands/`, `agents/` | Gõ `/network-ai-optimizer` hoặc gọi `@network-doctor` |
| **OpenCode CLI** | `AGENTS.md` / `SKILL.md` | `~/.config/opencode/skills/`, `commands/`, `agents/` | Gõ `/network-ai-optimizer` hoặc gọi `network-doctor` |
| **OpenAI Codex CLI** | `AGENTS.md` / `SKILL.md` | `~/.codex/skills/network-ai-optimizer/` | Nhắn Codex chạy `network-ai-optimizer` |
| **Cursor IDE** | `.cursor/rules/network-ai-optimizer.mdc` | `.cursor/rules/network-ai-optimizer.mdc` | Gõ `@network-ai-optimizer` hoặc nhắn Agent |
| **Windsurf / Copilot** | `AGENTS.md` | Workspace `AGENTS.md` | Nhắn trong Cascade / Copilot Chat |

---

## 📦 Cài Đặt Tự Động Chỉ Với 1 Lệnh

Clone repository về máy và chạy **`install.ps1`** để tự động đăng ký **Skill**, **Slash Command (`/network-ai-optimizer`)**, **Subagent (`network-doctor`)**, và **Cursor Rule** trên toàn hệ thống:

```powershell
git clone https://github.com/AlexDo96/network-ai-optimizer.git
cd network-ai-optimizer
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

---

## 🔥 6 Module Đột Phá Trong Phiên Bản v2.0

### 1. 🏢 Module "Vượt Tường Lửa & Chống Delay Ngầm" Cho Mạng Công Ty (`Enterprise-Safe`)
- **Xóa bỏ độ trễ 300–1500ms do lỗi IPv6 "Happy Eyeballs":** Tự động cấu hình `NODE_OPTIONS="--dns-result-order=ipv4first"` để các công cụ nền tảng Node.js (Claude Code, OpenCode, Playwright, MCP Servers) gọi thẳng IPv4, không bị treo chờ timeout trên các mạng công ty có IPv6 nội bộ bị nghẽn.
- **Tương thích Chứng chỉ Bảo mật Công ty (`Corporate SSL Inspection` - Zscaler / Fortinet / Netskope):** Bật `NODE_USE_SYSTEM_CA=1` và chuyển Git sang nhân bảo mật gốc của Windows (`git config --global http.sslBackend schannel`), chấm dứt hoàn toàn lỗi `UNABLE_TO_VERIFY_LEAF_SIGNATURE` khi chạy trên mạng doanh nghiệp.
- **Dò tìm "Hố đen MTU" (`VPN MTU Blackhole Detector`):** Tự động bắn gói tin không phân mảnh (`ping -f -l`) để phát hiện hiện tượng thu hẹp MTU khi bật VPN công ty (Cisco/FortiClient/GlobalProtect/WARP) làm các luồng trả lời dài của Claude/GPT bị đơ giữa chừng.

### 2. 🧪 Module "QA Automation & Multi-Agent Turbo" (Playwright / Appium / API Testing)
- **Mở khóa 55.535 Cổng Động (`MaxUserPort = 65534` & `TcpTimedWaitDelay = 30s`):** Mặc định Windows chỉ có ~16.000 cổng tạm và giữ cổng ở trạng thái `TIME_WAIT` tới 120 giây, gây nghẽn cổng khi chạy **Playwright E2E song song**, bắn tải API (Postman/Newman/k6) hoặc chạy nhiều MCP Servers. v2.0 mở rộng lên 55.535 cổng và giải phóng cổng chỉ sau 30 giây.
- **Tăng tốc đọc/ghi đĩa NTFS (`NtfsDisableLastAccessUpdate = 1`):** Tắt việc ghi đè thời gian truy cập mỗi khi quét qua hàng chục ngàn file trong `node_modules`, `.venv`, `.git`, giúp AI Agent đọc code và khởi tạo trình duyệt Playwright nhanh hơn 15–25%.

### 3. 🐧 Giải Cứu Mạng & RAM Cho WSL2 / Docker Desktop (`scripts/optimize-wsl2.ps1`)
- Tự động cấu hình `~/.wslconfig` với công nghệ mới nhất của Windows 11: **`networkingMode=mirrored`**, **`dnsTunneling=true`**, **`autoProxy=true`**, **`autoMemoryReclaim=gradual`**, và **`sparseVhd=true`**.
- **Kết quả:** WSL2 và Docker chạy thẳng trên card mạng vật lý với 100% tốc độ LAN, **không bao giờ bị mất mạng khi bật VPN công ty**, và tự động trả lại hàng GB RAM (`vmmemWSL`) cho Windows khi nghỉ!

### 4. 🛡️ Cơ Chế "Cỗ Máy Thời Gian" (`scripts/backup-and-rollback.ps1`)
- Trước khi `optimize-workstation.ps1` chỉnh bất kỳ thông số nào, hệ thống tự động chụp ảnh (Snapshot) toàn bộ cấu hình Registry, Card mạng, Biến môi trường và Git gốc ra file `backups/latest-snapshot.json`.
- **Khôi phục Zin 100% chỉ với 1 lệnh:** Bất cứ lúc nào trên máy công ty, chỉ cần chạy `.\scripts\backup-and-rollback.ps1 -Action Rollback` là máy trở về nguyên trạng ban đầu trong 3 giây!

### 5. 🧹 Dọn Zombie Giải Phóng RAM & GPU VRAM 1-Chạm (`scripts/free-ai-resources.ps1`)
- Tự động xả các model Ollama đang ngâm ngầm trong VRAM (`ollama ps` ➔ `ollama stop`), diệt sạch các tiến trình WebDriver bị treo sau khi chạy test (`chromedriver`, `geckodriver`, `msedgedriver`), và báo cáo dung lượng VRAM trống tức thì qua `nvidia-smi`.

### 6. 🏎️ Mở Khóa Kịch Trần Card Mạng, GPU HAGS & Xuất Báo Cáo Điểm Số (`Scorecard`)
- **Mạng & Phần cứng:** Mở khóa `NetworkThrottlingIndex = 0xffffffff`, `SystemResponsiveness = 0`, `TCPNoDelay = 1`, nâng bộ đệm `Receive/Transmit Buffers = 2048`, tắt chế độ ngủ `EEE` & `ULP`.
- **Tăng tốc Local AI:** Bật nguồn `High Performance`, GPU **HAGS (`HwSchMode = 2`)**, `OLLAMA_FLASH_ATTENTION = 1` và nén ngữ cảnh 8-bit `OLLAMA_KV_CACHE_TYPE = q8_0` (tiết kiệm ~50% VRAM).
- **Xuất Bảng Điểm Markdown Tự Động:** Chạy `.\scripts\diagnose-network-ai.ps1 -SaveReport` để xuất file bảng điểm `BENCHMARK_REPORT.md` cực đẹp.

---

## 🛠️ Bảng Lệnh Nhanh (PowerShell)

```powershell
# 1. Chẩn đoán toàn diện & xuất bảng điểm BENCHMARK_REPORT.md
powershell -ExecutionPolicy Bypass -File .\scripts\diagnose-network-ai.ps1 -SaveReport

# 2. Chạy tối ưu hóa toàn diện v2.0 (Tự động tạo bản Backup Time-Machine trước khi chỉnh)
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-workstation.ps1

# 3. Giải phóng GPU VRAM (Ollama) & dọn các tiến trình WebDriver bị treo
powershell -ExecutionPolicy Bypass -File .\scripts\free-ai-resources.ps1

# 4. Tối ưu mạng Mirrored & tự động thu hồi RAM cho WSL2 / Docker Desktop
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-wsl2.ps1

# 5. Khôi phục (Rollback) 100% nguyên trạng ban đầu của máy bất cứ lúc nào
powershell -ExecutionPolicy Bypass -File .\scripts\backup-and-rollback.ps1 -Action Rollback
```

---

## 📊 Kết Quả Thực Tế Sau Khi Tối Ưu (Benchmark)
- **Tốc độ trên PC (LAN / Mesh Backhaul):** Từ `220 Mbps` ➔ Vọt lên **`794.68 Mbps`** (`Ping 5ms`, Google DNS `26ms`)
- **Tốc độ trên Điện thoại (Wi-Fi 6 `160MHz` sóng 5G riêng):** Từ `287 Mbps` ➔ Vọt lên **`403 Mbps Download / 417 Mbps Upload`** (`Ping 6ms`, `Jitter 1ms`)
