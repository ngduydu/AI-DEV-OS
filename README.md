# AI-DEV-OS

A reusable operating system for working effectively with AI coding agents.

AI-DEV-OS giúp repository trở thành nguồn context có cấu trúc để AI có thể nhận một task, tự đọc đúng knowledge, hiểu codebase, reuse implementation hiện có, implement, verify, review, đồng bộ knowledge và đưa change tới trạng thái sẵn sàng cho human review.

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
Plan nếu cần
↓
Implement
↓
Verify
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

## Sáu gate quan trọng

1. **Understanding Gate** — không đoán requirement quan trọng.
2. **Reuse Gate** — chưa search code cũ thì chưa tạo implementation mới.
3. **Verification Gate** — chưa có evidence thì không nói Done.
4. **Independent Review** — change vừa/lớn/risky được review bằng context mới khi đáng giá.
5. **Knowledge Sync** — knowledge mới không được chết trong chat.
6. **Production Gate** — local test pass chưa đủ để gọi production candidate.

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

## Claude Code

Claude Code dùng:

```text
CLAUDE.md
→ @AGENTS.md
→ docs/README.md
→ relevant docs/code
```

Repository có Claude Code skills cho research, planning, implementation, bug fixing, review, verification, knowledge sync và bootstrap project.

Với change cần review độc lập, có thể dùng:

```text
.claude/agents/change-reviewer.md
.claude/agents/production-reviewer.md
```

Không dùng subagent/reviewer cho mọi thay đổi nhỏ; process phải tỷ lệ với độ phức tạp và rủi ro.

## Apply vào project mới hoặc project cũ

Xem `APPLY-TO-PROJECT.md`.

Luồng mong muốn:

```text
Copy core
↓
Run bootstrap-project
↓
AI scan code/config/tests/scripts
↓
Fill minimum reliable docs từ evidence
↓
Review UNKNOWN quan trọng
↓
Giao task bình thường
↓
Knowledge giàu dần sau mỗi task
```

Không cần ngồi điền 30 file trước khi code.

## Bootstrap philosophy

```text
Confirmed by repository
→ document

Unknown nhưng không chặn
→ để thiếu cũng được

Unknown có thể làm sai behavior/data/security/architecture
→ hỏi trước khi implement
```

Không bịa docs để template trông đầy.

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
- Không để business rule quan trọng chỉ nằm trong chat.
- Không gọi change production ready chỉ vì build/test local pass.
- Không tạo Skill/module docs chỉ để có vẻ đầy đủ.

## Philosophy

> Chat là tạm thời. Repository knowledge là lâu dài.
>
> Agent càng làm nhiều task, project càng phải hiểu chính nó tốt hơn — nhưng context thường trực vẫn phải nhỏ.

## Status

AI-DEV-OS đang được phát triển theo hướng v2: task execution contract, progressive project knowledge, project bootstrap và Claude Code execution/review layer.

## Contributing

Xem `CONTRIBUTING.md`.

## License

MIT License.
