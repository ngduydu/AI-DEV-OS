param(
    [int]$Port = 8787
)

$ErrorActionPreference = "Stop"

function Test-Command {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

if (-not (Test-Command "headroom")) {
    throw "Không tìm thấy headroom. Cài Headroom proxy trước theo docs/01-development/context-compression.md."
}

if (-not (Test-Command "claude")) {
    throw "Không tìm thấy Claude Code CLI."
}

$proxyUrl = "http://127.0.0.1:$Port"
$startedProcess = $null
$previousBaseUrl = $env:ANTHROPIC_BASE_URL

try {
    $alive = $false
    try {
        $null = Invoke-RestMethod -Uri "$proxyUrl/stats" -Method Get -TimeoutSec 2
        $alive = $true
    } catch {
        $alive = $false
    }

    if (-not $alive) {
        Write-Host "Đang khởi động Headroom proxy tại $proxyUrl..." -ForegroundColor Cyan
        $startedProcess = Start-Process -FilePath "headroom" -ArgumentList @("proxy", "--port", "$Port") -PassThru -WindowStyle Minimized

        $deadline = (Get-Date).AddSeconds(20)
        do {
            Start-Sleep -Milliseconds 500
            try {
                $null = Invoke-RestMethod -Uri "$proxyUrl/stats" -Method Get -TimeoutSec 2
                $alive = $true
            } catch {
                $alive = $false
            }
        } while (-not $alive -and (Get-Date) -lt $deadline)

        if (-not $alive) {
            throw "Headroom proxy không sẵn sàng sau 20 giây."
        }
    }

    $env:ANTHROPIC_BASE_URL = $proxyUrl
    Write-Host "Claude Code sẽ đi qua Headroom proxy: $proxyUrl" -ForegroundColor Green
    Write-Host "Xem token tiết kiệm: Invoke-RestMethod $proxyUrl/stats" -ForegroundColor DarkGray
    & claude
    exit $LASTEXITCODE
}
finally {
    if ($null -eq $previousBaseUrl) {
        Remove-Item Env:ANTHROPIC_BASE_URL -ErrorAction SilentlyContinue
    } else {
        $env:ANTHROPIC_BASE_URL = $previousBaseUrl
    }

    if ($startedProcess -and -not $startedProcess.HasExited) {
        Stop-Process -Id $startedProcess.Id -Force -ErrorAction SilentlyContinue
    }
}
