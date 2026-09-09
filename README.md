# AI-DEV-OS

A reusable operating system for working effectively with AI coding agents.

AI-DEV-OS giúp repository trở thành nguồn context có cấu trúc để AI có thể nhận một task, tự đọc đúng knowledge, hiểu codebase, reuse implementation hiện có, tuân convention của project, implement, verify, review, đồng bộ knowledge và đưa change tới trạng thái sẵn sàng cho human review.

> Mục tiêu không phải thay thế human review. Mục tiêu là để human tập trung review business và quyết định quan trọng, thay vì liên tục bắt lỗi agent quên context, duplicate code, thiếu test, thiếu docs hoặc bỏ sót production risk.

## Core workflow

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
Dependency Gate
↓
Plan nếu cần
↓
Implement
↓
Verify
↓
Cleanup
↓
Independent Review nếu phù hợp
↓
Knowledge Sync
↓
Production Gate
↓
Human Review
```

Workflow chi tiết: `docs/ai/16-TASK-EXECUTION.md`.

## Apply nhanh vào project

### Project đã có code

```text
Copy AI-DEV-OS core
↓
Run bootstrap-project
↓
AI scan docs/config/tooling/CI/code/tests
↓
Fill minimum reliable project knowledge
↓
Find canonical examples + reusable building blocks
↓
Resolve material UNKNOWN
↓
Bootstrap status: READY
↓
Giao task bình thường
```

### Project mới

Chỉ điền những gì đã biết chắc: project context, product intent, architecture đã chốt và coding convention ban đầu. Codebase map, commands, testing, module docs và operations docs được bổ sung dần khi project hình thành.

Chi tiết:

- `APPLY-TO-PROJECT.md` — bê gì sang project và bootstrap như nào.
- `USAGE.md` — mỗi ngày giao task ra sao, AI tự đọc file nào, khi nào hỏi lại.

## Sau khi setup, có phải nhắc AI đọc docs mỗi task không?

**Không.**

Với Claude Code, flow mặc định là:

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
AI tự load docs/module/code/test liên quan
```

Bạn không cần lặp lại prompt kiểu "đọc architecture, đọc coding standard, search code cũ, chạy test, update docs" ở mỗi task. Những việc đó là trách nhiệm của framework.

## Các gate quan trọng

1. **Understanding Gate** — không đoán requirement quan trọng.
2. **Reuse Gate** — chưa search code cũ/canonical implementation thì chưa tạo mới.
3. **Dependency Gate** — không thêm package/library khi project đã có giải pháp phù hợp.
4. **Verification Gate** — chưa có evidence thì không nói Done.
5. **Cleanup Gate** — không để dead code, debug artifact, stale TODO/comment do task tạo ra.
6. **Independent Review** — change vừa/lớn/risky được review bằng context mới khi đáng giá.
7. **Knowledge Sync** — knowledge mới không được chết trong chat.
8. **Production Gate** — local test pass chưa đủ để gọi production candidate.

## Context strategy

```text
Always-on context
→ càng nhỏ càng tốt

Knowledge trong repository
→ đủ đầy, đúng và dễ tìm

Context của từng task
→ chỉ nạp những gì liên quan
```

`AGENTS.md` chỉ là entry point ngắn. `CLAUDE.md` chỉ import `AGENTS.md`. Tài liệu chi tiết nằm trong `docs/`, workflow lặp lại nằm trong Skills.

## Cấu trúc chính

```text
.
├── AGENTS.md
├── CLAUDE.md
├── APPLY-TO-PROJECT.md
├── USAGE.md
│
├── docs/
│   ├── README.md
│   ├── ai/
│   ├── modules/
│   ├── operations/
│   ├── decisions/
│   └── work/
│
├── .claude/
│   ├── skills/
│   └── agents/
│
├── .agents/
│   └── skills/
│
├── prompts/
└── templates/
```

## Project knowledge

`docs/README.md` là documentation map. Agent không cần đọc toàn bộ docs cho mọi task.

Knowledge được phân loại:

```text
Project-wide knowledge   → docs/ai/
Module/domain knowledge  → docs/modules/<module>/
Operations knowledge     → docs/operations/
Architecture decisions   → docs/decisions/
Task-only context         → docs/work/
Recurring procedure      → Skill
```

Module và operations docs được tạo **on demand**, không scaffold hàng loạt file rỗng.

## Coding convention và reuse

Hai file quan trọng nhất khi tạo/sửa code:

```text
docs/ai/04-CODEBASE-MAP.md
→ canonical examples + reusable building blocks

docs/ai/06-CODING-STANDARDS.md
→ naming, structure, error, validation, logging, async, DB, API/data format, dependency policy, comments, tool enforcement
```

Convention project-specific phải được bootstrap/fill từ evidence thật của project, không copy mù từ một stack/project khác.

## Claude Code

Claude Code dùng:

```text
CLAUDE.md
→ @AGENTS.md
→ docs/README.md
→ relevant docs/code
```

Repository có Claude Code skills cho research, planning, implementation, bug fixing, review, verification, knowledge sync và bootstrap project.

Với change cần review độc lập:

```text
.claude/agents/change-reviewer.md
.claude/agents/production-reviewer.md
```

Không dùng subagent/reviewer cho mọi thay đổi nhỏ; process phải tỷ lệ với độ phức tạp và rủi ro.

## Bootstrap philosophy

```text
Confirmed by repository
→ document

Unknown nhưng không chặn
→ để thiếu cũng được

Unknown có thể làm sai behavior/data/security/architecture
→ hỏi trước khi implement
```

Bootstrap kết thúc bằng `READY / PARTIAL / BLOCKED`, không dựa trên số file đã điền.

## Task size

### Small

```text
Understand → Inspect → Change → Verify → Sync → Report
```

### Medium

```text
Understand → Research vừa đủ → Plan → Implement → Verify → Review → Sync
```

### Large / Risky

```text
Research → Spec → Plan → Tasks → Implement → Verify → Independent Review → Production Gate
```

## AI Development principle

```text
AI tạo
→ Tool kiểm tra
→ AI review khi phù hợp
→ Human review
→ CI/deploy process
```

Không phải:

```text
AI generate → merge → production
```

## Technology agnostic

Core không ép project dùng .NET, Java, Node.js, Python, React, Vue, SQL Server hay PostgreSQL.

Stack-specific convention nên được sinh ra từ project thật. Reusable stack pack chỉ nên được tách ra sau khi có đủ repetition thực tế.

## Những điều không nên làm

- Không biến `AGENTS.md` hoặc `CLAUDE.md` thành wiki hàng nghìn dòng.
- Không đọc mọi docs cho mọi task.
- Không duplicate cùng một rule ở nhiều nơi.
- Không tạo abstraction mới trước khi search implementation hiện có.
- Không thêm dependency chỉ vì agent quen dùng nó.
- Không để business rule quan trọng chỉ nằm trong chat.
- Không gọi change production ready chỉ vì build/test local pass.
- Không tạo Skill/module docs chỉ để có vẻ đầy đủ.

## Philosophy

> Chat là tạm thời. Repository knowledge là lâu dài.
>
> Agent càng làm nhiều task, project càng phải hiểu chính nó tốt hơn — nhưng context thường trực vẫn phải nhỏ.

## Status

AI-DEV-OS đang được phát triển theo hướng v2: task execution contract, progressive project knowledge, project bootstrap, project-specific conventions, canonical reuse map và Claude Code execution/review layer.

## Contributing

Xem `CONTRIBUTING.md`.

## License

MIT License.
