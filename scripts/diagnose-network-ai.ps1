<#
.SYNOPSIS
    v2.0 Comprehensive Diagnostic & Benchmark Suite for:
    - NIC Hardware Properties (Buffers, EEE, ULP, ITR) & Windows TCP Stack
    - Corporate Network Audit (IPv6 Happy-Eyeballs lag, VPN MTU Blackhole probe, TLS CA)
    - QA Automation & Multi-Agent Capacity (Ephemeral Port range, TimeWait, NTFS LastAccess)
    - Cloud AI Provider API Latency (Anthropic, OpenAI, Gemini, OpenRouter, GitHub) & DNS Race
    - Local AI & WSL2 Readiness (GPU HAGS, VRAM, Ollama flags, .wslconfig Mirrored Mode)
    - Optional Markdown Scorecard Generator (-SaveReport)
#>

param(
    [switch]$SaveReport,
    [string]$ReportPath = ""
)

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   1. ACTIVE NETWORK ADAPTERS & HARDWARE PROPERTIES" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$adapters = Get-NetAdapter | Where-Object Status -eq 'Up'
$adapters | Select-Object Name, InterfaceDescription, LinkSpeed, MacAddress | Format-Table -AutoSize

$primaryAdapter = $adapters | Where-Object { $_.InterfaceDescription -notmatch 'Virtual|VPN|WARP|Loopback|Bluetooth|Wireless Adapter for' } | Select-Object -First 1
if (-not $primaryAdapter) { $primaryAdapter = $adapters | Select-Object -First 1 }

$rxBuf = "N/A"; $txBuf = "N/A"; $eeeVal = "N/A"; $itrVal = "N/A"
if ($primaryAdapter) {
    Write-Host "Primary Adapter Selected: $($primaryAdapter.Name) ($($primaryAdapter.InterfaceDescription))" -ForegroundColor Yellow
    $advProps = Get-NetAdapterAdvancedProperty -Name $primaryAdapter.Name -ErrorAction SilentlyContinue
    $rxBuf  = ($advProps | Where-Object RegistryKeyword -eq '*ReceiveBuffers').DisplayValue
    $txBuf  = ($advProps | Where-Object RegistryKeyword -eq '*TransmitBuffers').DisplayValue
    $eeeVal = ($advProps | Where-Object { $_.RegistryKeyword -in @('EEELinkAdvertisement','*EEE','AdvancedEEE') } | Select-Object -First 1).DisplayValue
    $itrVal = ($advProps | Where-Object RegistryKeyword -eq 'ITR').DisplayValue

    $advProps | Where-Object { $_.RegistryKeyword -match 'Buffer|EEE|Green|Power|ULP|ITR|InterruptModeration|FlowControl' } |
        Select-Object DisplayName, DisplayValue, RegistryKeyword | Format-Table -AutoSize
}

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   2. OS NETWORK STACK, QA AUTOMATION PORTS & FILE SYSTEM I/O" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$sysProfile = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -ErrorAction SilentlyContinue
$psched     = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched' -ErrorAction SilentlyContinue
$tcpParams  = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' -ErrorAction SilentlyContinue
$fileSystem = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -ErrorAction SilentlyContinue

Write-Host ("NetworkThrottlingIndex : {0} (Default=10, Unlocked=4294967295 / 0xffffffff)" -f $sysProfile.NetworkThrottlingIndex)
Write-Host ("SystemResponsiveness   : {0}% (Default=20%, Unlocked=0%)" -f $sysProfile.SystemResponsiveness)
Write-Host ("QoS NonBestEffortLimit : {0} (Unlocked=0)" -f $psched.NonBestEffortLimit)
Write-Host ("QA MaxUserPort         : {0} (Default=N/A [16k ports], Turbo=65534 [55k ports])" -f $tcpParams.MaxUserPort)
Write-Host ("QA TcpTimedWaitDelay   : {0}s (Default=120s, Turbo=30s)" -f $tcpParams.TcpTimedWaitDelay)
Write-Host ("NTFS DisableLastAccess : {0} (0=Enabled [Slow], 1=Disabled [Fast I/O])" -f $fileSystem.NtfsDisableLastAccessUpdate)

