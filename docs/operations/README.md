# Operations Documentation

Thư mục này chứa knowledge cần để thay đổi có thể đi từ code tới production an toàn.

Không tạo file rỗng chỉ để đủ cấu trúc. Tạo khi project thực sự có nội dung cần giữ, ví dụ:

```text
environments.md
deployment.md
database-migration.md
rollback.md
monitoring.md
troubleshooting.md
```

## Nội dung nên lưu ở đây

- môi trường và khác biệt config quan trọng;
- deploy order hoặc dependency giữa services;
- migration/seed/data-fix procedure;
- backup/rollback/recovery;
- health checks, logs, metrics, alerts;
- operational limits và failure modes;
- troubleshooting procedure đã được kiểm chứng.

Không đặt secret hoặc credential thật vào docs.

## Production Gate

Khi task ảnh hưởng production, agent phải đọc phần operations liên quan và kiểm tra ít nhất những mục có áp dụng:

- backward compatibility;
- migration/data safety;
- rollback/recovery;
- config/environment/secret;
- security/privacy;
- observability;
- dependency failure;
- deployment order/feature flag.

Nếu knowledge vận hành quan trọng được phát hiện trong task, cập nhật thư mục này trong Knowledge Sync.

Mục tiêu: human review tập trung vào quyết định và business, không phải phát hiện agent đã quên deploy/rollback/config cơ bản.