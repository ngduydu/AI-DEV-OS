# Framework Lifecycle & Context Efficiency Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add versioned framework upgrades, context-efficient retrieval, mature optional tool profiles, and safe migration for repositories that already applied AI-DEV-OS.

**Architecture:** AI-DEV-OS stays agent-agnostic. Core behavior is docs + CODEBASE-MAP + targeted retrieval. Mature optional tools are layered by purpose: ripgrep default, ast-grep structural search, Repomix bootstrap/snapshot, and codebase-memory-mcp for large-codebase graph navigation. Project knowledge remains protected and source/tests/config remain ground truth.

**Tech Stack:** Markdown, Agent Skills, JSON MCP config template, GitHub repository docs.

**Spec:** `docs/superpowers/specs/2026-09-16-framework-lifecycle-context-retrieval-design.md`

## Global Constraints

- Framework baseline: `2.2.0`.
- Existing unversioned installs are legacy installs.
- MCP and optional tools must never be required for core operation.
- Source/tests/config override stale docs or indexes.
- Git history is not part of the default retrieval path.
- Never overwrite project-owned knowledge during framework upgrade.
- Do not auto-install optional tooling during upgrade.
- Tool Adoption Gate governs future recommended/default tools.

---

### Task 1: Framework lifecycle

**Files**
- Create: `.ai-dev-os/VERSION`
- Create: `UPGRADE.md`
- Modify: `docs/ai/14-AI-SYSTEM-MAINTENANCE.md`

- [ ] Add exact version marker `2.2.0`.
- [ ] Document legacy/unversioned migration and ownership classes.
- [ ] Add lifecycle rules to AI system maintenance.
- [ ] Verify no upgrade instruction says to overwrite whole `docs/`.
- [ ] Commit `feat: add framework lifecycle versioning`.

### Task 2: Context efficiency policy

**Files**
- Create: `docs/ai/17-CONTEXT-RETRIEVAL.md`
- Create: `docs/ai/18-TOOL-ADOPTION.md`
- Modify: `docs/ai/04-CODEBASE-MAP.md`
- Modify: `docs/ai/16-TASK-EXECUTION.md`
- Modify: `docs/README.md`

- [ ] Add deterministic retrieval escalation order.
- [ ] Add session hygiene: `/clear`, `/compact`, subagent isolation.
- [ ] Add STANDARD, LARGE-CODEBASE, BOOTSTRAP/SNAPSHOT profiles.
- [ ] Add Tool Adoption Gate.
- [ ] Mark CODEBASE-MAP as durable navigation cache, not source replacement.
- [ ] Remove default Git-history exploration wording from Task Execution.
- [ ] Add new docs to docs router.
- [ ] Verify normal tasks work with zero MCPs.
- [ ] Commit `docs: add context efficiency policy`.

### Task 3: Skills

**Files**
- Modify: `.claude/skills/bootstrap-project/SKILL.md`
- Modify: `.agents/skills/bootstrap-project/SKILL.md`
- Create: `.claude/skills/update-ai-dev-os/SKILL.md`
- Create: `.agents/skills/update-ai-dev-os/SKILL.md`

- [ ] Update bootstrap: broad initial scan only; targeted refresh later.
- [ ] Add safe `update-ai-dev-os` skill.
- [ ] Preserve project-owned docs and custom skills.
- [ ] Never auto-enable/install optional tools.
- [ ] Bump VERSION only after successful verification.
- [ ] Keep Claude/generic skill copies equivalent.
- [ ] Commit `feat: add safe AI-DEV-OS upgrade workflow`.

### Task 4: Optional tool integration

**Files**
- Create: `templates/mcp/claude-codebase-memory.json`
- Modify: `docs/ai/17-CONTEXT-RETRIEVAL.md`
- Modify: `CLAUDE-CODE-GUIDE.md`

- [ ] Add copyable codebase-memory-mcp project config template.
- [ ] Explain merge into existing `.mcp.json`, never overwrite.
- [ ] Explain `/mcp` verification and fallback.
- [ ] Document ripgrep default, ast-grep structural, Repomix bootstrap/snapshot.
- [ ] Document SQL/XML legacy fallback.
- [ ] Validate JSON syntax.
- [ ] Commit `docs: add optional context efficiency tools`.

### Task 5: User-facing onboarding and migration

**Files**
- Modify: `README.md`
- Modify: `START-HERE.md`
- Modify: `APPLY-TO-PROJECT.md`
- Modify: `FILE-INDEX.md`
- Modify: `CHANGELOG.md`

- [ ] Explain lifecycle/version in plain language.
- [ ] Explain what new repos copy.
- [ ] Explain how already-applied repos upgrade without re-bootstrap.
- [ ] Explain optional tool profiles and that tools are not mandatory.
- [ ] Update file index and release notes.
- [ ] Commit `docs: document lifecycle and context rollout`.

### Task 6: Verification and PR

- [ ] Compare branch to `main`.
- [ ] Validate all newly referenced paths exist.
- [ ] Confirm bootstrap skill copies are equal.
- [ ] Confirm update skill copies are equal.
- [ ] Validate MCP JSON.
- [ ] Confirm VERSION equals exactly `2.2.0`.
- [ ] Search for contradictory mandatory-MCP or full-doc-overwrite wording.
- [ ] Verify file count/index.
- [ ] Open PR to `main`.
