# Agentic Workstation Optimizer (`agentic-workstation-optimizer`)

[Read in English](./README.md) | **Tiếng Việt**

Bộ công cụ PowerShell và Skill hỗ trợ các AI Agent (Google Antigravity, Claude Code, OpenCode, Cursor, Codex, Windsurf, Copilot) tự động kiểm tra và tối ưu tốc độ mạng, kết nối API AI, môi trường chạy Automation Test (Playwright, Appium, API) và hiệu năng chạy AI cục bộ (Ollama, GPU) trên Windows.

---

## Lý do mình tạo bộ công cụ này

Trên Windows, nhiều thiết lập mặc định của hệ điều hành và driver card mạng được đặt ở mức tiết kiệm điện hoặc giới hạn thấp (ví dụ: giới hạn số gói tin xử lý mỗi mili-giây, bộ đệm nhận/truyền của card mạng nhỏ, hoặc bật chế độ ngủ của card LAN). Điều này khiến đường truyền thực tế 700–1000 Mbps đôi khi chỉ chạy được khoảng 200–250 Mbps trên máy tính.

Ngoài ra, khi làm việc hàng ngày với các công cụ AI (Claude Code, Cursor, OpenCode, Ollama) và chạy test tự động (Playwright, Appium, API testing), đặc biệt là trên mạng công ty, máy tính rất hay gặp các vấn đề thực tế sau:
- **Gọi API AI bị chậm hoặc lỗi chứng chỉ trên mạng công ty:** Mạng công ty thường bật IPv6 nội bộ nhưng không có đường ra quốc tế (làm Node.js phải chờ hết thời gian chờ IPv6 rồi mới chuyển sang IPv4, gây trễ khoảng 0.5 – 1.5 giây mỗi lần gọi lệnh) hoặc dùng tường lửa kiểm tra SSL (Zscaler, Fortinet) làm Git và Node.js báo lỗi chứng chỉ.
- **Đang nhận phản hồi dài từ AI thì bị đứng:** Khi bật VPN công ty, kích thước gói tin tối đa (MTU) bị nhỏ lại. Nếu gói tin lớn bị chặn, luồng chữ trả về từ Claude/OpenAI sẽ bị treo giữa chừng.
- **Chạy nhiều bài test song song bị lỗi kết nối:** Windows mặc định chỉ mở khoảng 16.000 cổng mạng tạm thời và giữ cổng chờ đóng tới 120 giây. Khi chạy Playwright E2E nhiều luồng hoặc bắn API test liên tục, máy dễ bị hết cổng.
- **WSL2 và Docker bị mất mạng khi bật VPN công ty** hoặc ngốn nhiều RAM không tự trả lại cho Windows.
- **Card đồ họa bị chiếm dụng bộ nhớ (VRAM) ngầm:** Sau khi chạy xong mô hình trên Ollama hoặc chạy test trình duyệt, các tiến trình chạy ngầm (`chromedriver`, `geckodriver`, hoặc model AI) vẫn nằm lại trong RAM/VRAM.

Bộ công cụ này gom toàn bộ các bước kiểm tra và khắc phục những vấn đề trên thành các script rõ ràng, kèm theo tính năng **sao lưu và khôi phục lại nguyên trạng cài đặt gốc** bất cứ lúc nào.

---

## Cài đặt

Yêu cầu: Windows 10/11 và PowerShell.

Chạy 3 lệnh sau để tải về và tự động cài Skill vào các công cụ AI đang có trên máy (Antigravity, Claude Code, OpenCode, Codex, Cursor):