$activeNics = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True" -ErrorAction SilentlyContinue
$tcpNoDelayStatus = "N/A"
foreach ($nic in $activeNics) {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($nic.SettingID)"
    $ifProps = Get-ItemProperty $regPath -ErrorAction SilentlyContinue
    if ($null -ne $ifProps.TCPNoDelay) { $tcpNoDelayStatus = $ifProps.TCPNoDelay }
    Write-Host ("Interface [{0}] IP={1} | Gateway={2} | DNS={3}" -f $nic.Description, ($nic.IPAddress -join ','), ($nic.DefaultIPGateway -join ','), ($nic.DNSServerSearchOrder -join ','))
    Write-Host ("   -> TCPNoDelay={0} | TcpAckFrequency={1}" -f $ifProps.TCPNoDelay, $ifProps.TcpAckFrequency)
}

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "   3. CORPORATE NETWORK, IPV6 HAPPY-EYEBALLS & VPN MTU AUDIT" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$vpnProcs = Get-Process | Where-Object { $_.ProcessName -match 'warp|vpn|wireguard|openvpn|tailscale|zerotier|cisco|forti|globalprotect|zscaler|steam|onedrive|dropbox' }
if ($vpnProcs) {
    $vpnProcs | Select-Object ProcessName, Id, @{n='RAM_MB';e={[math]::Round($_.WorkingSet64/1MB,1)}} | Format-Table -AutoSize
} else {
    Write-Host "[OK] No active VPN/Tunnel or heavy background sync processes detected." -ForegroundColor Green
}

# Check IPv6 vs IPv4 routing to detect Happy Eyeballs lag on Node.js / Claude Code
$ipv4Test = curl.exe -4 -o NUL -s -m 3 -w "%{http_code}" https://api.anthropic.com 2>$null
$ipv6Test = curl.exe -6 -o NUL -s -m 2 -w "%{http_code}" https://api.anthropic.com 2>$null
$nodeOpts = [Environment]::GetEnvironmentVariable('NODE_OPTIONS', 'User')
$nodeCa   = [Environment]::GetEnvironmentVariable('NODE_USE_SYSTEM_CA', 'User')
Write-Host "IPv4 Connectivity (Anthropic) : HTTP $ipv4Test"
Write-Host "IPv6 Connectivity (Anthropic) : $(if ($ipv6Test -and $ipv6Test -ne '000') { "HTTP $ipv6Test (Working)" } else { "Unreachable / Timeout (Potential Happy-Eyeballs lag if not ipv4first)" })"
Write-Host "NODE_OPTIONS (IPv4 Priority)  : $nodeOpts (Recommended: --dns-result-order=ipv4first)"
Write-Host "NODE_USE_SYSTEM_CA (Corp SSL) : $nodeCa (Recommended: 1)"

# Probe non-fragmented MTU ceiling (detects VPN MTU Blackholes that freeze SSE streams)
$mtuCeiling = 1500
foreach ($payload in @(1472, 1440, 1400, 1360)) {
    $pingMtu = ping -n 1 -w 1000 -f -l $payload 8.8.8.8 2>$null
    if ($pingMtu -match "Reply from") {
        $mtuCeiling = $payload + 28
        break
    }
}
Write-Host ("Effective Non-Fragmented MTU  : {0} bytes {1}" -f $mtuCeiling, $(if ($mtuCeiling -lt 1500) { "(VPN/Tunnel overhead detected!)" } else { "(Full 1500 Ethernet MTU)" }))

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "   4. CLOUD AI PROVIDER API LATENCY, DNS RACE & CDN SPEED" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$gw = ($activeNics | Where-Object { $_.DefaultIPGateway } | Select-Object -First 1).DefaultIPGateway[0]
$gwPingMs = "N/A"
if ($gw) {
    $gwOut = ping -n 3 $gw
    if ($gwOut -match "Average = (\d+)ms") { $gwPingMs = "$($matches[1]) ms" }
    Write-Host "Default Gateway ($gw) Average Ping: $gwPingMs" -ForegroundColor Green
}

