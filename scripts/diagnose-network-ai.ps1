<#
.SYNOPSIS
    Read-only diagnostic script for Windows Hardware, Software, Network, Gaming, QA Automation & AI readiness:
    1. Active Network Adapters & Hardware Properties (Buffers, EEE, ULP, ITR)
    2. Windows TCP Stack, Ephemeral Ports (Playwright/Appium/API) & File System I/O (NTFS, SSD)
    3. Corporate Network Check (IPv6 vs IPv4 routing, non-fragmented VPN MTU, TLS CA)
    4. Cloud AI Provider API Latency (Anthropic, OpenAI, Gemini, OpenRouter, GitHub) & CDN Speed
    5. Hardware & Software Performance (CPU Power Plan & Scheduler, RAM SvcHost Split, GPU HAGS & Gaming MMCSS, Windows UI & Background Apps, WSL2, Ollama)
    6. Optional Markdown Summary Report (-SaveReport)
#>

param(
    [switch]$SaveReport,
    [string]$ReportPath = ""
)

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   1. ACTIVE NETWORK ADAPTERS & HARDWARE PROPERTIES" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$adapters = $null
try {
    $adapters = Get-NetAdapter -ErrorAction Stop | Where-Object Status -eq 'Up'
    $adapters | Select-Object Name, InterfaceDescription, LinkSpeed, MacAddress | Format-Table -AutoSize
} catch {
    Write-Host "[INFO] WMI/CIM NetAdapter query restricted in current shell." -ForegroundColor Yellow
}

$primaryAdapter = $adapters | Where-Object { $_.InterfaceDescription -notmatch 'Virtual|VPN|WARP|Loopback|Bluetooth|Wireless Adapter for' } | Select-Object -First 1
if (-not $primaryAdapter) { $primaryAdapter = $adapters | Select-Object -First 1 }

$rxBuf = "N/A"; $txBuf = "N/A"; $eeeVal = "N/A"; $itrVal = "N/A"
if ($primaryAdapter) {
    Write-Host "Primary Adapter Selected: $($primaryAdapter.Name) ($($primaryAdapter.InterfaceDescription))" -ForegroundColor Yellow
    try {
        $advProps = Get-NetAdapterAdvancedProperty -Name $primaryAdapter.Name -ErrorAction SilentlyContinue
        $rxBuf  = ($advProps | Where-Object RegistryKeyword -eq '*ReceiveBuffers').DisplayValue
        $txBuf  = ($advProps | Where-Object RegistryKeyword -eq '*TransmitBuffers').DisplayValue
        $eeeVal = ($advProps | Where-Object { $_.RegistryKeyword -in @('EEELinkAdvertisement','*EEE','AdvancedEEE') } | Select-Object -First 1).DisplayValue
        $itrVal = ($advProps | Where-Object RegistryKeyword -eq 'ITR').DisplayValue

        $advProps | Where-Object { $_.RegistryKeyword -match 'Buffer|EEE|Green|Power|ULP|ITR|InterruptModeration|FlowControl' } |
            Select-Object DisplayName, DisplayValue, RegistryKeyword | Format-Table -AutoSize
    } catch {}
}

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   2. OS NETWORK STACK, EPHEMERAL PORTS & SSD / FILE SYSTEM I/O" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$sysProfile = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -ErrorAction SilentlyContinue
$psched     = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched' -ErrorAction SilentlyContinue
$tcpParams  = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' -ErrorAction SilentlyContinue
$fileSystem = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -ErrorAction SilentlyContinue

