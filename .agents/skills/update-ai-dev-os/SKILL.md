---
name: update-ai-dev-os
description: Use when a repository already contains AI-DEV-OS files and needs to upgrade from the canonical local AI-DEV-OS source without manually copying or merging framework files.
---

# Update AI-DEV-OS

## Ngôn ngữ phản hồi

Mọi phản hồi, báo cáo, cảnh báo, câu hỏi và kết quả cuối cùng gửi cho người dùng phải bằng **tiếng Việt**.

Có thể giữ nguyên tên file, command, path, Git branch, technical identifier hoặc error message gốc khi cần chính xác, nhưng phần giải thích cho người dùng phải bằng tiếng Việt.

Mục tiêu: nâng repository hiện tại lên AI-DEV-OS mới nhất từ canonical local source, preserve project knowledge và chỉ bump version sau verification.

## Source of truth

Nếu skill này được gọi qua personal launcher, launcher phải cung cấp absolute AI-DEV-OS source path.

Nếu không có launcher-provided source path:

1. dùng biến môi trường `AI_DEV_OS_HOME` nếu tồn tại;
2. nếu current repository chính là AI-DEV-OS source thì dùng repo root;
3. nếu vẫn không xác định được thì dừng và yêu cầu chạy installer từ AI-DEV-OS source:
   `tools/install-personal-updater.ps1`.

Không lấy project-level updater skill cũ làm canonical source khi personal launcher đã cung cấp source path.

## Phase 1 — Source preflight

Trước khi sửa TARGET:

1. Resolve source root.
2. Xác nhận source là Git repository.
3. Đọc:
   - `.ai-dev-os/VERSION`
   - `.ai-dev-os/manifest.json`
   - `.ai-dev-os/layouts.json`
   - `UPGRADE.md`
4. Xác nhận source working tree clean.
5. Xác nhận source branch là `main`.
6. Chạy:
   ```text
   git -C <source> pull --ff-only
   ```
7. Đọc lại VERSION + manifest sau pull.
8. Xác nhận `manifest.framework_version == VERSION`.
9. Xác nhận `layouts.json` có ít nhất `legacy-v1` và `ordered-v2`.

Nếu bất kỳ check nào fail: STOP trước target mutation.

## Phase 2 — Target preflight

TARGET là repository đang mở/current working repository.

Trước mutation:

1. Xác nhận target là Git repository.
2. Xác nhận target không phải source repository.
3. Xác nhận target working tree clean.
4. Detect current target version:
   - có `.ai-dev-os/VERSION` → đọc version;
   - không có → `legacy-unversioned`.
5. Xác nhận target thực sự là repository đã apply AI-DEV-OS:
   - nếu có `.ai-dev-os/VERSION` hoặc `.ai-dev-os/manifest.json` → recognized;
   - nếu là legacy/unversioned → phải có **ít nhất 2** high-confidence artifacts trong:
     - `UPGRADE.md`;
     - `docs/01-development/ai-development.md`;
     - `docs/ai/16-TASK-EXECUTION.md` (legacy);
     - `.claude/skills/bootstrap-project/SKILL.md`;
     - `.agents/skills/bootstrap-project/SKILL.md`.
   - `AGENTS.md` hoặc `CLAUDE.md` **không đủ** để nhận diện vì nhiều repository không dùng AI-DEV-OS cũng có các file này.
   - nếu không đạt điều kiện → STOP trước mutation và bảo dùng `/apply-ai-dev-os` nếu đây là repo mới.
6. Detect adapters:
   - Claude active nếu target có `CLAUDE.md` hoặc `.claude/`;
   - generic active nếu target có `.agents/`.
7. Detect target docs layout:
   - có `.ai-dev-os/state.json` → đọc `docs_layout`;
   - không có state → coi là `legacy-v1`.
8. Validate layout tồn tại trong source `.ai-dev-os/layouts.json`.
9. Nếu target = `legacy-v1` và source có `ordered-v2`, **lập migration plan sang ordered-v2**. Không bootstrap lại project.

