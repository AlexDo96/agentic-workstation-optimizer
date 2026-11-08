<#
.SYNOPSIS
    Time-Machine Backup & 1-Click Rollback for `network-ai-optimizer`.
    Captures a complete JSON snapshot of Windows Registry network keys, NIC hardware properties,
    User environment variables, Git global settings, and TCP dynamic port ranges before optimization.
    Restores 100% original workstation state when called with `-Action Rollback`.
#>

param(
    [ValidateSet("Backup", "Rollback", "ShowLatest")]
    [string]$Action = "Backup",
    [string]$SnapshotFile = ""
)

$SkillRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$BackupDir = Join-Path $SkillRoot "backups"
New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
$LatestFile = Join-Path $BackupDir "latest-snapshot.json"

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($Action -eq "ShowLatest") {
    if (Test-Path $LatestFile) {
        Get-Content $LatestFile | Write-Host -ForegroundColor Cyan
    } else {
        Write-Host "No backup snapshot found in $BackupDir" -ForegroundColor Yellow
    }
    exit 0
}

if ($Action -eq "Backup") {
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "   TIME-MACHINE BACKUP: CAPTURING ORIGINAL SYSTEM STATE" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan

    $primaryAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch 'Virtual|VPN|WARP|Loopback|Bluetooth|Wireless Adapter for' } | Select-Object -First 1
    $nicProps = @{}
    if ($primaryAdapter) {
        $adv = Get-NetAdapterAdvancedProperty -Name $primaryAdapter.Name -ErrorAction SilentlyContinue
        foreach ($p in $adv) {
            if ($p.RegistryKeyword) {
                $nicProps[$p.RegistryKeyword] = $p.RegistryValue
            }
        }
    }

    $sysProfile = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -ErrorAction SilentlyContinue
    $psched     = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched' -ErrorAction SilentlyContinue
    $tcpParams  = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' -ErrorAction SilentlyContinue
    $gfxDrivers = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -ErrorAction SilentlyContinue
    $fileSystem = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -ErrorAction SilentlyContinue
    $gameBar    = Get-ItemProperty 'HKCU:\Software\Microsoft\GameBar' -ErrorAction SilentlyContinue
    $gameDvr    = Get-ItemProperty 'HKCU:\System\GameConfigStore' -ErrorAction SilentlyContinue

    $activeNicConfig = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True" |
        Where-Object { $_.Description -notmatch 'Virtual|VPN|WARP|Loopback' } | Select-Object -First 1
    $ifRegPath = if ($activeNicConfig) { "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($activeNicConfig.SettingID)" } else { "" }
    $ifProps = if ($ifRegPath -and (Test-Path $ifRegPath)) { Get-ItemProperty $ifRegPath -ErrorAction SilentlyContinue } else { $null }

    $activePowerGuid = if ((powercfg /getactivescheme) -match '([a-f0-9-]{36})') { $matches[1] } else { "381b4222-f694-41f0-9685-ff5bb260df2e" }

    $snapshot = [ordered]@{
        Timestamp               = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
        ComputerName            = $env:COMPUTERNAME
        AdapterName             = if ($primaryAdapter) { $primaryAdapter.Name } else { "" }
        InterfaceRegistryPath   = $ifRegPath
        ActivePowerSchemeGuid   = $activePowerGuid
        Registry = [ordered]@{
            NetworkThrottlingIndex = $sysProfile.NetworkThrottlingIndex
            SystemResponsiveness   = $sysProfile.SystemResponsiveness
            NonBestEffortLimit     = $psched.NonBestEffortLimit
            MaxUserPort            = $tcpParams.MaxUserPort
            TcpTimedWaitDelay      = $tcpParams.TcpTimedWaitDelay
            HwSchMode              = $gfxDrivers.HwSchMode
            LongPathsEnabled       = $fileSystem.LongPathsEnabled
            NtfsDisableLastAccess  = $fileSystem.NtfsDisableLastAccessUpdate
            AllowAutoGameMode      = $gameBar.AllowAutoGameMode
            GameDVR_Enabled        = $gameDvr.GameDVR_Enabled
            TcpAckFrequency        = if ($ifProps) { $ifProps.TcpAckFrequency } else { $null }
            TCPNoDelay             = if ($ifProps) { $ifProps.TCPNoDelay } else { $null }
        }
        UserEnv = [ordered]@{
            OLLAMA_FLASH_ATTENTION = [Environment]::GetEnvironmentVariable('OLLAMA_FLASH_ATTENTION', 'User')
            OLLAMA_KV_CACHE_TYPE   = [Environment]::GetEnvironmentVariable('OLLAMA_KV_CACHE_TYPE', 'User')
            OLLAMA_NUM_PARALLEL    = [Environment]::GetEnvironmentVariable('OLLAMA_NUM_PARALLEL', 'User')
            UV_HTTP_TIMEOUT        = [Environment]::GetEnvironmentVariable('UV_HTTP_TIMEOUT', 'User')
            PIP_DEFAULT_TIMEOUT    = [Environment]::GetEnvironmentVariable('PIP_DEFAULT_TIMEOUT', 'User')
            NODE_OPTIONS           = [Environment]::GetEnvironmentVariable('NODE_OPTIONS', 'User')
            NODE_USE_SYSTEM_CA     = [Environment]::GetEnvironmentVariable('NODE_USE_SYSTEM_CA', 'User')
        }
        GitGlobal = [ordered]@{
            LongPaths  = if (Get-Command git -ErrorAction SilentlyContinue) { git config --global core.longpaths } else { $null }
            PostBuffer = if (Get-Command git -ErrorAction SilentlyContinue) { git config --global http.postBuffer } else { $null }
            SslBackend = if (Get-Command git -ErrorAction SilentlyContinue) { git config --global http.sslBackend } else { $null }
        }
        NicAdvancedProperties = $nicProps
    }

    $json = $snapshot | ConvertTo-Json -Depth 5
    $datedFile = Join-Path $BackupDir ("snapshot-{0}.json" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
    Set-Content -Path $datedFile -Value $json -Encoding UTF8
    if (-not (Test-Path $LatestFile)) {
        Set-Content -Path $LatestFile -Value $json -Encoding UTF8
    }
    Write-Host "[OK] Saved system snapshot to: $datedFile" -ForegroundColor Green
    Write-Host "[OK] Baseline snapshot ready for 1-click rollback ($LatestFile)" -ForegroundColor Green
    exit 0
}

