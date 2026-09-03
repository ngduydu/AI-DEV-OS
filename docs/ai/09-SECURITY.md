# Security Rules

## Nguyên tắc

- Không tin input từ client/external system.
- Authentication không đồng nghĩa authorization.
- Least privilege.
- Secret không nằm trong source code, prompt, log hoặc tài liệu commit vào git.
- Failure phải an toàn mặc định.

## Checklist cho thay đổi có input/API

- [ ] Validate input.
- [ ] Kiểm tra authorization tại server.
- [ ] Không tin ID/role/price/status do client tự khai nếu server có nguồn sự thật.
- [ ] Chống injection phù hợp với technology.
- [ ] Encode/escape output phù hợp.
- [ ] Kiểm tra file upload nếu có.
- [ ] Rate limiting/abuse nếu endpoint nhạy cảm.

## Authentication / Session

- ...

## Authorization

- ...

## Secrets

- Secret location: ...
- Rotation: ...

## Sensitive data

| Dữ liệu | Mức nhạy cảm | Cách bảo vệ |
|---|---|---|
| | | |

## Dependencies

- Dùng version supported.
- Không thêm package mới nếu standard library/dependency hiện có giải quyết được tốt.
- Với package quan trọng, kiểm tra maintenance/security/license phù hợp.

## Security-critical areas

- Auth
- Payment
- File upload
- Permission/tenant isolation
- Data export
- Admin actions
- Secrets/configuration

Thay đổi các vùng này cần review và test kỹ hơn bình thường.
