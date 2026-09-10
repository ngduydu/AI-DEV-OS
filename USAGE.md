# Cách sử dụng AI-DEV-OS hằng ngày

Tài liệu này trả lời câu hỏi thực tế nhất:

> Sau khi áp AI-DEV-OS vào project, mỗi lần giao task phải nói AI đọc file nào, hay AI tự đọc?

## Câu trả lời ngắn

**Sau khi setup đúng, bạn chỉ cần giao task. Không cần nhắc AI đọc từng file ở mỗi lần làm việc.**

Nếu bạn chưa cài hoặc chưa quen Claude Code, đọc trước `CLAUDE-CODE-GUIDE.md`.

Với Claude Code, luồng context của project được thiết kế như sau:

```text
Bạn giao task
↓
CLAUDE.md
↓
AGENTS.md
↓
docs/README.md
↓
Task Execution Contract
↓
AI tự xác định docs/module/code/test liên quan
↓
AI làm task
```

`AGENTS.md` và `CLAUDE.md` phải luôn ngắn. Chúng chỉ đóng vai trò entry point và router; knowledge chi tiết nằm trong `docs/`.

---

## 1. Lần đầu áp vào một project đã có code

Copy các thành phần theo `APPLY-TO-PROJECT.md`, sau đó chạy bootstrap project.

Luồng mong muốn:

```text
Copy AI-DEV-OS core
↓
Run bootstrap-project
↓
AI scan code / tests / config / CI / scripts
↓
AI fill minimum project knowledge
↓
AI tìm canonical examples + reusable building blocks
↓
AI báo UNKNOWN/conflict quan trọng
↓
Bạn trả lời những chỗ thật sự cần
↓
Commit bootstrap knowledge
↓
Bắt đầu giao task bình thường
```

Bạn không cần tự ngồi điền lại những gì codebase đã chứng minh rõ.

### Sau bootstrap, kiểm tra nhanh

AI phải trả lời được ít nhất:

- Project này làm gì?
- Stack và architecture hiện tại là gì?
- Module/code chính nằm ở đâu?
- Convention chính là gì?
- Code mẫu/canonical implementation nào nên bắt chước?
- Building block nào đã có để reuse?
- Build/test/lint bằng command nào?
- Những UNKNOWN nào có thể làm sai task tiếp theo?

Nếu những câu này chưa trả lời đáng tin cậy, bootstrap chưa đủ tốt.

---

## 2. Lần đầu áp vào project mới chưa có code nhiều

Không cần fill toàn bộ template.

Điền tối thiểu những gì đã biết chắc:

```text
docs/ai/01-PROJECT-CONTEXT.md
docs/ai/02-PRODUCT.md
docs/ai/03-ARCHITECTURE.md
docs/ai/06-CODING-STANDARDS.md
```

Khi đã có project skeleton thì bổ sung:

```text
docs/ai/04-CODEBASE-MAP.md
docs/ai/07-COMMANDS.md
docs/ai/08-TESTING.md
```

Business rule/module/operations/ADR được fill dần khi project thực sự có knowledge đó.

---

## 3. Mỗi lần giao task bình thường

Bạn chỉ cần mô tả task.

Ví dụ:

```text
Sửa lỗi khi hủy hợp đồng nhưng máy chưa chuyển về trạng thái Available.
```

Không cần viết:

```text
Hãy đọc AGENTS.md.
Hãy đọc architecture.
Hãy đọc coding standard.
Hãy đọc business rules.
Hãy search code cũ.
Hãy chạy test.
Hãy update docs.
```

Những việc đó là trách nhiệm của AI-DEV-OS và `docs/ai/16-TASK-EXECUTION.md`.

Agent phải tự làm:

```text
Task
↓
Load relevant context
↓
Inspect existing code/tests
↓
Understanding Gate
↓
Reuse Gate
↓
Plan nếu task cần
↓
Implement
↓
Verify
↓
Review nếu phù hợp
↓
Knowledge Sync
↓
Production Gate
↓
Report
```

---

## 4. AI tự đọc những file nào?

AI **không đọc toàn bộ docs cho mọi task**.

Nó bắt đầu từ `docs/README.md`, rồi route theo task.

Ví dụ:

### Sửa business logic của Contract

AI thường cần:

```text
docs/ai/16-TASK-EXECUTION.md
docs/modules/contracts/*
docs/ai/05-BUSINESS-RULES.md       # nếu có global rule liên quan
docs/ai/06-CODING-STANDARDS.md
relevant contract code/tests
```

### Sửa API

AI thường cần:

```text
docs/ai/16-TASK-EXECUTION.md
docs/ai/06-CODING-STANDARDS.md
module docs liên quan
canonical API example trong 04-CODEBASE-MAP.md
API implementation/tests liên quan
```

### Sửa database/migration

AI thường cần:

```text
docs/ai/06-CODING-STANDARDS.md
docs/ai/07-COMMANDS.md
docs/operations/* liên quan
docs/modules/<module>/*
existing migrations/schema/query patterns
```

### Sửa authentication/security

AI thường cần:

```text
docs/ai/09-SECURITY.md
docs/ai/03-ARCHITECTURE.md
module/auth docs nếu có
canonical implementation hiện tại
security/auth tests
```

