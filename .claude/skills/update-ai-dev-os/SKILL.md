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
   - `UPGRADE.md`
4. Xác nhận source working tree clean.
5. Xác nhận source branch là `main`.
6. Chạy:
   ```text
   git -C <source> pull --ff-only
   ```
7. Đọc lại VERSION + manifest sau pull.
8. Xác nhận `manifest.framework_version == VERSION`.

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

Nếu target version bằng source version, vẫn verify manifest/migration state. Nếu không có gì cần sửa thì report no-op.

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
6. từ sau upgrade, knowledge mới của task đi theo `docs/knowledge/README.md`.

Lý do: automatic split của knowledge cũ có rủi ro mất context/semantics và tạo diff lớn trong repo đang có branch chạy song song.

Nếu mixed merge của `docs/ai/13-KNOWN-PITFALLS.md`, `docs/ai/14-AI-SYSTEM-MAINTENANCE.md` hoặc `docs/README.md` có nguy cơ mất project-specific content: report `CONFLICT`, không overwrite.

## Phase 5 — Apply managed files

Đọc `.ai-dev-os/manifest.json` từ SOURCE.

Chỉ xét entry active theo target adapter:

- `core`: luôn active;
- `claude`: active khi target dùng Claude;
- `generic`: active khi target đã có `.agents/`.

### ownership = framework

Update target path từ canonical source.

Không dùng template/project file cũ làm source.

Nếu target path không tồn tại, create.

### ownership = mixed

Không copy đè.

Thực hiện semantic merge:

1. đọc source canonical;
2. đọc target hiện tại;
3. giữ toàn bộ project-specific knowledge/routing/rule còn đúng;
4. thêm framework rule mới chưa có;
5. loại duplicate rõ ràng;
6. không thay project-specific content bằng placeholder/template source.

Mixed files đặc biệt:

- `AGENTS.md`
- `docs/README.md`
- `docs/ai/04-CODEBASE-MAP.md`
- `docs/ai/14-AI-SYSTEM-MAINTENANCE.md`

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
2. tất cả active `framework` paths tồn tại ở target;
3. mixed files vẫn chứa project-specific knowledge trước upgrade;
4. không còn broken reference tới `docs/ai/17-AI-USAGE-POLICY.md` nếu migration đã chạy;
5. nếu target có team policy thì `docs/README.md` route đúng;
6. optional tool không bị auto-enabled;
7. target working tree chỉ chứa expected upgrade changes;
8. migration-specific checks trong UPGRADE.md đã pass;
9. không còn unresolved conflict.
10. conflict-safe knowledge policy 2.6.0 đã có và existing knowledge không bị auto-split/move.

Nếu verification fail: KHÔNG bump version.

## Phase 8 — Finalize version

Chỉ sau khi Phase 7 pass:

1. copy source `.ai-dev-os/manifest.json` sang target;
2. write target `.ai-dev-os/VERSION` = source version;
3. chạy verification lần cuối;
4. show diff summary.

Không tự commit/push/PR trừ khi user yêu cầu.

## Báo cáo cuối

```text
Nguồn AI-DEV-OS:
- <đường dẫn tuyệt đối>

Phiên bản trước:
- <version | legacy-unversioned>

Phiên bản mới:
- <source version>

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
