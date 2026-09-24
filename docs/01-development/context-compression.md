# Context Compression

Mục tiêu: giảm token/context rác mà không làm mất khả năng truy lại evidence gốc.

## Headroom profile

AI-DEV-OS hỗ trợ **Headroom** như một lớp context-compression optional.

Headroom phù hợp khi task tạo nhiều output lớn:

- log dài;
- tool result lớn;
- RAG chunks;
- file/read output lớn;
- DB query result;
- long-running investigation.

MCP mode cung cấp:

- `headroom_compress`;
- `headroom_retrieve`;
- `headroom_stats`.

Compression chạy local; original có thể được retrieve lại trong TTL của session.

## Hai mode sử dụng

### 1. MCP on-demand

```text
Claude nhận output lớn
→ gọi headroom_compress
→ reasoning trên bản nén
→ cần exact evidence
→ headroom_retrieve
```

Phù hợp khi muốn agent tự quyết lúc nào cần nén.

### 2. Transparent proxy/wrap

```text
Claude request
→ Headroom proxy
→ tự compress/cache-align context phù hợp
→ Anthropic
```

Đây là mode dùng khi mục tiêu là tiết kiệm token tự động trên toàn session.

AI-DEV-OS hỗ trợ mode này nhưng không ép bật cho mọi máy. Sau khi pilot ổn, team có thể dùng làm profile hằng ngày cho Claude Code.

Xem thống kê token tiết kiệm qua endpoint `/stats` hoặc `headroom_stats`.

## Setup

Headroom không được cài bởi `/apply-ai-dev-os` hoặc `/update-ai-dev-os` vì đó là project-framework update.

Từ AI-DEV-OS 2.8.0, machine setup mặc định cài Headroom upstream:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\setup-ai-dev-machine.ps1
```

Có thể bỏ qua external stack bằng `-SkipExternalAiStack`.

Khuyến nghị dùng `uv` để tách khỏi Python project:

```powershell
uv tool install --python 3.13 "headroom-ai[proxy,mcp]==0.37.0"
```

Nếu môi trường team quản lý Python theo cách khác, cài package tương đương trong môi trường riêng; không nhét dependency Headroom vào application project.

Template MCP:

```text
templates/mcp/claude-headroom.json
```

Sau khi config, verify:

```text
/mcp
```

## Khi nào agent nên compress?

Dùng khi:

- output đủ lớn làm loãng context;
- phần lớn là boilerplate/repetition;
- cần giữ khả năng retrieve bản gốc;
- câu hỏi hiện tại chỉ cần signal/summary.

Không compress khi:

- diff/hunk nhỏ cần đọc byte-for-byte;
- stack trace ngắn;
- security evidence cần exact text;
- migration/DDL cần exact SQL;
- output đã nhỏ;
- compression làm mất field quan trọng.

## Retrieval rule

```text
output nhỏ
→ đọc trực tiếp

output lớn/noisy
→ Headroom compress nếu Connected
→ reasoning trên compressed form
→ cần exact evidence?
→ retrieve original
```

Headroom không thay:

- `/clear`;
- `/compact`;
- targeted retrieval;
- codebase-memory-mcp;
- source/test/config ground truth.

Nó bổ sung một lớp **output compression** giữa retrieval và reasoning.

## Safety

- không dùng compressed text làm bằng chứng duy nhất cho security/data-destructive decision;
- nếu finding phụ thuộc một field cụ thể, retrieve original trước khi kết luận;
- không bật proxy tự động trên máy/team mà chưa review config;
- không dùng `headroom learn` để tự ghi vào shared AI-DEV-OS/project instructions trong workflow mặc định;
- mọi durable knowledge vẫn đi qua Knowledge Sync của AI-DEV-OS.


## Claude Code qua proxy

### CLI

AI-DEV-OS có launcher mỏng gọi thẳng wrapper upstream:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\start-claude-headroom.ps1
```

Launcher tương đương:

```powershell
headroom wrap claude --code-memory none
```

Không tự quản lý proxy lifecycle nữa; Headroom upstream tự khởi động proxy, cấu hình Claude session và giữ on-demand tool loading hoạt động. AI-DEV-OS truyền `--code-memory none` vì codebase-memory-mcp đã là code-memory chuẩn; không bật thêm Serena.

Xem stats khi session đang chạy:

```powershell
Invoke-RestMethod http://127.0.0.1:8787/stats
```

### VS Code Claude extension

Upstream hỗ trợ wrapper:

```powershell
headroom wrap vscode-claude
```

Sau đó reload VS Code theo hướng dẫn Headroom.

Không sửa settings thủ công nếu wrapper upstream đã quản lý được.

## Profile khuyến nghị

```text
Mặc định team
→ Headroom proxy/wrap nếu máy đã pilot ổn
→ MCP vẫn Connected để compress/retrieve thủ công khi cần
→ theo dõi headroom_stats hoặc /stats

Khi debug security/data-destructive/exact SQL
→ retrieve/read original trước kết luận
```

Mục tiêu là giảm token mà không hy sinh evidence.


## Persistent mặc định cho Claude Code

Trên Windows, machine setup của AI-DEV-OS cấu hình Headroom durable routing bằng upstream `init` ở user scope, không phụ thuộc Task Scheduler:

```powershell
headroom init -g --port 8787 claude
```

Sau khi PASS:

```text
Windows sign-in / reboot
→ HKCU Run gọi launcher ẩn của AI-DEV-OS
→ launcher chạy headroom init hook ensure --profile init-user
→ chờ http://127.0.0.1:8787/readyz PASS
→ mở Claude bình thường
→ request Claude đi qua Headroom tự động
```

Machine setup tạo launcher tại:

```text
%LOCALAPPDATA%\AI-DEV-OS\headroom\start-headroom.ps1
```

và đăng ký user autostart:

```text
HKCU\Software\Microsoft\Windows\CurrentVersion\Run
→ AI-DEV-OS-Headroom
```

Không dùng Task Scheduler và không cần admin.

Lý do: Headroom 0.37.0 có thể cold-start lâu hơn timeout 15 giây của Claude `SessionStart` hook. Vì Claude đã route `ANTHROPIC_BASE_URL` vào localhost:8787, chỉ dựa vào hook có thể tạo `ECONNREFUSED` sau reboot. AI-DEV-OS vì vậy chủ động ensure runtime ngay khi Windows sign-in; SessionStart hook chỉ còn là lớp recovery bổ sung.

Không cần mở một CMD riêng chạy `headroom wrap claude` mỗi ngày.

Kiểm tra runtime:

```powershell
headroom install status --profile ai-dev-os
headroom doctor
```

`headroom wrap claude --code-memory none` chỉ còn là launcher/diagnostic hoặc fallback khi durable routing có vấn đề.

AI-DEV-OS không dùng Serena từ Headroom vì đã chọn `codebase-memory-mcp` làm code-memory chuẩn.