Nếu target version bằng source version nhưng layout còn legacy, vẫn phải chạy layout migration.

## Phase 3 — Dedicated update branch

Không được chạy framework migration trực tiếp trên branch task đang phát triển.

1. đọc current branch;
2. xác định **target base branch**:
   - ưu tiên `git symbolic-ref --short refs/remotes/origin/HEAD` và bỏ prefix `origin/`;
   - nếu remote HEAD chưa được set, fallback `main`, rồi `master` nếu branch đó tồn tại;
   - nếu vẫn không xác định được: STOP trước mutation, không đoán default branch;
3. nếu current branch = target base branch:
   - lấy `git config user.name`;
   - chuyển thành slug lowercase, ký tự không hợp lệ → `-`;
   - branch đích: `<slug>/update-ai-dev-os-<source-version>`;
   - fallback: `ai-dev-os/update-<source-version>`;
   - nếu branch đích chưa tồn tại: tạo từ đúng HEAD hiện tại rồi switch;
   - nếu branch đích đã tồn tại nhưng HEAD của nó khác HEAD base hiện tại: STOP, không reuse branch cũ bằng suy đoán;
   - nếu branch đích đã tồn tại và cùng HEAD: switch;
4. nếu current branch đã đúng pattern update cho `<source-version>`: tiếp tục;
5. nếu current branch là bất kỳ feature/task branch nào khác: **STOP trước mutation** và yêu cầu chạy lại từ target base branch.

Mục tiêu: framework update luôn nằm trên branch riêng, không trộn rename/migration vào task đang chạy của thành viên và không hard-code repository phải dùng `main`/`master`.

Không commit/merge/push tự động trừ khi user yêu cầu.

## Phase 4 — Special migrations

Chạy migration theo `UPGRADE.md` cho mọi version từ current → source.

### Team AI policy namespace

Nếu tồn tại:

`docs/ai/17-AI-USAGE-POLICY.md`

và chưa tồn tại:

`docs/team/AI-USAGE-POLICY.md`

thì:

1. tạo `docs/team/` nếu cần;
2. dùng `git mv` để move file;
3. giữ nguyên nội dung;
4. search toàn repo các reference path cũ;
5. update sang `docs/team/AI-USAGE-POLICY.md`;
6. đảm bảo `docs/README.md` có route team policy.

Nếu cả source và destination đều tồn tại: STOP migration đó và report conflict; không overwrite.

### Conflict-safe knowledge + ordered layout migration — 2.6.0

Khi source version >= `2.6.0`:

1. preserve toàn bộ project-specific content hiện có;
2. **không bootstrap lại project**;
3. chuyển legacy docs sang `ordered-v2` bằng deterministic path mapping trong `.ai-dev-os/layouts.json`;
4. exact canonical files dùng `path_map`;
5. file legacy chưa biết trước nhưng nằm dưới root đã biết dùng `prefix_map`, giữ nguyên relative filename/subfolder;
6. không split nội dung bên trong một file cũ bằng suy đoán;
7. cập nhật conflict-safe Knowledge Sync policy;
8. từ sau migration, task discovery mới dùng entry-per-file;
9. update mọi active skill/routing còn hướng append vào shared docs;
10. verify không mất file, không mất content, không có duplicate legacy/ordered scaffold.

Ví dụ:

```text
docs/ai/03-ARCHITECTURE.md
→ docs/00-overview/architecture.md

docs/ai/custom-project-note.md
→ docs/01-development/project/custom-project-note.md

docs/modules/sales/*
→ docs/02-modules/sales/*

docs/operations/*
→ docs/04-operations/*

docs/decisions/*
→ docs/05-decisions/*
```

Không được dùng bootstrap để tái tạo knowledge vì sẽ tốn token và có nguy cơ khác nội dung cũ.


## Phase 4.5 — Legacy → ordered-v2 migration

