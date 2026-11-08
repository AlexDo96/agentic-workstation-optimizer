<#
.SYNOPSIS
    Complete Hardware, Software, Network, QA Testing & AI Workstation Optimizer.
    - Supports `-Mode All` (Default: Home Gaming + AI + Work), `-Mode Work` (Company/Office safe), and `-Mode Gaming`.
    - Automatically saves a backup snapshot via `backup-and-rollback.ps1` before making changes.
#>

param(
    [ValidateSet("All", "Work", "Gaming")]
    [string]$Mode = "All",
    [string]$AdapterName = "",
    [switch]$SkipBackup,
    [switch]$SkipWsl2
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# 0. Automatic Backup Before Any Modification
if (-not $SkipBackup -and (Test-Path "$ScriptDir\backup-and-rollback.ps1")) {
    & "$ScriptDir\backup-and-rollback.ps1" -Action Backup
}

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "   STEP 1: USER-LEVEL CPU POWER, AI, UI & TOOLING SETTINGS (Mode: $Mode)" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

# 1. Unlock and Activate Ultimate Performance (or High Performance) Power Plan & 100% AC CPU State
$ultimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
$powerList = (powercfg /list) | Out-String
if ($powerList -notmatch 'Ultimate Performance') {
    $null = powercfg /duplicatescheme $ultimateGuid 2>$null
    $powerList = (powercfg /list) | Out-String
}
if ($powerList -match '([a-f0-9-]{36})\s+\(Ultimate Performance\)') {
    $targetScheme = $matches[1]
    powercfg /setactive $targetScheme
} else {
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
}
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100 2>$null
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100 2>$null
powercfg /setactive scheme_current 2>$null
Write-Host "[OK] Active Power Plan: $(powercfg /getactivescheme) (AC CPU Min/Max = 100%)" -ForegroundColor Green

# 2. Local AI / Ollama Hardware Acceleration
if ($Mode -in @("All", "Work")) {
    [Environment]::SetEnvironmentVariable('OLLAMA_FLASH_ATTENTION', '1', 'User')
    [Environment]::SetEnvironmentVariable('OLLAMA_KV_CACHE_TYPE', 'q8_0', 'User')
    [Environment]::SetEnvironmentVariable('OLLAMA_NUM_PARALLEL', '2', 'User')
    Write-Host "[OK] Set OLLAMA_FLASH_ATTENTION=1, OLLAMA_KV_CACHE_TYPE=q8_0, OLLAMA_NUM_PARALLEL=2" -ForegroundColor Green

    # 3. Corporate Network & Cloud AI Compatibility (Node.js IPv4 Priority & Windows Certificate Store)
    $currentNodeOpts = [Environment]::GetEnvironmentVariable('NODE_OPTIONS', 'User')
    if (-not $currentNodeOpts) {
        [Environment]::SetEnvironmentVariable('NODE_OPTIONS', '--dns-result-order=ipv4first', 'User')
    } elseif ($currentNodeOpts -notmatch 'dns-result-order') {
        [Environment]::SetEnvironmentVariable('NODE_OPTIONS', "$currentNodeOpts --dns-result-order=ipv4first", 'User')
    }
    [Environment]::SetEnvironmentVariable('NODE_USE_SYSTEM_CA', '1', 'User')
    Write-Host "[OK] Set NODE_OPTIONS='--dns-result-order=ipv4first' & NODE_USE_SYSTEM_CA=1" -ForegroundColor Green

    # 4. Developer CLI Tooling (Git Windows SChannel SSL, LongPaths, 500MB Buffer, Python uv/pip timeouts)
    if (Get-Command git -ErrorAction SilentlyContinue) {
        git config --global core.longpaths true
        git config --global http.postBuffer 524288000
        git config --global http.sslBackend schannel
        git config --global http.lowSpeedLimit 1000
        git config --global http.lowSpeedTime 60
        Write-Host "[OK] Configured Git (http.sslBackend=schannel, core.longpaths=true, postBuffer=500MB)" -ForegroundColor Green
    }
    [Environment]::SetEnvironmentVariable('UV_HTTP_TIMEOUT', '120', 'User')
    [Environment]::SetEnvironmentVariable('PIP_DEFAULT_TIMEOUT', '120', 'User')
    Write-Host "[OK] Configured Python uv/pip network timeouts (120s)" -ForegroundColor Green

    # 5. WSL2 & Docker Desktop Mirrored Networking + Auto RAM Reclaim
    if (-not $SkipWsl2 -and (Test-Path "$ScriptDir\optimize-wsl2.ps1")) {
        & "$ScriptDir\optimize-wsl2.ps1"
    }
}

# 6. Windows Software, UI Snappiness, DirectX Flip Model & Background App Cleanup
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '10' -Force -ErrorAction SilentlyContinue
$bgRegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications'
if (-not (Test-Path $bgRegPath)) { New-Item -Path $bgRegPath -Force | Out-Null }
Set-ItemProperty -Path $bgRegPath -Name 'GlobalUserDisabled' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AllowAutoGameMode' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
$gameDvrPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR'
if (-not (Test-Path $gameDvrPath)) { New-Item -Path $gameDvrPath -Force | Out-Null }
Set-ItemProperty -Path $gameDvrPath -Name 'AppCaptureEnabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

if ($Mode -in @("All", "Gaming")) {
    $dxRegPath = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'
    if (-not (Test-Path $dxRegPath)) { New-Item -Path $dxRegPath -Force | Out-Null }
    Set-ItemProperty -Path $dxRegPath -Name 'DirectXUserGlobalSettings' -Value 'SwapEffectUpgradeEnable=1;' -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] Enabled DirectX Windowed Flip-Model Optimization & Auto Game Mode" -ForegroundColor Green
}
Write-Host "[OK] Tuned UI responsiveness (MenuShowDelay=10ms), disabled background Store app wakeups & GameDVR" -ForegroundColor Green

