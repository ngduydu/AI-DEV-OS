# Documentation Map

Đây là entry point của project knowledge. Không đọc toàn bộ `docs/` cho mọi task.

## Context strategy

```text
Always-on context  → cực nhỏ
Project knowledge   → đủ đầy để tra cứu
Task context        → chỉ nạp những gì liên quan
```

## Mặc định trước mọi task

1. Hiểu yêu cầu hiện tại.
2. Đọc `docs/01-development/ai-development.md`.
3. Xác định module/khu vực code bị ảnh hưởng.
4. Đọc `docs/00-overview/codebase-map.md` khi cần tìm canonical implementation/reuse source.
5. Đọc `docs/01-development/coding-standards.md` khi task tạo/sửa code.
6. Chỉ đọc thêm docs và code liên quan đến khu vực đó.

## Routing

| Khi task liên quan | Đọc |
|---|---|
| Product / behavior | `docs/00-overview/product.md`, business rules liên quan |
| Architecture | `docs/00-overview/architecture.md`, `docs/05-decisions/` |
| Tìm code / reuse / tạo implementation mới | `docs/00-overview/codebase-map.md`, module docs, code/test hiện có |
| Business rule | canonical: `docs/03-knowledge/business-rules.md`; task discovery: `docs/03-knowledge/business-rules/` |
| Coding convention / naming / error / validation / DB / API format | `docs/01-development/coding-standards.md` |
| Build / run / test / lint / format | `docs/01-development/commands.md`, `docs/01-development/testing.md` |
| Security | `docs/01-development/security.md` |
| Git / PR | `docs/01-development/git-workflow.md` |
| Quy định sử dụng AI của team/project | `docs/01-development/ai-usage-policy.md` nếu repository có policy này |
| Ready / ambiguity | `docs/01-development/definition-of-ready.md` |
| Done | `docs/01-development/definition-of-done.md` |
| Gotcha / lỗi khó nhớ | existing/canonical route: `docs/03-knowledge/known-pitfalls.md`; task discovery: `docs/03-knowledge/pitfalls/` |
| Knowledge maintenance | `docs/01-development/documentation-governance.md` |
| Context/token-efficient retrieval | `docs/01-development/context-retrieval.md` |
| Code graph / caller-callee / impact / graph UI | `docs/01-development/codebase-intelligence.md` |
| Output/log/RAG quá lớn, cần compression | `docs/01-development/context-compression.md` |
| SQL Server runtime diagnostics qua MCP | `docs/01-development/sql-server-mcp.md` |
| Chọn/đánh giá tool | `docs/01-development/tool-adoption.md` |
| Module cụ thể | `docs/02-modules/` |
| Deploy / migration / rollback / monitoring | `docs/04-operations/` |
| Quyết định có trade-off | `docs/05-decisions/` |
| Knowledge bền vững phát hiện trong task | `docs/03-knowledge/` |
| Context chỉ cho task hiện tại | `docs/06-work/` |

## Khi tạo code mới

Trước khi tạo service/helper/component/validator/query/mapper/DTO pattern hoặc business logic mới:

```text
docs/00-overview/codebase-map.md
→ canonical examples
→ reusable building blocks
→ nearby code/tests
→ mới quyết định reuse / extend / create new
```

Không dùng convention hoặc architecture từ trí nhớ của agent nếu project đã có source of truth riêng.

## Quy tắc đọc docs

- Không đọc tất cả docs chỉ vì chúng tồn tại.
- Ưu tiên source gần nhất với behavior đang sửa: module docs → code/test → global docs.
- Nếu docs và code mâu thuẫn, không tự chọn ngẫu nhiên; xác minh và nêu mâu thuẫn.
- Không dùng docs cũ làm lý do để bỏ qua evidence rõ ràng từ code/test/history.
- Knowledge bền vững phát hiện trong task phải được đồng bộ theo `docs/03-knowledge/README.md`; mặc định tạo file riêng để tránh conflict giữa branch.
- Nếu cùng một rule xuất hiện ở nhiều file và mâu thuẫn, ưu tiên sửa source of truth thay vì thêm một bản sao mới.

## Bootstrap project

Khi áp dụng AI-DEV-OS cho repository mới hoặc repository cũ chưa có docs đủ tốt:

1. Xem `APPLY-TO-PROJECT.md`.
2. Dùng skill `bootstrap-project`.
3. Chỉ bắt đầu giao task bình thường khi bootstrap báo `READY`, hoặc hiểu rõ phạm vi `PARTIAL`.
4. Sau đó dùng `USAGE.md` cho workflow hằng ngày.

## Nguyên tắc

> Docs là bản đồ và nguồn knowledge bền vững, không phải ceremony. Tài liệu chỉ có giá trị khi giúp agent hiểu đúng, reuse đúng và thay đổi an toàn hơn.

## Context retrieval mặc định

Sau bootstrap, không scan lại toàn repo cho mỗi task.

~~~text
CODEBASE-MAP
→ direct read nếu biết path
→ targeted text search
→ structural/graph tool khi thật sự cần
→ source/test
→ broaden/history chỉ khi evidence chưa đủ
~~~

Xem `docs/01-development/context-retrieval.md`.