Chỉ chạy khi target layout = `legacy-v1`.

### A. Dùng deterministic migrator, không đọc/viết tay từng file

Ưu tiên chạy script từ canonical SOURCE:

```powershell
powershell -ExecutionPolicy Bypass -File <source>/tools/migrate-docs-layout.ps1 -TargetRoot <target>
```

Dry-run này tự:

- inventory toàn bộ legacy docs;
- resolve destination bằng exact `path_map` rồi longest `prefix_map`;
- hash từng file;
- phát hiện collision trước mutation;
- liệt kê migration plan.

Nếu dry-run fail: STOP, không tự xử lý bằng suy đoán.

### B. Collision preflight

Trước mutation, với mọi destination:

- destination chưa tồn tại → OK;
- destination tồn tại và content giống hệt → đánh dấu deduplicate;
- destination tồn tại nhưng content khác → STOP toàn migration, report cả source/destination; không overwrite, không merge đoán.

Không được bắt đầu move nếu còn collision chưa xử lý.

### C. Apply bằng script

Sau dry-run PASS:

```powershell
powershell -ExecutionPolicy Bypass -File <source>/tools/migrate-docs-layout.ps1 -TargetRoot <target> -Apply
```

Script phải tự:

1. yêu cầu target working tree clean;
2. `git mv` nguyên file để giữ rename history;
3. deduplicate chỉ khi source/destination hash giống hệt;
4. verify hash ngay sau move;
5. rewrite reference chỉ trong docs/instruction Markdown, không rewrite application source code;
6. ghi `.ai-dev-os/state.json = ordered-v2 / 2`;
7. rollback về HEAD nếu migration fail giữa chừng.

Không bootstrap, không regenerate project knowledge, không yêu cầu agent đọc toàn bộ nội dung file để tự phân loại.

## Phase 5 — Apply managed files

Sau Phase 4.5, target phải ở `ordered-v2`.

Đọc `.ai-dev-os/manifest.json` từ SOURCE.

Manifest dùng **canonical ordered paths giống hệt source repository**. Không resolve ngược về legacy path.

Chỉ xét entry active theo target adapter:

- `core`: luôn active;
- `claude`: active khi target dùng Claude;
- `generic`: active khi target đã có `.agents/`.

### ownership = framework

Copy/update đúng canonical path từ SOURCE sang TARGET.

Ví dụ:

```text
source:
docs/01-development/ai-development.md

target:
docs/01-development/ai-development.md
```

Nếu target path không tồn tại sau migration, create.

### ownership = mixed

Không copy đè.

Thực hiện semantic merge:

1. đọc canonical ordered source;
2. đọc target hiện tại tại cùng ordered path;
3. giữ toàn bộ project-specific knowledge/routing/rule còn đúng;
4. thêm framework rule mới chưa có;
5. loại duplicate rõ ràng;
6. không thay project-specific content bằng placeholder/template source.

Mixed files đặc biệt:

- `AGENTS.md`
- `docs/README.md`
- `docs/01-development/setup-checklist.md`
- `docs/01-development/documentation-governance.md`
- `docs/02-modules/README.md`
- `docs/04-operations/README.md`
- `docs/05-decisions/README.md`
- `docs/06-work/README.md`

### Project-owned knowledge phải bất khả xâm phạm

Các file bootstrap/task knowledge sau **không nằm trong manifest** và updater không được semantic-merge/overwrite:

- `docs/00-overview/project-context.md`
- `docs/00-overview/product.md`
- `docs/00-overview/architecture.md`
- `docs/00-overview/codebase-map.md`
- `docs/01-development/coding-standards.md`
- `docs/01-development/commands.md`
- `docs/01-development/testing.md`
- `docs/01-development/security.md`
- `docs/01-development/git-workflow.md`
- `docs/01-development/definition-of-ready.md`
- `docs/01-development/definition-of-done.md`
- `docs/03-knowledge/business-rules.md`
- `docs/03-knowledge/known-pitfalls.md`
- mọi file dưới `docs/02-modules/<module>/`, `docs/03-knowledge/**/entries/`, `docs/04-operations/` ngoài các root README framework-mixed, `docs/05-decisions/entries/`, `docs/06-work/<task>/`.

