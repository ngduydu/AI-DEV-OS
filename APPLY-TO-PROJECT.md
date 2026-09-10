# Apply AI-DEV-OS to a Project

Tài liệu này hướng dẫn cách đưa AI-DEV-OS vào một repository thật mà không biến việc setup thành một dự án documentation riêng.

Mục tiêu là:

```text
Copy core
→ bootstrap từ code thật
→ review knowledge ban đầu
→ giao task bình thường
→ project knowledge tự giàu dần sau mỗi task
```

Sau khi setup xong, xem `USAGE.md` để biết cách giao task hằng ngày, AI tự đọc file nào, khi nào nó phải hỏi lại và khi nào cần chạy bootstrap lại.

## 1. Copy những gì?

### Bắt buộc

```text
AGENTS.md
CLAUDE.md                 # nếu dùng Claude Code
docs/
.claude/skills/           # nếu dùng Claude Code
.claude/agents/           # nếu dùng Claude Code và muốn review độc lập
```

Nếu dùng agent khác ngoài Claude Code, copy adapter/skills phù hợp của agent đó. Không cần mang các file quản trị public repository như `LICENSE`, `CONTRIBUTING.md`, issue template hoặc changelog của AI-DEV-OS vào project sản phẩm.

## 2. Project đã có code

Sau khi copy core vào repository:

1. Chạy skill `bootstrap-project`.
2. Để AI scan code, test, config, build scripts và cấu trúc hiện tại.
3. AI chỉ điền knowledge có bằng chứng từ repository.
4. Review nhanh các docs được tạo/cập nhật.
5. Trả lời các `UNKNOWN` thật sự chặn task hoặc ảnh hưởng behavior quan trọng.
6. Commit knowledge bootstrap.
7. Giao task bình thường theo `USAGE.md`.

Không viết lại toàn bộ tài liệu bằng tay nếu codebase đã chứa đủ bằng chứng để AI tự tổng hợp.

## 3. Project mới chưa có code

Chỉ điền mức tối thiểu đủ để bắt đầu:

- `docs/ai/01-PROJECT-CONTEXT.md`
- `docs/ai/02-PRODUCT.md`
- `docs/ai/03-ARCHITECTURE.md` ở mức đã quyết định
- `docs/ai/06-CODING-STANDARDS.md` với convention thật sự đã chốt
- `docs/ai/07-COMMANDS.md` khi đã có lệnh build/run/test
- `docs/ai/08-TESTING.md` khi test strategy đã rõ

Không tạo nội dung giả để lấp đầy template. Module, operation, ADR, pitfall và skill chỉ xuất hiện khi project thực sự cần.

## 4. Knowledge tăng dần theo task

Ban đầu docs có thể rất ít. Điều đó bình thường.

```text
Task chạm module Contract
→ tạo/cập nhật docs/modules/contracts/

Phát hiện business rule mới
→ lưu vào module hoặc business rules phù hợp

Chọn giải pháp có trade-off đáng kể
→ ADR

Phát hiện gotcha lặp lại
→ Known Pitfalls

Có procedure ổn định dùng nhiều lần
→ Skill

Thay đổi cách deploy/migrate/rollback
→ docs/operations/
```

Không giữ knowledge quan trọng chỉ trong chat.

## 5. Cách giao task sau khi setup

Không cần prompt dài. Ví dụ:

```text
Sửa lỗi không cập nhật trạng thái máy khi hủy hợp đồng.
```

Sau khi setup đúng, **không cần nhắc AI đọc từng file**. Agent phải tự đi theo:

```text
CLAUDE.md
→ AGENTS.md
→ docs/README.md
→ docs/ai/16-TASK-EXECUTION.md
→ docs/module/code/test liên quan
```

và thực hiện:

```text
Load context
→ Understanding Gate
→ Reuse Gate
→ Plan nếu cần
→ Implement
→ Verify
→ Review
→ Knowledge Sync
→ Production Gate
→ Report
```

Nếu requirement quan trọng chưa rõ, agent phải tự tìm trong repo trước; vẫn không đủ bằng chứng thì hỏi lại thay vì đoán.

Hướng dẫn chi tiết cách dùng hằng ngày: `USAGE.md`.

## 6. Khi nào setup được coi là đủ?

Không cần mọi file đều đầy. Setup đủ khi AI có thể trả lời đáng tin cậy:

- Project này giải quyết việc gì?
- Kiến trúc và stack hiện tại là gì?
- Code liên quan thường nằm ở đâu?
- Convention chính là gì?
- Canonical example/building block nào nên reuse?
- Build/run/test bằng lệnh nào?
- Business rule của task hiện tại nằm ở đâu?
- Điều gì chưa biết và có cần hỏi trước khi implement không?

## 7. Sau một thời gian sử dụng

Định kỳ sau milestone lớn:

- xóa knowledge lỗi thời;
- gộp rule trùng;
- kiểm tra docs có mâu thuẫn code không;
- chuyển procedure lặp lại thành Skill;
- bổ sung module/operations docs từ những gì đã học thật;
- refresh canonical examples/building blocks;
- giữ `AGENTS.md` và `CLAUDE.md` cực ngắn.

Nguyên tắc cuối cùng:

> Bootstrap vừa đủ để bắt đầu. Mỗi task làm project hiểu chính nó tốt hơn.