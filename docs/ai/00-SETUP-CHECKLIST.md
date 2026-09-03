# Setup Checklist

Checklist dùng khi đưa AI Development OS vào một repository mới.

## Bắt buộc

- [ ] Điền `01-PROJECT-CONTEXT.md`.
- [ ] Điền `02-PRODUCT.md`.
- [ ] Điền `03-ARCHITECTURE.md` ở mức hiện có, không tưởng tượng tương lai.
- [ ] Điền `04-CODEBASE-MAP.md` với các thư mục/module chính.
- [ ] Ghi các business rule quan trọng vào `05-BUSINESS-RULES.md`.
- [ ] Ghi convention thật của dự án vào `06-CODING-STANDARDS.md`.
- [ ] Điền lệnh chạy thực tế vào `07-COMMANDS.md`.
- [ ] Xác định chiến lược test trong `08-TESTING.md`.
- [ ] Xác định minimum security rules trong `09-SECURITY.md`.

## Sau khi repo ổn định hơn

- [ ] Bổ sung `13-KNOWN-PITFALLS.md` từ lỗi thực tế.
- [ ] Tạo ADR cho quyết định kiến trúc quan trọng.
- [ ] Chuyển workflow lặp lại thành Skill.
- [ ] Xóa rule lỗi thời hoặc trùng lặp.
- [ ] Kiểm tra `AGENTS.md` vẫn là bản đồ ngắn, không trở thành wiki.

## Không làm

- Không điền thông tin chỉ để file trông "đủ".
- Không copy coding rule của framework nếu dự án chưa dùng framework đó.
- Không bắt AI chạy lệnh không tồn tại.
- Không đặt secret, token, connection string thật vào tài liệu AI.
