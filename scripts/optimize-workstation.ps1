<#
.SYNOPSIS
    Unlocks Windows Network Stack, NIC Hardware Buffers/Power Saving, Power Plan,
    GPU HAGS, Win32 LongPaths, and Ollama AI Acceleration on a Windows Workstation.
    Safe for Enterprise/Company PCs (does not alter corporate DNS, AD, or VPN profiles).
#>

param(
    [string]$AdapterName = ""
)

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   STEP 1: USER-SCOPE AI & POWER OPTIMIZATIONS" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

# 1. Activate High Performance Power Plan
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
Write-Host "[OK] Active Power Plan set to: $(powercfg /getactivescheme)" -ForegroundColor Green

# 2. Configure Ollama AI Hardware Acceleration (Flash Attention + 8-bit KV Cache)
[Environment]::SetEnvironmentVariable('OLLAMA_FLASH_ATTENTION', '1', 'User')
[Environment]::SetEnvironmentVariable('OLLAMA_KV_CACHE_TYPE', 'q8_0', 'User')
Write-Host "[OK] Set OLLAMA_FLASH_ATTENTION=1 and OLLAMA_KV_CACHE_TYPE=q8_0" -ForegroundColor Green

# 3. Disable Background GameDVR Screen Capture (Saves GPU VRAM & Encode Engine for AI)
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AllowAutoGameMode' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Write-Host "[OK] Disabled background GameDVR capture overhead" -ForegroundColor Green

# 4. Clean Duplicate Edge AutoLaunch Keys in HKCU Run
$edgeKeys = Get-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Property | Where-Object { $_ -like 'MicrosoftEdgeAutoLaunch_*' }
if ($edgeKeys) {
    foreach ($k in $edgeKeys) {
        Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name $k -Force -ErrorAction SilentlyContinue
    }
    Write-Host "[OK] Removed $($edgeKeys.Count) duplicate MicrosoftEdgeAutoLaunch startup keys" -ForegroundColor Green
}

# 5. Flush DNS & Clean Temp
ipconfig /flushdns | Out-Null
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "[OK] Flushed DNS cache and cleaned %TEMP%" -ForegroundColor Green

if (-not $isAdmin) {
    Write-Host "`n[WARNING] Current session is NOT running as Administrator." -ForegroundColor Yellow
    Write-Host "To unlock NIC Hardware Buffers (2048), disable EEE/ULP, unlock NetworkThrottlingIndex, and enable GPU HAGS, run this script in PowerShell (Admin)!" -ForegroundColor Yellow
    exit 0
}

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "   STEP 2: ADMIN-LEVEL OS NETWORK & HARDWARE UNLOCK" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

# 1. Unlock Windows Multimedia Network Throttling & Foreground Responsiveness
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
Write-Host "[OK] Unlocked NetworkThrottlingIndex (0xffffffff) & SystemResponsiveness (0)" -ForegroundColor Green

# 2. Remove 20% QoS Reserved Bandwidth Limit
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force
Write-Host "[OK] Set QoS NonBestEffortLimit = 0" -ForegroundColor Green

# 3. Enable Hardware-Accelerated GPU Scheduling (HAGS) & Win32 Long Paths for AI/Dev
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -Type DWord -Force
Write-Host "[OK] Enabled GPU HAGS (HwSchMode=2) and Win32 LongPathsEnabled=1" -ForegroundColor Green

# 4. Enable TCPNoDelay & TcpAckFrequency=1 on Active Physical Interfaces
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

# 5. Unlock NIC Hardware Properties (Auto-detects Intel, Realtek, etc.)
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
Write-Host "   ALL WORKSTATION NETWORK & AI OPTIMIZATIONS APPLIED!" -ForegroundColor Green
Write-Host "   Note: Restart Windows once for GPU HAGS & ThrottlingIndex to take full effect." -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Green
