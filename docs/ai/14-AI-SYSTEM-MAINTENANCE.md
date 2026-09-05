# AI System Maintenance

Mục tiêu: hệ thống AI càng dùng càng hiểu project tốt hơn, nhưng always-on context vẫn nhỏ và docs không trở thành kho rác.

## Knowledge routing

Khi có knowledge mới, phân loại trước khi ghi:

| Knowledge | Nơi lưu |
|---|---|
| Rule cực ngắn áp dụng gần như mọi task | entry point/global docs, giữ tối thiểu |
| Project knowledge chung | `docs/ai/` |
| Knowledge/business rule riêng module | `docs/modules/<module>/` |
| Deploy/migration/rollback/monitoring/troubleshooting | `docs/operations/` |
| Quyết định architecture/public contract có trade-off | `docs/decisions/` ADR |
| Procedure nhiều bước đã lặp lại, tương đối ổn định | Skill |
| Gotcha/failure mode khó nhớ | `docs/ai/13-KNOWN-PITFALLS.md` |
| Context chỉ phục vụ task hiện tại | `docs/work/` |

Không copy cùng một rule vào nhiều nơi nếu không có lý do adapter/tool-specific.

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