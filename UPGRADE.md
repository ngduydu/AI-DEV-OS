# Upgrade AI-DEV-OS

Tài liệu này dùng khi một product repository đã copy AI-DEV-OS trước đó và cần nhận framework changes mới mà không làm mất project knowledge.

## Nguyên tắc

Không upgrade bằng cách copy đè toàn bộ `docs/`.

Project repository chứa hai loại tài sản:

- **Framework-owned**: execution contract, context policy, generic skills/agents, adapter files và framework templates.
- **Project-owned**: project context, product, architecture decision, CODEBASE-MAP đã bootstrap, business rules, coding convention thực tế, commands, testing, module/operations docs, ADR và custom skills.
- **Mixed**: file vừa chứa framework rule vừa có project customization; phải merge bằng diff/evidence.

Source code, tests và config hiện tại vẫn là ground truth.

## Version

Project đã áp dụng framework từ 2.2.0 trở đi có:

```text
.ai-dev-os/VERSION
```

Project chưa có file này được coi là **legacy / unversioned install**.

## Upgrade legacy / unversioned → 2.2.0

1. Không chạy bootstrap full lại nếu project knowledge hiện tại vẫn đáng tin cậy.
2. Giữ nguyên project-owned knowledge.
3. Cập nhật framework-owned files từ AI-DEV-OS 2.2.0.
4. Merge cẩn thận mixed files, đặc biệt coding standards hoặc custom skill.
5. Thêm:
   - `docs/ai/17-CONTEXT-RETRIEVAL.md`
   - `docs/ai/18-TOOL-ADOPTION.md`
   - skill `update-ai-dev-os`
6. Optional tool như codebase-memory-mcp, ast-grep hoặc Repomix **không tự cài/bật**.
7. Verify path/rule quan trọng.
8. Chỉ sau khi migration thành công mới tạo/cập nhật:
   ```text
   .ai-dev-os/VERSION = 2.2.0
   ```

## Ownership quick reference

| Nhóm | Ví dụ | Upgrade |
|---|---|---|
| Framework-owned | `CLAUDE.md`, task execution, context retrieval, generic skills/agents | Update có kiểm soát |
| Project-owned | project context, CODEBASE-MAP, business rules, commands/testing, module docs | Không overwrite |
| Mixed | `AGENTS.md`, coding standards, skill team đã customize | Merge + review |

## 2.2.0

### Framework changes

- Context Budget / retrieval escalation.
- Session hygiene: `/clear`, `/compact`, subagent isolation.
- Tool Adoption Gate.
- Optional mature-tool profiles: ripgrep, ast-grep, Repomix, codebase-memory-mcp.
- Framework version marker.
- Safe upgrade workflow.

### Existing projects cần làm gì?

Recommended:

- update Task Execution Contract;
- update bootstrap skill;
- add Context Retrieval + Tool Adoption docs;
- add `update-ai-dev-os` skill;
- add version marker sau khi verify.

Optional:

- pilot codebase-memory-mcp cho codebase lớn;
- dùng ast-grep khi structural search có lợi;
- dùng Repomix cho bootstrap/snapshot.

Không bắt buộc:

- cài MCP;
- bootstrap lại toàn repo;
- thay project knowledge bằng template mới.


## 2.3.0 — Global one-repo updater

### Mục tiêu

Từ version này, không cần copy/merge thủ công từng file cho mỗi product repository.

Cài personal updater **một lần trên máy** từ AI-DEV-OS local:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\install-personal-updater.ps1
```

Sau đó restart Claude Code.

Trong bất kỳ repository đã apply AI-DEV-OS nào:

```text
/update-ai-dev-os
```

Personal skill sẽ luôn đọc canonical updater từ repository AI-DEV-OS local nên không phụ thuộc project repo đã có updater skill mới hay chưa.

### Source requirements

Canonical AI-DEV-OS source phải:

- là Git repository;
- working tree clean;
- đang ở branch `main`;
- pull được bằng `git pull --ff-only`;
- có `.ai-dev-os/VERSION`, `.ai-dev-os/manifest.json` và canonical updater skill.

Nếu source repo đã bị move sang path khác, chạy lại:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\install-personal-updater.ps1
```

### Target requirements

Updater chỉ mutate target khi:

- target là Git repository;
- working tree clean;
- nhận diện được AI-DEV-OS artifacts hiện có.

Nếu target đang ở `main` hoặc `master`, updater phải tạo/switch sang branch update riêng trước khi sửa.

### Managed file manifest

`.ai-dev-os/manifest.json` là source of truth cho **framework-managed files**.

- `framework`: được update theo canonical source.
- `mixed`: phải merge, giữ project-specific knowledge.
- file không có trong manifest: mặc định không được updater đụng.

Scopes:

- `core`: mọi project.
- `claude`: chỉ project dùng Claude adapter.
- `generic`: chỉ project đã dùng `.agents/`.

### Migration team AI policy

Một số repo cũ có:

```text
docs/ai/17-AI-USAGE-POLICY.md
```

Đây là team-specific policy và bị trùng namespace với framework 2.2+.

Updater 2.3.0 phải tự move an toàn:

```text
docs/ai/17-AI-USAGE-POLICY.md
→ docs/team/AI-USAGE-POLICY.md
```

Rule:

- giữ nguyên nội dung;
- ưu tiên `git mv`;
- update references sang path mới;
- merge route vào `docs/README.md`;
- nếu destination đã tồn tại thì không overwrite, report conflict.

### Upgrade legacy / 2.2.0 → 2.3.0

Updater phải:

