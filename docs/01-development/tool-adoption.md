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

## Stack 2.7.0

| Tool | Vai trò | Trạng thái |
|---|---|---|
| ripgrep | text search nhanh | Recommended/default search |
| ast-grep | structural/syntax-aware search | Machine tool, dùng khi cần |
| Repomix | bootstrap/snapshot/handoff | Machine tool, dùng khi cần |
| codebase-memory-mcp | graph/dependency/impact cho codebase lớn | Machine tool + MCP user-scope, dùng khi cần |
| Headroom | compress/retrieve tool output, logs, RAG và file context | Optional recommended profile; MCP on-demand trước, proxy chỉ sau pilot |
| SQL MCP Server (Microsoft DAB) | runtime SQL Server diagnostics qua allowlisted entity/tools | Optional per-project; test/dev + least privilege mặc định |
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


## Pattern adoption 2.7.0

Một số nguồn tốt được **hấp thụ vào core**, không cài thêm plugin để tránh hai bộ instruction chồng nhau:

- Ponytail → Simplicity Gate: no-code/config → reuse → stdlib/platform → existing dependency → minimum new code.
- mattpocock/skills → test seam trước implementation, TDD skill, domain-modeling skill, merge-conflict skill, concise review/implementation handoff.
- Không cài nguyên Ponytail hay nguyên bộ mattpocock/skills vào project vì AI-DEV-OS đã có execution/knowledge architecture riêng.

Nguyên tắc:

```text
external pattern tốt hơn phần core hiện tại
→ thay/nâng core

external workflow còn thiếu
→ thêm skill nhỏ, portable

external tool tạo capability mới
→ optional tool profile

overlap mà không thêm capability
→ không cài
```

### Headroom

Dùng optional khi context/output lớn. Mặc định dùng MCP on-demand; proxy/wrap không bật tự động.

Chi tiết: `docs/01-development/context-compression.md`.

### SQL Server MCP

Dùng Microsoft Data API builder SQL MCP Server làm profile khuyến nghị vì permission/entity surface rõ và có stdio.

Chi tiết: `docs/01-development/sql-server-mcp.md`.
