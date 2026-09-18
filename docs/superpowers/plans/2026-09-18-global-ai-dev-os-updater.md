# Global AI-DEV-OS Updater Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cho phép cài updater một lần trên máy và chạy `/update-ai-dev-os` từ bất kỳ product repo đã apply AI-DEV-OS nào mà không copy/merge thủ công.

**Architecture:** Dùng Claude Code personal skill làm launcher toàn máy, trỏ tới canonical updater trong AI-DEV-OS local. Canonical updater đọc managed-file manifest để phân biệt framework/mixed ownership, chạy migration, merge, verify và bump version cuối cùng.

**Tech Stack:** Markdown Agent Skills, PowerShell installer, JSON manifest, Python static verifier, Git/Claude Code.

**Spec:** `docs/superpowers/specs/2026-09-18-global-ai-dev-os-updater-design.md`

## Global Constraints

- Target framework version: `2.3.0`.
- Không overwrite project-owned knowledge.
- Optional tools không auto-install/enable.
- Target working tree phải clean trước mutation.
- Source AI-DEV-OS phải clean, ở `main`, pull fast-forward được.
- VERSION chỉ update sau verification.
- Personal launcher phải usable từ legacy repo chưa có project-level updater skill.

---

### Task 1: Version + ownership manifest

**Files:**
- Modify: `.ai-dev-os/VERSION`
- Create: `.ai-dev-os/manifest.json`
- Modify: `UPGRADE.md`

- [ ] Bump source version thành 2.3.0.
- [ ] Thêm managed-file manifest với ownership/scope.
- [ ] Thêm migration 2.3.0, gồm team AI usage policy.
- [ ] Verify manifest JSON và source paths.
- [ ] Commit.

### Task 2: Personal updater installer

**Files:**
- Create: `tools/install-personal-updater.ps1`
- Create: `tools/tests/verify-updater.py`

- [ ] Viết verifier kỳ vọng version/manifest/installer/canonical skills.
- [ ] Baseline phải fail trước khi implementation artifacts đầy đủ.
- [ ] Installer tạo personal skill ở `~/.claude/skills/update-ai-dev-os/SKILL.md`.
- [ ] Launcher chứa absolute source path và luôn đọc canonical skill.
- [ ] Không sửa product repo.
- [ ] Verify static contract.
- [ ] Commit.

### Task 3: Canonical updater skill

**Files:**
- Modify: `.claude/skills/update-ai-dev-os/SKILL.md`
- Modify: `.agents/skills/update-ai-dev-os/SKILL.md`

- [ ] Resolve canonical source do personal launcher cung cấp.
- [ ] Source/target preflight.
- [ ] Auto branch khi target đang main/master.
- [ ] Read manifest + UPGRADE.
- [ ] Apply framework ownership.
- [ ] Semantic merge mixed files.
- [ ] Auto-migrate `17-AI-USAGE-POLICY.md` sang `docs/team/` khi safe.
- [ ] Verify trước VERSION.
- [ ] Giữ Claude/generic canonical skill tương đương.
- [ ] Commit.

### Task 4: User documentation

**Files:**
- Modify: `README.md`
- Modify: `START-HERE.md`
- Modify: `CLAUDE-CODE-GUIDE.md`
- Modify: `CHANGELOG.md`
- Modify: `FILE-INDEX.md`

- [ ] Hướng dẫn one-time install.
- [ ] Hướng dẫn daily upgrade: mở repo → `/update-ai-dev-os`.
- [ ] Nêu legacy repo không cần copy updater vào từng repo.
- [ ] Nêu update-all là future work.
- [ ] Sync changelog/file index.
- [ ] Commit.

### Task 5: Verification + PR

- [ ] Run `python tools/tests/verify-updater.py` trên branch snapshot.
- [ ] Parse manifest JSON.
- [ ] Confirm source VERSION = manifest version = 2.3.0.
- [ ] Confirm canonical updater skill mirrors exact.
- [ ] Confirm all managed source paths exist.
- [ ] Confirm installer targets personal skill path.
- [ ] Confirm UPGRADE contains legacy → 2.3.0 path and team policy migration.
- [ ] Compare branch to main.
- [ ] Open PR.
