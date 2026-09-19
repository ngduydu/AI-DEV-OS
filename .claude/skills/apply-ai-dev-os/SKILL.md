---
name: apply-ai-dev-os
description: Use when the current repository does not yet contain AI-DEV-OS and should be initialized from the canonical local AI-DEV-OS source without manual file copying. Supports Claude, generic, or both agent adapters.
disable-model-invocation: true
---

# Apply AI-DEV-OS

Mục tiêu: apply AI-DEV-OS vào repository hiện tại bằng một lệnh, với cấu trúc docs có thứ tự rõ ràng và không mặc định sai agent.

Mọi phản hồi cho người dùng phải bằng tiếng Việt.

## 1. Chọn agent profile

Nếu user chưa nói rõ agent profile trong cùng yêu cầu, hỏi đúng một lần:

```text
Chọn agent profile để apply:

1. claude  - Claude Code
2. generic - agent dùng AGENTS.md + .agents/skills
3. both    - dùng cả Claude Code và generic agent
```

Giá trị hợp lệ:

- `claude`
- `generic`
- `both`

Không tự suy đoán agent. **Không được mặc định agent**.

## 2. Source

Personal launcher phải cung cấp absolute path của canonical AI-DEV-OS source.

Nếu không có source path hợp lệ: dừng và yêu cầu chạy lại machine setup từ AI-DEV-OS.

## 3. Preflight source

Trước khi sửa target:

1. Source phải là Git repository.
2. Source phải đang ở branch `main`.
3. Source working tree phải clean.
4. Chạy `git -C <source> pull --ff-only`.
5. Đọc:
   - `.ai-dev-os/VERSION`
   - `.ai-dev-os/manifest.json`
   - `.ai-dev-os/layouts.json`
6. Source version/manifest/layout schema phải hợp lệ.
7. Nếu source preflight fail: dừng, không sửa target.

## 4. Preflight target

1. Current working directory phải là Git repository.
2. Target không được là chính AI-DEV-OS source.
3. Target working tree phải clean.
4. Nếu target đã có `.ai-dev-os/VERSION`: dừng và bảo dùng `/update-ai-dev-os`.
5. Nếu target đã có AI-DEV-OS artifacts đáng kể: coi là legacy/partial install, dừng và bảo dùng `/update-ai-dev-os`.
6. Xác định **target base branch**:
   - ưu tiên `git symbolic-ref --short refs/remotes/origin/HEAD` và bỏ prefix `origin/`;
   - nếu remote HEAD chưa được set, fallback `main`, rồi `master` nếu branch đó tồn tại;
   - nếu vẫn không xác định được: STOP trước mutation.
7. Apply phải chạy trên branch riêng:
   - nếu current branch = target base branch, tạo:
     `<git-user-slug>/apply-ai-dev-os-<version>`
     fallback: `ai-dev-os/apply-<version>`;
   - nếu current branch đã đúng pattern apply cho version này thì tiếp tục;
   - nếu current branch là feature/task branch khác: **STOP trước mutation** và yêu cầu chạy lại từ target base branch.
8. Nếu branch apply đích đã tồn tại nhưng HEAD khác HEAD của target base branch: STOP, không reuse branch cũ bằng suy đoán.

Không tự commit/push/merge.

## 5. Docs layout mặc định cho repo apply mới

Repo apply mới dùng layout:

```text
docs/
├── 00-overview/
│   ├── project-context.md
│   ├── product.md
│   ├── architecture.md
│   ├── codebase-map.md
│   └── glossary.md
│
├── 01-development/
│   ├── setup-checklist.md
│   ├── coding-standards.md
│   ├── commands.md
│   ├── testing.md
│   ├── security.md
│   ├── git-workflow.md
│   ├── definition-of-ready.md
│   ├── definition-of-done.md
│   ├── documentation-governance.md
│   ├── ai-development.md
│   ├── context-retrieval.md
│   ├── context-compression.md
│   ├── sql-server-mcp.md
│   └── tool-adoption.md
│
├── 02-modules/
├── 03-knowledge/
├── 04-operations/
├── 05-decisions/
└── 06-work/
```

Tên folder có prefix số để:

- nhìn tree biết ngay thứ tự đọc;
- nhóm tài liệu theo purpose;
- tránh folder ngang hàng lộn xộn;
- giữ cấu trúc ổn định khi project lớn dần.

Không tự nghĩ tên/path khác. Source of truth là `.ai-dev-os/layouts.json`, layout `ordered-v2`.

## 6. Copy canonical ordered layout

Canonical source **đã dùng trực tiếp `ordered-v2`**.

Không render từ `docs/ai/` sang folder khác khi apply.

Copy đúng canonical paths từ source:

