param(
    [switch]$SkipMcp,
    [switch]$WithSqlServerMcp,
    [switch]$SkipSqlServerMcp,
    [switch]$SkipExternalAiStack,
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
$HeadroomVersion = "0.37.0"

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
        (Join-Path $env:APPDATA "npm"),
        (Join-Path $HOME ".dotnet\tools"),
        (Join-Path $HOME ".local\bin")
    ) | Where-Object { $_ -and (Test-Path $_) }

    $env:Path = (($machine, $user) + $extra | Where-Object { $_ } | Select-Object -Unique) -join ";"
}

function Ensure-UserPathEntry {
    param([string]$Path)

    if (-not $Path -or -not (Test-Path $Path)) { return }

    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $parts = @($userPath -split ';' | Where-Object { $_ })
    $exists = $false
    foreach ($part in $parts) {
        if ([string]::Equals($part.TrimEnd('\'), $Path.TrimEnd('\'), [System.StringComparison]::OrdinalIgnoreCase)) {
            $exists = $true
            break
        }
    }

    if (-not $exists) {
        $newUserPath = (($parts + $Path) | Select-Object -Unique) -join ';'
        [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
    }

    Refresh-ProcessPath
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
        Ensure-UserPathEntry -Path (Split-Path -Parent $existing)
        try {
            $version = (& $existing --version 2>&1 | Select-Object -First 1)
            Add-Result "codebase-memory-mcp" "PASS" "Đã có: $version; PATH user đã được đảm bảo."
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

        Ensure-UserPathEntry -Path (Split-Path -Parent $installed)
        $version = (& $installed --version 2>&1 | Select-Object -First 1)
        Add-Result "codebase-memory-mcp" "PASS" "Đã cài: $version; PATH user đã được đảm bảo."
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
    if ($SkipSqlServerMcp -or $SkipExternalAiStack) {
        Add-Result "SQL Server MCP" "SKIP" "Đã bỏ qua theo tham số."
        return
    }

    Refresh-ProcessPath

    if (Test-Command "dab") {
        try {
            $versionText = (& dab --version 2>&1 | Select-Object -First 1)
            $match = [regex]::Match([string]$versionText, '(\d+\.\d+\.\d+)')
            if ($match.Success -and ([version]$match.Groups[1].Value) -ge [version]"2.0.0") {
                Add-Result "SQL Server MCP" "PASS" "Đã có DAB đủ MCP profile: $versionText"
                return
            }
            Write-Host "DAB hiện có chưa đạt baseline 2.0; sẽ update lên 2.0.12..." -ForegroundColor Cyan
            & dotnet tool update --global Microsoft.DataApiBuilder --version 2.0.12
            if ($LASTEXITCODE -ne 0) {
                Add-Result "SQL Server MCP" "FAIL" "dotnet tool update Microsoft.DataApiBuilder 2.0.12 thất bại với mã $LASTEXITCODE."
                return
            }
            Refresh-ProcessPath
            $updatedVersion = (& dab --version 2>&1 | Select-Object -First 1)
            Add-Result "SQL Server MCP" "PASS" "Đã update DAB: $updatedVersion. Chưa cấu hình database/project."
            return
        } catch {
            Add-Result "SQL Server MCP" "BLOCKED" "Có command dab nhưng không xác minh được version: $($_.Exception.Message)"
            return
        }
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

function Ensure-Uv {
    if ($SkipExternalAiStack) {
        Add-Result "uv" "SKIP" "Đã bỏ qua theo -SkipExternalAiStack."
        return $false
    }

    if (Test-Command "uv") {
        $version = (& uv --version 2>&1 | Select-Object -First 1)
        Add-Result "uv" "PASS" "Đã có: $version"
        return $true
    }

    if (-not (Test-Command "winget")) {
        Add-Result "uv" "BLOCKED" "Thiếu winget nên chưa thể cài astral-sh.uv."
        return $false
    }

    Write-Host "Đang cài uv từ WinGet..." -ForegroundColor Cyan
    & winget install --id astral-sh.uv -e --accept-source-agreements --accept-package-agreements --silent
    if ($LASTEXITCODE -ne 0) {
        Add-Result "uv" "FAIL" "winget install astral-sh.uv thất bại với mã $LASTEXITCODE."
        return $false
    }

    Refresh-ProcessPath
    if (-not (Test-Command "uv")) {
        Add-Result "uv" "BLOCKED" "Đã cài uv nhưng terminal hiện tại chưa thấy command. Mở terminal mới rồi chạy lại."
        return $false
    }

    $version = (& uv --version 2>&1 | Select-Object -First 1)
    Add-Result "uv" "PASS" "Đã cài: $version"
    return $true
}

function Ensure-Headroom {
    param([bool]$UvReady)

    if ($SkipExternalAiStack) {
        Add-Result "Headroom" "SKIP" "Đã bỏ qua theo -SkipExternalAiStack."
        return
    }

    if (-not $UvReady) {
        Add-Result "Headroom" "BLOCKED" "Cần uv để cài Headroom trong môi trường tool tách biệt."
        return
    }

    Write-Host "Đang cài/refresh Headroom $HeadroomVersion (proxy + MCP) bằng uv..." -ForegroundColor Cyan
    & uv tool install --python 3.13 "headroom-ai[proxy,mcp]==$HeadroomVersion"
    if ($LASTEXITCODE -ne 0) {
        Add-Result "Headroom" "FAIL" "uv tool install Headroom thất bại với mã $LASTEXITCODE."
        return
    }

    try {
        $binDir = (& uv tool dir --bin 2>&1 | Select-Object -First 1)
        if ($binDir -and (Test-Path $binDir)) {
            Ensure-UserPathEntry -Path $binDir
        }
    } catch {
        # Không chặn setup chỉ vì không đọc được tool bin path; verify command phía dưới sẽ quyết định.
    }

    Refresh-ProcessPath
    if (-not (Test-Command "headroom")) {
        Add-Result "Headroom" "BLOCKED" "Đã cài nhưng chưa thấy command headroom. Mở terminal mới rồi chạy lại."
        return
    }

    $version = (& headroom --version 2>&1 | Select-Object -First 1)

    if (-not $SkipMcp -and (Test-Command "claude")) {
        Write-Host "Đang đăng ký Headroom MCP theo installer upstream..." -ForegroundColor Cyan
        $mcpOutput = & headroom mcp install --force 2>&1
        $mcpExit = $LASTEXITCODE
        $mcpOutput | ForEach-Object { Write-Host $_ }
        if ($mcpExit -ne 0) {
            Add-Result "Headroom" "BLOCKED" "Headroom đã cài ($version) nhưng MCP install thất bại. Có thể vẫn dùng proxy/wrap."
            return
        }
    }

    Add-Result "Headroom" "PASS" "Đã cài upstream: $version; proxy/wrap + MCP sẵn sàng."
}

function Ensure-Ponytail {
    if ($SkipExternalAiStack) {
        Add-Result "Ponytail" "SKIP" "Đã bỏ qua theo -SkipExternalAiStack."
        return
    }

    if (-not (Test-Command "claude")) {
        Add-Result "Ponytail" "BLOCKED" "Không tìm thấy Claude Code CLI."
        return
    }

    if (-not (Test-Command "node")) {
        Add-Result "Ponytail" "BLOCKED" "Thiếu Node.js trên PATH; Ponytail Claude hooks cần Node."
        return
    }

    Write-Host "Đang thêm Ponytail marketplace upstream..." -ForegroundColor Cyan
    $marketOutput = & claude plugin marketplace add DietrichGebert/ponytail 2>&1
    $marketExit = $LASTEXITCODE
    $marketText = ($marketOutput | Out-String)
    $marketOutput | ForEach-Object { Write-Host $_ }

    if ($marketExit -ne 0 -and $marketText -notmatch "already|exists|configured") {
        Add-Result "Ponytail" "FAIL" "Không thêm được Ponytail marketplace."
        return
    }

    Write-Host "Đang cài Ponytail plugin upstream..." -ForegroundColor Cyan
    $installOutput = & claude plugin install ponytail@ponytail 2>&1
    $installExit = $LASTEXITCODE
    $installText = ($installOutput | Out-String)
    $installOutput | ForEach-Object { Write-Host $_ }

    if ($installExit -ne 0 -and $installText -notmatch "already|installed|enabled") {
        Add-Result "Ponytail" "FAIL" "Không cài được Ponytail plugin."
        return
    }

    Add-Result "Ponytail" "PASS" "Đã cài plugin upstream. Default mode của Ponytail là full; restart/reload Claude để hooks hoạt động."
}

function Ensure-MattPocockSkills {
    if ($SkipExternalAiStack) {
        Add-Result "Matt Pocock skills" "SKIP" "Đã bỏ qua theo -SkipExternalAiStack."
        return
    }

    if (-not (Test-Command "claude")) {
        Add-Result "Matt Pocock skills" "BLOCKED" "Không tìm thấy Claude Code CLI."
        return
    }

    Write-Host "Đang cài mattpocock-skills từ Claude Code official marketplace..." -ForegroundColor Cyan
    $output = & claude plugins install mattpocock-skills 2>&1
    $exit = $LASTEXITCODE
    $text = ($output | Out-String)
    $output | ForEach-Object { Write-Host $_ }

    if ($exit -ne 0 -and $text -notmatch "already|installed|enabled") {
        Add-Result "Matt Pocock skills" "FAIL" "Không cài được mattpocock-skills plugin."
        return
    }

    Add-Result "Matt Pocock skills" "PASS" "Đã cài upstream. Mỗi repo chạy /setup-matt-pocock-skills một lần trước khi dùng workflow của bộ skill."
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
        '[switch]$SkipSqlServerMcp',
        '[switch]$SkipExternalAiStack',
        'Microsoft.DataApiBuilder --version 2.0.12',
        'uv tool install --python 3.13 "headroom-ai[proxy,mcp]==$HeadroomVersion"',
        'headroom mcp install --force',
        'claude plugin marketplace add DietrichGebert/ponytail',
        'claude plugin install ponytail@ponytail',
        'claude plugins install mattpocock-skills',
        'Ensure-UserPathEntry',
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
$uvReady = Ensure-Uv
Ensure-Headroom -UvReady $uvReady
Ensure-Ponytail
Ensure-MattPocockSkills
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
Write-Host "Lưu ý: setup mặc định cài toàn bộ upstream stack đã chuẩn hóa: codebase-memory-mcp, Headroom, Ponytail, mattpocock-skills và Microsoft SQL MCP/DAB." -ForegroundColor DarkGray
Write-Host "SQL Server MCP chỉ cài CLI; database config/connection/permission vẫn là project-specific và phải least privilege." -ForegroundColor DarkGray
Write-Host "Mỗi product repo cần chạy /setup-matt-pocock-skills một lần nếu muốn dùng đầy đủ workflow Matt Pocock." -ForegroundColor DarkGray