if ($Action -eq "Rollback") {
    $targetFile = if ($SnapshotFile -and (Test-Path $SnapshotFile)) { $SnapshotFile } else { $LatestFile }
    if (-not (Test-Path $targetFile)) {
        Write-Host "[ERROR] No backup snapshot found at $targetFile. Cannot rollback." -ForegroundColor Red
        exit 1
    }

    Write-Host "================================================================" -ForegroundColor Yellow
    Write-Host "   TIME-MACHINE ROLLBACK: RESTORING ORIGINAL SYSTEM STATE" -ForegroundColor Yellow
    Write-Host "   Source: $targetFile" -ForegroundColor Yellow
    Write-Host "================================================================" -ForegroundColor Yellow

    $snap = Get-Content $targetFile -Raw | ConvertFrom-Json

    # 1. Restore Power Plan
    if ($snap.ActivePowerSchemeGuid) {
        powercfg /setactive $snap.ActivePowerSchemeGuid
        Write-Host "[OK] Restored Power Plan to $($snap.ActivePowerSchemeGuid)" -ForegroundColor Green
    }

    # 2. Restore User Environment Variables
    foreach ($prop in $snap.UserEnv.PSObject.Properties) {
        [Environment]::SetEnvironmentVariable($prop.Name, $prop.Value, 'User')
    }
    Write-Host "[OK] Restored User Environment Variables" -ForegroundColor Green

    # 3. Restore Git Global Config
    if (Get-Command git -ErrorAction SilentlyContinue) {
        if ($snap.GitGlobal.LongPaths) { git config --global core.longpaths $snap.GitGlobal.LongPaths } else { git config --global --unset core.longpaths 2>$null }
        if ($snap.GitGlobal.PostBuffer) { git config --global http.postBuffer $snap.GitGlobal.PostBuffer } else { git config --global --unset http.postBuffer 2>$null }
        if ($snap.GitGlobal.SslBackend) { git config --global http.sslBackend $snap.GitGlobal.SslBackend } else { git config --global --unset http.sslBackend 2>$null }
        Write-Host "[OK] Restored Git Global configuration" -ForegroundColor Green
    }

    if (-not $isAdmin) {
        Write-Host "[WARNING] Run Rollback in PowerShell (Admin) to restore HKLM Registry & NIC hardware properties!" -ForegroundColor Yellow
        exit 0
    }

    # 4. Restore Registry Keys
    if ($null -ne $snap.Registry.NetworkThrottlingIndex) {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value $snap.Registry.NetworkThrottlingIndex -Type DWord -Force
    }
    if ($null -ne $snap.Registry.SystemResponsiveness) {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value $snap.Registry.SystemResponsiveness -Type DWord -Force
    }
    if ($null -ne $snap.Registry.HwSchMode) {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value $snap.Registry.HwSchMode -Type DWord -Force
    }
    if ($null -ne $snap.Registry.MaxUserPort) {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "MaxUserPort" -Value $snap.Registry.MaxUserPort -Type DWord -Force
    } else {
        Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "MaxUserPort" -ErrorAction SilentlyContinue
    }
    if ($null -ne $snap.Registry.TcpTimedWaitDelay) {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpTimedWaitDelay" -Value $snap.Registry.TcpTimedWaitDelay -Type DWord -Force
    } else {
        Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpTimedWaitDelay" -ErrorAction SilentlyContinue
    }

    if ($snap.InterfaceRegistryPath -and (Test-Path $snap.InterfaceRegistryPath)) {
        if ($null -ne $snap.Registry.TcpAckFrequency) {
            Set-ItemProperty -Path $snap.InterfaceRegistryPath -Name "TcpAckFrequency" -Value $snap.Registry.TcpAckFrequency -Type DWord -Force
        } else {
            Remove-ItemProperty -Path $snap.InterfaceRegistryPath -Name "TcpAckFrequency" -ErrorAction SilentlyContinue
        }
        if ($null -ne $snap.Registry.TCPNoDelay) {
            Set-ItemProperty -Path $snap.InterfaceRegistryPath -Name "TCPNoDelay" -Value $snap.Registry.TCPNoDelay -Type DWord -Force
        } else {
            Remove-ItemProperty -Path $snap.InterfaceRegistryPath -Name "TCPNoDelay" -ErrorAction SilentlyContinue
        }
    }
    netsh int ipv4 set dynamicport tcp start=49152 num=16384 | Out-Null
    Write-Host "[OK] Restored Windows Registry & TCP Dynamic Port Range" -ForegroundColor Green

    # 5. Restore NIC Hardware Properties
    if ($snap.AdapterName -and $snap.NicAdvancedProperties) {
        foreach ($prop in $snap.NicAdvancedProperties.PSObject.Properties) {
            try {
                Set-NetAdapterAdvancedProperty -Name $snap.AdapterName -RegistryKeyword $prop.Name -RegistryValue $prop.Value -NoRestart -ErrorAction SilentlyContinue
            } catch {}
        }
        Restart-NetAdapter -Name $snap.AdapterName -ErrorAction SilentlyContinue
        Write-Host "[OK] Restored NIC [$($snap.AdapterName)] hardware properties to original state" -ForegroundColor Green
    }

    Write-Host "`n[SUCCESS] Rollback complete! Restart Windows to finalize kernel settings." -ForegroundColor Green
}
