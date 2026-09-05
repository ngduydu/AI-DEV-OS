---
name: update-project-knowledge
description: Preserve durable knowledge discovered during implementation, review, debugging, incidents, or user clarification. Run as the Knowledge Sync step before a task is considered Done.
---

# Update Project Knowledge

Knowledge Sync là bước bắt buộc trước Definition of Done.

## 1. Review what was learned

Xem lại:

- user clarification đã giải quyết ambiguity;
- behavior/business rule mới hoặc thay đổi;
- architecture/public contract decision;
- codebase/module knowledge có ích cho task sau;
- deploy/migration/rollback/monitoring knowledge;
- recurring failure/gotcha;
- procedure có khả năng lặp lại.

## 2. Route knowledge đúng chỗ

- project-wide knowledge → `docs/ai/`;
- module/domain knowledge → `docs/modules/<module>/`;
- operations knowledge → `docs/operations/`;
- architecture/public contract trade-off → `docs/decisions/` ADR;
- recurring multi-step procedure → create/update Skill;
- non-obvious recurring failure → `docs/ai/13-KNOWN-PITFALLS.md`;
- task-only context → `docs/work/`.

Giữ `AGENTS.md`/`CLAUDE.md` cực ngắn; không đẩy detailed knowledge vào always-on context.

## 3. User clarification

Nếu user vừa trả lời một câu hỏi về business rule/behavior và câu trả lời có giá trị bền vững:

```text
clarification
→ persist knowledge
→ implement
```

Không để task sau phải hỏi lại cùng một rule.

## 4. Hygiene

- Xóa/sửa guidance stale hoặc contradictory khi có evidence.
- Không duplicate cùng một rule ở nhiều file.
- Không biến assumption thành fact.
- Không tạo docs/module/skill chỉ để đủ cấu trúc.

## 5. Report

Nếu có update:

```text
Knowledge Sync:
- Updated: <path>
- Added: <path>
```

Nếu không có durable knowledge:

```text
Knowledge Sync: no durable changes
```

Không được bỏ qua bước này chỉ vì code/test đã pass.