$googlePingMs = "N/A"
$gOut = ping -n 3 8.8.8.8
if ($gOut -match "Average = (\d+)ms") { $googlePingMs = "$($matches[1]) ms" }
Write-Host "Google DNS (8.8.8.8) Average Ping     : $googlePingMs" -ForegroundColor Green

$aiEndpoints = @(
    @{ Name = "Anthropic (Claude Code / API)"; Url = "https://api.anthropic.com" },
    @{ Name = "OpenAI (Codex / Cursor / API)"; Url = "https://api.openai.com" },
    @{ Name = "Google Gemini (Antigravity)";   Url = "https://generativelanguage.googleapis.com" },
    @{ Name = "OpenRouter (OpenCode / Multi)"; Url = "https://openrouter.ai" },
    @{ Name = "GitHub (Copilot / Git)";        Url = "https://api.github.com" }
)

Write-Host "`n--- Cloud AI Provider TLS Handshake & Connect Latency ---" -ForegroundColor Gray
$aiResults = @{}
foreach ($ep in $aiEndpoints) {
    $timing = curl.exe -4 -o NUL -s -m 5 -w "DNS:%{time_namelookup}s | TCP:%{time_connect}s | TLS:%{time_appconnect}s" $ep.Url
    $aiResults[$ep.Name] = $timing
    Write-Host ("{0,-32} -> {1}" -f $ep.Name, $timing)
}

Write-Host "`n-> Testing 25MB Download Speed from Cloudflare CDN..." -ForegroundColor Gray
$speedBytes = curl.exe -4 -o NUL -s -w "%{speed_download}" https://speed.cloudflare.com/__down?bytes=25000000
$mbps = 0
if ($speedBytes -match '^\d+') {
    $mbps = [math]::Round(([double]$speedBytes * 8) / 1000000, 2)
    $mbs  = [math]::Round([double]$speedBytes / 1000000, 2)
    Write-Host "Single-Stream Cloudflare Throughput: $mbps Mbps ($mbs MB/s)" -ForegroundColor Green
}

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "   5. LOCAL AI WORKSTATION, WSL2 & AGENTIC TOOLING READINESS" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$powerScheme = powercfg /getactivescheme
$hags = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -ErrorAction SilentlyContinue).HwSchMode
$longPaths = $fileSystem.LongPathsEnabled
$flashAttn = [Environment]::GetEnvironmentVariable('OLLAMA_FLASH_ATTENTION', 'User')
$kvCache   = [Environment]::GetEnvironmentVariable('OLLAMA_KV_CACHE_TYPE', 'User')
$ollamaParallel = [Environment]::GetEnvironmentVariable('OLLAMA_NUM_PARALLEL', 'User')
$wslMirrored = if ((Test-Path "$HOME\.wslconfig") -and ((Get-Content "$HOME\.wslconfig" -Raw) -match 'networkingMode\s*=\s*mirrored')) { "Enabled (Mirrored)" } else { "Default NAT / Not Configured" }

Write-Host "Active Power Plan      : $powerScheme"
Write-Host "GPU HAGS (HwSchMode)   : $hags (1=Disabled, 2=Enabled)"
Write-Host "Win32 LongPathsEnabled : $longPaths (1=Enabled)"
Write-Host "WSL2 Network Mode      : $wslMirrored"
Write-Host "OLLAMA_FLASH_ATTENTION : $flashAttn (Recommended=1)"
Write-Host "OLLAMA_KV_CACHE_TYPE   : $kvCache (Recommended=q8_0)"
Write-Host "OLLAMA_NUM_PARALLEL    : $ollamaParallel (Recommended=2)"

