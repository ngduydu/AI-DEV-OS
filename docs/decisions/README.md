# Architecture Decision Records

ADR lưu **lý do của quyết định**, không chỉ kết quả.

## Entry-per-file

Quyết định mới tạo file riêng tại:

```text
docs/decisions/entries/<entry-id>-<decision-slug>.md
```

Ví dụ:

```text
docs/decisions/entries/hhm-123-use-outbox-for-order-events.md
docs/decisions/entries/2026-09-18-payment-retry-use-idempotency-key.md
```

Không dùng sequence toàn cục kiểu `0001`, `0002` cho ADR mới vì hai branch song song có thể chọn cùng số.

Không có central index bắt buộc phải update sau mỗi ADR.

Dùng `ADR-TEMPLATE.md`.

ADR numbering cũ đã tồn tại vẫn hợp lệ và không cần rename khi upgrade.

Không cần ADR cho mọi quyết định nhỏ. Dùng khi quyết định có trade-off đáng kể, ảnh hưởng nhiều phần hoặc khó thay đổi.
