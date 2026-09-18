param(
    [switch]$SkipMcp,
    [switch]$SelfTest
)

$ErrorActionPreference = "Stop"

if ($env:OS -ne "Windows_NT") {
    throw "Script này hiện chỉ hỗ trợ Windows."
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Results = New-Object System.Collections.Generic.List[object]

function Add-Result {
    param([string]$Name, [string]$Status, [string]$Detail)
    $Results.Add([PSCustomObject]@{ Name = $Name; Status = $Status; Detail = $Detail }) | Out-Null
}

function Test-Command {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Refresh-ProcessPath {
    $machine = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $user = [Environment]::GetEnvironmentVariable("Path", "User")
    $extra = @(
        (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links"),
        (Join-Path $env:LOCALAPPDATA "Programs\codebase-memory-mcp"),
        (Join-Path $env:APPDATA "npm")
    ) | Where-Object { $_ -and (Test-Path $_) }

    $env:Path = (($machine, $user) + $extra | Where-Object { $_ } | Select-Object -Unique) -join ";"
}

function Ensure-Winget {
    if (Test-Command "winget") {
        Add-Result "winget" "PASS" "Đã có."
        return
    }
    Add-Result "winget" "BLOCKED" "Không tìm thấy winget. Cài App Installer của Microsoft rồi chạy lại script."
}

function Ensure-WingetPackage {
    param([string]$DisplayName, [string]$CommandName, [string]$PackageId)

    if (Test-Command $CommandName) {
        try {
            $version = (& $CommandName --version 2>&1 | Select-Object -First 1)
            Add-Result $DisplayName "PASS" "Đã có: $version"
        } catch {
            Add-Result $DisplayName "PASS" "Đã có command '$CommandName'."
        }
        return
    }

    if (-not (Test-Command "winget")) {
        Add-Result $DisplayName "BLOCKED" "Thiếu winget nên chưa thể cài $PackageId."
        return
    }

    Write-Host "Đang cài $DisplayName..." -ForegroundColor Cyan
    & winget install --id $PackageId -e --accept-source-agreements --accept-package-agreements --silent
    if ($LASTEXITCODE -ne 0) {
        Add-Result $DisplayName "FAIL" "winget install thất bại với mã $LASTEXITCODE."
        return
    }

    Refresh-ProcessPath
    if (Test-Command $CommandName) {
        try {
            $version = (& $CommandName --version 2>&1 | Select-Object -First 1)
            Add-Result $DisplayName "PASS" "Đã cài: $version"
        } catch {
            Add-Result $DisplayName "PASS" "Đã cài command '$CommandName'."
        }
    } else {
        Add-Result $DisplayName "BLOCKED" "Đã cài nhưng terminal hiện tại chưa thấy '$CommandName'. Mở terminal mới rồi chạy lại."
    }
}

function Ensure-Repomix {
    if (Test-Command "repomix") {
        try {
            $version = (& repomix --version 2>&1 | Select-Object -First 1)
            Add-Result "Repomix" "PASS" "Đã có: $version"
        } catch {
            Add-Result "Repomix" "PASS" "Đã có command repomix."
        }
        return
    }

    if (-not (Test-Command "npm")) {
        Add-Result "Repomix" "BLOCKED" "Thiếu npm/Node.js. Repomix hiện yêu cầu Node.js >= 22. Cài Node phù hợp môi trường team rồi chạy lại."
        return
    }

    try {
        $nodeVersionText = (& node --version 2>&1 | Select-Object -First 1)
        $nodeMajor = [int](($nodeVersionText -replace '^v','').Split('.')[0])
        if ($nodeMajor -lt 22) {
            Add-Result "Repomix" "BLOCKED" "Node hiện tại là $nodeVersionText; Repomix yêu cầu Node.js >= 22. Không tự nâng Node để tránh ảnh hưởng project khác."
            return
        }
    } catch {
        Add-Result "Repomix" "BLOCKED" "Không xác định được Node version."
        return
    }

    Write-Host "Đang cài Repomix..." -ForegroundColor Cyan
    & npm install -g repomix
    if ($LASTEXITCODE -ne 0) {
        Add-Result "Repomix" "FAIL" "npm install -g repomix thất bại với mã $LASTEXITCODE."
        return
    }

    Refresh-ProcessPath
    if (Test-Command "repomix") {
        $version = (& repomix --version 2>&1 | Select-Object -First 1)
        Add-Result "Repomix" "PASS" "Đã cài: $version"
    } else {
        Add-Result "Repomix" "BLOCKED" "Đã cài nhưng terminal hiện tại chưa thấy repomix. Mở terminal mới rồi chạy lại."
    }
}

function Resolve-CbmExecutable {
    $command = Get-Command "codebase-memory-mcp" -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }

    $defaultPath = Join-Path $env:LOCALAPPDATA "Programs\codebase-memory-mcp\codebase-memory-mcp.exe"
    if (Test-Path $defaultPath) { return $defaultPath }

    return $null
}

function Ensure-CodebaseMemory {
    $existing = Resolve-CbmExecutable
    if ($existing) {
        try {
            $version = (& $existing --version 2>&1 | Select-Object -First 1)
            Add-Result "codebase-memory-mcp" "PASS" "Đã có: $version"
        } catch {
            Add-Result "codebase-memory-mcp" "PASS" "Đã có executable: $existing"
        }
        return $existing
    }

    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("ai-dev-os-cbm-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    $installer = Join-Path $tempDir "install.ps1"

    try {
        Write-Host "Đang tải installer chính thức của codebase-memory-mcp..." -ForegroundColor Cyan
        Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.ps1" -OutFile $installer
        Unblock-File $installer -ErrorAction SilentlyContinue

        Write-Host "Đang cài codebase-memory-mcp (binary only, không cho tool tự sửa agent config)..." -ForegroundColor Cyan
        & powershell -NoProfile -ExecutionPolicy Bypass -File $installer --skip-config
        if ($LASTEXITCODE -ne 0) {
            Add-Result "codebase-memory-mcp" "FAIL" "Installer thất bại với mã $LASTEXITCODE."
            return $null
        }

        Refresh-ProcessPath
        $installed = Resolve-CbmExecutable
        if (-not $installed) {
            Add-Result "codebase-memory-mcp" "BLOCKED" "Installer chạy xong nhưng chưa tìm thấy executable. Mở terminal mới rồi chạy lại."
            return $null
        }

        $version = (& $installed --version 2>&1 | Select-Object -First 1)
        Add-Result "codebase-memory-mcp" "PASS" "Đã cài: $version"
        return $installed
    } catch {
        Add-Result "codebase-memory-mcp" "FAIL" $_.Exception.Message
        return $null
    } finally {
        Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
    }
}

function Get-UserMcpEntry {
    param([string]$Name)

    $claudeJson = Join-Path $HOME ".claude.json"
    if (-not (Test-Path $claudeJson)) { return $null }

    try {
        $cfg = Get-Content $claudeJson -Raw | ConvertFrom-Json
        if ($cfg.mcpServers -and $cfg.mcpServers.PSObject.Properties.Name -contains $Name) {
            return $cfg.mcpServers.$Name
        }
    } catch {
        return $null
    }

    return $null
}

function Normalize-McpCommandPath {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    $candidate = $Value.Trim()

    if (
        ($candidate.StartsWith('"') -and $candidate.EndsWith('"')) -or
        ($candidate.StartsWith("'") -and $candidate.EndsWith("'"))
    ) {
        $candidate = $candidate.Substring(1, $candidate.Length - 2).Trim()
    }

    try {
        return [System.IO.Path]::GetFullPath($candidate)
    } catch {
        return $candidate
    }
}

function Ensure-ClaudeMcp {
    param([string]$CbmExe)

    if ($SkipMcp) {
        Add-Result "Claude MCP" "SKIP" "Đã bỏ qua theo tham số -SkipMcp."
        return
    }
    if (-not $CbmExe) {
        Add-Result "Claude MCP" "BLOCKED" "Chưa có codebase-memory-mcp executable."
        return
    }
    if (-not (Test-Command "claude")) {
        Add-Result "Claude MCP" "BLOCKED" "Không tìm thấy Claude Code CLI. Cài Claude Code CLI rồi chạy lại script để đăng ký MCP user-scope."
        return
    }

    $existing = Get-UserMcpEntry "codebase-memory-mcp"
    if ($existing) {
        $existingCommand = [string]$existing.command
        $existingNormalized = Normalize-McpCommandPath $existingCommand
        $expectedNormalized = Normalize-McpCommandPath $CbmExe

        if ($existingNormalized -and $expectedNormalized -and ($existingNormalized -ine $expectedNormalized)) {
            Add-Result "Claude MCP" "BLOCKED" "User-scope MCP 'codebase-memory-mcp' đã tồn tại nhưng command khác với binary vừa phát hiện. Existing='$existingCommand'. Expected='$CbmExe'. Không tự overwrite config đang có."
            return
        }
        Add-Result "Claude MCP" "PASS" "User-scope MCP đã tồn tại."
    } else {
        Write-Host "Đang đăng ký codebase-memory-mcp cho Claude Code ở user scope..." -ForegroundColor Cyan
        & claude mcp add --transport stdio --scope user codebase-memory-mcp -- $CbmExe
        if ($LASTEXITCODE -ne 0) {
            Add-Result "Claude MCP" "FAIL" "claude mcp add thất bại với mã $LASTEXITCODE."
            return
        }
        Add-Result "Claude MCP" "PASS" "Đã đăng ký user-scope cho mọi project trên máy."
    }

    try {
        $details = (& claude mcp get codebase-memory-mcp 2>&1 | Out-String).Trim()
        if ($LASTEXITCODE -eq 0) {
            Add-Result "Claude MCP verify" "PASS" ($details -replace "\r?\n", " | ")
        } else {
            Add-Result "Claude MCP verify" "BLOCKED" "Đã có config nhưng health check chưa pass. Restart Claude Code rồi chạy /mcp."
        }
    } catch {
        Add-Result "Claude MCP verify" "BLOCKED" "Không chạy được health check. Restart Claude Code rồi chạy /mcp."
    }
}

function Ensure-PersonalUpdater {
    $installer = Join-Path $RepoRoot "tools\install-personal-updater.ps1"
    if (-not (Test-Path $installer)) {
        Add-Result "Personal updater" "FAIL" "Thiếu tools/install-personal-updater.ps1 trong AI-DEV-OS."
        return
    }

    try {
        & powershell -NoProfile -ExecutionPolicy Bypass -File $installer
        if ($LASTEXITCODE -ne 0) {
            Add-Result "Personal updater" "FAIL" "Installer updater thất bại với mã $LASTEXITCODE."
            return
        }
        Add-Result "Personal updater" "PASS" "Đã cài/refresh /update-ai-dev-os cho user hiện tại."
    } catch {
        Add-Result "Personal updater" "FAIL" $_.Exception.Message
    }
}

if ($SelfTest) {
    $quoted = '"C:\Program Files\codebase-memory-mcp\codebase-memory-mcp.exe"'
    $expected = [System.IO.Path]::GetFullPath("C:\Program Files\codebase-memory-mcp\codebase-memory-mcp.exe")
    $actual = Normalize-McpCommandPath $quoted

    if ($actual -ne $expected) {
        throw "SELF-TEST FAIL: quoted MCP command path normalization."
    }

    $nonPath = 'cmd /c codebase-memory-mcp'
    $fallback = Normalize-McpCommandPath $nonPath
    if ([string]::IsNullOrWhiteSpace($fallback)) {
        throw "SELF-TEST FAIL: non-path MCP command fallback."
    }

    $expectedExe = "C:\Users\dev\AppData\Local\Programs\codebase-memory-mcp\codebase-memory-mcp.exe"
    $pollutedCommand = "codebase-memory-mcp installer (Windows) Downloading... Installed binary -> C:/Users/dev/AppData/Local/Programs/codebase-memory-mcp/codebase-memory-mcp.exe Done! $expectedExe"

    if (-not (Test-IsPollutedCbmCommand -ExistingCommand $pollutedCommand -ExpectedExe $expectedExe)) {
        throw "SELF-TEST FAIL: polluted installer output was not detected."
    }

    Write-Host "SELF-TEST PASS: MCP command normalization and pollution detection."
    exit 0
}

Write-Host ""
Write-Host "AI-DEV-OS - THIẾT LẬP TOOL CHO MÁY DEV" -ForegroundColor Cyan
Write-Host "Repo nguồn: $RepoRoot"
Write-Host ""
Write-Host "Script này cài tool ở cấp máy/user, Không sửa .mcp.json của project" -ForegroundColor DarkGray
Write-Host "CodeGraph: KHÔNG cài vì overlap với codebase-memory-mcp." -ForegroundColor DarkGray
Write-Host ""

Ensure-Winget
Ensure-WingetPackage -DisplayName "ripgrep" -CommandName "rg" -PackageId "BurntSushi.ripgrep.MSVC"
Ensure-WingetPackage -DisplayName "ast-grep" -CommandName "ast-grep" -PackageId "ast-grep.ast-grep"
Ensure-Repomix
$cbmExe = Ensure-CodebaseMemory
Ensure-ClaudeMcp -CbmExe $cbmExe
Ensure-PersonalUpdater

Write-Host ""
Write-Host "TÓM TẮT THIẾT LẬP" -ForegroundColor Cyan
Write-Host "------------------"

foreach ($item in $Results) {
    $color = switch ($item.Status) {
        "PASS" { "Green" }
        "SKIP" { "DarkGray" }
        "BLOCKED" { "Yellow" }
        default { "Red" }
    }
    Write-Host ("[{0}] {1}: {2}" -f $item.Status, $item.Name, $item.Detail) -ForegroundColor $color
}

$failed = @($Results | Where-Object { $_.Status -eq "FAIL" }).Count
$blocked = @($Results | Where-Object { $_.Status -eq "BLOCKED" }).Count

Write-Host ""
if ($failed -gt 0) {
    Write-Host "KẾT QUẢ: FAIL - có $failed lỗi cần xử lý." -ForegroundColor Red
    exit 1
}
if ($blocked -gt 0) {
    Write-Host "KẾT QUẢ: PARTIAL - có $blocked mục BLOCKED. Xử lý các mục trên rồi chạy lại script." -ForegroundColor Yellow
    exit 2
}

Write-Host "KẾT QUẢ: PASS - máy đã sẵn sàng." -ForegroundColor Green
Write-Host "Restart Claude Code rồi dùng /mcp để xác nhận codebase-memory-mcp Connected." -ForegroundColor Green
Write-Host ""
Write-Host "Lưu ý: tool đã cài sẵn không có nghĩa task nào cũng dùng. AI-DEV-OS vẫn ưu tiên CODEBASE-MAP -> direct read -> ripgrep -> ast-grep -> codebase-memory-mcp khi thật sự cần." -ForegroundColor DarkGray
