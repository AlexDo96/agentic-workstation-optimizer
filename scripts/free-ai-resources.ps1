<#
.SYNOPSIS
    Frees GPU VRAM, physical System RAM, and closes leftover automation WebDriver processes.
    - Unloads idle Ollama models from GPU memory (`ollama ps` -> `ollama stop`).
    - Closes leftover WebDriver processes (`chromedriver`, `geckodriver`, `msedgedriver`).
    - Trims idle working set memory from background processes via Windows PSAPI (`EmptyWorkingSet`).
    - Prints available physical RAM and GPU VRAM before and after.
#>

param(
    [switch]$IncludeWallpaperEngine
)

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   FREEING GPU VRAM, SYSTEM RAM & LEFTOVER PROCESSES" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

Add-Type -AssemblyName Microsoft.VisualBasic
$compInfo = New-Object Microsoft.VisualBasic.Devices.ComputerInfo
$ramFreeBeforeMB = [math]::Round($compInfo.AvailablePhysicalMemory / 1MB, 0)
Write-Host "System RAM Free Before : $ramFreeBeforeMB MB" -ForegroundColor Yellow

# 1. Check GPU VRAM Before
if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
    $vramBefore = nvidia-smi --query-gpu=memory.used,memory.free,memory.total --format=csv,noheader
    Write-Host "GPU VRAM Before        : $vramBefore" -ForegroundColor Yellow
}

# 2. Unload active Ollama models from VRAM
if (Get-Command ollama -ErrorAction SilentlyContinue) {
    $runningModels = ollama ps 2>$null | Select-Object -Skip 1
    if ($runningModels) {
        foreach ($line in $runningModels) {
            $modelName = ($line -split '\s+')[0]
            if ($modelName) {
                Write-Host "Unloading Ollama model from VRAM: $modelName..." -ForegroundColor Yellow
                ollama stop $modelName | Out-Null
                Write-Host "[OK] Stopped model: $modelName" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "[OK] No idle Ollama models currently occupying VRAM." -ForegroundColor Green
    }
}

# 3. Close leftover QA Automation WebDrivers (Playwright / Selenium / Appium)
$leftoverDrivers = @('chromedriver', 'geckodriver', 'msedgedriver', 'iedriverserver')
if ($IncludeWallpaperEngine) {
    $leftoverDrivers += @('wallpaper32', 'wallpaper64')
}

$killedCount = 0
foreach ($drv in $leftoverDrivers) {
    $procs = Get-Process -Name $drv -ErrorAction SilentlyContinue
    if ($procs) {
        $procs | Stop-Process -Force -ErrorAction SilentlyContinue
        $killedCount += $procs.Count
        Write-Host "[OK] Closed $($procs.Count) leftover '$drv' process(es)" -ForegroundColor Green
    }
}
if ($killedCount -eq 0) {
    Write-Host "[OK] No leftover WebDriver processes found." -ForegroundColor Green
}

# 4. Reclaim Unused Physical RAM Working Set from Background Processes (Win32 EmptyWorkingSet)
$memberDef = @'
[DllImport("psapi.dll")]
public static extern bool EmptyWorkingSet(IntPtr hwProc);
'@
try {
    $Win32Psapi = Add-Type -MemberDefinition $memberDef -Name "Win32Psapi" -Namespace "MemoryUtils" -PassThru -ErrorAction SilentlyContinue
    $trimmedCount = 0
    foreach ($proc in (Get-Process | Where-Object { $_.WorkingSet64 -gt 30MB -and $_.ProcessName -notin @('Idle','System','Memory Compression') })) {
        try {
            if ($Win32Psapi::EmptyWorkingSet($proc.Handle)) { $trimmedCount++ }
        } catch {}
    }
    Write-Host "[OK] Trimmed unused background memory pages across $trimmedCount processes" -ForegroundColor Green
} catch {}

# 5. Trigger .NET Garbage Collection & Flush DNS
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
ipconfig /flushdns | Out-Null

Start-Sleep -Seconds 1
$ramFreeAfterMB = [math]::Round($compInfo.AvailablePhysicalMemory / 1MB, 0)
$ramGainedMB = $ramFreeAfterMB - $ramFreeBeforeMB
Write-Host ("System RAM Free After  : {0} MB ({1}{2} MB freed)" -f $ramFreeAfterMB, $(if ($ramGainedMB -ge 0) { "+" } else { "" }), $ramGainedMB) -ForegroundColor Green

# 6. Check GPU VRAM After
if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
    $vramAfter = nvidia-smi --query-gpu=memory.used,memory.free,memory.total --format=csv,noheader
    Write-Host "GPU VRAM After         : $vramAfter" -ForegroundColor Green
}
