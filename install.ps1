<#
.SYNOPSIS
    安装 dsh-session-notes 里的 Agent Skill。

.EXAMPLE
    .\install.ps1
    安装到 ~/.agents/skills

.EXAMPLE
    .\install.ps1 -Claude
    同时安装到 ~/.agents/skills 和 ~/.claude/skills
#>
[CmdletBinding()]
param(
    [switch]$Claude,
    [string]$SkillsRoot
)

$ErrorActionPreference = 'Stop'

$src = Join-Path $PSScriptRoot 'skills'
if (-not (Test-Path $src)) {
    throw "找不到 skills 目录：$src"
}

$targets = @()
if ($SkillsRoot) {
    $targets += $SkillsRoot
} else {
    $targets += (Join-Path $HOME '.agents\skills')
}
if ($Claude) {
    $targets += (Join-Path $HOME '.claude\skills')
}

$skills = Get-ChildItem -Path $src -Directory
if ($skills.Count -eq 0) {
    throw "skills 目录里没有 skill：$src"
}

foreach ($skill in $skills) {
    foreach ($target in $targets) {
        if (-not (Test-Path $target)) {
            New-Item -ItemType Directory -Path $target -Force | Out-Null
        }
        $dest = Join-Path $target $skill.Name
        if (Test-Path $dest) {
            Remove-Item -Path $dest -Recurse -Force
            Write-Host "覆盖旧版本：$dest"
        }
        Copy-Item -Path $skill.FullName -Destination $dest -Recurse -Force
        Write-Host "已安装：$dest"
    }
}

Write-Host ""
Write-Host "完成。记得改 skills\conclude\SKILL.md 里的「默认仓库」占位符。"
