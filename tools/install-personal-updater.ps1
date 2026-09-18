param(
    [string]$SourceRoot = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($SourceRoot)) {
    $SourceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
} else {
    $SourceRoot = (Resolve-Path $SourceRoot).Path
}

$canonicalSkill = Join-Path $SourceRoot ".claude\skills\update-ai-dev-os\SKILL.md"
$versionFile = Join-Path $SourceRoot ".ai-dev-os\VERSION"

if (-not (Test-Path $canonicalSkill)) {
    throw "Canonical updater skill not found: $canonicalSkill"
}

if (-not (Test-Path $versionFile)) {
    throw "AI-DEV-OS VERSION not found: $versionFile"
}

$targetDir = Join-Path $HOME ".claude\skills\update-ai-dev-os"
$targetFile = Join-Path $targetDir "SKILL.md"
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

$escapedSource = $SourceRoot.Replace("\", "\\")
$content = @"
---
name: update-ai-dev-os
description: Use when a repository already contains AI-DEV-OS files and needs to upgrade from the canonical local AI-DEV-OS source without manually copying or merging framework files.
disable-model-invocation: true
---

# Global AI-DEV-OS Updater Launcher

Canonical AI-DEV-OS source:

```text
$SourceRoot
```

For every invocation:

1. Treat the current working repository as the TARGET repository.
2. Read and follow the canonical updater skill from:
   `$canonicalSkill`
3. Pass this exact source root to the canonical workflow:
   `$SourceRoot`
4. Do not use a stale project-level updater skill as the authority.
5. Do not modify the AI-DEV-OS source repository except the canonical workflow's safe `git pull --ff-only` preflight.
6. If the source path no longer exists, stop and tell the user to rerun:
   `tools/install-personal-updater.ps1`

The canonical skill is the source of truth for all upgrade behavior.
"@

Set-Content -Path $targetFile -Value $content -Encoding UTF8

Write-Host "Installed personal updater skill:"
Write-Host "  $targetFile"
Write-Host "Canonical source:"
Write-Host "  $SourceRoot"
Write-Host ""
Write-Host "Restart Claude Code, open any AI-DEV-OS project, then run:"
Write-Host "  /update-ai-dev-os"
