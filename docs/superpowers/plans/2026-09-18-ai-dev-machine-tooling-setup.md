# AI Development Machine Tooling Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cài và cấu hình một lần trên Windows để mọi repo AI-DEV-OS có sẵn ripgrep, ast-grep, Repomix, codebase-memory-mcp, Claude MCP user-scope và personal updater.

**Architecture:** Một PowerShell script idempotent trong AI-DEV-OS quản lý machine-level tooling. Script chỉ tự cài các tool đã chốt, dùng installer/channels chính thức, cấu hình codebase-memory-mcp ở Claude Code user scope, gọi personal updater installer hiện có, rồi verify từng capability và báo bằng tiếng Việt.

**Tech Stack:** PowerShell, winget, npm, Claude Code CLI, codebase-memory-mcp, Python static verification.

**Spec:** Thiết kế đã được chốt trong trao đổi ngày 2026-09-18: setup máy một lần, tool luôn có sẵn nhưng execution vẫn theo progressive retrieval.

## Global Constraints

- Target framework version: `2.4.0`.
- Windows-first.
- Không cài CodeGraph song song; graph/memory layer là `codebase-memory-mcp`.
- Không để installer của codebase-memory-mcp tự thêm skills/hooks/agent config; dùng `--skip-config`.
- Claude MCP phải ở user scope để dùng cho mọi repo.
- Không sửa project-specific MCP config.
- Không tự bật tool trong mọi task; `docs/ai/17-CONTEXT-RETRIEVAL.md` vẫn quyết định khi nào dùng.
- Mọi output của setup script phải bằng tiếng Việt.
- Script phải idempotent: tool đã có thì verify, không cài lại vô lý.

---

### Task 1: Static contract test

**Files:**
- Create: `tools/tests/verify-machine-setup.py`

- [ ] Test kỳ vọng setup script tồn tại.
- [ ] Test tool stack gồm ripgrep, ast-grep, Repomix, codebase-memory-mcp.
- [ ] Test codebase-memory installer dùng `--skip-config`.
- [ ] Test Claude MCP dùng `--scope user`.
- [ ] Test gọi personal updater installer.
- [ ] Test output/heading tiếng Việt.
- [ ] Baseline thiếu setup script phải fail.

### Task 2: Machine setup script

**Files:**
- Create: `tools/setup-ai-dev-machine.ps1`

- [ ] Detect Windows + prerequisites.
- [ ] Ensure ripgrep bằng winget nếu thiếu.
- [ ] Ensure ast-grep bằng winget nếu thiếu.
- [ ] Ensure Repomix bằng npm nếu thiếu; nếu npm thiếu thì báo BLOCKED rõ, không tự cài Node.
- [ ] Ensure codebase-memory-mcp bằng official Windows installer với `--skip-config`.
- [ ] Refresh current-process PATH sau install khi cần.
- [ ] Configure Claude Code user-scope stdio MCP nếu chưa có; không overwrite config khác nếu phát hiện conflict.
- [ ] Install/refresh personal `/update-ai-dev-os` launcher.
- [ ] Verify versions and MCP registration.
- [ ] Print PASS/BLOCKED/FAIL summary in Vietnamese.

### Task 3: Framework behavior/docs

**Files:**
- Modify: `docs/ai/17-CONTEXT-RETRIEVAL.md`
- Modify: `docs/ai/18-TOOL-ADOPTION.md`
- Modify: `README.md`
- Modify: `START-HERE.md`
- Modify: `CLAUDE-CODE-GUIDE.md`
- Modify: `UPGRADE.md`
- Modify: `CHANGELOG.md`
- Modify: `.ai-dev-os/VERSION`

- [ ] Document machine setup command.
- [ ] Clarify installed/available != always invoked.
- [ ] Clarify codebase-memory-mcp is graph/memory layer; CodeGraph is not installed due overlap.
- [ ] Add MCP indexing/coverage rule before graph query.
- [ ] Add 2.4.0 upgrade note.
- [ ] Bump VERSION to 2.4.0.

### Task 4: Index + verification

**Files:**
- Modify: `FILE-INDEX.md`

- [ ] Run static verification against branch snapshot.
- [ ] Confirm updater skill mirrors still equal.
- [ ] Confirm setup script references official installation paths/commands.
- [ ] Confirm no project `.mcp.json` mutation.
- [ ] Sync FILE-INDEX.
- [ ] Open PR.