if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitPostBuffer = git config --global http.postBuffer
    $gitLongPaths  = git config --global core.longpaths
    $gitSslBackend = git config --global http.sslBackend
    Write-Host "Git Global Config      : longpaths=$gitLongPaths | postBuffer=$gitPostBuffer | sslBackend=$gitSslBackend"
}

$gpuSummary = "N/A"
if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
    Write-Host "`n--- NVIDIA GPU Status ---" -ForegroundColor Gray
    $gpuSummary = nvidia-smi --query-gpu=name,driver_version,temperature.gpu,power.draw,memory.used,memory.total --format=csv,noheader
    Write-Host $gpuSummary -ForegroundColor Green
}

if ($SaveReport) {
    if (-not $ReportPath) {
        $SkillRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
        $ReportPath = Join-Path $SkillRoot "BENCHMARK_REPORT.md"
    }
    $reportMd = @"
# 📊 Workstation Network & AI Readiness Scorecard

- **Timestamp:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
- **Workstation:** `$env:COMPUTERNAME`
- **Primary Adapter:** `$($primaryAdapter.InterfaceDescription)` (`$($primaryAdapter.LinkSpeed)`)
- **GPU:** `$gpuSummary`

## 1. Network & Hardware Unlocks
| Parameter | Current Value | Optimal Target |
| :--- | :--- | :--- |
| **Receive / Transmit Buffers** | `$rxBuf / $txBuf` | `2048 / 2048` |
| **Energy Efficient Ethernet (EEE)** | `$eeeVal` | `Off` |
| **Interrupt Moderation Rate (ITR)** | `$itrVal` | `Off` |
| **OS NetworkThrottlingIndex** | `$($sysProfile.NetworkThrottlingIndex)` | `4294967295 (0xffffffff)` |
| **TCPNoDelay (Instant SSE)** | `$tcpNoDelayStatus` | `1` |
| **QA Ephemeral MaxUserPort** | `$($tcpParams.MaxUserPort)` | `65534 (55k ports)` |
| **QA TcpTimedWaitDelay** | `$($tcpParams.TcpTimedWaitDelay)s` | `30s` |
| **Effective Non-Fragmented MTU** | `$mtuCeiling bytes` | `1500 bytes` |

## 2. Latency & Cloud AI API Handshake
| Metric / Endpoint | Result |
| :--- | :--- |
| **Default Gateway Ping** | `$gwPingMs` |
| **Google DNS (`8.8.8.8`) Ping** | `$googlePingMs` |
| **Single-Stream CDN Speed** | **`$mbps Mbps`** |
| **Anthropic (`api.anthropic.com`)** | `$($aiResults["Anthropic (Claude Code / API)"])` |
| **OpenAI (`api.openai.com`)** | `$($aiResults["OpenAI (Codex / Cursor / API)"])` |
| **Google Gemini (`googleapis.com`)** | `$($aiResults["Google Gemini (Antigravity)"])` |
| **OpenRouter (`openrouter.ai`)** | `$($aiResults["OpenRouter (OpenCode / Multi)"])` |

## 3. AI, Tooling & WSL2 Configuration
| Parameter | Current Value | Optimal Target |
| :--- | :--- | :--- |
| **GPU HAGS (`HwSchMode`)** | `$hags` | `2 (Enabled)` |
| **Ollama Flash Attention & KV Cache** | `FA=$flashAttn / KV=$kvCache` | `FA=1 / KV=q8_0` |
| **Node.js Corporate / IPv4 Priority** | `NODE_OPTIONS=$nodeOpts / CA=$nodeCa` | `--dns-result-order=ipv4first / CA=1` |
| **Git SChannel SSL & LongPaths** | `ssl=$gitSslBackend / longpaths=$gitLongPaths` | `schannel / true` |
| **WSL2 Networking Mode** | `$wslMirrored` | `Enabled (Mirrored)` |
"@
    Set-Content -Path $ReportPath -Value $reportMd -Encoding UTF8
    Write-Host "`n[OK] Saved Markdown Scorecard Report to: $ReportPath" -ForegroundColor Green
}
