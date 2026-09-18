# AI System Maintenance

Mục tiêu: hệ thống AI càng dùng càng hiểu project tốt hơn, nhưng always-on context vẫn nhỏ và docs không trở thành kho rác.

## Knowledge routing

Khi có knowledge mới, phân loại trước khi ghi.

### Conflict-safe default

Knowledge **phát hiện trong task** mặc định tạo file riêng dưới `docs/knowledge/` để tránh nhiều branch cùng append vào shared file.

| Knowledge phát hiện trong task | Nơi lưu mặc định |
|---|---|
| Business rule / behavior bền vững | `docs/knowledge/business-rules/entries/<entry-id>-<rule>.md` |
| Gotcha / failure mode khó nhớ | `docs/knowledge/pitfalls/entries/<entry-id>-<failure-mode>.md` |
| Module discovery | `docs/knowledge/modules/<module>/entries/<entry-id>-<topic>.md` |
| Deploy/migration/rollback/monitoring discovery | `docs/knowledge/operations/<system>/entries/<entry-id>-<topic>.md` |
| Context chỉ phục vụ task hiện tại | `docs/work/` |
| Quyết định architecture/public contract có trade-off | `docs/decisions/` ADR |
| Procedure nhiều bước đã lặp lại, tương đối ổn định | Skill |

Không có central index/summary/changelog phải append sau mỗi task. Với task-generated artifact, ưu tiên `entries/<entry-id>-<slug>.md`; không dùng global sequence.

### Shared canonical docs

Chỉ sửa shared canonical docs như `docs/ai/`, `docs/modules/`, `docs/operations/` khi canonical truth thực sự thay đổi.

Ví dụ:

- architecture hiện hành đổi;
- command build/test chính thức đổi;
- coding convention chính thức đổi;
- public/project-wide contract đổi;
- canonical implementation/route trong CODEBASE-MAP đổi.

Không sửa shared canonical file chỉ để lưu một discovery của task.

Chi tiết: `docs/knowledge/README.md`.


## User correction phải trở thành knowledge khi phù hợp

Nếu agent phải hỏi user để giải quyết ambiguity quan trọng và câu trả lời là behavior/rule bền vững:

```text
Ask
→ Confirm
→ Persist to correct docs
→ Implement
```

Không để cùng một câu hỏi quay lại ở task sau chỉ vì câu trả lời trước chết trong chat.

## Knowledge Sync là bước bắt buộc

Cuối mỗi task, trước Definition of Done:

1. Review những gì vừa học.
2. Phân loại theo bảng trên.
3. Cập nhật knowledge bền vững.
4. Xóa/sửa guidance cũ nếu đã mâu thuẫn.
5. Nếu không có gì cần lưu, report `Knowledge Sync: no durable changes`.

## Rule hygiene

Sau milestone lớn hoặc định kỳ:

- [ ] Xóa rule không còn đúng.
- [ ] Gộp rule trùng nhau.
- [ ] Kiểm tra contradiction giữa docs/code/test.
- [ ] Chuyển procedure dài khỏi global docs thành Skill.
- [ ] Kiểm tra commands vẫn chạy được.
- [ ] Kiểm tra canonical examples trong codebase map chưa lỗi thời.
- [ ] Kiểm tra module/operations docs có orphan hoặc stale không.
- [ ] Giữ `AGENTS.md`/`CLAUDE.md` cực ngắn.

## Khi nào tạo Skill?

Tạo khi procedure:

- đã lặp lại đủ để chứng minh có giá trị;
- có các bước tương đối ổn định;
- làm sai dễ gây lỗi hoặc mất thời gian;
- cần checklist/reference cụ thể;
- không cần nạp vào context của mọi phiên.

Không tạo Skill chỉ vì một prompt nghe hay.

## Khi nào tạo ADR?

Tạo khi quyết định:

- ảnh hưởng architecture hoặc public contract;
- có nhiều phương án hợp lý;
- trade-off đáng kể;
- khó đảo ngược hoặc chi phí đảo ngược cao;
- người sau có khả năng hỏi "tại sao làm thế này?".

Không cần ADR cho quyết định implementation nhỏ và dễ đảo ngược.

## Context budget

```text
AGENTS.md / CLAUDE.md = entry point cực nhỏ
Docs                   = knowledge on demand
Module docs            = domain context theo phạm vi
Skills                  = procedure on demand
Subagents               = review/research context độc lập khi đáng giá
Work docs               = context của một task
```

Nguyên tắc:

> Context thường trực càng ít càng tốt; project knowledge càng đúng và dễ tìm càng tốt.

## Framework lifecycle

Project đã apply AI-DEV-OS từ baseline 2.2.0 có version marker tại `.ai-dev-os/VERSION`.

Khi nâng framework:

1. đọc `UPGRADE.md`;
2. phân loại file thành framework-owned, project-owned hoặc mixed;
3. không overwrite project knowledge đã bootstrap;
4. merge mixed file bằng diff/evidence;
5. verify trước khi bump version.

Optional tool không được tự cài chỉ vì framework có integration.

Chi tiết ownership và migration: `UPGRADE.md`.

## Context efficiency

Sau bootstrap, task bình thường phải reuse `04-CODEBASE-MAP.md` và đi theo `17-CONTEXT-RETRIEVAL.md` thay vì scan lại repository.

Khi task độc lập hoàn tất và durable knowledge đã sync vào repo, với Claude Code nên dùng `/clear` trước task độc lập tiếp theo. Với cùng task nhưng context đã lớn, dùng `/compact`.
