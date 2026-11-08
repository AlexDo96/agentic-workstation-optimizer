# Agentic Workstation Optimizer (`agentic-workstation-optimizer`)

[Read in English](./README.md) | **Tiếng Việt**

Bộ công cụ PowerShell và Skill hỗ trợ các AI Agent (Google Antigravity, Claude Code, OpenCode, Cursor, Codex, Windsurf, Copilot) tự động kiểm tra và tối ưu toàn diện **phần cứng (CPU, GPU, RAM, ổ cứng SSD)**, **phần mềm hệ thống Windows**, **tốc độ mạng**, **hiệu năng chơi Game**, **môi trường chạy Automation Test (Playwright, Appium, API)** và **làm việc với AI (Cloud AI & Ollama cục bộ)**.

Hỗ trợ chế độ chạy riêng cho **máy tính ở nhà (`-Mode All` / `-Mode Gaming`)** và **máy tính trên công ty (`-Mode Work`)**, đi kèm cơ chế **tự động sao lưu và khôi phục cài đặt gốc** bằng 1 lệnh.

---

## Lý do mình tạo bộ công cụ này

Mặc định trên Windows 10 và Windows 11, nhiều thiết lập về quản lý xung nhịp CPU, phân bổ RAM, đọc/ghi ổ cứng SSD và driver card mạng được đặt ở mức tiết kiệm điện hoặc giữ tương thích cũ, làm máy chưa phát huy hết hiệu năng phần cứng:
- **Nghẽn phần cứng và phần mềm nền:** Chế độ nguồn mặc định (`Balanced`) thường hạ xung nhịp CPU hoặc bóp hiệu năng các tiến trình biên dịch/Docker chạy nền; Windows tách `svchost.exe` thành hàng chục tiến trình nhỏ gây tốn RAM; ổ cứng NTFS phải ghi lại thời gian truy cập (`LastAccess`) và tạo tên file ngắn kiểu cũ (`8.3`) mỗi khi quét qua hàng chục nghìn file trong `node_modules` hay `.venv`; tính năng tự quay màn hình ngầm (`GameDVR`) và tải cập nhật ngang hàng (`Windows Update P2P`) làm giảm FPS và gây giật ping khi đang chơi game hoặc họp trực tuyến.
- **Nghẽn tốc độ mạng trên đường truyền cáp quang nhanh:** Giới hạn 10 gói tin mỗi mili-giây (`NetworkThrottlingIndex`), bộ đệm nhận/truyền của card mạng nhỏ (`256/512`), cùng các chế độ tự ngủ của cổng LAN (`EEE`/`ULP`) khiến đường truyền 700–1000 Mbps nhiều khi chỉ nhận được khoảng 200–250 Mbps trên máy tính.
- **Gọi API AI bị chậm hoặc lỗi chứng chỉ trên mạng công ty:** Mạng công ty thường bật IPv6 nội bộ nhưng không có đường ra quốc tế (làm Node.js phải chờ hết thời gian chờ IPv6 rồi mới chuyển sang IPv4, gây trễ 0.5 – 1.5 giây mỗi lần gọi lệnh) hoặc dùng tường lửa kiểm tra SSL (Zscaler, Fortinet) làm Git và Node.js báo lỗi chứng chỉ.
- **Đang nhận phản hồi dài từ AI thì bị đứng:** Khi bật VPN công ty, kích thước gói tin tối đa (MTU) bị nhỏ lại. Nếu gói tin lớn bị rớt, luồng chữ trả về từ Claude/OpenAI sẽ bị treo giữa chừng.
- **Chạy nhiều bài test song song bị hết cổng kết nối:** Windows mặc định chỉ mở khoảng 16.000 cổng mạng tạm thời và giữ cổng chờ đóng tới 120 giây. Khi chạy Playwright E2E nhiều luồng hoặc bắn API test liên tục, máy rất dễ bị báo lỗi kết nối.
- **WSL2 và Docker bị mất mạng khi bật VPN công ty** hoặc ngốn nhiều RAM không tự trả lại cho Windows, cộng thêm các tiến trình `chromedriver` hoặc model AI trên Ollama vẫn chiếm dụng RAM/VRAM sau khi đã dùng xong.