Updater chỉ được:
1. `git mv` nguyên file khi layout migration yêu cầu;
2. rewrite **chính xác path reference cũ → mới**;
3. sau đó giữ nguyên toàn bộ nội dung còn lại.

Không được dùng source template/framework file để thay thế các file project-owned này.

Nếu không thể merge mà không có nguy cơ mất project rule: report `CONFLICT`, không đoán.

### Unmanaged files

File không có trong manifest mặc định là project-owned.

Không sửa chỉ vì source AI-DEV-OS có file cùng loại.

## Phase 6 — Optional tools

Không tự:

- cài `codebase-memory-mcp`;
- cài `ast-grep`;
- cài `Repomix`;
- bật MCP;
- sửa global MCP config;
- overwrite target `.mcp.json`.

Chỉ report optional tool state nếu liên quan migration.

## Phase 7 — Verification

Trước khi write VERSION:

1. source VERSION và manifest version khớp;
2. target docs layout = `ordered-v2`;
3. inventory trước/sau có cùng số file logic, trừ duplicate-identical đã ghi nhận;
4. mọi migrated file giữ nguyên content hash trước bước framework merge;
5. tất cả active `framework` paths tồn tại ở đúng canonical ordered path;
6. mixed files vẫn chứa project-specific knowledge trước upgrade;
7. mọi project-owned knowledge file trước update vẫn tồn tại sau update ở cùng path hoặc mapped ordered path; ngoài deterministic path-reference rewrite, nội dung phải được preserve;
8. không còn broken reference tới migrated legacy docs path;
9. không còn broken reference tới `docs/ai/17-AI-USAGE-POLICY.md` nếu migration đã chạy;
10. nếu target có team policy thì route mới đúng;
11. optional tool không bị auto-enabled;
12. target working tree chỉ chứa expected upgrade + layout migration changes;
13. migration-specific checks trong UPGRADE.md đã pass;
14. không còn unresolved conflict;
15. conflict-safe knowledge policy đã có;
16. active task/knowledge/fix-bug skills không còn append discovery vào shared docs;
17. ADR/task-generated docs mới dùng entry-per-file và không phụ thuộc global sequence;
18. không còn duplicate scaffold ở legacy path và ordered path;
19. không có bước bootstrap-project nào được chạy trong upgrade.

Nếu verification fail: KHÔNG bump version.

## Phase 8 — Finalize version

Chỉ sau khi Phase 7 pass:

1. copy source `.ai-dev-os/manifest.json` và `.ai-dev-os/layouts.json` sang target;
2. xác nhận migrator đã ghi `.ai-dev-os/state.json = ordered-v2 / 2`;
3. write target `.ai-dev-os/VERSION` = source version;
4. chạy verification lần cuối;
5. show diff summary.

Không tự commit/push/PR trừ khi user yêu cầu.

## Báo cáo cuối

```text
Nguồn AI-DEV-OS:
- <đường dẫn tuyệt đối>

Phiên bản trước:
- <version | legacy-unversioned>

Phiên bản mới:
- <source version>

Docs layout:
- trước: legacy-v1 / ordered-v2
- sau: ordered-v2
- migrated files: <n>
- preserved content: PASS / FAIL

Nhánh:
- <branch>

File framework đã cập nhật:
- ...

File mixed đã merge:
- ...

Migration đã thực hiện:
- ...

Project knowledge đã giữ nguyên:
- ...

Conflict:
- không có / ...

Optional tools:
- không đổi / ...

Kiểm tra:
- PASS / FAIL

Version:
- đã cập nhật / chưa cập nhật
```

Không claim success nếu VERSION chưa được write sau verification.
