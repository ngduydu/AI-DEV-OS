# Agent Instructions

Trước mọi task trong repository, đọc `docs/README.md` và chỉ nạp tài liệu/code liên quan đến task hiện tại.

Tuân theo `docs/01-development/ai-development.md`: không implement khi còn ambiguity quan trọng, không tạo mới trước khi kiểm tra khả năng reuse, và không coi task là Done trước khi Verify + Knowledge Sync + Production Gate.

## Ngôn ngữ mặc định

- Mọi phản hồi, báo cáo, plan/spec và tài liệu do agent tạo cho team phải dùng **tiếng Việt**.
- Code, identifier, API/schema và tên kỹ thuật giữ theo convention của project; không Việt hóa code chỉ để đồng bộ ngôn ngữ.
- Comment mới hoặc comment được sửa trong source code phải dùng **tiếng Việt**, ưu tiên giải thích **WHY** thay vì lặp lại code đang làm gì.
- Không tự dịch/đổi các comment tiếng Anh cũ ngoài scope task chỉ để đồng nhất ngôn ngữ.
