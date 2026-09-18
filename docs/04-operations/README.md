# Operations Documentation

Thư mục này chứa canonical knowledge cần để thay đổi có thể đi từ code tới production an toàn.

Không tạo file rỗng chỉ để đủ cấu trúc. Canonical operations docs có thể gồm:

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

Knowledge vận hành bền vững **phát hiện trong task** mặc định tạo entry riêng tại:

```text
docs/03-knowledge/operations/<system>/entries/<entry-id>-<topic>.md
```

Chỉ sửa canonical operations docs khi task thực sự thay đổi runbook/procedure/contract vận hành chính thức.

Không append discovery mới vào shared troubleshooting/deployment list chỉ để lưu lại knowledge.
