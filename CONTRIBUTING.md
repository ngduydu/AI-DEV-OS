# Contributing to AI-DEV-OS

Cảm ơn bạn đã quan tâm đến AI-DEV-OS.

Mục tiêu của repository này là xây dựng một bộ khung thực tế giúp developer và team làm việc với AI coding agents hiệu quả hơn, có cấu trúc hơn và ít phụ thuộc vào việc phải nhắc lại context trong từng cuộc chat.

## Nguyên tắc đóng góp

Mọi thay đổi nên ưu tiên:

- Đơn giản, dễ hiểu.
- Có giá trị thực tế khi làm dự án.
- Không làm tăng context một cách không cần thiết.
- Không ép mọi dự án phải dùng cùng một công nghệ.
- Không biến repository thành nơi chứa hàng trăm prompt trùng lặp.
- Ưu tiên tài liệu ngắn ở root và kiến thức chi tiết ở đúng thư mục.
- Workflow lặp lại nhiều lần nên cân nhắc chuyển thành Skill.
- Rule chỉ áp dụng cho một công nghệ nên để trong phần technology-specific, không đưa vào core chung.

## Trước khi tạo Pull Request

Hãy kiểm tra:

1. Thay đổi này giải quyết vấn đề gì?
2. Nó có áp dụng cho nhiều dự án hay chỉ một trường hợp riêng?
3. Nó nên là Rule, Documentation, Template, Skill, Prompt hay Example?
4. Có làm tăng lượng context AI phải đọc mặc định không?
5. Có tài liệu nào hiện tại đã giải quyết việc này chưa?

## Cấu trúc đóng góp

### Thêm rule chung

Cân nhắc cập nhật:

```text
AGENTS.md
docs/ai/
```

Không nên làm `AGENTS.md` dài nếu nội dung có thể đặt trong tài liệu chuyên biệt.

### Thêm workflow lặp lại

Cân nhắc thêm hoặc sửa:

```text
.agents/skills/
.claude/skills/
```

### Thêm template

Đặt trong:

```text
templates/
```

### Thêm prompt dùng thủ công

Đặt trong:

```text
prompts/
```

### Thêm quyết định kiến trúc

Dùng ADR:

```text
docs/decisions/
```

## Pull Request

PR nên:

- Chỉ tập trung vào một mục tiêu chính.
- Mô tả rõ vấn đề và lý do thay đổi.
- Không refactor hoặc đổi cấu trúc không liên quan.
- Cập nhật tài liệu nếu thay đổi cách sử dụng repository.
- Giữ backward compatibility nếu hợp lý.

## Issue

Bạn có thể tạo issue cho:

- File hoặc rule còn thiếu.
- Workflow chưa hợp lý.
- AI agent hiểu sai do cấu trúc hiện tại.
- Context bị nạp quá nhiều.
- Một pattern thực tế nên được chuẩn hóa.
- Đề xuất hỗ trợ tool hoặc coding agent mới.

Khi báo issue, nếu có thể hãy cung cấp:

```text
Agent / Tool:
Loại dự án:
Task:
Vấn đề gặp phải:
Kết quả mong muốn:
```

## Những đóng góp không khuyến khích

Repository này không hướng tới:

- Prompt collection khổng lồ.
- Framework bắt buộc cho mọi project.
- Một kiến trúc phần mềm cụ thể.
- Một stack công nghệ duy nhất.
- Rule quá chi tiết nhưng không có giá trị tái sử dụng.
- Tự động nạp toàn bộ tài liệu vào context của AI.

## Triết lý

```text
Context thường trực
→ càng nhỏ càng tốt

Knowledge trong repository
→ đủ đầy để tra cứu

Context cho từng task
→ chỉ đọc những gì cần thiết
```

## Code of Conduct

Hãy trao đổi kỹ thuật thẳng thắn nhưng tôn trọng nhau.

Phản biện ý tưởng, thiết kế và implementation — không công kích cá nhân.