```powershell
git clone https://github.com/AlexDo96/agentic-workstation-optimizer.git
cd agentic-workstation-optimizer
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### Cách gọi trong từng công cụ AI

| Công cụ AI / IDE | Cách sử dụng |
| :--- | :--- |
| **Claude Code CLI** | Gõ `/agentic-workstation-optimizer` hoặc gọi agent phụ `@network-doctor` |
| **OpenCode CLI** | Gõ `/agentic-workstation-optimizer` hoặc gọi agent `network-doctor` |
| **Google Antigravity** | Nhắn AI dùng skill `agentic-workstation-optimizer` hoặc agent `network-doctor` |
| **OpenAI Codex CLI** | Nhắn Codex chạy skill `agentic-workstation-optimizer` |
| **Cursor IDE** | Gõ `@agentic-workstation-optimizer` trong khung chat |
| **Windsurf / Copilot** | Mở thư mục dự án, AI sẽ tự đọc hướng dẫn trong file `AGENTS.md` |

---

## Các tính năng chính

### 1. Mở khóa tốc độ mạng trên Windows và Card mạng
- Tắt giới hạn xử lý gói tin mặc định của Windows (`NetworkThrottlingIndex = 0xffffffff`, `SystemResponsiveness = 0`) và mở giới hạn 20% băng thông dự trữ của QoS.
- Tự động nhận diện card mạng (Intel, Realtek, Broadcom, MediaTek) để tăng bộ đệm nhận/truyền (`ReceiveBuffers` và `TransmitBuffers`) từ mức mặc định `256/512` lên `2048`.
- Tắt các chế độ tự ngủ / tiết kiệm điện của card mạng LAN (`Energy Efficient Ethernet - EEE`, `Ultra Low Power Mode - ULP`, `Green Ethernet`) vốn hay làm tăng độ trễ (ping).
- Bật `TCPNoDelay = 1` và `TcpAckFrequency = 1` để máy gửi và xác nhận gói tin ngay lập tức thay vì gom gói chờ 200ms.

### 2. Tối ưu kết nối cho mạng công ty (An toàn, không đụng vào DNS hay VPN công ty)
- **Ưu tiên IPv4 cho Node.js (`NODE_OPTIONS=--dns-result-order=ipv4first`):** Giúp Claude Code, OpenCode, Playwright và các MCP server kết nối thẳng qua IPv4, tránh bị trễ khi mạng công ty không hỗ trợ IPv6 ra quốc tế.
- **Dùng kho chứng chỉ gốc của Windows cho Git và Node.js:** Bật `NODE_USE_SYSTEM_CA=1` và `git config --global http.sslBackend schannel` để tránh lỗi chứng chỉ SSL khi đi qua tường lửa công ty.
- **Kiểm tra kích thước gói tin (MTU) khi dùng VPN:** Tự động đo ngưỡng MTU không phân mảnh thực tế trên đường truyền để phát hiện trường hợp VPN làm rớt các gói tin lớn.

### 3. Hỗ trợ chạy Automation Test (Playwright, Appium, API) và công cụ lập trình
- **Mở rộng dải cổng mạng tạm thời (Ephemeral Ports):** Nâng giới hạn cổng từ ~16.000 lên 55.535 cổng (`MaxUserPort = 65534`) và giảm thời gian chờ đóng cổng (`TcpTimedWaitDelay`) từ 120 giây xuống 30 giây, giúp chạy test E2E song song hoặc gọi API liên tục không bị nghẽn cổng.
- **Giảm tải đọc/ghi ổ cứng khi quét thư mục lớn:** Bật `LongPathsEnabled = 1` (tránh lỗi đường dẫn dài quá 260 ký tự trên Windows) và tắt việc cập nhật thời gian truy cập file của NTFS (`disablelastaccess = 1`), giúp thao tác với `node_modules`, `.venv`, `.git` nhanh hơn.
- **Tăng bộ đệm cho Git và thời gian chờ cho Python (`uv`, `pip`):** Đặt `http.postBuffer = 500MB` cho Git và tăng timeout lên 120 giây khi tải các thư viện AI nặng.

### 4. Tối ưu chạy mô hình AI cục bộ (Ollama, GPU) và dọn bộ nhớ
- Chuyển chế độ nguồn của Windows sang `High Performance` và bật tính năng lập lịch GPU bằng phần cứng (`HAGS / HwSchMode = 2`).
- Bật `OLLAMA_FLASH_ATTENTION = 1` và nén bộ nhớ ngữ cảnh về 8-bit (`OLLAMA_KV_CACHE_TYPE = q8_0`), giúp giảm gần một nửa lượng VRAM tiêu thụ khi chạy ngữ cảnh dài trên Ollama.
- **Giải phóng VRAM và tắt các tiến trình bị treo (`scripts/free-ai-resources.ps1`):** Khi chạy xong mô hình trên Ollama hoặc đóng trình duyệt test, đôi khi mô hình vẫn nằm trong VRAM của card đồ họa và các tiến trình điều khiển trình duyệt (`chromedriver`, `geckodriver`, `msedgedriver`) vẫn chạy ngầm. Script này giúp tắt gọn các tiến trình bị kẹt đó để trả lại RAM và VRAM trống.

### 5. Sửa lỗi mất mạng và ngốn RAM của WSL2 / Docker (`scripts/optimize-wsl2.ps1`)
- Tạo file cấu hình `~/.wslconfig` bật chế độ mạng `networkingMode=mirrored`, `dnsTunneling=true`, `autoProxy=true` trên Windows 11. Nhờ đó WSL2 và Docker dùng chung kết nối mạng với Windows, không bị mất mạng khi bật VPN công ty.
- Bật `autoMemoryReclaim=gradual` và `sparseVhd=true` để WSL2 tự động trả lại RAM và dung lượng ổ cứng cho Windows khi không sử dụng.

### 6. Sao lưu và khôi phục cài đặt gốc (`scripts/backup-and-rollback.ps1`)
- Trước khi thay đổi bất kỳ thông số nào, script tối ưu sẽ tự động lưu toàn bộ cấu hình hiện tại của máy vào file `backups/latest-snapshot.json`.
- Nếu muốn đưa máy về lại đúng trạng thái ban đầu (rất cần thiết khi dùng trên máy công ty), bạn chỉ cần chạy lệnh Rollback.

---

## Cách chạy trực tiếp bằng PowerShell

Nếu không gọi qua AI Agent, bạn có thể mở **PowerShell (với quyền Administrator)** và chạy trực tiếp từng script theo nhu cầu:

```powershell
# 1. Kiểm tra hiện trạng mạng, độ trễ API AI, cấu hình máy và xuất báo cáo ra file BENCHMARK_REPORT.md
powershell -ExecutionPolicy Bypass -File .\scripts\diagnose-network-ai.ps1 -SaveReport