Bộ công cụ này gom toàn bộ các bước kiểm tra và tối ưu phần cứng, phần mềm, mạng, Gaming và AI thành các script rõ ràng, có **tự động sao lưu trước khi chạy** để bạn yên tâm sử dụng trên cả máy cá nhân lẫn máy công ty.

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

## Chi tiết các hạng mục tối ưu

### 1. Tối ưu Phần cứng: CPU, Card đồ họa (GPU), RAM và Ổ cứng SSD
- **CPU & Chế độ nguồn:** Mở khóa và kích hoạt chế độ nguồn **`Ultimate Performance`** của Windows (hoặc `High performance`), giữ mức xung nhịp tối thiểu/tối đa khi cắm điện ở `100%` để tránh hiện tượng tụt xung gây khựng khung hình (stutter). Chỉnh bộ lập lịch nhân Windows (`Win32PrioritySeparation = 38` / `0x26`) để ưu tiên độ phản hồi cho cửa sổ đang dùng (Game, IDE) mà không làm nghẽn các tác vụ chạy nền, đồng thời tắt cơ chế bóp xung tiến trình nền (`PowerThrottlingOff = 1`) cho Docker, WSL2 và trình biên dịch.
- **GPU & Hiệu năng Gaming:** Bật lập lịch GPU bằng phần cứng (`HAGS / HwSchMode = 2`), bật `DirectX Windowed Flip Model` (`SwapEffectUpgradeEnable=1;`) giúp giảm độ trễ chuột/phím khi chơi game ở chế độ cửa sổ không viền (Borderless Windowed), bật `Auto Game Mode`, tắt tính năng tự quay màn hình chạy ngầm `GameDVR` (`GameDVR_Enabled = 0`), và thiết lập ưu tiên cao nhất cho tiến trình Game trong bộ lập lịch đa phương tiện của Windows (`MMCSS Tasks\Games`: `GPU Priority = 8`, `Priority = 6`, `Scheduling Category = High`).
- **Tối ưu phân bổ RAM & Thu hồi bộ nhớ thực:** Thiết lập `SvcHostSplitThresholdInKB` theo đúng tổng dung lượng RAM vật lý để Windows gộp các tiến trình `svchost.exe` bị phân mảnh. Đi kèm script `scripts/free-ai-resources.ps1` gọi trực tiếp hàm `EmptyWorkingSet` (`psapi.dll`) của Windows để thu hồi phần bộ nhớ vật lý đang bị các ứng dụng nền giữ dư thừa, trả lại hàng trăm MB đến hàng GB RAM trống ngay lập tức mà không làm đóng ứng dụng.
- **Tốc độ đọc/ghi ổ cứng SSD & NTFS:** Bật hỗ trợ đường dẫn dài quá 260 ký tự (`LongPathsEnabled = 1`), tắt việc ghi lại thời gian truy cập file (`disablelastaccess = 1`) và tắt việc tạo tên file ngắn kiểu cũ (`8dot3name set 1`) giúp tăng tốc độ quét thư mục `node_modules`, `.venv`, `.git` và thư mục cài game. Đồng thời kiểm tra bật lệnh `TRIM` (`DisableDeleteNotify = 0`) để duy trì tốc độ ghi cho ổ cứng SSD.

### 2. Tối ưu Phần mềm Windows, Giao diện & Tác vụ chạy ngầm
- Giảm độ trễ hiển thị menu của Windows từ `400ms` xuống `10ms` (`MenuShowDelay = 10`).
- Tắt việc tự động đánh thức ngầm các ứng dụng Microsoft Store không sử dụng (`GlobalUserDisabled = 1`).
- Tắt tính năng chia sẻ băng thông tải bản cập nhật ngang hàng (`Windows Update Delivery Optimization P2P / DODownloadMode = 0`) để máy không tự động upload dữ liệu làm tăng ping khi đang chơi game hoặc làm việc.
- Dọn các khóa khởi động trùng lặp của `MicrosoftEdgeAutoLaunch_*` và xóa các file rác tồn đọng trong thư mục `%TEMP%`.

