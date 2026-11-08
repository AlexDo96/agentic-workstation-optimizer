<#
.SYNOPSIS
    Universal Multi-Agent Installer v2.0 for `agentic-workstation-optimizer`.
    Automatically installs this Skill, Slash Command (/agentic-workstation-optimizer),
    Specialist Subagent (@network-doctor), and Rule into:
      1. Google Antigravity (~/.gemini/config/skills/ & ~/.gemini/config/agents/)
      2. Claude Code CLI (~/.claude/skills/, ~/.claude/commands/, ~/.claude/agents/)
      3. OpenCode CLI (~/.config/opencode/skills/, commands/, agents/)
      4. OpenAI Codex CLI (~/.codex/skills/)
      5. Cursor IDE (.cursor/rules/)
      6. Windsurf / GitHub Copilot (AGENTS.md)
#>

param(
    [ValidateSet("Global", "Workspace", "Both")]
    [string]$Scope = "Both",
    [string]$TargetWorkspace = (Get-Location).Path
)

$SkillRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   UNIVERSAL AI AGENT INSTALLER v2.0: agentic-workstation-optimizer" -ForegroundColor Cyan
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
    Write-Host "[OK] Installed Skill Bundle for $AgentName -> $DestDir" -ForegroundColor Green
}

if ($Scope -in @("Global", "Both")) {
    Write-Host "`n--- Installing to Global User Directories ($HOME) ---" -ForegroundColor Yellow

    # Clean up legacy v1.0 directory name if present so skills don't duplicate
    foreach ($legacyPath in @(
        "$HOME\.gemini\config\skills\network-ai-optimizer",
        "$HOME\.claude\skills\network-ai-optimizer",
        "$HOME\.config\opencode\skills\network-ai-optimizer",
        "$HOME\.codex\skills\network-ai-optimizer"
    )) {
        if (Test-Path $legacyPath) { Remove-Item -Path $legacyPath -Recurse -Force -ErrorAction SilentlyContinue }
    }

    # 1. Google Antigravity Global Skill & Subagent
    Copy-SkillBundle -DestDir "$HOME\.gemini\config\skills\agentic-workstation-optimizer" -AgentName "Google Antigravity (Global Skill)"
    New-Item -ItemType Directory -Path "$HOME\.gemini\config\agents" -Force | Out-Null
    Copy-Item -Path "$SkillRoot\.agents\agents\network-doctor.md" -Destination "$HOME\.gemini\config\agents\network-doctor.md" -Force
    Write-Host "[OK] Installed Antigravity Subagent (network-doctor) -> $HOME\.gemini\config\agents\network-doctor.md" -ForegroundColor Green

    # 2. Claude Code Global Skill, Slash Command (/agentic-workstation-optimizer) & Subagent (@network-doctor)
    Copy-SkillBundle -DestDir "$HOME\.claude\skills\agentic-workstation-optimizer" -AgentName "Claude Code (Global Skill)"
    New-Item -ItemType Directory -Path "$HOME\.claude\commands" -Force | Out-Null
    Copy-Item -Path "$SkillRoot\.claude\commands\agentic-workstation-optimizer.md" -Destination "$HOME\.claude\commands\agentic-workstation-optimizer.md" -Force
    New-Item -ItemType Directory -Path "$HOME\.claude\agents" -Force | Out-Null
    Copy-Item -Path "$SkillRoot\.claude\agents\network-doctor.md" -Destination "$HOME\.claude\agents\network-doctor.md" -Force
    Write-Host "[OK] Installed Claude Code Command (/agentic-workstation-optimizer) & Subagent (network-doctor)" -ForegroundColor Green

    # 3. OpenCode Global Skill, Command & Subagent
    Copy-SkillBundle -DestDir "$HOME\.config\opencode\skills\agentic-workstation-optimizer" -AgentName "OpenCode CLI (Global Skill)"
    New-Item -ItemType Directory -Path "$HOME\.config\opencode\commands" -Force | Out-Null
    Copy-Item -Path "$SkillRoot\.claude\commands\agentic-workstation-optimizer.md" -Destination "$HOME\.config\opencode\commands\agentic-workstation-optimizer.md" -Force
    New-Item -ItemType Directory -Path "$HOME\.config\opencode\agents" -Force | Out-Null
    Copy-Item -Path "$SkillRoot\.agents\agents\network-doctor.md" -Destination "$HOME\.config\opencode\agents\network-doctor.md" -Force
    Write-Host "[OK] Installed OpenCode Command (/agentic-workstation-optimizer) & Subagent (network-doctor)" -ForegroundColor Green

    # 4. OpenAI Codex CLI Global Skill
    Copy-SkillBundle -DestDir "$HOME\.codex\skills\agentic-workstation-optimizer" -AgentName "OpenAI Codex CLI (Global Skill)"
}

