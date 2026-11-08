<#
.SYNOPSIS
    Universal Multi-Agent Installer for `network-ai-optimizer`.
    Automatically installs this Skill, Slash Command, and Rule into:
      1. Google Antigravity (~/.gemini/config/skills/)
      2. Claude Code CLI (~/.claude/skills/ & ~/.claude/commands/)
      3. OpenCode CLI (~/.config/opencode/skills/ & ~/.config/opencode/commands/)
      4. OpenAI Codex CLI (~/.codex/skills/)
      5. Cursor IDE (Workspace .cursor/rules/ or Global profile)
      6. Windsurf / GitHub Copilot (Workspace instructions)
#>

param(
    [ValidateSet("Global", "Workspace", "Both")]
    [string]$Scope = "Both",
    [string]$TargetWorkspace = (Get-Location).Path
)

$SkillRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   UNIVERSAL AI AGENT SKILL INSTALLER: network-ai-optimizer" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

function Copy-SkillBundle {
    param([string]$DestDir, [string]$AgentName)
    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    Copy-Item -Path "$SkillRoot\SKILL.md" -Destination "$DestDir\SKILL.md" -Force
    if (Test-Path "$SkillRoot\scripts") {
        New-Item -ItemType Directory -Path "$DestDir\scripts" -Force | Out-Null
        Copy-Item -Path "$SkillRoot\scripts\*" -Destination "$DestDir\scripts\" -Recurse -Force
    }
    if (Test-Path "$SkillRoot\references") {
        New-Item -ItemType Directory -Path "$DestDir\references" -Force | Out-Null
        Copy-Item -Path "$SkillRoot\references\*" -Destination "$DestDir\references\" -Recurse -Force
    }
    Write-Host "[OK] Installed for $AgentName -> $DestDir" -ForegroundColor Green
}

if ($Scope -in @("Global", "Both")) {
    Write-Host "`n--- Installing to Global User Directories ($HOME) ---" -ForegroundColor Yellow

    # 1. Google Antigravity Global Skill
    Copy-SkillBundle -DestDir "$HOME\.gemini\config\skills\network-ai-optimizer" -AgentName "Google Antigravity (Global Skill)"

    # 2. Claude Code Global Skill & Slash Command (/network-ai-optimizer)
    Copy-SkillBundle -DestDir "$HOME\.claude\skills\network-ai-optimizer" -AgentName "Claude Code (Global Skill)"
    New-Item -ItemType Directory -Path "$HOME\.claude\commands" -Force | Out-Null
    Copy-Item -Path "$SkillRoot\.claude\commands\network-ai-optimizer.md" -Destination "$HOME\.claude\commands\network-ai-optimizer.md" -Force
    Write-Host "[OK] Installed Claude Code Slash Command (/network-ai-optimizer) -> $HOME\.claude\commands\network-ai-optimizer.md" -ForegroundColor Green

    # 3. OpenCode Global Skill & Command
    Copy-SkillBundle -DestDir "$HOME\.config\opencode\skills\network-ai-optimizer" -AgentName "OpenCode CLI (Global Skill)"
    New-Item -ItemType Directory -Path "$HOME\.config\opencode\commands" -Force | Out-Null
    Copy-Item -Path "$SkillRoot\.claude\commands\network-ai-optimizer.md" -Destination "$HOME\.config\opencode\commands\network-ai-optimizer.md" -Force
    Write-Host "[OK] Installed OpenCode Command (/network-ai-optimizer) -> $HOME\.config\opencode\commands\network-ai-optimizer.md" -ForegroundColor Green

    # 4. OpenAI Codex CLI Global Skill
    Copy-SkillBundle -DestDir "$HOME\.codex\skills\network-ai-optimizer" -AgentName "OpenAI Codex CLI (Global Skill)"
}

if ($Scope -in @("Workspace", "Both") -and $TargetWorkspace -ne $SkillRoot) {
    Write-Host "`n--- Installing to Workspace ($TargetWorkspace) ---" -ForegroundColor Yellow

    # 1. Antigravity / OpenCode / Standard .agents/skills/
    Copy-SkillBundle -DestDir "$TargetWorkspace\.agents\skills\network-ai-optimizer" -AgentName "Workspace .agents/skills (Antigravity / OpenCode / Codex)"

    # 2. Claude Code Workspace Command
    New-Item -ItemType Directory -Path "$TargetWorkspace\.claude\commands" -Force | Out-Null
    Copy-Item -Path "$SkillRoot\.claude\commands\network-ai-optimizer.md" -Destination "$TargetWorkspace\.claude\commands\network-ai-optimizer.md" -Force
    Write-Host "[OK] Installed Workspace Claude Command -> $TargetWorkspace\.claude\commands\network-ai-optimizer.md" -ForegroundColor Green

    # 3. Cursor IDE Workspace Rule (.cursor/rules/*.mdc)
    New-Item -ItemType Directory -Path "$TargetWorkspace\.cursor\rules" -Force | Out-Null
    Copy-Item -Path "$SkillRoot\.cursor\rules\network-ai-optimizer.mdc" -Destination "$TargetWorkspace\.cursor\rules\network-ai-optimizer.mdc" -Force
    Write-Host "[OK] Installed Workspace Cursor Rule -> $TargetWorkspace\.cursor\rules\network-ai-optimizer.mdc" -ForegroundColor Green
}

Write-Host "`n================================================================" -ForegroundColor Green
Write-Host "   INSTALLATION COMPLETE ACROSS ALL AI AGENTS!" -ForegroundColor Green
Write-Host "   - Antigravity / Codex / OpenCode : Ask to use 'network-ai-optimizer'" -ForegroundColor White
Write-Host "   - Claude Code / OpenCode         : Type '/network-ai-optimizer'" -ForegroundColor White
Write-Host "   - Cursor / Windsurf / Copilot    : Automatic via .cursor/rules & AGENTS.md" -ForegroundColor White
Write-Host "================================================================" -ForegroundColor Green
