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

## Stack 2.2.0

| Tool | Vai trò | Trạng thái |
|---|---|---|
| ripgrep | text search nhanh | Recommended/default search |
| ast-grep | structural/syntax-aware search | Optional |
| Repomix | bootstrap/snapshot/handoff | Optional |
| codebase-memory-mcp | graph/dependency/impact cho codebase lớn | Optional pilot |
| Sourcegraph MCP | enterprise code intelligence khi tổ chức đã có Sourcegraph | Enterprise alternative |

Không đưa vào default ở 2.2.0:

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
