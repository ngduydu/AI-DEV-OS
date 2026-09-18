# Global AI-DEV-OS Updater Design

Date: 2026-09-18

## Mục tiêu

Sau khi setup một lần trên máy, người dùng đứng trong bất kỳ repository đã apply AI-DEV-OS nào và chạy:

```text
/update-ai-dev-os
```

Updater tự lấy framework mới nhất từ repository AI-DEV-OS local, preserve project knowledge, apply framework changes, xử lý migration rõ ràng, verify và chỉ sau đó bump version.

Không còn copy/merge thủ công từng file cho mỗi repository.

## Quyết định chính

Claude Code hỗ trợ personal skills tại `~/.claude/skills/`, dùng được cho mọi project. Vì vậy updater được chia làm hai lớp:

```text
Personal launcher (cài một lần trên máy)
~/.claude/skills/update-ai-dev-os/SKILL.md
        │
        │ trỏ tới absolute path AI-DEV-OS local
        ▼
Canonical updater
AI-DEV-OS/.claude/skills/update-ai-dev-os/SKILL.md
        │
        ▼
product repo hiện tại
```

Personal launcher chỉ làm nhiệm vụ tìm canonical source. Logic upgrade luôn sống trong AI-DEV-OS source để lần sau framework thay đổi không phải reinstall launcher.

## One-time setup

AI-DEV-OS source có:

```text
tools/install-personal-updater.ps1
```

Chạy một lần từ repository AI-DEV-OS local:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\install-personal-updater.ps1
```

Script:

1. xác định absolute path của AI-DEV-OS source;
2. validate canonical updater skill tồn tại;
3. tạo `~/.claude/skills/update-ai-dev-os/SKILL.md`;
4. launcher chứa source path tuyệt đối;
5. không sửa product repo nào.

Nếu AI-DEV-OS source được move sang path khác, chạy installer lại.

## Version

Feature này nâng framework lên:

```text
2.3.0
```

## Managed-file manifest

Source có:

```text
.ai-dev-os/manifest.json
```

Manifest chỉ liệt kê file framework quản lý, không liệt kê toàn repository.

Mỗi entry có:

- `path`;
- `ownership`: `framework` hoặc `mixed`;
- `scope`: `core`, `claude`, hoặc `generic`.

Mọi file không có trong manifest mặc định được coi là project-owned/không được updater đụng.

### framework

Updater có thể copy/update canonical content.

### mixed

Updater phải merge semantic, giữ project-specific knowledge và không overwrite mù.

### scope

- `core`: apply cho mọi AI-DEV-OS project;
- `claude`: chỉ apply khi target dùng Claude adapter;
- `generic`: chỉ apply khi target đã dùng `.agents/`.

## Upgrade flow

```text
/update-ai-dev-os
↓
resolve AI-DEV-OS source
↓
source preflight
↓
pull --ff-only source/main nếu safe
↓
target preflight
↓
read source VERSION + manifest + UPGRADE
↓
detect current target version hoặc legacy
↓
create/update branch nếu đang ở main/master
↓
run special migrations
↓
framework-owned → update tự động
↓
mixed → semantic merge, preserve project knowledge
↓
verify
↓
write manifest snapshot
↓
bump target VERSION cuối cùng
↓
report
```

## Safety gates

### Source

Trước target mutation:

- source path phải là Git repository AI-DEV-OS;
- source working tree phải clean;
- canonical files phải tồn tại;
- branch source phải là `main`;
- `git pull --ff-only` phải thành công hoặc updater dừng.

### Target

Trước mutation:

- phải là Git repository;
- working tree phải clean;
- phải nhận diện được AI-DEV-OS artifacts;
- nếu đang ở `main`/`master`, updater tự tạo branch update riêng;
- không overwrite project-owned file;
- optional tools không tự cài/bật.

## Automatic branch

Nếu target đang ở `main` hoặc `master`, updater tạo branch:

```text
<git-user-slug>/update-ai-dev-os-<target-version>
```

Nếu không lấy được git user name, fallback:

```text
ai-dev-os/update-<target-version>
```

Nếu branch đã tồn tại và không thể switch an toàn, stop và báo rõ.

## Special migration: team AI usage policy

Một số repository cũ có:

```text
docs/ai/17-AI-USAGE-POLICY.md
```

Đây là team-specific policy, không thuộc framework namespace.

Updater 2.3.0 xử lý:

```text
docs/ai/17-AI-USAGE-POLICY.md
→ docs/team/AI-USAGE-POLICY.md
```

- dùng `git mv` để preserve history;
- giữ nguyên nội dung;
- update references;
- nếu destination đã tồn tại thì report conflict, không overwrite;
- route trong `docs/README.md` được merge vào mixed file.

Như vậy các repository còn lại không phải xử lý thủ công conflict số 17.

## Mixed files 2.3.0

Các file mixed chính:

- `AGENTS.md`;
- `docs/README.md`;
- `docs/ai/04-CODEBASE-MAP.md`;
- `docs/ai/14-AI-SYSTEM-MAINTENANCE.md`.

Rule:

- source framework rule phải được thêm/cập nhật;
- target project knowledge phải còn nguyên;
- duplicate rõ ràng được gộp;
- ambiguity/conflict có thể làm mất rule thì stop riêng file đó và report.

## Adapter behavior

### Claude target

Nếu target có `CLAUDE.md` hoặc `.claude/`, apply Claude-scoped managed files.

### Generic target

Chỉ apply `.agents/` files khi target đã có `.agents/`.

Không tự thêm adapter mà product repo chưa dùng.

## Optional tools

Updater không tự:

- cài codebase-memory-mcp;
- cài ast-grep;
- cài Repomix;
- bật MCP;
- sửa global MCP config.

Tool integration tiếp tục là opt-in.

## Verification

Trước bump VERSION:

- source version và manifest version khớp;
- tất cả framework files active theo scope tồn tại;
- mixed files không mất project-specific knowledge;
- team AI policy migration không để broken reference;
- Claude/generic mirrored updater skill trong source tương đương;
- manifest JSON parse được;
- target VERSION chỉ được write sau các check trên.

## Failure behavior

Nếu fail trước mutation: không thay đổi target.

Nếu conflict giữa migration/merge: không bump VERSION; report exact path và lý do.

Không claim upgrade thành công khi verification chưa đủ.

## Non-goals

Version này chưa làm:

- update-all nhiều repository;
- package manager riêng;
- background auto-update;
- tự merge Git commit/PR;
- tự cài optional tools;
- cloud updater.

Sau khi one-repo updater được dùng ổn thực tế mới làm update-all.
