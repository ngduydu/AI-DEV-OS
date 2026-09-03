# AI System Maintenance

Mục tiêu: hệ thống AI càng dùng càng tốt thay vì càng ngày càng dài và mâu thuẫn.

## Quy tắc chuyển hóa knowledge

### Khi phải nhắc AI lần thứ hai

Hỏi: đây là loại thông tin gì?

| Thông tin | Nơi lưu |
|---|---|
| Luật áp dụng gần như mọi task | `AGENTS.md` |
| Kiến thức dự án | `docs/ai/` |
| Quyết định có trade-off | ADR |
| Procedure nhiều bước lặp lại | Skill |
| Lỗi/gotcha khó nhớ | `13-KNOWN-PITFALLS.md` |
| Thông tin chỉ cho task hiện tại | `docs/work/...` |

## Rule hygiene

Mỗi tháng hoặc sau milestone lớn:

- [ ] Xóa rule không còn đúng.
- [ ] Gộp rule trùng nhau.
- [ ] Kiểm tra contradiction.
- [ ] Chuyển procedure dài khỏi `AGENTS.md` thành Skill.
- [ ] Chuyển kiến thức chi tiết khỏi `AGENTS.md` về docs.
- [ ] Kiểm tra commands vẫn chạy được.
- [ ] Kiểm tra canonical example trong codebase map chưa lỗi thời.

## Khi nào tạo Skill?

Tạo Skill khi một quy trình:

- đã lặp lại ít nhất vài lần;
- có các bước tương đối ổn định;
- nếu làm sai dễ gây lỗi;
- cần checklist/reference cụ thể;
- không cần nạp vào context của mọi phiên.

Không tạo Skill chỉ vì một prompt nghe hay.

## Khi nào tạo ADR?

Tạo khi quyết định:

- ảnh hưởng architecture hoặc public contract;
- có nhiều phương án hợp lý;
- khó đảo ngược;
- người sau có khả năng hỏi "tại sao làm thế này?".

## Context budget

Giữ luôn-on context nhỏ.

```text
AGENTS.md = map + invariant rules
Docs       = knowledge on demand
Skills     = procedure on demand
Work docs  = context của một task
```
