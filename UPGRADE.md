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

1. preserve toàn bộ project-specific knowledge hiện có;
2. **không bootstrap lại project**;
3. tự migrate nguyên file legacy sang ordered folder bằng deterministic mapping;
4. không split/rewrite semantics bên trong knowledge cũ bằng suy đoán;
5. thêm conflict-safe knowledge policy;
6. cập nhật Task Execution / Knowledge Sync / fix-bug routing;
7. update mọi active instruction còn hướng task mới vào shared append-only files;
8. với task-generated artifact mới, dùng `entries/<entry-id>-<slug>.md` và không dùng global sequence;
9. chỉ bump VERSION sau migration + verification PASS.

Các entry cũ trong `docs/ai/13-KNOWN-PITFALLS.md`, `docs/ai/05-BUSINESS-RULES.md`, module docs và operations docs tiếp tục hợp lệ.

### Team đang có branch task chạy song song

Không cần dừng task đang chạy chỉ để migration framework.

Sau khi task hiện tại merge/working tree sạch, chạy `/update-ai-dev-os` trước task tiếp theo.

Branch đã sửa shared knowledge file trước 2.6.0 vẫn có thể gặp conflict khi merge; updater không thể xóa một conflict đã được tạo trước migration mà không đoán semantics. Từ task chạy trên 2.6.0 trở đi, discovery mới mặc định đi file riêng.

### Compatibility với repo đang chạy task

Các file cũ như `13-KNOWN-PITFALLS.md`, business rules, module/operations docs và ADR numbering cũ **không bị mất nội dung**.

Migration có thể đổi **path** của nguyên file để đưa về ordered layout, nhưng:

- dùng `git mv` để giữ rename history;
- giữ content nguyên vẹn trước bước rewrite reference;
- không split một file cũ thành nhiều file bằng suy đoán;
- không bootstrap lại project;
- không yêu cầu AI đọc lại toàn bộ codebase để tái tạo knowledge.

Repo đã apply hiện tại chỉ cần chạy `/update-ai-dev-os`; updater tự inventory, move, rewrite reference và verify.


## Docs layout versioning — từ 2.6.0

AI-DEV-OS tách **framework version** và **docs layout version**.

Source of truth:

```text
.ai-dev-os/layouts.json
```

Layout đích chuẩn:

```text
ordered-v2
→ docs/00-overview
→ docs/01-development
→ docs/02-modules
→ docs/03-knowledge
→ docs/04-operations
→ docs/05-decisions
→ docs/06-work
```

### Repo cũ được migrate thế nào?

Repo chưa có `.ai-dev-os/state.json` hoặc đang ở `legacy-v1` được `/update-ai-dev-os` tự migrate sang `ordered-v2`.

Migration **không bootstrap lại project** và không tái sinh knowledge.

Flow bắt buộc:

```text
inventory toàn bộ docs legacy
→ resolve destination bằng path_map/prefix_map
→ collision preflight
→ git mv giữ nguyên content
→ rewrite docs references
→ semantic merge framework rules
→ verify file/content preservation
→ ghi state ordered-v2
→ bump VERSION cuối cùng
```

### Bảo toàn dữ liệu

- exact canonical file dùng `path_map`;
- file project-specific không biết trước vẫn được giữ bằng `prefix_map`;
- không split nội dung bên trong file cũ bằng suy đoán;
- destination khác nội dung → STOP trước mutation, không overwrite;
- destination giống hệt → deduplicate có kiểm soát;
- content hash được kiểm tra trước/sau bước move;
- không chạy `bootstrap-project` trong upgrade.

### Branch đang chạy

Migration layout là thay đổi có chủ đích của framework. Git rename history phải được giữ bằng `git mv` để branch cũ có cơ hội merge rename-aware.

Conflict đã được tạo từ trước khi migration (ví dụ một branch đang sửa cùng shared file legacy) không thể được xóa bằng cách đoán semantics. Nhưng sau migration, task mới không còn append discovery vào shared docs nên conflict rác không tiếp tục phát sinh.


## 2.7.0 — AI engineering stack integration

Repo đang ở 2.6.x chạy bình thường:

```text
/update-ai-dev-os
```

Updater chỉ thêm/cập nhật framework-owned artifacts; **không bootstrap lại project** và không overwrite project-owned knowledge.

### Framework-owned additions

- `docs/01-development/context-compression.md`;
- `docs/01-development/sql-server-mcp.md`;
- TDD skill;
- domain-modeling skill;
- merge-conflict resolution skill;
- Claude MCP reference templates cho Headroom và SQL Server DAB;
- Simplicity Gate + review/planning hardening.

### Optional tools

Không tự cài/bật khi update:

- Headroom;
- SQL Server MCP/DAB;
- codebase-memory-mcp;
- ast-grep;
- Repomix.

Nếu muốn SQL Server MCP machine capability:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\setup-ai-dev-machine.ps1 -WithSqlServerMcp
```

Lệnh chỉ cài/verify DAB CLI. Database connection/entity/permission vẫn là project-specific và phải least-privilege.

Headroom dùng profile trong `docs/01-development/context-compression.md`; không bật proxy toàn cục mặc định.

### Compatibility

- Project knowledge/entries cũ giữ nguyên.
- Không tạo lại shared append-only knowledge.
- Skills mới không thay project-specific custom skill trùng tên bằng suy đoán; nếu target đã customize cùng managed path, updater phải review theo ownership contract trước merge.
