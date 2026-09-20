param(
    [int]$Port = 8787
)

$ErrorActionPreference = "Stop"

function Test-Command {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

if (-not (Test-Command "headroom")) {
    throw "Không tìm thấy headroom. Chạy tools/setup-ai-dev-machine.ps1 trước."
}

if (-not (Test-Command "claude")) {
    throw "Không tìm thấy Claude Code CLI."
}

Write-Host "Đang mở Claude Code qua Headroom upstream tại cổng $Port..." -ForegroundColor Cyan
Write-Host "Headroom sẽ tự khởi động proxy, cấu hình Claude session và giữ tool search hoạt động." -ForegroundColor DarkGray
Write-Host "Xem thống kê khi đang chạy: http://127.0.0.1:$Port/stats" -ForegroundColor DarkGray

& headroom wrap claude --port $Port
exit $LASTEXITCODE