if ($Scope -in @("Workspace", "Both") -and $TargetWorkspace -ne $SkillRoot) {
    Write-Host "`n--- Installing to Workspace ($TargetWorkspace) ---" -ForegroundColor Yellow

    if (Test-Path "$TargetWorkspace\.agents\skills\network-ai-optimizer") {
        Remove-Item -Path "$TargetWorkspace\.agents\skills\network-ai-optimizer" -Recurse -Force -ErrorAction SilentlyContinue
    }

    # 1. Antigravity / OpenCode / Standard .agents/skills/ & .agents/agents/
    Copy-SkillBundle -DestDir "$TargetWorkspace\.agents\skills\agentic-workstation-optimizer" -AgentName "Workspace .agents/skills"
    New-Item -ItemType Directory -Path "$TargetWorkspace\.agents\agents" -Force | Out-Null
    Copy-Item -Path "$SkillRoot\.agents\agents\network-doctor.md" -Destination "$TargetWorkspace\.agents\agents\network-doctor.md" -Force

    # 2. Claude Code Workspace Command & Subagent
    New-Item -ItemType Directory -Path "$TargetWorkspace\.claude\commands" -Force | Out-Null
    Copy-Item -Path "$SkillRoot\.claude\commands\agentic-workstation-optimizer.md" -Destination "$TargetWorkspace\.claude\commands\agentic-workstation-optimizer.md" -Force
    New-Item -ItemType Directory -Path "$TargetWorkspace\.claude\agents" -Force | Out-Null
    Copy-Item -Path "$SkillRoot\.claude\agents\network-doctor.md" -Destination "$TargetWorkspace\.claude\agents\network-doctor.md" -Force
    Write-Host "[OK] Installed Workspace Claude Command & Subagent (network-doctor)" -ForegroundColor Green

    # 3. Cursor IDE Workspace Rule (.cursor/rules/*.mdc)
    New-Item -ItemType Directory -Path "$TargetWorkspace\.cursor\rules" -Force | Out-Null
    Copy-Item -Path "$SkillRoot\.cursor\rules\agentic-workstation-optimizer.mdc" -Destination "$TargetWorkspace\.cursor\rules\agentic-workstation-optimizer.mdc" -Force
    Write-Host "[OK] Installed Workspace Cursor Rule -> $TargetWorkspace\.cursor\rules\agentic-workstation-optimizer.mdc" -ForegroundColor Green
}

Write-Host "`n================================================================" -ForegroundColor Green
Write-Host "   v2.0 INSTALLATION COMPLETE ACROSS ALL AI AGENTS!" -ForegroundColor Green
Write-Host "   - Skill      : agentic-workstation-optimizer" -ForegroundColor White
Write-Host "   - Command    : /agentic-workstation-optimizer (Claude Code / OpenCode)" -ForegroundColor White
Write-Host "   - Subagent   : network-doctor (Claude Code / Antigravity / OpenCode)" -ForegroundColor White
Write-Host "   - Cursor IDE : .cursor/rules/agentic-workstation-optimizer.mdc" -ForegroundColor White
Write-Host "================================================================" -ForegroundColor Green