1. preserve project-owned knowledge;
2. chạy migration team AI policy nếu cần;
3. apply framework-managed files từ manifest;
4. semantic merge mixed files;
5. không auto-install optional tools;
6. verify;
7. copy/update target manifest;
8. chỉ cuối cùng mới ghi:
   ```text
   .ai-dev-os/VERSION = 2.3.0
   ```

Nếu có conflict có nguy cơ làm mất project rule, **không bump VERSION**.


## 2.4.0 — Machine tooling setup

2.4.0 bổ sung setup tool dùng chung cho máy developer.

Chạy từ repository AI-DEV-OS local:

~~~powershell
powershell -ExecutionPolicy Bypass -File .\tools\setup-ai-dev-machine.ps1
~~~

Đây là **machine setup**, không phải product-repo migration.

Vì vậy:

- `/update-ai-dev-os` vẫn nâng framework docs/skills trong product repo;
- `setup-ai-dev-machine.ps1` chỉ chạy một lần trên từng máy developer;
- script không được copy vào product repo;
- script không sửa project `.mcp.json`;
- codebase-memory-mcp được đăng ký Claude MCP ở user scope;
- CodeGraph không được cài trong 2.4.0 do overlap.

Product repo đã lên 2.3.0 có thể chạy `/update-ai-dev-os` bình thường để nhận framework 2.4.0. Machine setup có thể chạy riêng trước hoặc sau, không cần chạy lại updater chỉ vì cài tool.


## 2.6.0 — Conflict-safe Knowledge Sync

### Mục tiêu

Giảm conflict khi nhiều task/branch song song cùng Knowledge Sync.

Từ 2.6.0:

~~~text
task discovery
→ mặc định tạo file riêng trong docs/knowledge/

shared canonical docs
→ chỉ sửa khi canonical truth thực sự thay đổi
~~~

### Migration cho project đã dùng 2.5.x hoặc cũ hơn

Chạy:

~~~text
/update-ai-dev-os
~~~

Updater phải:

1. thêm `docs/knowledge/README.md`;
2. cập nhật Task Execution / Knowledge Sync skills;
3. cập nhật routing trong docs framework;
4. preserve project-specific knowledge hiện có;
5. **không di chuyển hoặc tách knowledge cũ tự động**;
6. không tự tạo hàng loạt file knowledge từ nội dung cũ;
7. chỉ bump VERSION sau verification;
8. update các active skill/routing docs còn hướng task mới vào shared append-only files;
9. với task-generated artifact mới, dùng `entries/<entry-id>-<slug>.md` và không dùng global sequence.

Các entry cũ trong `docs/ai/13-KNOWN-PITFALLS.md`, `docs/ai/05-BUSINESS-RULES.md`, module docs và operations docs tiếp tục hợp lệ.

### Team đang có branch task chạy song song

Không cần dừng task đang chạy chỉ để migration framework.

Sau khi task hiện tại merge/working tree sạch, chạy `/update-ai-dev-os` trước task tiếp theo.

Branch đã sửa shared knowledge file trước 2.6.0 vẫn có thể gặp conflict khi merge; updater không thể xóa một conflict đã được tạo trước migration mà không đoán semantics. Từ task chạy trên 2.6.0 trở đi, discovery mới mặc định đi file riêng.

### Compatibility với repo đang chạy task

Updater **không auto-move/rename/xóa** knowledge cũ và không rewrite project-owned entries.

Các file cũ như `13-KNOWN-PITFALLS.md`, business rules, module/operations docs, ADR numbering cũ vẫn tiếp tục được đọc.

Migration chỉ:
- thêm policy/routing mới;
- cập nhật framework-owned skill/contract;
- semantic-merge mixed routing docs và preserve project content;
- tạo `entries/` on demand khi task mới thực sự cần ghi knowledge.

Vì vậy repo đã apply hiện tại không cần sửa tay từng file knowledge trước khi chạy `/update-ai-dev-os`.


## Docs layout versioning — từ 2.6.0

AI-DEV-OS tách **framework version** và **docs layout version**.

Source of truth:

```text
.ai-dev-os/layouts.json
```

Có hai layout:

```text
legacy-v1
→ repo đã apply trước 2.6.0
→ giữ nguyên docs/ai, docs/modules, docs/operations, docs/decisions, docs/work

ordered-v2
→ repo apply mới
→ docs/00-overview
→ docs/01-development
→ docs/02-modules
→ docs/03-knowledge
→ docs/04-operations
→ docs/05-decisions
→ docs/06-work
```

### Rule bắt buộc của /update-ai-dev-os

`/update-ai-dev-os` **không được tự đổi docs layout**.

Repo cũ chưa có `.ai-dev-os/state.json` được nhận diện là `legacy-v1`.

Sau update thành công, updater có thể tạo state marker:

```json
{
  "docs_layout": "legacy-v1",
  "docs_layout_version": 1
}
```

nhưng không move/rename project docs.

Repo `ordered-v2` phải tiếp tục update vào ordered path hiện tại thông qua mapping trong `layouts.json`.

### Vì sao không auto-migrate repo cũ sang ordered-v2?

Vì team có thể đang có branch task song song tham chiếu path cũ. Tự move hàng loạt docs trong `/update-ai-dev-os` sẽ tạo:

- diff lớn không liên quan task;
- rename/delete conflict với branch đang chạy;
- broken reference trong task branch cũ;
- khó review và khó rollback.

Nếu sau này muốn đổi một repo cũ sang `ordered-v2`, đó phải là migration riêng có chủ đích, không nằm trong updater framework thông thường.
