<#
.SYNOPSIS
    Read-only diagnostic script for Network Throughput, NIC Hardware Properties,
    Cloud AI API Latency (Anthropic, OpenAI, Gemini, OpenRouter, GitHub),
    Local AI Readiness (GPU HAGS, VRAM, Ollama), and Agentic Tooling Config (Git, Node, Python).
#>

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   1. ACTIVE NETWORK ADAPTERS & LINK SPEED" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$adapters = Get-NetAdapter | Where-Object Status -eq 'Up'
$adapters | Select-Object Name, InterfaceDescription, LinkSpeed, MacAddress | Format-Table -AutoSize

$primaryAdapter = $adapters | Where-Object { $_.InterfaceDescription -notmatch 'Virtual|VPN|WARP|Loopback|Bluetooth|Wireless Adapter for' } | Select-Object -First 1
if (-not $primaryAdapter) { $primaryAdapter = $adapters | Select-Object -First 1 }

if ($primaryAdapter) {
    Write-Host "Primary Adapter Selected: $($primaryAdapter.Name) ($($primaryAdapter.InterfaceDescription))" -ForegroundColor Yellow
    Write-Host "`n--- Hardware Advanced Properties (Buffers, Power Saving, Interrupts) ---" -ForegroundColor Gray
    Get-NetAdapterAdvancedProperty -Name $primaryAdapter.Name -ErrorAction SilentlyContinue |
        Where-Object { $_.RegistryKeyword -match 'Buffer|EEE|Green|Power|ULP|ITR|InterruptModeration|FlowControl|Jumbo|SpeedDuplex' } |
        Select-Object DisplayName, DisplayValue, RegistryKeyword | Format-Table -AutoSize
}

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   2. WINDOWS OS NETWORK STACK & THROTTLING PARAMETERS" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$sysProfile = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -ErrorAction SilentlyContinue
$psched = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched' -ErrorAction SilentlyContinue

Write-Host ("NetworkThrottlingIndex : {0} (Default=10, Unlocked=4294967295 / 0xffffffff)" -f $sysProfile.NetworkThrottlingIndex)
Write-Host ("SystemResponsiveness   : {0}% (Default=20%, Unlocked=0%)" -f $sysProfile.SystemResponsiveness)
Write-Host ("QoS NonBestEffortLimit : {0} (Unlocked=0)" -f $psched.NonBestEffortLimit)

$activeNics = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True" -ErrorAction SilentlyContinue
foreach ($nic in $activeNics) {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($nic.SettingID)"
    $ifProps = Get-ItemProperty $regPath -ErrorAction SilentlyContinue
    Write-Host ("Interface [{0}] IP={1} | Gateway={2} | DNS={3}" -f $nic.Description, ($nic.IPAddress -join ','), ($nic.DefaultIPGateway -join ','), ($nic.DNSServerSearchOrder -join ','))
    Write-Host ("   -> TCPNoDelay={0} | TcpAckFrequency={1}" -f $ifProps.TCPNoDelay, $ifProps.TcpAckFrequency)
}

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "   3. BACKGROUND VPN / PROXY / BANDWIDTH INTERCEPTORS" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$vpnProcs = Get-Process | Where-Object { $_.ProcessName -match 'warp|vpn|wireguard|openvpn|tailscale|zerotier|cisco|forti|globalprotect|zscaler|steam|onedrive|dropbox' }
if ($vpnProcs) {
    $vpnProcs | Select-Object ProcessName, Id, @{n='RAM_MB';e={[math]::Round($_.WorkingSet64/1MB,1)}} | Format-Table -AutoSize
} else {
    Write-Host "No active VPN/Tunnel or heavy sync processes detected." -ForegroundColor Green
}

$httpProxy  = [Environment]::GetEnvironmentVariable('HTTP_PROXY', 'User')
$httpsProxy = [Environment]::GetEnvironmentVariable('HTTPS_PROXY', 'User')
if ($httpProxy -or $httpsProxy) {
    Write-Host "Active User Proxy Variables: HTTP_PROXY=$httpProxy | HTTPS_PROXY=$httpsProxy" -ForegroundColor Yellow
}

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   4. CLOUD AI PROVIDER API LATENCY & CDN THROUGHPUT" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$gw = ($activeNics | Where-Object { $_.DefaultIPGateway } | Select-Object -First 1).DefaultIPGateway[0]
if ($gw) {
    Write-Host "-> Pinging Default Gateway ($gw)..." -ForegroundColor Gray
    ping -n 3 $gw
    Get-NetNeighbor -IPAddress $gw -ErrorAction SilentlyContinue | Select-Object IPAddress, LinkLayerAddress, State | Format-Table -AutoSize
}

