$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$migrator = Join-Path $repoRoot "tools/migrate-docs-layout.ps1"
$layouts = Join-Path $repoRoot ".ai-dev-os/layouts.json"

function Invoke-GitCommand([string]$Root, [string[]]$GitArgs) {
    $gitExe = (Get-Command git.exe -ErrorAction Stop).Source
    & $gitExe -C $Root @GitArgs | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw ("git failed: {0}" -f ($GitArgs -join " "))
    }
}

function New-TestRepo([string]$Root) {
    New-Item -ItemType Directory -Path $Root -Force | Out-Null
    Invoke-GitCommand $Root @("init")
    Invoke-GitCommand $Root @("config", "user.email", "test@example.com")
    Invoke-GitCommand $Root @("config", "user.name", "AI DEV OS Test")
}

function Write-Fixture([string]$Root, [string]$RelativePath, [string]$Content) {
    $path = Join-Path $Root ($RelativePath -replace "/", [IO.Path]::DirectorySeparatorChar)
    $dir = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Set-Content -LiteralPath $path -Value $Content -Encoding UTF8 -NoNewline
}

$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("ai-dev-os-layout-safety-" + [Guid]::NewGuid().ToString("N"))

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    # Case 1: different-content destination must block before mutation.
    $collisionRepo = Join-Path $tempRoot "collision"
    New-TestRepo $collisionRepo
    Write-Fixture $collisionRepo "docs/ai/03-ARCHITECTURE.md" "LEGACY"
    Write-Fixture $collisionRepo "docs/00-overview/architecture.md" "NEW-DIFFERENT"
    Invoke-GitCommand $collisionRepo @("add", ".")
    Invoke-GitCommand $collisionRepo @("commit", "-m", "collision fixture")

    $previousEap = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        & powershell -NoProfile -ExecutionPolicy Bypass -File $migrator -TargetRoot $collisionRepo -LayoutFile $layouts *> $null
        $collisionExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousEap
    }
    if ($collisionExitCode -eq 0) {
        throw "Collision safety test expected failure."
    }

    $legacyContent = Get-Content -LiteralPath (Join-Path $collisionRepo "docs\ai\03-ARCHITECTURE.md") -Raw -Encoding UTF8
    $newContent = Get-Content -LiteralPath (Join-Path $collisionRepo "docs\00-overview\architecture.md") -Raw -Encoding UTF8
    if ($legacyContent -ne "LEGACY" -or $newContent -ne "NEW-DIFFERENT") {
        throw "Collision preflight mutated files."
    }

    $status = (& git -C $collisionRepo status --porcelain) -join [Environment]::NewLine
    if (-not [string]::IsNullOrWhiteSpace($status)) {
        throw "Collision preflight changed working tree."
    }

    # Case 2: malicious mapping must never escape repository root.
    $escapeRepo = Join-Path $tempRoot "escape"
    New-TestRepo $escapeRepo
    Write-Fixture $escapeRepo "docs/ai/custom.md" "SAFE"
    Invoke-GitCommand $escapeRepo @("add", ".")
    Invoke-GitCommand $escapeRepo @("commit", "-m", "escape fixture")

    $maliciousLayout = Join-Path $tempRoot "malicious-layout.json"
    $layout = Get-Content -LiteralPath $layouts -Raw -Encoding UTF8 | ConvertFrom-Json
    $layout.layouts.'ordered-v2'.prefix_map.'docs/ai/' = "../outside/"
    ($layout | ConvertTo-Json -Depth 20) | Set-Content -LiteralPath $maliciousLayout -Encoding UTF8

    $previousEap = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        & powershell -NoProfile -ExecutionPolicy Bypass -File $migrator -TargetRoot $escapeRepo -LayoutFile $maliciousLayout *> $null
        $escapeExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousEap
    }
    if ($escapeExitCode -eq 0) {
        throw "Path-escape safety test expected failure."
    }

    if (Test-Path -LiteralPath (Join-Path $tempRoot "outside\custom.md")) {
        throw "Path-escape test wrote outside repository."
    }

    $escapeStatus = (& git -C $escapeRepo status --porcelain) -join [Environment]::NewLine
    if (-not [string]::IsNullOrWhiteSpace($escapeStatus)) {
        throw "Path-escape preflight changed working tree."
    }

    Write-Host "PASS: docs migration collision and path-escape guards"
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