Agent tự chọn context. Bạn không phải nhớ đường dẫn này khi giao task.

---

## 5. Khi nào AI phải hỏi bạn?

AI không được hỏi vì lười search.

Nó phải:

```text
Search docs
↓
Search code/tests/config/history
↓
Vẫn còn ambiguity quan trọng?
├── Không → tự làm
└── Có → hỏi bạn
```

AI phải hỏi nếu câu trả lời có thể làm thay đổi đáng kể:

- business behavior;
- data/invariant;
- API/public contract;
- permission/security;
- architecture;
- Acceptance Criteria;
- destructive migration/rollback behavior.

AI không nên hỏi những thứ có thể suy ra an toàn từ convention/codebase, ví dụ tên biến, pattern folder đã quá rõ hoặc formatter xử lý được.

---

## 6. Khi bạn trả lời câu hỏi của AI

Nếu câu trả lời là knowledge bền vững, AI phải lưu lại trước/đồng thời với implementation.

Ví dụ:

```text
AI hỏi:
"Hủy hợp đồng thì máy có trở về Available không?"

Bạn trả lời:
"Có, và phải chốt counter cuối trước khi hủy."
```

AI phải:

```text
Update business/module docs
↓
Implement theo rule vừa xác nhận
↓
Task sau không hỏi lại cùng rule
```

Không để project knowledge quan trọng chỉ nằm trong chat.

---

## 7. Task nhỏ, task lớn có giao khác nhau không?

Thông thường **không cần**.

Bạn vẫn giao task tự nhiên.

Ví dụ task nhỏ:

```text
Sửa validation số điện thoại ở màn tạo khách hàng.
```

Ví dụ task lớn:

```text
Thêm luồng gia hạn hợp đồng thuê máy, bao gồm lịch sử gia hạn và cập nhật phí thuê.
```

Agent tự classify Small / Medium / Large-Risky và tăng/giảm process tương ứng.

Nếu bạn muốn kiểm soát một task đặc biệt, có thể nói rõ:

```text
Chỉ research và plan, chưa code.
```

hoặc:

```text
Làm task này end-to-end theo AI-DEV-OS và đưa tới Production Candidate để tôi review.
```

Nhưng đây là override theo nhu cầu, không phải prompt bắt buộc hằng ngày.

---

## 8. Bạn review gì ở cuối task?

Final report của agent nên cho bạn thấy tối thiểu:

```text
Changed:
- đã thay đổi gì

Verified:
- command/test/check nào đã chạy

Review:
- reviewer/check nào đã thực hiện

Knowledge Sync:
- docs/ADR/module/pitfall nào đã cập nhật
- hoặc no durable changes

Production:
- Candidate / Blocked / Not applicable
- risk còn lại
```

Mục tiêu là bạn tập trung review:

- business đúng chưa;
- giải pháp có hợp lý không;
- diff có sạch, đúng scope không;
- risk nào bạn chưa chấp nhận.

Bạn không nên phải tự đi phát hiện những lỗi quy trình kiểu "quên test", "quên đọc convention", "duplicate helper" hoặc "quên update docs" nếu framework đang hoạt động đúng.

---

## 9. Khi nào cần chạy lại bootstrap-project?

Không chạy mỗi task.

Chỉ nên chạy/refresh khi:

- mới áp AI-DEV-OS vào repo;
- docs đã cũ nhiều so với code;
- project vừa restructure lớn;
- onboarding một codebase legacy chưa có knowledge tốt;
- canonical examples/conventions bị thay đổi nhiều;
- agent liên tục hỏi lại những thứ repository lẽ ra phải biết.

Task bình thường dùng Task Execution Contract, không bootstrap lại.

---

## 10. Nếu AI vẫn làm sai workflow

Kiểm tra theo thứ tự:

1. `CLAUDE.md`/adapter của tool có tồn tại và đúng không?
2. `AGENTS.md` có trỏ tới `docs/README.md` và Task Execution Contract không?
3. Project đã bootstrap đủ chưa?
4. `04-CODEBASE-MAP.md` có canonical examples/building blocks chưa?
5. `06-CODING-STANDARDS.md` có convention thật của project chưa?
6. `07-COMMANDS.md` có command verify thật chưa?
7. Business/module docs có thiếu knowledge quan trọng không?
8. Tool enforcement/CI có bắt được rule nào nên tự động bắt không?

Nếu phải nhắc AI cùng một điều nhiều lần, đừng tiếp tục nhắc bằng chat. Hãy đưa rule/knowledge đó về đúng nơi trong repository.

---

## 11. Cách dùng ngắn nhất

### Project đã có code

```text
1. Copy AI-DEV-OS core
2. Run bootstrap-project
3. Review UNKNOWN quan trọng
4. Commit bootstrap knowledge
5. Giao task
```

### Mỗi task sau đó

```text
Bạn: <mô tả task>

AI:
tự đọc đúng context
→ tự search/reuse
→ hỏi nếu thật sự chưa hiểu
→ code
→ test/verify
→ review
→ update knowledge
→ production check
→ báo cáo
```

Đó là trải nghiệm AI-DEV-OS hướng tới.
