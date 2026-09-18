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
   - không có state → **coi là `legacy-v1`**.
8. Validate layout tồn tại trong source `.ai-dev-os/layouts.json`.

**Invariant quan trọng:** `/update-ai-dev-os` không tự đổi docs layout của target.

```text
repo cũ không có state
→ legacy-v1
→ giữ nguyên docs/ai, docs/modules, docs/operations...

repo apply mới ordered-v2
→ giữ ordered-v2
→ update vào đúng 00-overview/01-development/... hiện có
```

Nếu target version bằng source version, vẫn verify manifest/migration/layout state. Nếu không có gì cần sửa thì report no-op.

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

### Conflict-safe knowledge migration — 2.6.0

Khi source version >= `2.6.0`:

1. tạo/update `docs/knowledge/README.md` theo manifest;
2. cập nhật conflict-safe Knowledge Sync policy qua managed files;
3. preserve toàn bộ project-specific knowledge đang có trong shared/mixed docs;
4. **không di chuyển hoặc tách knowledge cũ tự động** từ:
   - `docs/ai/13-KNOWN-PITFALLS.md`;
   - `docs/ai/05-BUSINESS-RULES.md`;
   - module/operations docs hiện hữu;
5. không tạo hàng loạt isolated file bằng cách đoán boundary từ text cũ;
6. từ sau upgrade, knowledge mới của task đi theo `docs/knowledge/README.md`;
7. update các framework/mixed routing file có thể còn chỉ dẫn append vào shared docs;
8. verify không còn active skill/task contract nào route task discovery vào shared `KNOWN-PITFALLS`, shared module/operations list hoặc numbered ADR.

Lý do: automatic split của knowledge cũ có rủi ro mất context/semantics và tạo diff lớn trong repo đang có branch chạy song song.

Nếu mixed merge của `docs/ai/13-KNOWN-PITFALLS.md`, `docs/ai/14-AI-SYSTEM-MAINTENANCE.md` hoặc `docs/README.md` có nguy cơ mất project-specific content: report `CONFLICT`, không overwrite.

## Phase 5 — Apply managed files theo target layout

Đọc:

- `.ai-dev-os/manifest.json`
- `.ai-dev-os/layouts.json`

từ SOURCE.

### Resolve target path

Manifest luôn dùng **canonical source path**.

Với mỗi managed path:

1. nếu target layout = `legacy-v1` → target path = source path;
2. nếu target layout có exact mapping trong `path_map` → dùng mapped target path;
3. nếu không exact match nhưng thuộc `prefix_map` → rewrite prefix;
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
2. target docs layout không bị đổi trong quá trình update;
3. tất cả active `framework` paths tồn tại ở **resolved target path**;
4. mixed files vẫn chứa project-specific knowledge trước upgrade;
5. không còn broken reference tới legacy path do layout rendering tạo ra;
6. không còn broken reference tới `docs/ai/17-AI-USAGE-POLICY.md` nếu migration đã chạy;
7. nếu target có team policy thì `docs/README.md` route đúng;
8. optional tool không bị auto-enabled;
9. target working tree chỉ chứa expected upgrade changes;
10. migration-specific checks trong UPGRADE.md đã pass;
11. không còn unresolved conflict;
12. conflict-safe knowledge policy 2.6.0 đã có và existing knowledge không bị auto-split/move;
13. active task/knowledge/fix-bug skills không còn append discovery vào shared docs;
14. ADR/task-generated docs mới dùng entry-per-file và không phụ thuộc global sequence;
15. target không đồng thời có duplicate scaffold ở legacy path và ordered path.

Nếu verification fail: KHÔNG bump version.

## Phase 8 — Finalize version

Chỉ sau khi Phase 7 pass:

1. copy source `.ai-dev-os/manifest.json` và `.ai-dev-os/layouts.json` sang target;
2. nếu target chưa có `.ai-dev-os/state.json`, tạo:
   ```json
   {
     "docs_layout": "legacy-v1",
     "docs_layout_version": 1
   }
   ```
   để đánh dấu repo cũ mà **không move docs**;
3. nếu target đã có state, preserve nguyên `docs_layout`;
4. write target `.ai-dev-os/VERSION` = source version;
5. chạy verification lần cuối;
6. show diff summary.

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
- legacy-v1 / ordered-v2
- preserved, không auto-migrate layout

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