Write-Host ("NetworkThrottlingIndex : {0} (Default=10, Unlocked=4294967295 / 0xffffffff)" -f $sysProfile.NetworkThrottlingIndex)
Write-Host ("SystemResponsiveness   : {0}% (Default=20%, Unlocked=0%)" -f $sysProfile.SystemResponsiveness)
Write-Host ("QoS NonBestEffortLimit : {0} (Unlocked=0)" -f $psched.NonBestEffortLimit)
Write-Host ("Ephemeral MaxUserPort  : {0} (Default=N/A [16k ports], Target=65534 [55k ports])" -f $tcpParams.MaxUserPort)
Write-Host ("TcpTimedWaitDelay      : {0}s (Default=120s, Target=30s)" -f $tcpParams.TcpTimedWaitDelay)
Write-Host ("Win32 LongPathsEnabled : {0} (1=Enabled)" -f $fileSystem.LongPathsEnabled)
Write-Host ("NTFS DisableLastAccess : {0} (0=Enabled [Slower I/O], 1=Disabled [Faster I/O])" -f $fileSystem.NtfsDisableLastAccessUpdate)
Write-Host ("NTFS Disable8dot3Names : {0} (1=Disabled legacy short names [Faster I/O])" -f $fileSystem.NtfsDisable8dot3NameCreation)

$activeNics = $null
try {
    $activeNics = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True" -ErrorAction Stop
} catch {}
$tcpNoDelayStatus = "N/A"
foreach ($nic in $activeNics) {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($nic.SettingID)"
    $ifProps = Get-ItemProperty $regPath -ErrorAction SilentlyContinue
    if ($null -ne $ifProps.TCPNoDelay) { $tcpNoDelayStatus = $ifProps.TCPNoDelay }
    Write-Host ("Interface [{0}] IP={1} | Gateway={2} | DNS={3}" -f $nic.Description, ($nic.IPAddress -join ','), ($nic.DefaultIPGateway -join ','), ($nic.DNSServerSearchOrder -join ','))
    Write-Host ("   -> TCPNoDelay={0} | TcpAckFrequency={1}" -f $ifProps.TCPNoDelay, $ifProps.TcpAckFrequency)
}

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "   3. CORPORATE NETWORK, IPV6 ROUTING & VPN MTU CHECK" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$vpnProcs = Get-Process | Where-Object { $_.ProcessName -match 'warp|vpn|wireguard|openvpn|tailscale|zerotier|cisco|forti|globalprotect|zscaler|steam|onedrive|dropbox' }
if ($vpnProcs) {
    $vpnProcs | Select-Object ProcessName, Id, @{n='RAM_MB';e={[math]::Round($_.WorkingSet64/1MB,1)}} | Format-Table -AutoSize
} else {
    Write-Host "[OK] No active VPN/Tunnel or heavy background sync processes detected." -ForegroundColor Green
}

$ipv4Test = curl.exe -4 -o NUL -s -m 3 -w "%{http_code}" https://api.anthropic.com 2>$null
$ipv6Test = curl.exe -6 -o NUL -s -m 2 -w "%{http_code}" https://api.anthropic.com 2>$null
$nodeOpts = [Environment]::GetEnvironmentVariable('NODE_OPTIONS', 'User')
$nodeCa   = [Environment]::GetEnvironmentVariable('NODE_USE_SYSTEM_CA', 'User')
Write-Host "IPv4 Connectivity (Anthropic) : HTTP $ipv4Test"
Write-Host "IPv6 Connectivity (Anthropic) : $(if ($ipv6Test -and $ipv6Test -ne '000') { "HTTP $ipv6Test (Working)" } else { "Unreachable / Timeout (Requires ipv4first to avoid connection delay)" })"
Write-Host "NODE_OPTIONS (IPv4 Priority)  : $nodeOpts (Target: --dns-result-order=ipv4first)"
Write-Host "NODE_USE_SYSTEM_CA (Corp SSL) : $nodeCa (Target: 1)"

