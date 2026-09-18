# Conflict-safe Project Knowledge

Mục tiêu: lưu knowledge bền vững mà không biến các file dùng chung thành điểm conflict khi nhiều task/branch chạy song song.

## Rule mặc định

**mỗi knowledge item = một file riêng**.

Knowledge phát hiện trong một task không được append mặc định vào một shared file đang được nhiều branch cùng sửa.

Ví dụ:

```text
docs/knowledge/
├── business-rules/
│   └── salespaper-bha-document-flow.md
├── pitfalls/
│   └── rabbitmq-publish-does-not-create-queue.md
├── modules/
│   └── salespaper-webhook-contract.md
└── operations/
    └── deploy-salespaper-worker.md
```

Các folder con được tạo on demand. Không scaffold hàng loạt folder rỗng.

## Không có central index

Không có central index bắt buộc phải append sau mỗi task.

Retrieval dùng:

- `docs/README.md` để biết route;
- CODEBASE-MAP/module docs khi đã có canonical route;
- targeted search trong `docs/knowledge/` khi cần;
- source/tests vẫn là ground truth.

Mục tiêu là để hai task độc lập có thể tạo hai file khác nhau và merge gần như không chạm nhau.

## Naming

Tên file phải:

- mô tả domain/behavior, không dùng tên chung như `note.md`;
- lowercase kebab-case;
- đủ cụ thể để search được;
- không phụ thuộc số thứ tự toàn cục.

Ví dụ tốt:

```text
docs/knowledge/pitfalls/rabbitmq-publish-does-not-create-queue.md
docs/knowledge/business-rules/salespaper-bha-document-flow.md
```

Không dùng sequence chung kiểu `KP-001`, `BR-023` cho file mới vì nhiều branch có thể chọn trùng số.

## Khi nào sửa shared canonical docs?

Shared canonical docs chỉ sửa khi **canonical truth thực sự thay đổi**, ví dụ:

- architecture hiện hành thay đổi;
- coding convention chính thức thay đổi;
- command build/test chính thức thay đổi;
- public contract/rule project-wide được thay đổi có chủ đích;
- CODEBASE-MAP cần thay route/canonical implementation vì code thật đã đổi.

Không sửa shared canonical docs chỉ để ghi lại một discovery của task.

```text
discovery của task
→ mặc định tạo file riêng trong docs/knowledge/

canonical truth thực sự thay đổi
→ sửa shared canonical docs phù hợp
```

Nếu hai branch cùng thay canonical truth và conflict, đó là conflict có ý nghĩa cần review, không phải conflict rác.

## Categories

### Business rules

```text
docs/knowledge/business-rules/<domain>-<rule>.md
```

Dùng cho rule bền vững được phát hiện/xác nhận trong task nhưng chưa cần sửa canonical project-wide contract.

### Pitfalls

```text
docs/knowledge/pitfalls/<domain>-<failure-mode>.md
```

Dùng cho gotcha/failure mode khó nhớ, có khả năng lặp lại.

### Module knowledge

```text
docs/knowledge/modules/<module>-<topic>.md
```

Dùng cho discovery cục bộ của module khi chưa cần consolidate vào module canonical docs.

### Operations

```text
docs/knowledge/operations/<system>-<topic>.md
```

Dùng cho deploy/migration/rollback/monitoring/troubleshooting discovery.

## Nội dung mỗi file

Giữ ngắn và có evidence:

```markdown
# <Tên knowledge>

## Context
<khi nào knowledge này áp dụng>

## Rule / Finding
<nội dung cần nhớ>

## Evidence
- source/test/config: <path>
- issue/PR nếu có: <ref>

## Verification
<cách xác minh khi cần>
```

Không biến task transcript thành documentation.

## Existing knowledge từ trước 2.6.0

Không di chuyển hoặc tách knowledge cũ tự động.

Các entry cũ trong:

- `docs/ai/13-KNOWN-PITFALLS.md`;
- `docs/ai/05-BUSINESS-RULES.md`;
- module/operations docs hiện hữu;

vẫn hợp lệ và tiếp tục được đọc.

Từ 2.6.0, **knowledge mới phát hiện trong task** đi theo conflict-safe rule ở tài liệu này.

Việc consolidate knowledge cũ/mới là maintenance riêng, không nằm trên critical path của task.

## Maintenance định kỳ

Khi có nhiều isolated knowledge file:

- gộp những file thực sự trùng;
- promote rule thành canonical docs nếu nó đã trở thành source of truth;
- xóa stale knowledge;
- giữ redirect/reference nếu việc di chuyển có thể làm search cũ mất dấu.

Không consolidate trong từng task trừ khi task đó chính là knowledge maintenance.
