# Security Review

Review thay đổi theo `docs/ai/09-SECURITY.md`.

Tập trung vào:

- authentication;
- authorization/tenant isolation;
- input validation;
- injection/XSS/CSRF tùy stack;
- secret exposure;
- sensitive data/logging;
- file upload/path traversal;
- SSRF/external request;
- dependency risk;
- unsafe defaults;
- race/TOCTOU khi liên quan permission/resource.

Chỉ báo finding có đường khai thác hoặc impact hợp lý; tránh liệt kê checklist chung chung như bug cụ thể.