$mtuCeiling = 1500
foreach ($payload in @(1472, 1464, 1440, 1400, 1360)) {
    $pingMtu = (ping -n 1 -w 1000 -f -l $payload 8.8.8.8 2>$null) | Out-String
    if ($pingMtu -match "Reply from") {
        $mtuCeiling = $payload + 28
        break
    }
}
Write-Host ("Effective Non-Fragmented MTU  : {0} bytes {1}" -f $mtuCeiling, $(if ($mtuCeiling -lt 1492) { "(Reduced MTU due to VPN/Tunnel overhead)" } else { "(Standard Ethernet / PPPoE Fiber MTU)" }))

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "   4. CLOUD AI PROVIDER API LATENCY & DOWNLOAD SPEED" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$gw = if ($activeNics) { ($activeNics | Where-Object { $_.DefaultIPGateway } | Select-Object -First 1).DefaultIPGateway[0] } else { $null }
$gwPingMs = "N/A"
if ($gw) {
    $gwOut = (ping -n 3 $gw) | Out-String
    if ($gwOut -match "Average = (\d+)ms") { $gwPingMs = "$($matches[1]) ms" }
    Write-Host "Default Gateway ($gw) Average Ping: $gwPingMs" -ForegroundColor Green
}

$googlePingMs = "N/A"
$gOut = (ping -n 3 8.8.8.8) | Out-String
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
Write-Host "   5. HARDWARE, SOFTWARE, GAMING & AI WORKSTATION READINESS" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$powerScheme = powercfg /getactivescheme
$prioControl = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -ErrorAction SilentlyContinue).Win32PrioritySeparation
$pwrThrottle = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' -ErrorAction SilentlyContinue).PowerThrottlingOff
$svcSplit    = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control' -ErrorAction SilentlyContinue).SvcHostSplitThresholdInKB
$osMem       = $null
try { $osMem = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop } catch {}
$totalRamGB  = if ($osMem) { [math]::Round($osMem.TotalVisibleMemorySize / 1MB, 1) } else { "N/A" }
$freeRamGB   = if ($osMem) { [math]::Round($osMem.FreePhysicalMemory / 1MB, 2) } else { "N/A" }

$hags        = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -ErrorAction SilentlyContinue).HwSchMode
$dxFlip      = (Get-ItemProperty 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences' -ErrorAction SilentlyContinue).DirectXUserGlobalSettings
$gamesMmcss  = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' -ErrorAction SilentlyContinue
$gameDvr     = (Get-ItemProperty 'HKCU:\System\GameConfigStore' -ErrorAction SilentlyContinue).GameDVR_Enabled
$menuDelay   = (Get-ItemProperty 'HKCU:\Control Panel\Desktop' -ErrorAction SilentlyContinue).MenuShowDelay
$bgAppsOff   = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -ErrorAction SilentlyContinue).GlobalUserDisabled

$flashAttn   = [Environment]::GetEnvironmentVariable('OLLAMA_FLASH_ATTENTION', 'User')
$kvCache     = [Environment]::GetEnvironmentVariable('OLLAMA_KV_CACHE_TYPE', 'User')
$ollamaPar   = [Environment]::GetEnvironmentVariable('OLLAMA_NUM_PARALLEL', 'User')
$wslMirrored = if ((Test-Path "$HOME\.wslconfig" -ErrorAction SilentlyContinue) -and ((Get-Content "$HOME\.wslconfig" -Raw -ErrorAction SilentlyContinue) -match 'networkingMode\s*=\s*mirrored')) { "Enabled (Mirrored)" } else { "Default NAT / Not Configured" }

Write-Host "Active Power Plan         : $powerScheme"
Write-Host "CPU PrioritySeparation    : $prioControl (Default=2, Target=38 [0x26 Foreground Boost])"
Write-Host "CPU PowerThrottlingOff    : $pwrThrottle (1=Disabled background throttling)"
Write-Host "System Physical RAM       : $freeRamGB GB Free / $totalRamGB GB Total"
Write-Host "RAM SvcHostSplitThreshold : $svcSplit KB (Consolidates svchost.exe when >= Total RAM KB)"
Write-Host "GPU HAGS (HwSchMode)      : $hags (1=Disabled, 2=Enabled)"
Write-Host "DirectX Windowed Flip     : $dxFlip"
Write-Host "MMCSS Games Priority      : GPU Priority=$($gamesMmcss.'GPU Priority') (Target=8) | CPU Priority=$($gamesMmcss.Priority) (Target=6)"
Write-Host "Background GameDVR        : $gameDvr (0=Disabled [Higher FPS], 1=Enabled)"
Write-Host "UI MenuShowDelay          : $menuDelay ms (Default=400, Target=10)"
Write-Host "Store Background Apps Off : $bgAppsOff (1=Disabled background wakeups)"
Write-Host "WSL2 Network Mode         : $wslMirrored"
Write-Host "OLLAMA_FLASH_ATTENTION    : $flashAttn (Target=1)"
Write-Host "OLLAMA_KV_CACHE_TYPE      : $kvCache (Target=q8_0)"
Write-Host "OLLAMA_NUM_PARALLEL       : $ollamaPar (Target=2)"