```text
docs/00-overview/
docs/01-development/
docs/02-modules/
docs/03-knowledge/
docs/04-operations/
docs/05-decisions/
docs/06-work/
```

`.ai-dev-os/layouts.json` chỉ còn dùng để migrate repository cũ khi chạy `/update-ai-dev-os`.

Không tạo lại legacy folders như `docs/ai/`, `docs/modules/`, `docs/knowledge/`, `docs/operations/`, `docs/decisions/`, `docs/work/`.

## 7. Core luôn apply

Mọi profile đều copy/render:

- `.ai-dev-os/VERSION`
- `.ai-dev-os/manifest.json`
- `.ai-dev-os/layouts.json`
- `UPGRADE.md`
- `AGENTS.md`
- `docs/README.md`

Project docs copy trực tiếp từ canonical ordered source:

- toàn bộ `docs/00-overview/`;
- toàn bộ `docs/01-development/`;
- `docs/02-modules/README.md`;
- `docs/03-knowledge/README.md`;
- `docs/03-knowledge/business-rules.md`;
- `docs/03-knowledge/known-pitfalls.md`;
- `docs/04-operations/README.md`;
- `docs/05-decisions/README.md`;
- `docs/05-decisions/ADR-TEMPLATE.md`;
- `docs/06-work/README.md`;
- toàn bộ `docs/06-work/_template/*.md`.

Không copy:

- `docs/superpowers/`
- `START-HERE.md`
- `APPLY-TO-PROJECT.md`
- `USAGE.md`
- `CLAUDE-CODE-GUIDE.md`
- `CHANGELOG.md`
- `FILE-INDEX.md`
- `LICENSE`
- repo issue/PR metadata
- `prompts/`
- `templates/` nói chung (trừ hai MCP reference template được allowlist ở Claude profile)
- machine setup scripts

## 8. Target state

Sau khi render core thành công, tạo:

```json
{
  "docs_layout": "ordered-v2",
  "docs_layout_version": 2
}
```

tại:

```text
.ai-dev-os/state.json
```

Đây là target-specific state.

Không lấy `state.json` từ source.
Không thêm project-specific state vào canonical manifest.

## 9. Adapter theo agent profile

### claude

Copy thêm:

- `CLAUDE.md`
- toàn bộ `.claude/skills/` trừ `.claude/skills/apply-ai-dev-os/`
- toàn bộ `.claude/agents/`
- `templates/mcp/claude-headroom.json`
- `templates/mcp/claude-sql-server-dab.json`

Không copy `.agents/skills/`.

### generic

Copy thêm toàn bộ `.agents/skills/`.

Không copy:

- `CLAUDE.md`
- `.claude/skills/`
- `.claude/agents/`

### both

Copy cả Claude adapter và generic adapter, nhưng bootstrap chỉ chạy một lần.

## 10. Collision rule

`/apply-ai-dev-os` chỉ dùng cho repo chưa apply framework.

Nếu mapped destination quan trọng đã tồn tại với nội dung khác source/rendered content, dừng và báo collision thay vì overwrite.

Không tự xóa project docs hiện hữu.

## 11. Bootstrap ngay sau apply

Sau khi copy thành công, chạy bootstrap một lần theo profile.

Bootstrap phải làm việc trực tiếp với canonical ordered paths.

Bootstrap phải:

1. scan code/config/tests thật;
2. cập nhật minimum reliable project knowledge;
3. không tạo knowledge giả chỉ để fill template;
4. knowledge phát hiện theo conflict-safe entry-per-file;
5. kết thúc bằng `READY / PARTIAL / BLOCKED`.

## 12. Verification

Trước khi báo xong, verify:

- `.ai-dev-os/VERSION` khớp source;
- `.ai-dev-os/state.json` = `ordered-v2 / 2`;
- có đủ ordered roots:
  - `docs/00-overview/`
  - `docs/01-development/`
  - `docs/02-modules/`
  - `docs/03-knowledge/`
  - `docs/04-operations/`
  - `docs/05-decisions/`
  - `docs/06-work/`;
- không còn project scaffold duplicate dưới `docs/ai/`, `docs/modules/`, `docs/knowledge/`, `docs/operations/`, `docs/decisions/`, `docs/work/`;
- rendered docs/skills không còn broken reference về legacy path;
- không copy `docs/superpowers/` hoặc machine setup scripts;
- bootstrap đã chạy hoặc báo rõ blocker;
- chỉ có expected diff.

## 13. Báo cáo cuối

```text
AI-DEV-OS:
- Applied version: <version>
- Agent profile: claude / generic / both
- Docs layout: ordered-v2

Branch:
- <branch>

Bootstrap:
- READY / PARTIAL / BLOCKED

Next:
- giao task bình thường
```