### 3. Mở khóa tốc độ mạng trên Windows và Card mạng
- Tắt giới hạn xử lý gói tin mặc định của Windows (`NetworkThrottlingIndex = 0xffffffff`, `SystemResponsiveness = 0`) và mở giới hạn 20% băng thông dự trữ của QoS.
- Tự động nhận diện card mạng (Intel, Realtek, Broadcom, MediaTek) để tăng bộ đệm nhận/truyền (`ReceiveBuffers` và `TransmitBuffers`) từ mức mặc định `256/512` lên `2048`.
- Tắt các chế độ tự ngủ / tiết kiệm điện của card mạng LAN (`Energy Efficient Ethernet - EEE`, `Ultra Low Power Mode - ULP`, `Green Ethernet`) và tắt gom ngắt (`ITR = Off`).
- Bật `TCPNoDelay = 1` và `TcpAckFrequency = 1` để máy gửi và xác nhận gói tin ngay lập tức thay vì gom gói chờ 200ms (giúp giảm độ trễ khi chơi game online và nhận phản hồi AI nhanh hơn).

### 4. Tối ưu kết nối cho mạng công ty (`-Mode Work` an toàn tuyệt đối)
- **Ưu tiên IPv4 cho Node.js (`NODE_OPTIONS=--dns-result-order=ipv4first`):** Giúp Claude Code, OpenCode, Playwright và các MCP server kết nối thẳng qua IPv4, tránh bị trễ khi mạng công ty không hỗ trợ IPv6 ra quốc tế.
- **Dùng kho chứng chỉ gốc của Windows cho Git và Node.js:** Bật `NODE_USE_SYSTEM_CA=1` và `git config --global http.sslBackend schannel` để tránh lỗi chứng chỉ SSL khi đi qua tường lửa công ty.
- **Kiểm tra kích thước gói tin (MTU) khi dùng VPN:** Tự động đo ngưỡng MTU không phân mảnh thực tế trên đường truyền để phát hiện trường hợp VPN làm rớt các gói tin lớn.
- *Lưu ý an toàn:* Chế độ `-Mode Work` chỉ tối ưu hiệu năng máy và môi trường làm việc, không bao giờ thay đổi DNS nội bộ, Active Directory hay cấu hình VPN của công ty.

### 5. Hỗ trợ chạy Automation Test (Playwright, Appium, API) và công cụ lập trình
- **Mở rộng dải cổng mạng tạm thời (Ephemeral Ports):** Nâng giới hạn cổng từ ~16.000 lên 55.535 cổng (`MaxUserPort = 65534`) và giảm thời gian chờ đóng cổng (`TcpTimedWaitDelay`) từ 120 giây xuống 30 giây, giúp chạy test E2E song song hoặc gọi API liên tục không bị nghẽn cổng.
- **Tăng bộ đệm cho Git và thời gian chờ cho Python (`uv`, `pip`):** Đặt `http.postBuffer = 500MB` cho Git và tăng timeout lên 120 giây khi tải các thư viện AI nặng.

### 6. Tối ưu chạy mô hình AI cục bộ (Ollama, GPU), WSL2 và dọn bộ nhớ
- Bật `OLLAMA_FLASH_ATTENTION = 1` và nén bộ nhớ ngữ cảnh về 8-bit (`OLLAMA_KV_CACHE_TYPE = q8_0`), giúp giảm gần một nửa lượng VRAM tiêu thụ khi chạy ngữ cảnh dài trên Ollama.
- **Giải phóng VRAM, đóng WebDriver bị treo và thu hồi RAM (`scripts/free-ai-resources.ps1`):** Tự động tắt các model Ollama đang nằm chờ trong VRAM (`ollama stop`), đóng các tiến trình điều khiển trình duyệt bị kẹt (`chromedriver`, `geckodriver`, `msedgedriver`) và thu hồi RAM vật lý từ các tiến trình nền.
- **Sửa lỗi mất mạng và ngốn RAM của WSL2 / Docker (`scripts/optimize-wsl2.ps1`):** Cấu hình `~/.wslconfig` bật `networkingMode=mirrored`, `dnsTunneling=true`, `autoProxy=true` và `autoMemoryReclaim=gradual` để WSL2/Docker không bị mất mạng khi bật VPN công ty và tự trả lại RAM trống cho Windows.

