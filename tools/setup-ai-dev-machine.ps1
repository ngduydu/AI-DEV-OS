param(
    [switch]$SkipMcp,
    [switch]$WithSqlServerMcp,
    [switch]$SelfTest
)

$ErrorActionPreference = "Stop"

if ($env:OS -ne "Windows_NT") {
    throw "Script này hiện chỉ hỗ trợ Windows."
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Results = New-Object System.Collections.Generic.List[object]

# Pin third-party installer source to an immutable reviewed commit.
# The upstream installer then performs mandatory SHA-256 verification for the release binary.
$CodebaseMemoryInstallerCommit = "aacf96a20e3b9c450ba968c8aae663da25598992"
$CodebaseMemoryVersion = "v0.11.0"
$CodebaseMemoryInstallerUrl = "https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/$CodebaseMemoryInstallerCommit/install.ps1"
$CodebaseMemoryReleaseUrl = "https://github.com/DeusData/codebase-memory-mcp/releases/download/$CodebaseMemoryVersion"

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
    & npm install -g repomix@1.18.0
    if ($LASTEXITCODE -ne 0) {
        Add-Result "Repomix" "FAIL" "npm install -g repomix@1.18.0 thất bại với mã $LASTEXITCODE."
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
        Invoke-WebRequest -UseBasicParsing -Uri $CodebaseMemoryInstallerUrl -OutFile $installer
        Unblock-File $installer -ErrorAction SilentlyContinue

        Write-Host "Đang cài codebase-memory-mcp $CodebaseMemoryVersion (binary only, không cho tool tự sửa agent config)..." -ForegroundColor Cyan
        $previousDownloadUrl = $env:CBM_DOWNLOAD_URL
        try {
            $env:CBM_DOWNLOAD_URL = $CodebaseMemoryReleaseUrl
            $installOutput = & powershell -NoProfile -ExecutionPolicy Bypass -File $installer --skip-config 2>&1
            $installExitCode = $LASTEXITCODE
        }
        finally {
            if ($null -eq $previousDownloadUrl) {
                Remove-Item Env:CBM_DOWNLOAD_URL -ErrorAction SilentlyContinue
            }
            else {
                $env:CBM_DOWNLOAD_URL = $previousDownloadUrl
            }
        }
        $installOutput | ForEach-Object { Write-Host $_ }

        if ($installExitCode -ne 0) {
            Add-Result "codebase-memory-mcp" "FAIL" "Installer thất bại với mã $installExitCode."
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
        Add-Result "Claude MCP" "BLOCKED" "Không tìm thấy Claude Code CLI."
        return
    }

    # Entry này do AI-DEV-OS quản lý. Luôn đăng ký lại canonical command để
    # tự sửa mọi config cũ/hỏng và tránh logic so sánh path phức tạp.
    $removeOutput = & claude mcp remove --scope user codebase-memory-mcp 2>&1
    $removeOutput | ForEach-Object { Write-Host $_ }

    Write-Host "Đang đăng ký codebase-memory-mcp cho Claude Code ở user scope..." -ForegroundColor Cyan
    $addOutput = & claude mcp add --transport stdio --scope user codebase-memory-mcp -- $CbmExe 2>&1
    $addExitCode = $LASTEXITCODE
    $addOutput | ForEach-Object { Write-Host $_ }

    if ($addExitCode -ne 0) {
        Add-Result "Claude MCP" "FAIL" "claude mcp add thất bại với mã $addExitCode."
        return
    }

    $getOutput = & claude mcp get codebase-memory-mcp 2>&1
    $getExitCode = $LASTEXITCODE
    $getText = ($getOutput | Out-String).Trim()

    if ($getExitCode -ne 0) {
        Add-Result "Claude MCP" "FAIL" "Đăng ký xong nhưng không đọc lại được MCP config."
        return
    }

    if ($getText -notmatch [regex]::Escape($CbmExe)) {
        Add-Result "Claude MCP" "FAIL" "MCP config chưa trỏ đúng executable canonical: $CbmExe"
        return
    }

    $listOutput = & claude mcp list 2>&1
    $listText = ($listOutput | Out-String).Trim()

    if ($listText -match "codebase-memory-mcp" -and $listText -match "Connected") {
        Add-Result "Claude MCP" "PASS" "codebase-memory-mcp đã Connected."
    } else {
        Add-Result "Claude MCP" "BLOCKED" "Config đã đúng nhưng chưa Connected. Restart Claude Code/terminal rồi chạy 'claude mcp list'."
    }
}

function Ensure-SqlServerMcp {
    if (-not $WithSqlServerMcp) {
        Add-Result "SQL Server MCP" "SKIP" "Không bật -WithSqlServerMcp."
        return
    }

    if (Test-Command "dab") {
        try {
            $version = (& dab --version 2>&1 | Select-Object -First 1)
            Add-Result "SQL Server MCP" "PASS" "Đã có DAB: $version"
        } catch {
            Add-Result "SQL Server MCP" "PASS" "Đã có command dab."
        }
        return
    }

    if (-not (Test-Command "dotnet")) {
        Add-Result "SQL Server MCP" "BLOCKED" "Thiếu .NET SDK. DAB yêu cầu .NET 8+."
        return
    }

    try {
        $dotnetVersion = (& dotnet --version 2>&1 | Select-Object -First 1)
        $major = [int]($dotnetVersion.Split('.')[0])
        if ($major -lt 8) {
            Add-Result "SQL Server MCP" "BLOCKED" "dotnet hiện tại là $dotnetVersion; DAB yêu cầu .NET 8+."
            return
        }
    } catch {
        Add-Result "SQL Server MCP" "BLOCKED" "Không xác định được dotnet version."
        return
    }

    Write-Host "Đang cài Microsoft Data API builder 2.0.12 cho SQL MCP..." -ForegroundColor Cyan
    & dotnet tool install --global Microsoft.DataApiBuilder --version 2.0.12
    if ($LASTEXITCODE -ne 0) {
        Add-Result "SQL Server MCP" "FAIL" "dotnet tool install Microsoft.DataApiBuilder 2.0.12 thất bại với mã $LASTEXITCODE."
        return
    }

    Refresh-ProcessPath
    if (Test-Command "dab") {
        $version = (& dab --version 2>&1 | Select-Object -First 1)
        Add-Result "SQL Server MCP" "PASS" "Đã cài DAB: $version. Chưa cấu hình database/project."
    } else {
        Add-Result "SQL Server MCP" "BLOCKED" "Đã cài DAB nhưng terminal hiện tại chưa thấy command dab. Mở terminal mới rồi chạy lại."
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
    $scriptText = Get-Content $PSCommandPath -Raw

    $required = @(
        '$installOutput = & powershell',
        '$CodebaseMemoryInstallerCommit = "aacf96a20e3b9c450ba968c8aae663da25598992"',
        '$CodebaseMemoryVersion = "v0.11.0"',
        '$env:CBM_DOWNLOAD_URL = $CodebaseMemoryReleaseUrl',
        'Invoke-WebRequest -UseBasicParsing -Uri $CodebaseMemoryInstallerUrl -OutFile $installer',
        'claude mcp remove --scope user codebase-memory-mcp',
        'claude mcp add --transport stdio --scope user codebase-memory-mcp -- $CbmExe',
        'claude mcp get codebase-memory-mcp',
        'claude mcp list',
        '[switch]$WithSqlServerMcp',
        'Microsoft.DataApiBuilder --version 2.0.12',
        'Đã cài DAB'
    )

    foreach ($needle in $required) {
        if (-not $scriptText.Contains($needle)) {
            throw "SELF-TEST FAIL: thiếu contract '$needle'."
        }
    }

    Write-Host "SELF-TEST PASS: machine setup MCP flow."
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
Ensure-SqlServerMcp
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
Write-Host "SQL Server MCP chỉ được cài khi dùng -WithSqlServerMcp và vẫn cần project config + least-privilege DB role riêng." -ForegroundColor DarkGray
