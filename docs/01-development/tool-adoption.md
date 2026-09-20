# Tool Adoption

Mục tiêu: AI-DEV-OS không biến thành một bộ sưu tập tool. Chỉ tool đủ trưởng thành và giải quyết pain thật mới được đưa vào recommended/default stack.

## Tool Adoption Gate

Trước khi thêm tool vào recommended/default:

1. **Community adoption** — có community/usage đáng kể. GitHub stars là tín hiệu, không phải bằng chứng duy nhất.
2. **Maintenance** — repository còn active, release/issue được xử lý.
3. **Maturity** — scope/failure mode rõ, không chỉ viral ngắn hạn.
4. **Security** — review advisories, filesystem/network/write capability và trust boundary.
5. **Platform** — chạy phù hợp môi trường team, đặc biệt Windows nếu team dùng Windows.
6. **Evidence** — giải quyết pain thật; claim tiết kiệm token ưu tiên benchmark/thử nghiệm thực tế hơn marketing.
7. **Overlap** — không thêm tool mới nếu tool hiện có đã làm đủ tốt.
8. **Exit path** — optional tool phải có fallback, không lock project vào tool.

## Stack 2.8.0

| Tool | Vai trò | Trạng thái |
|---|---|---|
| ripgrep | text search nhanh | Recommended/default search |
| ast-grep | structural/syntax-aware search | Machine tool, dùng khi cần |
| Repomix | bootstrap/snapshot/handoff | Machine tool, dùng khi cần |
| codebase-memory-mcp | graph/dependency/impact cho codebase lớn | Cài upstream thật ở machine setup + MCP user-scope |
| Headroom | compress/cache-align/retrieve context, tool output, logs, RAG và file result | Cài upstream thật ở machine setup; proxy/wrap + MCP |
| Ponytail | always-on minimal-code discipline, hooks, review/audit/debt/gain | Cài upstream Claude plugin thật; default full |
| mattpocock/skills | grilling/spec/TDD/debug/design/review/implementation workflows | Cài upstream Claude plugin thật; mỗi repo chạy setup upstream một lần |
| SQL MCP Server (Microsoft DAB) | runtime SQL Server diagnostics qua allowlisted entity/tools | Cài DAB CLI ở machine setup; database config vẫn per-project |
| Sourcegraph MCP | enterprise code intelligence khi tổ chức đã có Sourcegraph | Enterprise alternative |

Không đưa vào default machine stack:

- CodeGraph;
- grepai;
- RTK;
- Serena.

Việc không đưa vào default không có nghĩa tool xấu; chỉ có nghĩa chưa vượt Tool Adoption Gate cho nhu cầu hiện tại hoặc bị overlap.

## Rule khi project chọn optional tool

- không auto-install bằng framework upgrade;
- không hard-code secret;
- merge config, không overwrite file config hiện hữu;
- có command/check verify tool hoạt động;
- có fallback khi tool lỗi;
- remove được mà core workflow vẫn chạy.

## Review định kỳ

Sau milestone hoặc khi tool ecosystem thay đổi:

- kiểm tra maintenance/security mới;
- xem tool còn giúp thật không;
- xem có tool built-in/native thay thế tốt hơn không;
- bỏ tool nếu maintenance cost > lợi ích.

Default stack phải nhỏ, dễ hiểu và có lý do rõ.


## Machine setup

AI-DEV-OS cung cấp một setup command cho Windows:

~~~powershell
powershell -ExecutionPolicy Bypass -File .\tools\setup-ai-dev-machine.ps1
~~~

Chạy từ repository AI-DEV-OS local. Mỗi developer chạy một lần trên máy, không chạy theo từng product repo.

Script:

- cài/verify `ripgrep`;
- cài/verify `ast-grep`;
- cài/verify `Repomix`;
- cài binary `codebase-memory-mcp` với `--skip-config`;
- đăng ký `codebase-memory-mcp` vào Claude Code bằng MCP `--scope user`;
- cài/refresh personal `/update-ai-dev-os` launcher.

Không sửa `.mcp.json` của product repo.

### CodeGraph

Không cài CodeGraph song song ở 2.4.0 vì overlap với graph/memory capability của `codebase-memory-mcp`.

Nếu thực tế chứng minh `codebase-memory-mcp` thiếu capability quan trọng, đánh giá lại CodeGraph qua Tool Adoption Gate thay vì cài trùng từ đầu.


## Upstream-first adoption 2.8.0

Từ 2.8.0, với các tool/skill được team chọn dùng thực tế, AI-DEV-OS ưu tiên **cài upstream thật** thay vì tự viết lại một bản gần giống.

```text
upstream có plugin/tool chính thức và team muốn dùng
→ cài upstream thật

AI-DEV-OS
→ giữ orchestration, project knowledge, routing, safety và upgrade contract

generic agent không dùng được plugin upstream
→ dùng adapter/fallback của AI-DEV-OS khi cần
```

Cụ thể:

- Ponytail: dùng plugin upstream thật để giữ ladder + persistence + lifecycle hooks + subagent injection + review/audit/debt/gain.
- mattpocock/skills: dùng plugin upstream thật `mattpocock-skills` để nhận toàn bộ skill và update upstream; AI-DEV-OS chỉ route artifacts/knowledge theo cấu trúc repo.
- codebase-memory-mcp, Headroom, Microsoft DAB: dùng binary/package upstream thật.
- Simplicity Gate và các adapter hiện có vẫn là fallback/core guard cho agent không có plugin, không được coi là bản thay thế upstream trên Claude Code.

### Headroom

Machine setup cài Headroom upstream. Với Claude Code có thể dùng proxy/wrap để automatic savings và MCP để compress/retrieve/stats.

Chi tiết: `docs/01-development/context-compression.md`.

### SQL Server MCP

Dùng Microsoft Data API builder SQL MCP Server làm profile khuyến nghị vì permission/entity surface rõ và có stdio.

Chi tiết: `docs/01-development/sql-server-mcp.md`.