# 2. Chạy tối ưu toàn bộ (Tự động sao lưu cấu hình gốc trước khi thực hiện)
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-workstation.ps1

# 3. Tắt model Ollama đang chiếm VRAM và đóng các tiến trình WebDriver chạy ngầm bị treo
powershell -ExecutionPolicy Bypass -File .\scripts\free-ai-resources.ps1

# 4. Cấu hình mạng Mirrored và tự thu hồi RAM cho WSL2 / Docker
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-wsl2.ps1

# 5. Khôi phục toàn bộ cài đặt của máy về trạng thái ban đầu
powershell -ExecutionPolicy Bypass -File .\scripts\backup-and-rollback.ps1 -Action Rollback
```

---

## Kết quả thử nghiệm thực tế

Kết quả đo trước và sau khi áp dụng trên mạng cáp quang gia đình (kết hợp hướng dẫn cấu hình băng tần 5GHz `160MHz` trong `references/router-optimization.md`):
- **Trên máy tính bàn (cắm dây LAN qua cục thu Mesh Wi-Fi 6):** Tốc độ tải tăng từ `~220 Mbps` lên **`794.68 Mbps`**, ping giảm xuống `5 ms` (ping tới Google DNS `8.8.8.8` giảm từ `31 ms` xuống `26 ms`).
- **Trên điện thoại (kết nối vào sóng Wi-Fi 5GHz `160MHz` tách riêng):** Tốc độ tăng từ `287 Mbps` lên **`403 Mbps tải xuống / 417 Mbps tải lên`**, ping `6 ms`, độ trễ dao động (Jitter) `1 ms`.
