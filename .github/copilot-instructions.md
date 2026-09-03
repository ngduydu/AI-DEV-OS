# Repository instructions

Trước khi sửa code, hãy đọc `AGENTS.md` và tài liệu liên quan trong `docs/ai/`.

Quy tắc chính:

- Hiểu code hiện tại trước khi sửa.
- Bám đúng scope và pattern hiện có.
- Không tự tạo abstraction/core mới nếu chưa có nhu cầu rõ ràng.
- Không suy đoán business rule; kiểm tra `docs/ai/05-BUSINESS-RULES.md` và code/test hiện có.
- Dùng lệnh trong `docs/ai/07-COMMANDS.md` để build/test/lint.
- Mọi thay đổi phải được verify; không tuyên bố test pass nếu chưa chạy.
- Bug fix nên thêm regression test khi khả thi.
- Kiểm tra security theo `docs/ai/09-SECURITY.md`.
- Nếu behavior, architecture hoặc business rule thay đổi, cập nhật tài liệu tương ứng.
- Với thay đổi lớn, dùng workflow trong `docs/work/README.md`: research → spec → plan → tasks → implement → verification.

Khi trả lời, ưu tiên ngắn gọn: thay đổi gì, verify bằng gì, còn rủi ro gì.
