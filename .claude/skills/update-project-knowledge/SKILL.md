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

## 2. Conflict-safe default

Knowledge phát hiện trong task **mặc định tạo file riêng** dưới `docs/03-knowledge/`.

Không sửa shared canonical docs chỉ để lưu discovery của task.

Routing mặc định:

```text
business rule / behavior
→ docs/03-knowledge/business-rules/entries/<entry-id>-<rule>.md

pitfall / failure mode
→ docs/03-knowledge/pitfalls/entries/<entry-id>-<failure-mode>.md

module discovery
→ docs/03-knowledge/modules/<module>/entries/<entry-id>-<topic>.md

operations discovery
→ docs/03-knowledge/operations/<system>/entries/<entry-id>-<topic>.md
```

Không có central index/summary/changelog phải append sau mỗi task.

Trước khi ghi, chạy Conflict Surface Gate: nếu destination là shared file và change chỉ là append item/link/registry/sequence, tạo isolated entry thay vì sửa shared file. Ưu tiên task/issue/branch id; không dùng global counter.

Tên file dùng lowercase kebab-case, mô tả domain/behavior và không dùng sequence toàn cục.

## 3. Shared canonical docs chỉ sửa khi canonical truth đổi

Không sửa shared canonical docs như:

- `docs/00-overview/architecture.md`;
- `docs/00-overview/codebase-map.md`;
- `docs/03-knowledge/business-rules.md`;
- `docs/03-knowledge/known-pitfalls.md`;
- shared module/operations docs;

chỉ để thêm một discovery của task.

Chỉ sửa chúng khi task thực sự thay đổi canonical truth tương ứng.

Nếu hai branch cùng thay canonical truth và conflict, đó là conflict có ý nghĩa cần review.

## 4. User clarification

Nếu user vừa trả lời một câu hỏi về business rule/behavior và câu trả lời có giá trị bền vững:

```text
clarification
→ tạo isolated knowledge file phù hợp
→ implement
```

Chỉ promote vào shared canonical docs nếu câu trả lời chính là thay đổi canonical contract.

## 5. Existing knowledge

Knowledge có từ trước 2.6.0 vẫn hợp lệ.

Không split/rewrite semantics của knowledge cũ bằng suy đoán. Layout migration có thể `git mv` nguyên file sang ordered path nhưng phải giữ nguyên content.

Không rewrite `docs/03-knowledge/known-pitfalls.md` hoặc các shared file chỉ để phù hợp layout mới.

## 6. Hygiene

- Không duplicate cùng một rule ở nhiều file.
- Không biến assumption thành fact.
- Không tạo knowledge file nếu không có durable knowledge thật.
- Không tạo central index chỉ để liệt kê file.
- Nếu isolated knowledge trở thành canonical source of truth, consolidate trong task maintenance riêng hoặc khi task thực sự thay đổi contract.
- Giữ `AGENTS.md`/`CLAUDE.md` cực ngắn.

Policy đầy đủ: `docs/03-knowledge/README.md`.

## 7. Report

Nếu có update:

```text
Knowledge Sync:
- Added: docs/03-knowledge/<category>/<file>.md
```

Nếu canonical truth thật sự đổi:

```text
Knowledge Sync:
- Updated canonical: <path>
```

Nếu không có durable knowledge:

```text
Knowledge Sync: no durable changes
```

Không được bỏ qua bước này chỉ vì code/test đã pass.
