<#
.SYNOPSIS
    v2.0 Master Workstation Optimizer for Network Throughput, Corporate Cloud AI Streaming,
    QA Automation (Playwright/Appium/API Testing), WSL2/Docker, and Local AI (Ollama/CUDA/HAGS).
    - Automatically snapshots original system state via `backup-and-rollback.ps1` before making changes.
    - Safe for Enterprise/Company PCs (does not alter corporate DNS, AD, or VPN profiles).
#>

param(
    [string]$AdapterName = "",
    [switch]$SkipBackup,
    [switch]$SkipWsl2
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# 0. Automatic Time-Machine Backup Before Any Modification
if (-not $SkipBackup -and (Test-Path "$ScriptDir\backup-and-rollback.ps1")) {
    & "$ScriptDir\backup-and-rollback.ps1" -Action Backup
}

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "   STEP 1: USER-SCOPE AI, CORPORATE PROXY PIERCER & TOOLING" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

# 1. Activate High Performance Power Plan
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
Write-Host "[OK] Active Power Plan set to: $(powercfg /getactivescheme)" -ForegroundColor Green

# 2. Configure Local AI Hardware Acceleration (Ollama / Local LLM Runtimes)
[Environment]::SetEnvironmentVariable('OLLAMA_FLASH_ATTENTION', '1', 'User')
[Environment]::SetEnvironmentVariable('OLLAMA_KV_CACHE_TYPE', 'q8_0', 'User')
if (-not [Environment]::GetEnvironmentVariable('OLLAMA_NUM_PARALLEL', 'User')) {
    [Environment]::SetEnvironmentVariable('OLLAMA_NUM_PARALLEL', '2', 'User')
}
Write-Host "[OK] Set OLLAMA_FLASH_ATTENTION=1, OLLAMA_KV_CACHE_TYPE=q8_0, OLLAMA_NUM_PARALLEL=2" -ForegroundColor Green

# 3. Corporate Network & Cloud AI Piercer (Eliminates IPv6 Happy-Eyeballs 1s lag & fixes Corporate SSL CA)
$currentNodeOpts = [Environment]::GetEnvironmentVariable('NODE_OPTIONS', 'User')
if (-not $currentNodeOpts) {
    [Environment]::SetEnvironmentVariable('NODE_OPTIONS', '--dns-result-order=ipv4first', 'User')
} elseif ($currentNodeOpts -notmatch 'dns-result-order') {
    [Environment]::SetEnvironmentVariable('NODE_OPTIONS', "$currentNodeOpts --dns-result-order=ipv4first", 'User')
}
[Environment]::SetEnvironmentVariable('NODE_USE_SYSTEM_CA', '1', 'User')
Write-Host "[OK] Set NODE_OPTIONS='--dns-result-order=ipv4first' & NODE_USE_SYSTEM_CA=1 (Fast Claude Code / OpenCode / Playwright)" -ForegroundColor Green

# 4. Configure Agentic CLI Tooling (Git Windows SChannel SSL, LongPaths, 500MB HTTP Buffer, uv/pip timeouts)
if (Get-Command git -ErrorAction SilentlyContinue) {
    git config --global core.longpaths true
    git config --global http.postBuffer 524288000
    git config --global http.sslBackend schannel
    git config --global http.lowSpeedLimit 1000
    git config --global http.lowSpeedTime 60
    Write-Host "[OK] Configured Git (http.sslBackend=schannel for Corporate SSL, core.longpaths=true, postBuffer=500MB)" -ForegroundColor Green
}
[Environment]::SetEnvironmentVariable('UV_HTTP_TIMEOUT', '120', 'User')
[Environment]::SetEnvironmentVariable('PIP_DEFAULT_TIMEOUT', '120', 'User')
Write-Host "[OK] Configured Python uv/pip network timeouts (120s)" -ForegroundColor Green

# 5. Optimize WSL2 & Docker Networking (.wslconfig Mirrored Mode + Auto RAM Reclaim)
if (-not $SkipWsl2 -and (Test-Path "$ScriptDir\optimize-wsl2.ps1")) {
    & "$ScriptDir\optimize-wsl2.ps1"
}

# 6. Disable Background GameDVR Screen Capture & Clean Startup Bloat
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AllowAutoGameMode' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Write-Host "[OK] Disabled background GameDVR capture overhead" -ForegroundColor Green

$edgeKeys = Get-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Property | Where-Object { $_ -like 'MicrosoftEdgeAutoLaunch_*' }
if ($edgeKeys) {
    foreach ($k in $edgeKeys) {
        Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name $k -Force -ErrorAction SilentlyContinue
    }
    Write-Host "[OK] Removed $($edgeKeys.Count) duplicate MicrosoftEdgeAutoLaunch startup keys" -ForegroundColor Green
}

ipconfig /flushdns | Out-Null
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "[OK] Flushed DNS cache and cleaned %TEMP%" -ForegroundColor Green

if (-not $isAdmin) {
    Write-Host "`n[WARNING] Current session is NOT running as Administrator." -ForegroundColor Yellow
    Write-Host "To unlock NIC Hardware Buffers (2048), 55k QA Ephemeral Ports, NTFS Fast I/O, NetworkThrottlingIndex, and GPU HAGS, run this script in PowerShell (Admin)!" -ForegroundColor Yellow
    exit 0
}

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "   STEP 2: ADMIN-LEVEL OS NETWORK, QA TURBO & HARDWARE UNLOCK" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

# 1. Unlock Windows Multimedia Network Throttling & Foreground Responsiveness
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
Write-Host "[OK] Unlocked NetworkThrottlingIndex (0xffffffff) & SystemResponsiveness (0)" -ForegroundColor Green

# 2. Remove 20% QoS Reserved Bandwidth Limit
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force
Write-Host "[OK] Set QoS NonBestEffortLimit = 0" -ForegroundColor Green

# 3. QA Automation (Playwright/Appium/API Testing) & Multi-Agent Ephemeral Port Turbo
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "MaxUserPort" -Value 65534 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpTimedWaitDelay" -Value 30 -Type DWord -Force
netsh int ipv4 set dynamicport tcp start=10000 num=55535 | Out-Null
Write-Host "[OK] Unlocked 55,535 Ephemeral Ports (MaxUserPort=65534) & TcpTimedWaitDelay=30s for Parallel E2E & MCP" -ForegroundColor Green

# 4. Enable Hardware-Accelerated GPU Scheduling (HAGS), Win32 LongPaths & Fast NTFS I/O
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -Type DWord -Force
fsutil behavior set disablelastaccess 1 | Out-Null
Write-Host "[OK] Enabled GPU HAGS (HwSchMode=2), LongPathsEnabled=1, and disabled NTFS LastAccess overhead" -ForegroundColor Green

# 5. Enable TCPNoDelay & TcpAckFrequency=1 on Active Physical Interfaces (Instant SSE Token Streaming)
$nics = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True" |
    Where-Object { $_.Description -notmatch 'Virtual|VPN|WARP|Loopback' }
foreach ($n in $nics) {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($n.SettingID)"
    if (Test-Path $regPath) {
        Set-ItemProperty -Path $regPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $regPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force
        Write-Host "[OK] Enabled TCPNoDelay=1 & TcpAckFrequency=1 on $($n.Description)" -ForegroundColor Green
    }
}

# 6. Unlock NIC Hardware Properties (Auto-detects Intel, Realtek, Broadcom, MediaTek)
if (-not $AdapterName) {
    $primaryAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch 'Virtual|VPN|WARP|Loopback|Bluetooth|Wireless Adapter for' } | Select-Object -First 1
    if ($primaryAdapter) { $AdapterName = $primaryAdapter.Name }
}