### 7. Sao lưu và khôi phục cài đặt gốc (`scripts/backup-and-rollback.ps1`)
- Trước khi thay đổi bất kỳ thông số nào, script tối ưu sẽ tự động lưu toàn bộ cấu hình hiện tại của máy vào file `backups/latest-snapshot.json`.
- Nếu muốn đưa máy về lại đúng trạng thái ban đầu, bạn chỉ cần chạy 1 lệnh Rollback.

---

## Cách chạy trực tiếp bằng PowerShell

Bạn có thể mở **PowerShell (với quyền Administrator)** và chạy trực tiếp theo đúng nhu cầu sử dụng (ở nhà hoặc trên công ty):

```powershell
# 1. Kiểm tra toàn bộ phần cứng, phần mềm, mạng, độ trễ API AI và xuất báo cáo ra file BENCHMARK_REPORT.md
powershell -ExecutionPolicy Bypass -File .\scripts\diagnose-network-ai.ps1 -SaveReport

# 2A. Tối ưu toàn diện cho MÁY Ở NHÀ (Tất cả: Phần cứng, Phần mềm, Gaming, Mạng & AI)
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-workstation.ps1 -Mode All

# 2B. Tối ưu cho MÁY CÔNG TY (Chỉ tối ưu Phần cứng, Phần mềm, Mạng công ty, Test & AI; bỏ qua tinh chỉnh Game)
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-workstation.ps1 -Mode Work

# 2C. Tối ưu chuyên biệt cho GAMING
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-workstation.ps1 -Mode Gaming

# 3. Thu hồi RAM trống, tắt model Ollama đang chiếm VRAM và đóng các tiến trình WebDriver chạy ngầm
powershell -ExecutionPolicy Bypass -File .\scripts\free-ai-resources.ps1

# 4. Cấu hình mạng Mirrored và tự thu hồi RAM cho WSL2 / Docker
powershell -ExecutionPolicy Bypass -File .\scripts\optimize-wsl2.ps1

# 5. Khôi phục toàn bộ cài đặt của máy về trạng thái ban đầu
powershell -ExecutionPolicy Bypass -File .\scripts\backup-and-rollback.ps1 -Action Rollback
```

---

## Kết quả thử nghiệm thực tế

Kết quả đo trước và sau khi áp dụng trên máy tính bàn (Intel Core i5-8600K / 16GB RAM / RTX 3060 12GB VRAM):
- **Tốc độ mạng trên máy tính bàn (cắm dây LAN qua cục thu Mesh Wi-Fi 6):** Tăng từ `~220 Mbps` lên **`794.68 Mbps`**, ping giảm xuống `5 ms` (ping tới Google DNS `8.8.8.8` giảm từ `31 ms` xuống `26 ms`).
- **Tốc độ mạng trên điện thoại (kết nối vào sóng Wi-Fi 5GHz `160MHz` tách riêng):** Tăng từ `287 Mbps` lên **`403 Mbps tải xuống / 417 Mbps tải lên`**, ping `6 ms`, độ trễ dao động (Jitter) `1 ms`.
- **Thu hồi bộ nhớ (`free-ai-resources.ps1`):** Giải phóng ngay lập tức `~800 MB – 1.5 GB` RAM vật lý đang bị giữ bởi các tiến trình chạy nền chỉ trong 2 giây mà không làm ảnh hưởng đến ứng dụng đang mở.
