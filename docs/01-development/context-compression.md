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

## Vì sao không bật proxy mặc định?

AI-DEV-OS không route toàn bộ Claude traffic qua proxy mặc định vì:

- thay đổi trust/network path của agent;
- compression tự động có thể che chi tiết cần debug;
- machine/team cần benchmark accuracy/latency thực tế;
- MCP on-demand có exit path đơn giản hơn.

Default recommendation:

```text
Headroom MCP on-demand
→ dùng cho output lớn/noisy
→ retrieve original khi cần evidence
```

Proxy/wrap chỉ bật khi team đã pilot và chấp nhận trade-off.

## Setup

Headroom không được cài tự động bởi `/apply-ai-dev-os` hoặc `/update-ai-dev-os`.

Cài riêng trên máy khi muốn pilot:

```powershell
py -m pip install "headroom-ai[mcp]==0.37.0"
```

Hoặc dùng môi trường Python/uv riêng theo hướng dẫn upstream.

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
