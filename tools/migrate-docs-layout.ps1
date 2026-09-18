[CmdletBinding()]
param(
    [string]$TargetRoot = ".",
    [string]$LayoutFile = "",
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

function Normalize-Rel([string]$Path) {
    return ($Path -replace "\\", "/").TrimStart([char[]]@(".", "/"))
}

function Get-MapValue($Object, [string]$Name) {
    if ($null -eq $Object) { return $null }
    $p = $Object.PSObject.Properties[$Name]
    if ($null -eq $p) { return $null }
    return [string]$p.Value
}

function Resolve-Destination([string]$RelativePath, $Layout) {
    $relative = Normalize-Rel $RelativePath

    $exact = Get-MapValue $Layout.path_map $relative
    if (-not [string]::IsNullOrWhiteSpace($exact)) {
        return Normalize-Rel $exact
    }

    $prefixes = @($Layout.prefix_map.PSObject.Properties | Sort-Object { $_.Name.Length } -Descending)
    foreach ($p in $prefixes) {
        $from = Normalize-Rel $p.Name
        if ($relative.StartsWith($from, [StringComparison]::OrdinalIgnoreCase)) {
            $to = Normalize-Rel ([string]$p.Value)
            return $to + $relative.Substring($from.Length)
        }
    }

    return $relative
}

function File-Hash([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Invoke-GitCommand([string]$Root, [string[]]$Args) {
    $gitExe = (Get-Command git.exe -ErrorAction Stop).Source
    & $gitExe -C $Root @Args
    if ($LASTEXITCODE -ne 0) {
        throw ("Git command failed in {0}: git {1}" -f $Root, ($Args -join " "))
    }
}

function Load-OrderedLayout([string]$File) {
    if (-not (Test-Path -LiteralPath $File -PathType Leaf)) {
        throw "Layout file not found: $File"
    }

    $config = Get-Content -LiteralPath $File -Raw -Encoding UTF8 | ConvertFrom-Json
    $layout = $config.layouts.'ordered-v2'
    if ($null -eq $layout) {
        throw "ordered-v2 layout is missing: $File"
    }
    return $layout
}

function Build-Plan([string]$Root, $Layout) {
    $legacyRoots = @(
        "docs/ai",
        "docs/team",
        "docs/modules",
        "docs/knowledge",
        "docs/operations",
        "docs/decisions",
        "docs/work"
    )

    $plan = @()

    foreach ($legacyRoot in $legacyRoots) {
        $fullRoot = Join-Path $Root ($legacyRoot -replace "/", [IO.Path]::DirectorySeparatorChar)
        if (-not (Test-Path -LiteralPath $fullRoot -PathType Container)) { continue }

        Get-ChildItem -LiteralPath $fullRoot -File -Recurse | ForEach-Object {
            $source = Normalize-Rel ($_.FullName.Substring($Root.Length).TrimStart("\", "/"))
            $destination = Resolve-Destination $source $Layout

            if ($destination -eq $source) {
                throw "No ordered-v2 mapping for legacy file: $source"
            }

            $plan += [PSCustomObject]@{
                Source = $source
                Destination = $destination
                SourceFull = $_.FullName
                DestinationFull = Join-Path $Root ($destination -replace "/", [IO.Path]::DirectorySeparatorChar)
                Hash = File-Hash $_.FullName
                Action = "Move"
            }
        }
    }

    return @($plan | Sort-Object Source)
}

function Validate-Plan([object[]]$Plan) {
    $seen = @{}
    $errors = @()

    foreach ($item in $Plan) {
        $key = $item.Destination.ToLowerInvariant()

        if ($seen.ContainsKey($key)) {
            $errors += "Two sources map to $($item.Destination): $($seen[$key]) and $($item.Source)"
            continue
        }
        $seen[$key] = $item.Source

        if (Test-Path -LiteralPath $item.DestinationFull -PathType Leaf) {
            if ((File-Hash $item.DestinationFull) -eq $item.Hash) {
                $item.Action = "Deduplicate"
            }
            else {
                $errors += "Destination exists with different content: $($item.Source) -> $($item.Destination)"
            }
        }
        elseif (Test-Path -LiteralPath $item.DestinationFull) {
            $errors += "Destination exists and is not a file: $($item.Destination)"
        }
    }

    if ($errors.Count -gt 0) {
        Write-Host "Migration blocked:"
        $errors | ForEach-Object { Write-Host " - $_" }
        throw "Collision preflight failed. No file was moved."
    }
}

function Rewrite-References([string]$Root, $Layout) {
    $pairs = @()

    $Layout.path_map.PSObject.Properties |
        Sort-Object { $_.Name.Length } -Descending |
        ForEach-Object {
            $pairs += [PSCustomObject]@{
                From = Normalize-Rel $_.Name
                To = Normalize-Rel ([string]$_.Value)
            }
        }

    $Layout.prefix_map.PSObject.Properties |
        Sort-Object { $_.Name.Length } -Descending |
        ForEach-Object {
            $pairs += [PSCustomObject]@{
                From = Normalize-Rel $_.Name
                To = Normalize-Rel ([string]$_.Value)
            }
        }

    $files = @()

    foreach ($rootFile in @("AGENTS.md", "CLAUDE.md")) {
        $p = Join-Path $Root $rootFile
        if (Test-Path -LiteralPath $p -PathType Leaf) {
            $files += Get-Item -LiteralPath $p
        }
    }

    foreach ($folder in @("docs", ".claude", ".agents")) {
        $p = Join-Path $Root $folder
        if (Test-Path -LiteralPath $p -PathType Container) {
            $files += Get-ChildItem -LiteralPath $p -File -Recurse -Filter *.md
        }
    }

    $changed = 0

    foreach ($file in @($files | Sort-Object FullName -Unique)) {
        $before = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
        $after = $before

        foreach ($pair in $pairs) {
            $after = $after.Replace($pair.From, $pair.To)
            $after = $after.Replace(($pair.From -replace "/", "\"), ($pair.To -replace "/", "\"))
        }

        if ($after -ne $before) {
            Set-Content -LiteralPath $file.FullName -Value $after -Encoding UTF8 -NoNewline
            $changed++
        }
    }

    return $changed
}

function Write-State([string]$Root) {
    $dir = Join-Path $Root ".ai-dev-os"
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $state = [ordered]@{
        docs_layout = "ordered-v2"
        docs_layout_version = 2
    }

    (($state | ConvertTo-Json) + [Environment]::NewLine) |
        Set-Content -LiteralPath (Join-Path $dir "state.json") -Encoding UTF8 -NoNewline
}

if ([string]::IsNullOrWhiteSpace($LayoutFile)) {
    $LayoutFile = Join-Path (Split-Path -Parent $PSScriptRoot) ".ai-dev-os/layouts.json"
}

$root = (Resolve-Path -LiteralPath $TargetRoot).Path.TrimEnd("\", "/")
$layoutFileResolved = (Resolve-Path -LiteralPath $LayoutFile).Path
$layout = Load-OrderedLayout $layoutFileResolved
$plan = Build-Plan $root $layout

Validate-Plan $plan

Write-Host ("Legacy docs inventory: {0} file(s)" -f $plan.Count)
foreach ($item in $plan) {
    Write-Host (" - [{0}] {1} -> {2}" -f $item.Action, $item.Source, $item.Destination)
}

if (-not $Apply) {
    Write-Host "Dry run only. No file changed."
    exit 0
}

$gitExe = (Get-Command git.exe -ErrorAction Stop).Source
$status = (& $gitExe -C $root status --porcelain)
if ($LASTEXITCODE -ne 0) {
    throw "Target is not a Git repository: $root"
}
if (-not [string]::IsNullOrWhiteSpace(($status -join [Environment]::NewLine))) {
    throw "Target working tree must be clean before migration."
}

try {
    foreach ($item in $plan) {
        $destinationDir = Split-Path -Parent $item.DestinationFull
        if (-not (Test-Path -LiteralPath $destinationDir -PathType Container)) {
            New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
        }

        if ($item.Action -eq "Deduplicate") {
            Invoke-GitCommand $root @("rm", "--", $item.Source)
        }
        else {
            Invoke-GitCommand $root @("mv", "--", $item.Source, $item.Destination)
        }
    }

    foreach ($item in $plan) {
        if (-not (Test-Path -LiteralPath $item.DestinationFull -PathType Leaf)) {
            throw "Migrated file missing: $($item.Destination)"
        }
        if ((File-Hash $item.DestinationFull) -ne $item.Hash) {
            throw "Content changed during move: $($item.Source) -> $($item.Destination)"
        }
    }

    $rewritten = Rewrite-References $root $layout
    Write-State $root

    Write-Host ("Reference files rewritten: {0}" -f $rewritten)
    Write-Host "PASS: docs layout migrated to ordered-v2 without bootstrap."
}
catch {
    Write-Host "Migration failed. Restoring clean pre-migration state."
    $gitExe = (Get-Command git.exe -ErrorAction Stop).Source
    & $gitExe -C $root reset --hard HEAD | Out-Null
    & $gitExe -C $root clean -fd | Out-Null
    throw
}
