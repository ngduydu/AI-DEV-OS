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
