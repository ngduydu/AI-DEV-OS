$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$migrator = Join-Path $repoRoot "tools/migrate-docs-layout.ps1"
$layouts = Join-Path $repoRoot ".ai-dev-os/layouts.json"
$temp = Join-Path ([IO.Path]::GetTempPath()) ("ai-dev-os-layout-test-" + [Guid]::NewGuid().ToString("N"))

function Git([string]$Root, [string[]]$Args) {
    & git -C $Root @Args | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw ("git failed: {0}" -f ($Args -join " "))
    }
}

try {
    New-Item -ItemType Directory -Path $temp -Force | Out-Null
    Git $temp @("init")
    Git $temp @("config", "user.email", "test@example.com")
    Git $temp @("config", "user.name", "AI DEV OS Test")

    $fixtures = @{
        "docs/ai/03-ARCHITECTURE.md" = "ARCH"
        "docs/ai/custom-project-note.md" = "CUSTOM"
        "docs/modules/sales/rules.md" = "MODULE"
        "docs/knowledge/pitfalls/legacy.md" = "PITFALL"
        "docs/operations/deployment.md" = "OPS"
        "docs/decisions/0001-old.md" = "ADR"
        "docs/work/task-1/PLAN.md" = "PLAN"
        "AGENTS.md" = "Read docs/ai/03-ARCHITECTURE.md and docs/modules/sales/rules.md"
    }

    foreach ($entry in $fixtures.GetEnumerator()) {
        $path = Join-Path $temp ($entry.Key -replace "/", [IO.Path]::DirectorySeparatorChar)
        $dir = Split-Path -Parent $path
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        Set-Content -LiteralPath $path -Value $entry.Value -Encoding UTF8 -NoNewline
    }

    Git $temp @("add", ".")
    Git $temp @("commit", "-m", "fixture")

    & powershell -ExecutionPolicy Bypass -File $migrator -TargetRoot $temp -LayoutFile $layouts
    if ($LASTEXITCODE -ne 0) { throw "Dry-run failed" }

    $statusAfterDryRun = (& git -C $temp status --porcelain) -join [Environment]::NewLine
    if (-not [string]::IsNullOrWhiteSpace($statusAfterDryRun)) {
        throw "Dry-run changed working tree"
    }

    & powershell -ExecutionPolicy Bypass -File $migrator -TargetRoot $temp -LayoutFile $layouts -Apply
    if ($LASTEXITCODE -ne 0) { throw "Apply failed" }

    $expected = @{
        "docs/00-overview/architecture.md" = "ARCH"
        "docs/01-development/project/custom-project-note.md" = "CUSTOM"
        "docs/02-modules/sales/rules.md" = "MODULE"
        "docs/03-knowledge/pitfalls/legacy.md" = "PITFALL"
        "docs/04-operations/deployment.md" = "OPS"
        "docs/05-decisions/0001-old.md" = "ADR"
        "docs/06-work/task-1/PLAN.md" = "PLAN"
    }

    foreach ($entry in $expected.GetEnumerator()) {
        $path = Join-Path $temp ($entry.Key -replace "/", [IO.Path]::DirectorySeparatorChar)
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Missing migrated file: $($entry.Key)"
        }

        $actual = Get-Content -LiteralPath $path -Raw -Encoding UTF8
        if ($actual -ne $entry.Value) {
            throw "Content changed: $($entry.Key)"
        }
    }

    foreach ($legacy in @(
        "docs/ai/03-ARCHITECTURE.md",
        "docs/ai/custom-project-note.md",
        "docs/modules/sales/rules.md",
        "docs/knowledge/pitfalls/legacy.md",
        "docs/operations/deployment.md",
        "docs/decisions/0001-old.md",
        "docs/work/task-1/PLAN.md"
    )) {
        $path = Join-Path $temp ($legacy -replace "/", [IO.Path]::DirectorySeparatorChar)
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            throw "Legacy file still exists: $legacy"
        }
    }

    $agents = Get-Content -LiteralPath (Join-Path $temp "AGENTS.md") -Raw -Encoding UTF8
    if ($agents -notmatch "docs/00-overview/architecture.md") {
        throw "Architecture reference was not rewritten"
    }
    if ($agents -notmatch "docs/02-modules/sales/rules.md") {
        throw "Module reference was not rewritten"
    }

    $state = Get-Content -LiteralPath (Join-Path $temp ".ai-dev-os/state.json") -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($state.docs_layout -ne "ordered-v2" -or $state.docs_layout_version -ne 2) {
        throw "Invalid state marker"
    }

    Write-Host "PASS: deterministic docs layout migration preserves content"
}
finally {
    if (Test-Path $temp) {
        Remove-Item -LiteralPath $temp -Recurse -Force
    }
}
