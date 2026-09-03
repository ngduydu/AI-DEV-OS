# Work Artifacts

Thư mục này chứa context của **một công việc cụ thể**, không phải kiến thức vĩnh viễn của dự án.

## Chọn mức quy trình

### Level S — Small

Ví dụ: typo, config nhỏ, bug rõ nguyên nhân, thay đổi cục bộ ít rủi ro.

```text
Understand → Implement → Verify
```

Không bắt buộc tạo work folder.

### Level M — Medium

Ví dụ: feature vài file, business rule rõ, thay đổi API nhỏ.

```text
Brief/Spec → Plan → Implement → Verify
```

Tạo folder nếu giúp review/context.

### Level L — Large / Risky

Ví dụ:

- chưa hiểu codebase liên quan;
- cross-cutting change;
- architecture;
- auth/security/payment;
- migration dữ liệu;
- feature lớn;
- refactor nhiều module.

```text
Research
→ Spec
→ Plan
→ Tasks
→ Implement theo phase
→ Verification
```

## Naming

```text
docs/work/2026-09-02-user-subscription/
```

Có thể copy từ `_template/`.

## Quy tắc

- Research mô tả **hiện trạng**, không lén biến thành kế hoạch.
- Spec mô tả **behavior mong muốn**, không đi sâu từng dòng code.
- Plan mô tả **cách triển khai** và verification.
- Tasks chia plan thành đơn vị thực thi/review được.
- Verification ghi **bằng chứng đã chạy**, không phải dự định.

## Sau khi task hoàn thành

Kiến thức nào còn giá trị lâu dài phải được chuyển về:

- `docs/ai/`
- ADR
- Skill
- Known Pitfalls

Không bắt AI đọc tất cả work folder cũ cho mọi task.