if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitPostBuffer = git config --global http.postBuffer
    $gitLongPaths  = git config --global core.longpaths
    $gitSslBackend = git config --global http.sslBackend
    Write-Host "Git Global Config         : longpaths=$gitLongPaths | postBuffer=$gitPostBuffer | sslBackend=$gitSslBackend"
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
# Workstation Hardware, Software, Network & AI Diagnostic Report

- **Timestamp:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
- **Workstation:** `$env:COMPUTERNAME`
- **Primary Adapter:** `$($primaryAdapter.InterfaceDescription)` (`$($primaryAdapter.LinkSpeed)`)
- **RAM:** `$freeRamGB GB Free / $totalRamGB GB Total`
- **GPU:** `$gpuSummary`

## 1. Network & Hardware Settings
| Parameter | Current Value | Target Value |
| :--- | :--- | :--- |
| **Receive / Transmit Buffers** | `$rxBuf / $txBuf` | `2048 / 2048` |
| **Energy Efficient Ethernet (EEE)** | `$eeeVal` | `Off` |
| **Interrupt Moderation Rate (ITR)** | `$itrVal` | `Off` |
| **OS NetworkThrottlingIndex** | `$($sysProfile.NetworkThrottlingIndex)` | `4294967295 (0xffffffff)` |
| **TCPNoDelay (Nagle Disabled)** | `$tcpNoDelayStatus` | `1` |
| **Ephemeral MaxUserPort** | `$($tcpParams.MaxUserPort)` | `65534 (55k ports)` |
| **TcpTimedWaitDelay** | `$($tcpParams.TcpTimedWaitDelay)s` | `30s` |
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

## 3. Hardware, Software, Gaming & AI Configuration
| Parameter | Current Value | Target Value |
| :--- | :--- | :--- |
| **CPU PrioritySeparation** | `$prioControl` | `38 (0x26)` |
| **RAM SvcHostSplitThresholdInKB** | `$svcSplit KB` | `>= Total RAM KB` |
| **GPU HAGS (`HwSchMode`)** | `$hags` | `2 (Enabled)` |
| **DirectX Windowed Flip Model** | `$dxFlip` | `SwapEffectUpgradeEnable=1;` |
| **MMCSS Games Priority (GPU / CPU)** | `$($gamesMmcss.'GPU Priority') / $($gamesMmcss.Priority)` | `8 / 6` |
| **Background GameDVR Capture** | `$gameDvr` | `0 (Disabled)` |
| **NTFS LastAccess / 8dot3 Names** | `$($fileSystem.NtfsDisableLastAccessUpdate) / $($fileSystem.NtfsDisable8dot3NameCreation)` | `1 / 1 (Disabled)` |
| **Ollama Flash Attention & KV Cache** | `FA=$flashAttn / KV=$kvCache` | `FA=1 / KV=q8_0` |
| **Node.js Corporate / IPv4 Priority** | `NODE_OPTIONS=$nodeOpts / CA=$nodeCa` | `--dns-result-order=ipv4first / CA=1` |
| **Git SChannel SSL & LongPaths** | `ssl=$gitSslBackend / longpaths=$gitLongPaths` | `schannel / true` |
| **WSL2 Networking Mode** | `$wslMirrored` | `Enabled (Mirrored)` |
"@
    Set-Content -Path $ReportPath -Value $reportMd -Encoding UTF8
    Write-Host "`n[OK] Saved diagnostic report to: $ReportPath" -ForegroundColor Green
}
