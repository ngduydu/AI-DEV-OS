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

function Get-SafeFiles([string]$Directory) {
    $result = @()
    $stack = New-Object 'System.Collections.Generic.Stack[System.IO.DirectoryInfo]'
    $rootItem = Get-Item -LiteralPath $Directory -Force

    if ($rootItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        throw "Refusing reparse-point directory during docs migration: $Directory"
    }

    $stack.Push($rootItem)

    while ($stack.Count -gt 0) {
        $current = $stack.Pop()
        foreach ($item in (Get-ChildItem -LiteralPath $current.FullName -Force)) {
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                throw "Refusing reparse-point entry during docs migration: $($item.FullName)"
            }

            if ($item.PSIsContainer) {
                $stack.Push([System.IO.DirectoryInfo]$item)
            }
            else {
                $result += $item
            }
        }
    }

    return @($result)
}

function Resolve-SafeDestinationFullPath([string]$Root, [string]$Destination) {
    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd("\", "/")
    $candidate = [System.IO.Path]::GetFullPath(
        (Join-Path $rootFull ($Destination -replace "/", [IO.Path]::DirectorySeparatorChar))
    )
    $prefix = $rootFull + [IO.Path]::DirectorySeparatorChar

    if (-not $candidate.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Destination escapes target repository: $Destination"
    }

    $relative = $candidate.Substring($prefix.Length)
    $segments = @($relative.Split([IO.Path]::DirectorySeparatorChar))
    $current = $rootFull

    foreach ($segment in $segments) {
        if ([string]::IsNullOrWhiteSpace($segment)) { continue }
        $current = Join-Path $current $segment
        if (Test-Path -LiteralPath $current) {
            $item = Get-Item -LiteralPath $current -Force
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                throw "Refusing reparse-point destination during docs migration: $current"
            }
        }
    }

    return $candidate
}

function Invoke-GitCommand([string]$Root, [string[]]$GitArgs) {
    $gitExe = (Get-Command git.exe -ErrorAction Stop).Source
    & $gitExe -C $Root @GitArgs
    if ($LASTEXITCODE -ne 0) {
        throw ("Git command failed in {0}: git {1}" -f $Root, ($GitArgs -join " "))
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

function Get-RewritePairs($Layout) {
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

    return @($pairs)
}

function Rewrite-Text([string]$Text, [object[]]$Pairs) {
    $result = $Text
    foreach ($pair in $Pairs) {
        $result = $result.Replace($pair.From, $pair.To)
        $result = $result.Replace(($pair.From -replace "/", "\"), ($pair.To -replace "/", "\"))
    }
    return $result
}

function Build-Plan([string]$Root, $Layout) {
    $legacyRoots = @(
        "docs/ai",
        "docs/team",
        "docs/01-development/project",
        "docs/01-development/team",
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

        Get-SafeFiles -Directory $fullRoot | ForEach-Object {
            $source = Normalize-Rel ($_.FullName.Substring($Root.Length).TrimStart("\", "/"))
            $destination = Resolve-Destination $source $Layout

            if ($destination -eq $source) {
                throw "No ordered-v2 mapping for legacy file: $source"
            }

            $destinationFull = Resolve-SafeDestinationFullPath -Root $Root -Destination $destination

            $isMarkdown = $_.Extension -ieq ".md"
            $originalText = $null
            if ($isMarkdown) {
                $originalText = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8
            }

            $plan += [PSCustomObject]@{
                Source = $source
                Destination = $destination
                SourceFull = $_.FullName
                DestinationFull = $destinationFull
                Hash = File-Hash $_.FullName
                IsMarkdown = $isMarkdown
                OriginalText = $originalText
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
    $pairs = Get-RewritePairs $Layout
    $files = @()

    # Rewrite documentation/instruction Markdown only; never application source code.
    # Root Markdown is included because project README/usage guides commonly link to AI-DEV-OS docs.
    foreach ($rootFileItem in @(Get-ChildItem -LiteralPath $Root -File -Filter *.md -Force)) {
        if ($rootFileItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            throw "Refusing reparse-point instruction file during docs migration: $($rootFileItem.FullName)"
        }
        $files += $rootFileItem
    }

    foreach ($folder in @("docs", ".claude", ".agents", ".github", "prompts")) {
        $p = Join-Path $Root $folder
        if (Test-Path -LiteralPath $p -PathType Container) {
            $files += @(Get-SafeFiles -Directory $p | Where-Object { $_.Extension -eq ".md" })
        }
    }

    $changed = 0

    foreach ($file in @($files | Sort-Object FullName -Unique)) {
        $before = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
        $after = Rewrite-Text -Text $before -Pairs $pairs

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

$statePath = Join-Path $root ".ai-dev-os\state.json"
$stateExistedBefore = Test-Path -LiteralPath $statePath

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

    # Data-loss guard: migrated files must equal the original content with only
    # deterministic path-reference rewrites applied. Binary/non-Markdown files
    # must remain byte-identical.
    $rewritePairs = Get-RewritePairs $layout
    foreach ($item in $plan) {
        if ($item.IsMarkdown) {
            $expectedText = Rewrite-Text -Text $item.OriginalText -Pairs $rewritePairs
            $actualText = Get-Content -LiteralPath $item.DestinationFull -Raw -Encoding UTF8
            if ($actualText -ne $expectedText) {
                throw "Data preservation check failed after reference rewrite: $($item.Source) -> $($item.Destination)"
            }
        }
        else {
            if ((File-Hash $item.DestinationFull) -ne $item.Hash) {
                throw "Binary/non-Markdown content changed during migration: $($item.Source) -> $($item.Destination)"
            }
        }
    }

    Write-State $root

    Write-Host ("Reference files rewritten: {0}" -f $rewritten)
    Write-Host "PASS: docs layout migrated to ordered-v2 without bootstrap."
}
catch {
    Write-Host "Migration failed. Restoring clean pre-migration state."
    $gitExe = (Get-Command git.exe -ErrorAction Stop).Source
    & $gitExe -C $root reset --hard HEAD | Out-Null

    if (-not $stateExistedBefore -and (Test-Path -LiteralPath $statePath -PathType Leaf)) {
        Remove-Item -LiteralPath $statePath -Force -ErrorAction SilentlyContinue
    }

    throw
}
