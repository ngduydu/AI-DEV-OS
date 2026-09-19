# Repository Instructions

Đọc `AGENTS.md`, sau đó dùng `docs/README.md` để chỉ nạp context liên quan đến task hiện tại.

Tuân theo `docs/01-development/ai-development.md`: giải quyết ambiguity quan trọng trước khi implement, search/reuse code hiện có trước khi tạo mới, verify bằng evidence, chạy Knowledge Sync và đánh giá Production Gate trước khi gọi task Done.

Không duplicate business rule, không refactor ngoài scope, không tuyên bố test/build pass nếu chưa chạy. Với task lớn/risky, dùng workflow trong `docs/06-work/README.md`.

Khi báo cáo kết quả, nêu ngắn gọn: thay đổi, verification, knowledge sync và production risk còn lại.

Ngôn ngữ mặc định: trả lời/báo cáo bằng tiếng Việt. Code và identifier giữ theo convention của project; comment mới hoặc comment được sửa trong code phải viết bằng tiếng Việt.
