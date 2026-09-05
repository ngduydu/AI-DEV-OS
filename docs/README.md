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
2. Đọc `docs/ai/16-TASK-EXECUTION.md`.
3. Xác định module/khu vực code bị ảnh hưởng.
4. Chỉ đọc docs và code liên quan đến khu vực đó.

## Routing

| Khi task liên quan | Đọc |
|---|---|
| Product / behavior | `docs/ai/02-PRODUCT.md`, business rules liên quan |
| Architecture | `docs/ai/03-ARCHITECTURE.md`, `docs/decisions/` |
| Tìm code / reuse | `docs/ai/04-CODEBASE-MAP.md`, module docs, code/test hiện có |
| Business rule | `docs/ai/05-BUSINESS-RULES.md`, `docs/modules/<module>/` |
| Coding convention | `docs/ai/06-CODING-STANDARDS.md` |
| Build / run / test | `docs/ai/07-COMMANDS.md`, `docs/ai/08-TESTING.md` |
| Security | `docs/ai/09-SECURITY.md` |
| Git / PR | `docs/ai/10-GIT-WORKFLOW.md` |
| Ready / ambiguity | `docs/ai/11-DEFINITION-OF-READY.md` |
| Done | `docs/ai/12-DEFINITION-OF-DONE.md` |
| Gotcha / lỗi khó nhớ | `docs/ai/13-KNOWN-PITFALLS.md` |
| Knowledge maintenance | `docs/ai/14-AI-SYSTEM-MAINTENANCE.md` |
| Module cụ thể | `docs/modules/` |
| Deploy / migration / rollback / monitoring | `docs/operations/` |
| Quyết định có trade-off | `docs/decisions/` |
| Context chỉ cho task hiện tại | `docs/work/` |

## Quy tắc đọc docs

- Không đọc tất cả docs chỉ vì chúng tồn tại.
- Ưu tiên source gần nhất với behavior đang sửa: module docs → code/test → global docs.
- Nếu docs và code mâu thuẫn, không tự chọn ngẫu nhiên; xác minh và nêu mâu thuẫn.
- Không dùng docs cũ làm lý do để bỏ qua evidence rõ ràng từ code/test/history.
- Knowledge bền vững phát hiện trong task phải được đồng bộ về đúng nơi trước khi Done.

## Bootstrap project

Khi áp dụng AI-DEV-OS cho repository mới hoặc repository cũ chưa có docs đủ tốt, xem `APPLY-TO-PROJECT.md` và dùng skill `bootstrap-project`.

## Nguyên tắc

> Docs là bản đồ và nguồn knowledge bền vững, không phải ceremony. Tài liệu chỉ có giá trị khi giúp agent hiểu đúng, reuse đúng và thay đổi an toàn hơn.