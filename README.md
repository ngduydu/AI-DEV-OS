# AI-DEV-OS

A reusable operating system for working effectively with AI coding agents.

AI-DEV-OS giúp repository trở thành nguồn context có cấu trúc để AI có thể nhận một task, tự đọc đúng knowledge, hiểu codebase, reuse implementation hiện có, tuân convention của project, implement, verify, review, đồng bộ knowledge và đưa change tới trạng thái sẵn sàng cho human review.

> Mục tiêu không phải thay thế human review. Mục tiêu là để human tập trung review business và quyết định quan trọng, thay vì liên tục bắt lỗi agent quên context, duplicate code, thiếu test, thiếu docs hoặc bỏ sót production risk.

## Lần đầu sử dụng?

Bắt đầu tại:

```text
START-HERE.md
```

File này dẫn từ số 0: kiểm tra/cài Git, VS Code, Claude Code, toolchain của project, copy đúng AI-DEV-OS core, verify context, bootstrap và đưa repo tới trạng thái `READY / PARTIAL / BLOCKED` trước task đầu tiên.

Không cần tự mò các file khác trước.

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
START-HERE.md
↓
Check machine/toolchain
↓
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

Tài liệu theo mục đích:

- `START-HERE.md` — cửa vào cho người mới, từ cài đặt tới task đầu tiên.
- `APPLY-TO-PROJECT.md` — chi tiết bê gì sang project và bootstrap như nào.
- `USAGE.md` — mỗi ngày giao task ra sao, AI tự đọc file nào, khi nào hỏi lại.
- `CLAUDE-CODE-GUIDE.md` — cài Claude Code, dùng VS Code/CLI, Plan mode, worktree, skills/subagents và workflow khuyến nghị.

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

## Cấu trúc repository và mỗi phần dùng để làm gì

AI-DEV-OS không phải một package cài vào application. Nó là một bộ **instruction + project knowledge + reusable AI workflow** được đặt ngay trong repository để agent làm việc có context và có quy trình.

Nhìn tổng thể:

```text
.
├── START-HERE.md
├── AGENTS.md
├── CLAUDE.md
├── APPLY-TO-PROJECT.md
├── USAGE.md
├── CLAUDE-CODE-GUIDE.md
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

### Nhóm core dùng trong project

| Thành phần | Nó là gì? | Khi copy vào project thì để làm gì? |
|---|---|---|
| `.ai-dev-os/VERSION` | Version baseline của AI-DEV-OS trong product repo | Giúp biết project đang dùng framework version nào để upgrade đúng thay vì copy đè toàn bộ framework. |
| `UPGRADE.md` | Contract/migration guide của framework | Giải thích file nào được update, file nào phải preserve khi nâng AI-DEV-OS. |
| `AGENTS.md` | Entry point rule chung cho AI agent | Nói cho agent biết phải đọc documentation map nào, phải tuân workflow/gate nào và không được tự ý bỏ qua verify/reuse/clarification. Đây là file nhỏ nhưng luôn quan trọng. |
| `docs/` | Bộ nhớ lâu dài của project | Lưu những thứ AI cần hiểu về project mà không nên chỉ nằm trong chat: product, architecture, codebase map, coding convention, commands, testing, business rules, module knowledge, operations, ADR... Sau bootstrap, AI sẽ đọc/update các file này theo task. |

### Adapter dành cho Claude Code

| Thành phần | Nó là gì? | Khi copy vào project thì để làm gì? |
|---|---|---|
| `CLAUDE.md` | Entry point riêng của Claude Code | Claude Code tự đọc file này. Trong AI-DEV-OS nó chỉ dẫn sang `AGENTS.md` để tránh duplicate rule. |
| `.claude/skills/` | Các workflow tái sử dụng mà Claude Code có thể nhận diện và gọi | Cho Claude biết **cách làm một loại công việc lặp lại**, không chỉ biết “phải làm gì”. Ví dụ: `bootstrap-project`, `fix-bug`, `plan-change`, `verify-change`. |
| `.claude/agents/` | Các subagent chuyên trách | Dùng khi cần một Claude context khác làm reviewer độc lập, ví dụ review change hoặc production risk. Không bắt buộc cho task nhỏ. |

Nếu project chỉ dùng Claude Code, thường copy:

```text
.ai-dev-os/VERSION
UPGRADE.md
AGENTS.md
CLAUDE.md
docs/
.claude/skills/
.claude/agents/   # optional
```

và **không cần `.agents/skills/`**.

### Skill thực chất là gì?

Có thể hiểu đơn giản:

```text
Prompt một lần
→ chat

