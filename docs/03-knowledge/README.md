# Conflict-safe Project Knowledge

Mục tiêu: lưu knowledge bền vững mà không biến các file dùng chung thành điểm conflict khi nhiều task/branch chạy song song.

## Nguyên tắc bất biến

1. **Mỗi discovery bền vững của task = một file entry riêng.**
2. Không append discovery mới vào shared summary/index/list chỉ để "ghi lại cho đủ".
3. Không dùng sequence toàn cục như `0001`, `KP-001`, `BR-001` cho entry mới.
4. Shared canonical docs chỉ sửa khi chính task làm thay đổi canonical truth tương ứng.
5. Knowledge cũ phải được preserve; upgrade không auto-split, auto-move hoặc rewrite nội dung project.

## Routing mặc định

Task-generated knowledge dùng `entries/`:

```text
business rule / behavior
→ docs/03-knowledge/business-rules/entries/<entry-id>-<slug>.md

pitfall / failure mode
→ docs/03-knowledge/pitfalls/entries/<entry-id>-<slug>.md

module discovery
→ docs/03-knowledge/modules/<module>/entries/<entry-id>-<slug>.md

operations discovery
→ docs/03-knowledge/operations/<system>/entries/<entry-id>-<slug>.md

architecture/public-contract decision
→ docs/05-decisions/entries/<entry-id>-<slug>.md

task-only context
→ docs/06-work/<task-id>/
```

Folder con được tạo on demand. Không scaffold hàng loạt folder rỗng.

Nếu project đã có cấu trúc `<section>/entries/` tương đương, ưu tiên dùng cấu trúc có sẵn thay vì tạo một shared file tổng hợp mới.

## Entry ID và tên file

Ưu tiên identifier đã có của task:

```text
<hhm-123>-<topic>.md
<issue-42>-<topic>.md
<branch-slug>-<topic>.md
```

Nếu không có task identifier ổn định:

```text
<yyyy-mm-dd>-<task-slug>-<topic>.md
```

Tên phải lowercase kebab-case, đủ cụ thể để search được và không phụ thuộc global counter.

Hai branch độc lập phải có khả năng tạo hai file khác nhau mà không cần phối hợp trước để "xin số".

## Không có central index bắt buộc

Không update một file chung chỉ để đăng ký entry mới.

Đặc biệt, không append task discovery vào các dạng file dễ trở thành conflict hotspot như:

- `README.md` chỉ để thêm link mới;
- `changelog.md`;
- `decisions.md`;
- `known-issues.md`;
- `roadmap.md`;
- shared business-rule/pitfall list;
- shared registry/index khác.

Các file đó chỉ đổi khi task thật sự có scope thay đổi chính nội dung canonical của chúng.

Retrieval dùng targeted search trong `entries/`, route hiện có và source/tests. Không cần một danh sách trung tâm phải sửa sau mỗi task.

## Conflict Surface Gate

Trước khi ghi durable artifact, kiểm tra:

1. File đích có phải file chung mà nhiều branch có khả năng cùng sửa không?
2. Change có phải kiểu append item, thêm link, tăng sequence hoặc cập nhật registry/list không?
3. Có thể lưu thành file entry riêng với task-local identifier không?

Nếu câu trả lời là có, **mặc định tạo entry riêng**.

Chỉ chấp nhận sửa shared file khi conflict đó phản ánh cùng một canonical truth đang bị hai branch thay đổi thật sự. Đó là conflict có ý nghĩa cần review, không phải conflict do thiết kế documentation.

## Shared canonical docs

Các file như:

- `docs/00-overview/architecture.md`;
- `docs/00-overview/codebase-map.md`;
- `docs/03-knowledge/business-rules.md`;
- `docs/03-knowledge/known-pitfalls.md`;
- module/operations canonical docs;
- `AGENTS.md` / `CLAUDE.md`;

không được sửa chỉ để persist một discovery của task.

Chỉ sửa khi task thực sự thay đổi canonical contract/rule/route tương ứng.

## Nội dung mỗi entry

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

## Existing knowledge trước 2.6.0

Không split/rewrite semantics của knowledge cũ bằng suy đoán. Layout migration có thể `git mv` nguyên file sang ordered path nhưng phải giữ nguyên content.

Các entry/nội dung cũ trong:

- `docs/03-knowledge/known-pitfalls.md`;
- `docs/03-knowledge/business-rules.md`;
- module/operations docs hiện hữu;
- ADR cũ, kể cả ADR dùng numbering;

vẫn hợp lệ và tiếp tục được đọc.

Từ 2.6.0, knowledge mới phát hiện trong task đi theo conflict-safe routing ở tài liệu này.

## Maintenance định kỳ

Consolidation là task maintenance riêng, không nằm trên critical path của từng task.

Khi maintenance:

- gộp entry thực sự trùng;
- promote rule thành canonical docs nếu nó đã trở thành source of truth;
- xóa stale knowledge;
- sửa redirect/reference nếu cần;
- không tạo lại central append-only index.
