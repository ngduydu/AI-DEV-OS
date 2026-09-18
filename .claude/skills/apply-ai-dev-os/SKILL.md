---
name: apply-ai-dev-os
description: Use when the current repository does not yet contain AI-DEV-OS and should be initialized from the canonical local AI-DEV-OS source for Claude Code without manual file copying.
disable-model-invocation: true
---

# Apply AI-DEV-OS

Mục tiêu: apply AI-DEV-OS vào repository hiện tại bằng một lệnh, không copy tay.

Mọi phản hồi cho người dùng phải bằng tiếng Việt.

## Source

Personal launcher phải cung cấp absolute path của canonical AI-DEV-OS source.

Nếu không có source path hợp lệ: dừng và yêu cầu chạy lại machine setup từ AI-DEV-OS.

## Preflight source

Trước khi sửa target:

1. Source phải là Git repository.
2. Source phải đang ở branch `main`.
3. Source working tree phải clean.
4. Chạy `git -C <source> pull --ff-only`.
5. Đọc:
   - `.ai-dev-os/VERSION`
   - `.ai-dev-os/manifest.json`
6. Nếu source preflight fail: dừng, không sửa target.

## Preflight target

1. Current working directory phải là Git repository.
2. Target không được là chính AI-DEV-OS source.
3. Target working tree phải clean.
4. Nếu target đã có `.ai-dev-os/VERSION`: dừng và bảo dùng `/update-ai-dev-os`.
5. Nếu target đã có AI-DEV-OS artifacts đáng kể như `docs/ai/16-TASK-EXECUTION.md`, `.claude/skills/bootstrap-project/SKILL.md` hoặc `UPGRADE.md`: coi là legacy/partial install, dừng và bảo dùng `/update-ai-dev-os`.
6. Nếu đang ở `main` hoặc `master`, tạo branch:
   `<git-user-slug>/apply-ai-dev-os-<version>`
   fallback: `ai-dev-os/apply-<version>`.

Không tự commit/push/merge.

## Apply cho Claude Code

Copy từ canonical source vào target đúng các nhóm sau.

### Core

- `.ai-dev-os/VERSION`
- `.ai-dev-os/manifest.json`
- `UPGRADE.md`
- `AGENTS.md`
- `CLAUDE.md`

### Project knowledge scaffold

- `docs/README.md`
- toàn bộ `docs/ai/*.md`
- `docs/modules/README.md`
- `docs/operations/README.md`
- `docs/decisions/README.md`
- `docs/decisions/ADR-TEMPLATE.md`
- `docs/work/README.md`
- toàn bộ `docs/work/_template/*.md`

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
- `templates/`
- `.agents/` khi target chỉ dùng Claude Code

### Claude adapter

Copy:

- toàn bộ `.claude/skills/` **trừ** `.claude/skills/apply-ai-dev-os/` vì apply là personal machine skill, không cần nằm trong product repo;
- toàn bộ `.claude/agents/`.

Không copy machine setup scripts hoặc personal apply launcher vào product repo.

## Collision rule

`/apply-ai-dev-os` chỉ dùng cho repo chưa apply framework.

Nếu bất kỳ destination framework path quan trọng nào đã tồn tại với nội dung khác source, dừng và báo collision thay vì overwrite. Không tự xóa knowledge/project docs hiện hữu.

## Bootstrap ngay sau apply

Sau khi copy thành công:

1. Đọc canonical workflow vừa được copy tại:
   `.claude/skills/bootstrap-project/SKILL.md`
2. Tiếp tục thực hiện bootstrap project trong cùng invocation.
3. Bootstrap phải scan code/config/tests thật và cập nhật minimum reliable project knowledge.
4. Không tạo knowledge giả chỉ để fill template.
5. Kết thúc bằng `READY / PARTIAL / BLOCKED`.

## Verification

Trước khi báo xong, verify:

- target có `.ai-dev-os/VERSION` và version khớp source;
- target có `AGENTS.md`, `CLAUDE.md`, `docs/README.md`;
- target có `.claude/skills/bootstrap-project/SKILL.md`;
- target có `.claude/skills/update-ai-dev-os/SKILL.md`;
- target có `.claude/agents/`;
- không copy `docs/superpowers/`;
- không copy machine setup scripts;
- bootstrap đã chạy hoặc báo rõ blocker;
- chỉ có expected diff.

## Báo cáo cuối

```text
AI-DEV-OS:
- Applied version: <version>

Branch:
- <branch>

Applied:
- core
- Claude skills
- Claude agents
- project knowledge scaffold

Bootstrap:
- READY / PARTIAL / BLOCKED

Material unknowns:
- ...

Next:
- giao task bình thường
```
