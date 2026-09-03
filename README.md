# AI Development OS

Bộ khung làm việc với AI Coding Agent dùng cho một repository phần mềm.

Mục tiêu của bộ này không phải là nhét thật nhiều prompt vào dự án. Mục tiêu là tạo **hệ thống context có cấu trúc** để AI:

- hiểu sản phẩm trước khi sửa code;
- biết kiến trúc, business rule và convention;
- nghiên cứu trước khi thay đổi phần chưa hiểu;
- lập kế hoạch cho việc phức tạp;
- triển khai theo phạm vi đã thống nhất;
- tự kiểm tra bằng test/build/lint thay vì chỉ nói "đã xong";
- lưu lại kiến thức quan trọng cho lần làm việc sau;
- dùng được với nhiều AI coding tool mà không phải viết lại toàn bộ hướng dẫn.

---

## 1. Cấu trúc

```text
.
├── AGENTS.md                         # Bản đồ chính cho AI coding agent
├── CLAUDE.md                         # Adapter cho Claude Code
├── .github/
│   └── copilot-instructions.md       # Adapter cho GitHub Copilot
│
├── .agents/skills/                   # Repo skills cho Codex / Agent Skills
├── .claude/skills/                   # Cùng skills cho Claude Code
│
├── docs/
│   ├── ai/                           # Kiến thức bền vững của dự án
│   ├── decisions/                    # ADR - quyết định kiến trúc
│   └── work/                         # Research/spec/plan của từng việc
│
├── templates/                        # Mẫu artifact cho feature/bug/release
├── prompts/                          # Prompt thủ công khi không dùng Skills
└── REFERENCES.md                     # Nguồn nghiên cứu của bộ khung
```

---

## 2. Triết lý chính

### 2.1. AGENTS.md là bản đồ, không phải bách khoa toàn thư

`AGENTS.md` chỉ chứa những điều AI phải biết gần như mọi lúc và các đường dẫn đến tài liệu chi tiết.

Không đưa vào đó:

- toàn bộ architecture;
- tất cả business rule;
- mô tả từng file;
- tài liệu API dài;
- checklist dài hàng trăm dòng.

Những nội dung đó nằm trong `docs/` và AI chỉ đọc khi cần.

### 2.2. Phân biệt 4 loại kiến thức

| Loại | Đặt ở đâu | Ví dụ |
|---|---|---|
| Luật luôn áp dụng | `AGENTS.md` | phải test, không sửa ngoài scope |
| Kiến thức dự án | `docs/ai/` | architecture, business rule |
| Quyết định kỹ thuật | `docs/decisions/` | tại sao dùng PostgreSQL |
| Quy trình lặp lại | `SKILL.md` | research, review, fix bug |

### 2.3. Không dùng cùng một mức quy trình cho mọi task

**Task nhỏ**: hiểu → sửa → verify.

**Task vừa**: brief → plan → implement → verify.

**Task lớn/rủi ro cao**: research → spec → plan → tasks → implement → verification.

Không biến sửa typo thành dự án nghiên cứu. Cũng không xử lý thay đổi kiến trúc bằng một prompt hai dòng.

---

## 3. Thiết lập cho dự án mới

Không cần điền tất cả file ngay lập tức. Làm theo thứ tự:

1. `docs/ai/01-PROJECT-CONTEXT.md`
2. `docs/ai/02-PRODUCT.md`
3. `docs/ai/03-ARCHITECTURE.md`
4. `docs/ai/04-CODEBASE-MAP.md`
5. `docs/ai/05-BUSINESS-RULES.md`
6. `docs/ai/06-CODING-STANDARDS.md`
7. `docs/ai/07-COMMANDS.md`
8. `docs/ai/08-TESTING.md`
9. `docs/ai/09-SECURITY.md`

Sau đó cập nhật dần khi dự án phát triển.

> Không để nội dung giả trong file. Nếu chưa biết, ghi rõ `Chưa xác định` thay vì cho AI một thông tin suy đoán.

---

## 4. Cách dùng hàng ngày

### Feature nhỏ

```text
Yêu cầu
→ AI đọc AGENTS.md + file liên quan
→ sửa code
→ chạy kiểm tra phù hợp
→ báo thay đổi + bằng chứng verify
```

### Feature vừa/lớn

Tạo thư mục:

```text
docs/work/YYYY-MM-DD-ten-cong-viec/
```

Sau đó dùng:

```text
RESEARCH.md
→ SPEC.md
→ PLAN.md
→ TASKS.md
→ code
→ VERIFICATION.md
```

Không phải task nào cũng cần đủ năm file. `docs/work/README.md` có quy tắc chọn mức quy trình.

---

## 5. Khi nào cập nhật hệ thống AI

Khi AI mắc cùng một lỗi từ lần thứ hai, đừng chỉ nhắc lại trong chat.

Đưa kiến thức đó về đúng nơi:

```text
Thông tin luôn đúng cho cả repo
→ AGENTS.md hoặc docs/ai

Quy tắc chỉ cho một khu vực
→ tài liệu/rule gần khu vực đó

Quyết định kiến trúc
→ ADR

Quy trình nhiều bước hay lặp lại
→ Skill

Lỗi/gotcha khó phát hiện
→ KNOWN-PITFALLS.md
```

Xem `docs/ai/14-AI-SYSTEM-MAINTENANCE.md`.

---

## 6. Dùng với từng AI

### Codex

- Đọc `AGENTS.md` ở root.
- Skills dùng bản trong `.agents/skills/`.
- Với task phức tạp có thể gọi rõ skill, ví dụ `$research-codebase` hoặc `$plan-change` nếu client đang dùng hỗ trợ cú pháp này.

### Claude Code

- `CLAUDE.md` import `AGENTS.md`, tránh duy trì hai bộ luật khác nhau.
- Skills nằm ở `.claude/skills/`.

### GitHub Copilot

- Luật repository nằm ở `.github/copilot-instructions.md`.
- File này cố ý ngắn và dẫn Copilot đến cùng nguồn kiến thức trong `docs/ai/`.

### Cursor

- Cursor hỗ trợ `AGENTS.md` trực tiếp.
- Chỉ thêm `.cursor/rules` sau khi dự án thực sự có rule theo path/framework cần tự động áp dụng.

---

## 7. Nguyên tắc quan trọng nhất

```text
Chat là tạm thời.
Repository knowledge là lâu dài.

Prompt dùng một lần → chat.
Prompt dùng lặp lại → skill/template.
Thông tin dự án → docs.
Quyết định quan trọng → ADR.
Bằng chứng hoàn thành → test/build/verification.
```
