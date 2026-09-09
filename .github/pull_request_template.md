## Mục tiêu

Mô tả ngắn gọn vấn đề PR này giải quyết và lý do thay đổi cần tồn tại.

## Loại thay đổi

- [ ] Rule / project knowledge
- [ ] Skill / workflow
- [ ] Template / prompt
- [ ] Documentation
- [ ] Community / repository maintenance
- [ ] Khác

## Thay đổi chính

- 

## Context impact

- [ ] Không làm tăng always-on context.
- [ ] Giảm context hoặc giúp AI tìm đúng context nhanh hơn.
- [ ] Có tăng always-on context và đã giải thích lý do bên dưới.

Nếu sửa `AGENTS.md`, `CLAUDE.md` hoặc `.github/copilot-instructions.md`, hãy giải thích tại sao nội dung này cần được nạp thường xuyên thay vì đặt trong docs/skill:

> 

## Reuse / convention impact

- [ ] Đã kiểm tra canonical examples/reusable building blocks nếu thay đổi có tạo implementation/workflow mới.
- [ ] Không duplicate rule/logic/skill đã tồn tại.
- [ ] Convention/project-specific behavior mới đã được đặt đúng source of truth.
- [ ] Dependency mới đã được giải thích nếu có.

## Verification

Nêu rõ cách đã kiểm tra thay đổi này. Với thay đổi tài liệu, kiểm tra link/path/cấu trúc và tính nhất quán. Với workflow/skill, mô tả scenario đã dùng để kiểm tra.

```text
Verification:
```

## Knowledge Sync

```text
Updated:
- <path>
```

hoặc:

```text
Knowledge Sync: no durable changes
```

## Checklist

- [ ] PR chỉ tập trung vào một mục tiêu chính.
- [ ] Không duplicate knowledge đã có nơi khác.
- [ ] Không thêm rule chung cho một trường hợp quá riêng biệt.
- [ ] Không over-engineering hoặc thêm abstraction/dependency không cần thiết.
- [ ] Không để temp/debug/dead/commented-out artifact do change tạo ra.
- [ ] Không đưa secret, credential hoặc dữ liệu nhạy cảm vào repository.
- [ ] Các path/file được nhắc tới thực sự tồn tại.
- [ ] `FILE-INDEX.md` được cập nhật nếu thêm/xóa file.
- [ ] Documentation liên quan đã được cập nhật nếu behavior hoặc workflow thay đổi.
- [ ] Verification report phản ánh check đã thực sự chạy; check chưa chạy được ghi rõ.
