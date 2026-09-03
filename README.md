# AI-DEV-OS

A reusable operating system for working effectively with AI coding agents.

AI-DEV-OS cung cấp một bộ khung để tổ chức context, rules, workflow, documentation và reusable skills cho các công cụ như Claude Code, Codex, GitHub Copilot và các AI coding agents khác.

> Đây là **template/framework tham khảo**, không phải một bộ luật bắt buộc cho mọi dự án.

---

## Vì sao repository này tồn tại?

Khi làm việc với AI, vấn đề thường không phải là AI không biết code.

Vấn đề là AI:

- Không hiểu đầy đủ project.
- Không biết business rule.
- Không biết architecture.
- Không biết coding convention.
- Phải nghiên cứu lại codebase ở nhiều task.
- Dễ làm sai vì thiếu context.
- Đọc quá nhiều context không liên quan.
- Không giữ được kinh nghiệm từ những lần sửa trước.

AI-DEV-OS hướng tới việc biến repository thành **nguồn context có cấu trúc cho AI**.

```text
Human
  ↓
Task
  ↓
AI Agent
  ↓
AGENTS.md
  ↓
Relevant Docs / Skills
  ↓
Research
  ↓
Plan
  ↓
Implement
  ↓
Verify
```

---

## Mục tiêu

```text
Hiểu project nhanh hơn
+
Giảm việc nhắc lại context
+
Giảm AI sửa sai
+
Chuẩn hóa workflow
+
Giảm context không cần thiết
+
Tái sử dụng kinh nghiệm giữa các task
```

---

## Nguyên tắc quan trọng nhất

AI **không nên đọc toàn bộ repository documentation cho mọi task**.

```text
Không:

Task
↓
Load 50+ docs
↓
Code
```

Thay vào đó:

```text
Task
↓
Read AGENTS.md
↓
Xác định context cần thiết
↓
Read relevant docs / skills
↓
Code
```

### Context Strategy

```text
Context thường trực
→ càng nhỏ càng tốt

Knowledge trong repository
→ đủ đầy để tra cứu

Context của từng task
→ chỉ đọc những gì cần thiết
```

---

## Cấu trúc chính

```text
.
├── AGENTS.md
├── CLAUDE.md
├── .github/
│   └── copilot-instructions.md
│
├── docs/
│   ├── ai/
│   ├── decisions/
│   └── work/
│
├── .agents/
│   └── skills/
│
├── .claude/
│   └── skills/
│
├── prompts/
├── templates/
├── CONTRIBUTING.md
├── LICENSE
└── REFERENCES.md
```

---

## AGENTS.md

`AGENTS.md` là entry point chính cho AI agent.

Nó nên:

- Ngắn.
- Chỉ chứa rule quan trọng.
- Chỉ cho AI biết tài liệu nào cần đọc.
- Không chứa toàn bộ knowledge của project.

Có thể coi nó như:

```text
AI README
+
Project Map
+
Critical Rules
```

---

## docs/ai

Đây là nơi lưu knowledge thực tế của project.

Ví dụ:

```text
Product overview
Architecture
Business rules
Database
API
Coding conventions
Security
Testing
Deployment
Operations
Known pitfalls
```

AI chỉ đọc file liên quan tới task hiện tại.

---

## Skills

Workflow lặp lại nhiều lần được đóng gói thành Skill.

Ví dụ:

```text
research-codebase
plan-change
implement-plan
fix-bug
review-change
verify-change
update-project-knowledge
```

Mục tiêu là không phải viết lại cùng một prompt ở mọi task.

---

## Workflow cho task lớn

```text
Research
↓
Specification
↓
Plan
↓
Tasks
↓
Implement
↓
Verification
```

Không bắt buộc dùng full workflow cho mọi việc.

## Workflow cho task nhỏ

```text
Understand
↓
Change
↓
Verify
```

> Process phải tỷ lệ với độ phức tạp của task.

---

## Khi nào nên cập nhật knowledge?

Khi AI hoặc developer phát hiện một kiến thức có khả năng được dùng lại.

```text
Correction lặp lại
→ Project rule

Quy trình lặp lại
→ Skill

Quyết định kiến trúc
→ ADR

Bug/pitfall đặc biệt
→ Known pitfall

Business behavior
→ Business rules
```

Mục tiêu là repository ngày càng hiểu chính nó tốt hơn.

---

## Technology-agnostic

Core của AI-DEV-OS không gắn với:

```text
.NET
Java
Node.js
Python
React
Vue
Flutter
SQL Server
PostgreSQL
```

Project thực tế sẽ bổ sung rules cho stack của chính nó.

```text
AI-DEV-OS
        ↓
Project
        ↓
Technology Rules
        ↓
.NET + React + PostgreSQL
```

---

## Quick Start

### 1. Copy AI-DEV-OS vào repository

Không cần giữ tất cả file nếu project không cần.

### 2. Điền project knowledge

Bắt đầu từ các tài liệu quan trọng:

```text
Product Overview
Architecture
Business Rules
Coding Rules
Testing
Deployment
```

### 3. Chỉnh AGENTS.md

Chỉ giữ:

```text
Critical Rules
Commands
Project Map
Relevant Docs
```

### 4. Chạy task đầu tiên với AI

Ví dụ:

```text
Research luồng authentication hiện tại trước.
Sau đó đề xuất plan để thêm OAuth Google.
Không implement trước khi plan rõ.
```

### 5. Sau mỗi task quan trọng

Cập nhật những knowledge có giá trị lâu dài về repository.

---

## Không nên làm

- Không tạo `AGENTS.md` hàng nghìn dòng.
- Không duplicate documentation.
- Không lưu mọi cuộc chat.
- Không biến mọi workflow thành ceremony.
- Không ép tất cả project dùng cùng một architecture.

---

## Repository này phù hợp với ai?

- Developer dùng AI coding tools thường xuyên.
- Team muốn chuẩn hóa cách AI làm việc.
- Team muốn giảm việc AI phải nghiên cứu lại codebase.
- Người xây nhiều sản phẩm và muốn có template dùng lại.
- Project muốn lưu knowledge ngay trong repository.

---

## Project Status

AI-DEV-OS hiện nên được xem là:

```text
v1
```

Một foundation để thử nghiệm trong các project thực tế.

Nó nên tiếp tục thay đổi dựa trên usage thực tế, failure của AI, feedback của developer và những workflow thực sự lặp lại.

---

## Contributing

Contributions, issues và experiments đều được hoan nghênh.

Xem `CONTRIBUTING.md`.

---

## License

MIT License.

Bạn có thể sử dụng, sửa đổi và phân phối project theo các điều khoản của MIT License.

---

## Philosophy

> Repository không chỉ chứa source code.
>
> Với AI-assisted development, repository còn nên chứa đủ knowledge để AI có thể hiểu **tại sao hệ thống được xây như vậy và nó phải thay đổi như thế nào**.

AI-DEV-OS được xây quanh mục tiêu đó.