if ($AdapterName) {
    Write-Host "Tuning NIC Hardware Properties on Adapter: [$AdapterName]..." -ForegroundColor Yellow
    $advProps = Get-NetAdapterAdvancedProperty -Name $AdapterName -ErrorAction SilentlyContinue

    $desiredSettings = @(
        @{ Keyword = '*ReceiveBuffers';         Val = 2048; Fallback = 1024 },
        @{ Keyword = '*TransmitBuffers';        Val = 2048; Fallback = 1024 },
        @{ Keyword = 'EEELinkAdvertisement';    Val = 0 },
        @{ Keyword = '*EEE';                    Val = 0 },
        @{ Keyword = 'AdvancedEEE';             Val = 0 },
        @{ Keyword = 'GreenEthernet';           Val = 0 },
        @{ Keyword = 'ULPMode';                 Val = 0 },
        @{ Keyword = 'ReduceSpeedOnPowerDown';  Val = 0 },
        @{ Keyword = 'PowerSavingMode';         Val = 0 },
        @{ Keyword = 'ITR';                     Val = 0 }
    )

    foreach ($item in $desiredSettings) {
        $prop = $advProps | Where-Object { $_.RegistryKeyword -eq $item.Keyword }
        if ($prop) {
            try {
                Set-NetAdapterAdvancedProperty -Name $AdapterName -RegistryKeyword $item.Keyword -RegistryValue $item.Val -NoRestart -ErrorAction Stop
                Write-Host "   -> Set $($item.Keyword) = $($item.Val)" -ForegroundColor Green
            } catch {
                if ($null -ne $item.Fallback) {
                    try {
                        Set-NetAdapterAdvancedProperty -Name $AdapterName -RegistryKeyword $item.Keyword -RegistryValue $item.Fallback -NoRestart -ErrorAction Stop
                        Write-Host "   -> Set $($item.Keyword) = $($item.Fallback) (Fallback Max)" -ForegroundColor Green
                    } catch {}
                }
            }
        }
    }
    Restart-NetAdapter -Name $AdapterName -ErrorAction SilentlyContinue
    Write-Host "[OK] NIC [$AdapterName] restarted with max hardware configuration!" -ForegroundColor Green
}

Write-Host "`n================================================================" -ForegroundColor Green
Write-Host "   v2.0 WORKSTATION NETWORK, QA TURBO & AI OPTIMIZATIONS APPLIED!" -ForegroundColor Green
Write-Host "   To rollback at any time: .\scripts\backup-and-rollback.ps1 -Action Rollback" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Green
