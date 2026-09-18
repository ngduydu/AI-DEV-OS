---
name: apply-ai-dev-os
description: Use when the current repository does not yet contain AI-DEV-OS and should be initialized from the canonical local AI-DEV-OS source without manual file copying. Supports Claude, generic, or both agent adapters.
disable-model-invocation: true
---

# Apply AI-DEV-OS

Mục tiêu: apply AI-DEV-OS vào repository hiện tại bằng một lệnh, không copy tay và không mặc định sai agent.

Mọi phản hồi cho người dùng phải bằng tiếng Việt.

## 1. Chọn agent profile trước khi sửa repository

Nếu user chưa nói rõ agent profile trong cùng yêu cầu, **bắt buộc hỏi đúng một lần** trước khi apply:

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

Không được mặc định agent.

Nếu user đã ghi rõ một trong ba giá trị trên thì dùng luôn, không hỏi lại.

Không tự suy đoán agent từ việc skill này đang được gọi trong Claude Code.

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
6. Nếu source preflight fail: dừng, không sửa target.

## 4. Preflight target

1. Current working directory phải là Git repository.
2. Target không được là chính AI-DEV-OS source.
3. Target working tree phải clean.
4. Nếu target đã có `.ai-dev-os/VERSION`: dừng và bảo dùng `/update-ai-dev-os`.
5. Nếu target đã có AI-DEV-OS artifacts đáng kể như `docs/ai/16-TASK-EXECUTION.md`, `.claude/skills/bootstrap-project/SKILL.md`, `.agents/skills/bootstrap-project/SKILL.md` hoặc `UPGRADE.md`: coi là legacy/partial install, dừng và bảo dùng `/update-ai-dev-os`.
6. Nếu đang ở `main` hoặc `master`, tạo branch:
   `<git-user-slug>/apply-ai-dev-os-<version>`
   fallback: `ai-dev-os/apply-<version>`.

Không tự commit/push/merge.

## 5. Core luôn apply

Mọi profile đều copy:

- `.ai-dev-os/VERSION`
- `.ai-dev-os/manifest.json`
- `UPGRADE.md`
- `AGENTS.md`

### Project knowledge scaffold

Mọi profile đều copy:

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
- machine setup scripts

## 6. Adapter theo agent profile

### Profile: claude

Copy thêm:

- `CLAUDE.md`
- toàn bộ `.claude/skills/` **trừ** `.claude/skills/apply-ai-dev-os/`
- toàn bộ `.claude/agents/`

Không copy:

- `.agents/skills/`

### Profile: generic

Copy thêm:

- toàn bộ `.agents/skills/`

Không copy:

- `CLAUDE.md`
- `.claude/skills/`
- `.claude/agents/`

### Profile: both

Copy thêm:

- `CLAUDE.md`
- toàn bộ `.claude/skills/` **trừ** `.claude/skills/apply-ai-dev-os/`
- toàn bộ `.claude/agents/`
- toàn bộ `.agents/skills/`

## 7. Collision rule

`/apply-ai-dev-os` chỉ dùng cho repo chưa apply framework.

Chỉ kiểm tra collision trên các destination thuộc **core + profile đã chọn**.

Nếu destination framework path quan trọng đã tồn tại với nội dung khác source, dừng và báo collision thay vì overwrite.

Không tự xóa knowledge/project docs hiện hữu.

## 8. Bootstrap ngay sau apply

Sau khi copy thành công, chạy bootstrap **một lần** theo profile:

- `claude` → dùng `.claude/skills/bootstrap-project/SKILL.md`
- `generic` → dùng `.agents/skills/bootstrap-project/SKILL.md`
- `both` → dùng `.claude/skills/bootstrap-project/SKILL.md`; không chạy bootstrap lần hai

Bootstrap phải:

1. scan code/config/tests thật;
2. cập nhật minimum reliable project knowledge;
3. không tạo knowledge giả chỉ để fill template;
4. kết thúc bằng `READY / PARTIAL / BLOCKED`.

## 9. Verification

Trước khi báo xong, verify chung:

- target có `.ai-dev-os/VERSION` và version khớp source;
- target có `AGENTS.md`, `docs/README.md`;
- không copy `docs/superpowers/`;
- không copy machine setup scripts;
- bootstrap đã chạy hoặc báo rõ blocker;
- chỉ có expected diff.

Verify theo profile:

### claude

- có `CLAUDE.md`;
- có `.claude/skills/bootstrap-project/SKILL.md`;
- có `.claude/skills/update-ai-dev-os/SKILL.md`;
- có `.claude/agents/`;
- không có `.agents/skills/` do framework vừa copy.

### generic

- có `.agents/skills/bootstrap-project/SKILL.md`;
- có `.agents/skills/update-ai-dev-os/SKILL.md`;
- không có `CLAUDE.md` do framework vừa copy;
- không có `.claude/` do framework vừa copy.

### both

- có toàn bộ điều kiện của Claude adapter;
- có `.agents/skills/bootstrap-project/SKILL.md`;
- có `.agents/skills/update-ai-dev-os/SKILL.md`.

## 10. Báo cáo cuối

```text
AI-DEV-OS:
- Applied version: <version>
- Agent profile: claude / generic / both

Branch:
- <branch>

Applied:
- core
- project knowledge scaffold
- <adapter đã chọn>

Bootstrap:
- READY / PARTIAL / BLOCKED

Material unknowns:
- ...

Next:
- giao task bình thường
```