$aiEndpoints = @(
    @{ Name = "Anthropic (Claude Code / API)"; Url = "https://api.anthropic.com" },
    @{ Name = "OpenAI (Codex / Cursor / API)"; Url = "https://api.openai.com" },
    @{ Name = "Google Gemini (Antigravity)";   Url = "https://generativelanguage.googleapis.com" },
    @{ Name = "OpenRouter (OpenCode / Multi)"; Url = "https://openrouter.ai" },
    @{ Name = "GitHub (Copilot / Git)";        Url = "https://api.github.com" }
)

Write-Host "`n--- Cloud AI Provider TLS Handshake & Connect Latency ---" -ForegroundColor Gray
foreach ($ep in $aiEndpoints) {
    $timing = curl.exe -o NUL -s -m 5 -w "DNS:%{time_namelookup}s | TCP:%{time_connect}s | TLS:%{time_appconnect}s | Total:%{time_total}s" $ep.Url
    Write-Host ("{0,-32} -> {1}" -f $ep.Name, $timing)
}

Write-Host "`n-> Testing 25MB Download Speed from Cloudflare CDN..." -ForegroundColor Gray
$speedBytes = curl.exe -o NUL -s -w "%{speed_download}" https://speed.cloudflare.com/__down?bytes=25000000
if ($speedBytes -match '^\d+') {
    $mbps = [math]::Round(([double]$speedBytes * 8) / 1000000, 2)
    $mbs  = [math]::Round([double]$speedBytes / 1000000, 2)
    Write-Host "Single-Stream Cloudflare Throughput: $mbps Mbps ($mbs MB/s)" -ForegroundColor Green
}

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "   5. LOCAL AI WORKSTATION & AGENTIC TOOLING READINESS" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
$powerScheme = powercfg /getactivescheme
$hags = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -ErrorAction SilentlyContinue).HwSchMode
$longPaths = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -ErrorAction SilentlyContinue).LongPathsEnabled
$flashAttn = [Environment]::GetEnvironmentVariable('OLLAMA_FLASH_ATTENTION', 'User')
$kvCache   = [Environment]::GetEnvironmentVariable('OLLAMA_KV_CACHE_TYPE', 'User')
$ollamaParallel = [Environment]::GetEnvironmentVariable('OLLAMA_NUM_PARALLEL', 'User')
$ollamaModels = [Environment]::GetEnvironmentVariable('OLLAMA_MODELS', 'User')

Write-Host "Active Power Plan      : $powerScheme"
Write-Host "GPU HAGS (HwSchMode)   : $hags (1=Disabled, 2=Enabled)"
Write-Host "Win32 LongPathsEnabled : $longPaths (1=Enabled)"
Write-Host "OLLAMA_FLASH_ATTENTION : $flashAttn (Recommended=1)"
Write-Host "OLLAMA_KV_CACHE_TYPE   : $kvCache (Recommended=q8_0)"
Write-Host "OLLAMA_NUM_PARALLEL    : $ollamaParallel (Recommended=2 or 4 for multi-agent)"
Write-Host "OLLAMA_MODELS Path     : $ollamaModels"

if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitPostBuffer = git config --global http.postBuffer
    $gitLongPaths  = git config --global core.longpaths
    Write-Host "Git Global Config      : core.longpaths=$gitLongPaths | http.postBuffer=$gitPostBuffer"
}

$edgeStartupCount = (Get-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property | Where-Object { $_ -like 'MicrosoftEdgeAutoLaunch_*' }).Count
Write-Host "Edge AutoLaunch Bloat  : $edgeStartupCount duplicate keys found"

if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
    Write-Host "`n--- NVIDIA GPU Status ---" -ForegroundColor Gray
    nvidia-smi --query-gpu=name,driver_version,temperature.gpu,power.draw,memory.used,memory.total --format=csv
}