Knowledge của project
→ docs/

Workflow lặp đi lặp lại
→ skill
```

Một skill là một instruction/workflow được đóng gói để agent dùng lại. Ví dụ `fix-bug` có thể quy định:

```text
reproduce bug
→ tìm root cause
→ kiểm tra code hiện có
→ sửa tối thiểu
→ chạy regression verification
→ review
→ report
```

Với Claude Code, skill nằm ở:

```text
.claude/skills/<ten-skill>/SKILL.md
```

Ví dụ:

```text
.claude/skills/bootstrap-project/SKILL.md
.claude/skills/fix-bug/SKILL.md
```

AI-DEV-OS đã có một số skill dùng chung. Khi team có một procedure lặp lại riêng, bạn có thể tự viết skill mới hoặc sửa skill hiện có.

Ví dụ sau này project có quy trình đặc thù:

```text
update-stored-procedure
release-admin-package
create-database-migration
review-report-query
```

thì có thể chuẩn hóa thành skill thay vì mỗi lần lại viết một prompt dài.

Không cần biến mọi task thành skill. Chỉ tạo skill khi workflow đó **lặp lại, có quy tắc rõ và đáng tái sử dụng**.

### Adapter dành cho agent khác

| Thành phần | Nó là gì? | Khi copy vào project thì để làm gì? |
|---|---|---|
| `.agents/skills/` | Bản skill theo convention dành cho agent hỗ trợ đường dẫn này | Chỉ copy khi agent bạn dùng cần/hiểu adapter này. Nếu project chỉ dùng Claude Code thì bỏ qua. |

Mục tiêu của repo là có core knowledge chung, còn adapter nào được copy sang product repo phụ thuộc agent thực tế đang dùng.

### Các folder chủ yếu để người dùng tham khảo, không copy mặc định

| Thành phần | Tác dụng |
|---|---|
| `START-HERE.md` | Onboarding từ số 0: cài tool, chọn agent, apply framework, bootstrap. |
| `APPLY-TO-PROJECT.md` | Hướng dẫn chi tiết copy thành phần nào sang product repo và bootstrap ra sao. |
| `USAGE.md` | Hướng dẫn cách giao task hằng ngày sau khi setup. |
| `CLAUDE-CODE-GUIDE.md` | Hướng dẫn cài và vận hành Claude Code. |
| `prompts/` | Prompt thủ công cho các tình huống cần chạy bằng tay hoặc tham khảo. Không cần nếu đã dùng skill tương ứng. |
| `templates/` | Mẫu Feature Brief, Bug Brief, PR, Postmortem, Release Checklist... Chỉ copy khi team muốn áp dụng các mẫu này. |

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

Hướng dẫn cài đặt và cách dùng theo workflow đề xuất: `CLAUDE-CODE-GUIDE.md`.

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


## Context efficiency và quota

Sau bootstrap, AI-DEV-OS không coi "đọc nhiều hơn" là mặc định tốt hơn.

~~~text
CODEBASE-MAP
→ direct read nếu đã biết file
→ targeted text search
→ structural search nếu cần
→ graph/MCP nếu codebase lớn và đã bật
→ source/test thật
→ broaden/history chỉ khi evidence chưa đủ
~~~

Stack 2.2.0:

- **ripgrep** — default text search.
- **ast-grep** — optional structural search.
- **Repomix** — optional bootstrap/snapshot/handoff.
- **codebase-memory-mcp** — optional pilot cho large codebase.
- **Sourcegraph MCP** — enterprise alternative khi tổ chức đã có Sourcegraph.

Không bắt buộc cài tất cả. Tool mới phải qua `docs/ai/18-TOOL-ADOPTION.md`.

Với Claude Code:

~~~text
task độc lập hoàn tất + Knowledge Sync
→ /clear

cùng task nhưng context lớn
→ /compact
~~~

Chi tiết: `docs/ai/17-CONTEXT-RETRIEVAL.md`.

## Framework version và upgrade

Product repo từ baseline 2.2.0 có:

~~~text
.ai-dev-os/VERSION
~~~

Khi AI-DEV-OS thay đổi, không copy đè toàn bộ `docs/`.

~~~text
đọc current VERSION
→ đọc UPGRADE.md của target version
→ update framework-owned
→ preserve project-owned
→ merge mixed files
→ verify
→ bump VERSION
~~~

Repo đã apply trước 2.2.0 nhưng chưa có VERSION được coi là legacy/unversioned install và có thể nâng bằng skill `update-ai-dev-os`.

Chi tiết: `UPGRADE.md`.
