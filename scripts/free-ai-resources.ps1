<#
.SYNOPSIS
    1-Click Zombie Process & VRAM Cleaner for AI Engineers & QA Automation.
    - Unloads idle/stuck Ollama models from GPU VRAM (`ollama ps` -> `ollama stop`).
    - Terminates orphaned automation drivers (`chromedriver`, `geckodriver`, `msedgedriver`, stuck headless browsers).
    - Reports freed RAM and GPU VRAM (`nvidia-smi`).
#>

param(
    [switch]$IncludeWallpaperEngine
)

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   AI & QA AUTOMATION RESOURCE CLEANER (VRAM & ZOMBIE PROCESSES)" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

# 1. Check GPU VRAM Before
if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
    $vramBefore = nvidia-smi --query-gpu=memory.used,memory.free,memory.total --format=csv,noheader
    Write-Host "GPU VRAM Before : $vramBefore" -ForegroundColor Yellow
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

# 3. Clean up orphaned QA Automation WebDrivers (Playwright / Selenium / Appium)
$zombieDrivers = @('chromedriver', 'geckodriver', 'msedgedriver', 'iedriverserver')
if ($IncludeWallpaperEngine) {
    $zombieDrivers += @('wallpaper32', 'wallpaper64')
}

$killedCount = 0
foreach ($drv in $zombieDrivers) {
    $procs = Get-Process -Name $drv -ErrorAction SilentlyContinue
    if ($procs) {
        $procs | Stop-Process -Force -ErrorAction SilentlyContinue
        $killedCount += $procs.Count
        Write-Host "[OK] Terminated $($procs.Count) orphaned '$drv' process(es)" -ForegroundColor Green
    }
}
if ($killedCount -eq 0) {
    Write-Host "[OK] No orphaned WebDriver processes found." -ForegroundColor Green
}

# 4. Trigger .NET Garbage Collection & Flush DNS
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
ipconfig /flushdns | Out-Null

# 5. Check GPU VRAM After
if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 1
    $vramAfter = nvidia-smi --query-gpu=memory.used,memory.free,memory.total --format=csv,noheader
    Write-Host "GPU VRAM After  : $vramAfter" -ForegroundColor Green
}