# 7. Clean Duplicate Edge AutoLaunch Keys, Temp Files & DNS Cache
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
    Write-Host "To apply Admin-level CPU, GPU HAGS, RAM consolidation, SSD I/O, 55k Ephemeral Ports, and NIC Hardware Buffer settings, run this script in PowerShell (Admin)!" -ForegroundColor Yellow
    exit 0
}

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "   STEP 2: ADMIN-LEVEL HARDWARE, KERNEL, SSD & NETWORK SETTINGS" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

# 1. CPU Scheduler Priority (Win32PrioritySeparation = 0x26) & Disable Power Throttling
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force
$pwrThrottlePath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
if (-not (Test-Path $pwrThrottlePath)) { New-Item -Path $pwrThrottlePath -Force | Out-Null }
Set-ItemProperty -Path $pwrThrottlePath -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force
Write-Host "[OK] Configured CPU Foreground Scheduler (Win32PrioritySeparation=0x26) & disabled Power Throttling" -ForegroundColor Green

# 2. RAM Consolidation (SvcHostSplitThresholdInKB matched to Physical RAM)
Add-Type -AssemblyName Microsoft.VisualBasic
$totalRamKB = [uint32]([math]::Round((New-Object Microsoft.VisualBasic.Devices.ComputerInfo).TotalPhysicalMemory / 1KB, 0))
if ($totalRamKB -gt 4194304) {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value $totalRamKB -Type DWord -Force
    Write-Host "[OK] Consolidated svchost.exe RAM overhead (SvcHostSplitThresholdInKB=$totalRamKB)" -ForegroundColor Green
}

# 3. GPU HAGS & Multimedia Class Scheduler (MMCSS) Priority for Gaming/Rendering
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force
if ($Mode -in @("All", "Gaming")) {
    $gamesReg = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    if (Test-Path $gamesReg) {
        Set-ItemProperty -Path $gamesReg -Name "GPU Priority" -Value 8 -Type DWord -Force
        Set-ItemProperty -Path $gamesReg -Name "Priority" -Value 6 -Type DWord -Force
        Set-ItemProperty -Path $gamesReg -Name "Scheduling Category" -Value "High" -Force
        Set-ItemProperty -Path $gamesReg -Name "SFIO Priority" -Value "High" -Force
        Write-Host "[OK] Set MMCSS 'Games' thread priority to High (GPU Priority=8, Priority=6)" -ForegroundColor Green
    }
}

# 4. SSD & File System I/O (LongPaths, Disable LastAccess, Disable 8.3 Legacy Names, Enable TRIM)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -Type DWord -Force
fsutil behavior set disablelastaccess 1 | Out-Null
fsutil 8dot3name set 1 | Out-Null
fsutil behavior set DisableDeleteNotify 0 | Out-Null
Write-Host "[OK] Optimized SSD & NTFS I/O (LongPaths=1, DisableLastAccess=1, Disable8dot3=1, TRIM=Enabled)" -ForegroundColor Green

# 5. Windows Network Stack, Delivery Optimization P2P Disable & Ephemeral Ports
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
$pschedPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
if (-not (Test-Path $pschedPath)) { New-Item -Path $pschedPath -Force | Out-Null }
Set-ItemProperty -Path $pschedPath -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force
$doConfigPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
if (-not (Test-Path $doConfigPath)) { New-Item -Path $doConfigPath -Force | Out-Null }
Set-ItemProperty -Path $doConfigPath -Name "DODownloadMode" -Value 0 -Type DWord -Force

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "MaxUserPort" -Value 65534 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpTimedWaitDelay" -Value 30 -Type DWord -Force
netsh int ipv4 set dynamicport tcp start=10000 num=55535 | Out-Null
Write-Host "[OK] Unlocked OS Network Stack, 55,535 Ephemeral Ports, and disabled Windows Update P2P uploads" -ForegroundColor Green

# 6. Enable TCPNoDelay & TcpAckFrequency=1 on Active Physical Interfaces
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

# 7. Unlock NIC Hardware Properties (Auto-detects Intel, Realtek, Broadcom, MediaTek)
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
Write-Host "   ALL HARDWARE, SOFTWARE, NETWORK, TESTING & AI SETTINGS APPLIED!" -ForegroundColor Green
Write-Host "   To revert at any time: .\scripts\backup-and-rollback.ps1 -Action Rollback" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Green
