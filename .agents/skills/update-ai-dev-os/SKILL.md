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
5. Xác nhận target có AI-DEV-OS artifacts, tối thiểu một trong:
   - `AGENTS.md`
   - `CLAUDE.md`
   - `docs/ai/16-TASK-EXECUTION.md`
   - `.claude/skills/bootstrap-project/SKILL.md`.
6. Detect adapters:
   - Claude active nếu target có `CLAUDE.md` hoặc `.claude/`;
   - generic active nếu target có `.agents/`.
7. Detect target docs layout:
   - có `.ai-dev-os/state.json` → đọc `docs_layout`;
   - không có state → coi là `legacy-v1`.
8. Validate layout tồn tại trong source `.ai-dev-os/layouts.json`.
9. Nếu target = `legacy-v1` và source có `ordered-v2`, **lập migration plan sang ordered-v2**. Không bootstrap lại project.

Nếu target version bằng source version nhưng layout còn legacy, vẫn phải chạy layout migration.

## Phase 3 — Safe branch

Nếu target đang ở `main` hoặc `master`:

1. lấy `git config user.name`;
2. chuyển thành slug lowercase, ký tự không hợp lệ → `-`;
3. branch:
   `<slug>/update-ai-dev-os-<source-version>`;
4. nếu không có user.name, dùng:
   `ai-dev-os/update-<source-version>`;
5. tạo và switch branch.

Nếu branch đã tồn tại:
- chỉ switch nếu working tree clean và branch dùng cho cùng target version;
- nếu không chắc, STOP và report.

Nếu target đã ở branch khác, tiếp tục trên branch hiện tại.

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

### A. Inventory trước mutation

1. Liệt kê toàn bộ file dưới:
   - `docs/ai/`
   - `docs/team/`
   - `docs/modules/`
   - `docs/knowledge/`
   - `docs/operations/`
   - `docs/decisions/`
   - `docs/work/`
2. Với mỗi file, tính:
   - source path;
   - destination path theo exact `path_map` hoặc longest matching `prefix_map`;
   - content hash trước migration.
3. Không bỏ qua file chỉ vì framework không biết tên file đó.
4. Tạo migration plan đầy đủ trước khi move file đầu tiên.

### B. Collision preflight

Trước mutation, với mọi destination:

- destination chưa tồn tại → OK;
- destination tồn tại và content giống hệt → đánh dấu deduplicate;
- destination tồn tại nhưng content khác → STOP toàn migration, report cả source/destination; không overwrite, không merge đoán.

Không được bắt đầu move nếu còn collision chưa xử lý.

### C. Move preserving content

1. Tạo destination folder khi cần.
2. Dùng `git mv` cho từng file để Git giữ rename history.
3. Với duplicate-identical, giữ một bản và xóa path legacy bằng Git.
4. Không sửa nội dung trong bước move.
5. Không bootstrap, không regenerate project docs.

### D. Rewrite references

Sau khi move xong:

1. search toàn repo các legacy path;
2. rewrite exact path trước, prefix sau;
3. áp dụng cho Markdown, skill, config/instruction text;
4. không rewrite source code string nếu path đó là runtime value trừ khi evidence xác nhận đó là docs reference;
5. search lại và yêu cầu không còn broken legacy reference thuộc migrated docs.

### E. State

Chỉ sau khi move + reference rewrite + verification pass:

```json
{
  "docs_layout": "ordered-v2",
  "docs_layout_version": 2
}
```

ghi vào `.ai-dev-os/state.json`.

Nếu fail ở bất kỳ bước nào: không ghi state ordered-v2 và không bump VERSION.

## Phase 5 — Apply managed files theo target layout

Đọc:

- `.ai-dev-os/manifest.json`
- `.ai-dev-os/layouts.json`

từ SOURCE.

### Resolve target path

Manifest luôn dùng **canonical source path**.

Với mỗi managed path:

1. sau Phase 4.5, target layout phải là `ordered-v2`;
2. nếu có exact mapping trong `path_map` → dùng mapped target path;
3. nếu không exact match nhưng thuộc `prefix_map` → rewrite longest matching prefix;
4. nếu không có mapping → giữ nguyên path.

Ví dụ:

```text
source manifest:
docs/ai/16-TASK-EXECUTION.md

legacy-v1 target:
docs/ai/16-TASK-EXECUTION.md

ordered-v2 target:
docs/01-development/ai-development.md
```

### Rewrite reference trong text

Khi source text được apply vào target:

1. rewrite exact source path theo `path_map`;
2. rewrite folder prefix theo `prefix_map`;
3. chỉ rewrite path/reference, không đổi project semantics;
4. không tạo duplicate legacy + ordered path.

Chỉ xét entry active theo target adapter:

- `core`: luôn active;
- `claude`: active khi target dùng Claude;
- `generic`: active khi target đã có `.agents/`.

### ownership = framework

Update **resolved target path** từ canonical source, sau khi render references theo target layout.

Không dùng template/project file cũ làm source.

Nếu resolved target path không tồn tại, create.

### ownership = mixed

Không copy đè.

Thực hiện semantic merge trên **resolved target path**:

1. đọc source canonical và render reference theo target layout;
2. đọc target hiện tại;
3. giữ toàn bộ project-specific knowledge/routing/rule còn đúng;
4. thêm framework rule mới chưa có;
5. loại duplicate rõ ràng;
6. không thay project-specific content bằng placeholder/template source.

Mixed files đặc biệt theo canonical source path:

- `AGENTS.md`
- `docs/README.md`
- `docs/ai/00-SETUP-CHECKLIST.md`
- `docs/ai/04-CODEBASE-MAP.md`
- `docs/ai/14-AI-SYSTEM-MAINTENANCE.md`
- `docs/decisions/README.md`
- `docs/modules/README.md`
- `docs/operations/README.md`
- `docs/work/README.md`

Khi target = `ordered-v2`, các path trên phải resolve sang folder số tương ứng trước khi merge.

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
5. tất cả active `framework` paths tồn tại ở **resolved target path**;
6. mixed files vẫn chứa project-specific knowledge trước upgrade;
7. không còn broken reference tới migrated legacy docs path;
8. không còn broken reference tới `docs/ai/17-AI-USAGE-POLICY.md` nếu migration đã chạy;
9. nếu target có team policy thì route mới đúng;
10. optional tool không bị auto-enabled;
11. target working tree chỉ chứa expected upgrade + layout migration changes;
12. migration-specific checks trong UPGRADE.md đã pass;
13. không còn unresolved conflict;
14. conflict-safe knowledge policy đã có;
15. active task/knowledge/fix-bug skills không còn append discovery vào shared docs;
16. ADR/task-generated docs mới dùng entry-per-file và không phụ thuộc global sequence;
17. không còn duplicate scaffold ở legacy path và ordered path;
18. không có bước bootstrap-project nào được chạy trong upgrade.

Nếu verification fail: KHÔNG bump version.

## Phase 8 — Finalize version

Chỉ sau khi Phase 7 pass:

1. copy source `.ai-dev-os/manifest.json` và `.ai-dev-os/layouts.json` sang target;
2. write/update `.ai-dev-os/state.json` = `ordered-v2 / 2`;
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
