# Repository Instructions

Đọc `AGENTS.md`, sau đó dùng `docs/README.md` để chỉ nạp context liên quan đến task hiện tại.

Tuân theo `docs/ai/16-TASK-EXECUTION.md`: giải quyết ambiguity quan trọng trước khi implement, search/reuse code hiện có trước khi tạo mới, verify bằng evidence, chạy Knowledge Sync và đánh giá Production Gate trước khi gọi task Done.

Không duplicate business rule, không refactor ngoài scope, không tuyên bố test/build pass nếu chưa chạy. Với task lớn/risky, dùng workflow trong `docs/work/README.md`.

Khi báo cáo kết quả, nêu ngắn gọn: thay đổi, verification, knowledge sync và production risk còn lại.