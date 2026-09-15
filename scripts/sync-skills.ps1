$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$SourceRoot = Join-Path $RepoRoot ".claude/skills"
$MirrorRoot = Join-Path $RepoRoot ".agents/skills"

if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
    throw "Source skills directory not found: $SourceRoot"
}

New-Item -ItemType Directory -Force -Path $MirrorRoot | Out-Null

$count = 0
Get-ChildItem -LiteralPath $SourceRoot -Directory | ForEach-Object {
    $sourceFile = Join-Path $_.FullName "SKILL.md"
    if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
        return
    }

    $mirrorDir = Join-Path $MirrorRoot $_.Name
    New-Item -ItemType Directory -Force -Path $mirrorDir | Out-Null
    Copy-Item -LiteralPath $sourceFile -Destination (Join-Path $mirrorDir "SKILL.md") -Force
    $count++
}

Get-ChildItem -LiteralPath $MirrorRoot -Directory | ForEach-Object {
    $sourceFile = Join-Path (Join-Path $SourceRoot $_.Name) "SKILL.md"
    if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
        Remove-Item -LiteralPath $_.FullName -Recurse -Force
    }
}

Write-Host "Synced $count skill(s) from .claude/skills to .agents/skills."
