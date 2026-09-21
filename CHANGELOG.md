# Changelog

Các thay đổi đáng chú ý của AI-DEV-OS được ghi lại tại đây.

Dự án vẫn đang được kiểm nghiệm qua usage thực tế; workflow và structure chỉ nên thay đổi khi giúp agent làm task đáng tin cậy hơn.

## Unreleased

## 2.8.6 — Headroom durable init on Windows

### Fixed

- Không dùng Scheduled Task cho Headroom nữa vì có thể bị Windows chặn quyền `schtasks /Create`.
- Dùng upstream `headroom init -g --port 8787 claude` để cấu hình durable routing ở user scope.
- Claude `SessionStart` hook của Headroom tự start/recover detached runtime khi cần; không yêu cầu admin hoặc một terminal proxy riêng.

## 2.8.5 — Windows setup hang fix

### Fixed

- Fix vòng lặp shim `codebase-memory-mcp.cmd` tự gọi chính nó khiến machine setup có thể treo ngay sau banner.
- Resolver luôn ưu tiên binary `.exe` thật trong `%LOCALAPPDATA%\Programs\codebase-memory-mcp`.
- Thêm progress marker `[1/12] ... [12/12]` để nếu setup dừng ở bước nào thì nhìn thấy ngay.

## 2.8.4 — Headroom Windows persistent deployment fix

### Fixed

- Windows machine setup dùng upstream `headroom deploy --no-docker` thay vì ép trực tiếp `persistent-task`; Headroom tự chọn supervisor phù hợp và có fallback managed detached runtime.
- Khi persistent deployment fail, setup giữ lại diagnostic output cuối để nhìn ra nguyên nhân thay vì chỉ báo BLOCKED chung chung.

## 2.8.3 — Runtime UX on Windows

### Fixed

- Machine setup tạo shim `~/.local/bin/codebase-memory-mcp.cmd` để CMD/PowerShell gọi `codebase-memory-mcp --version` ổn định.
- Headroom được cấu hình persistent cho Claude Code trên Windows; sau setup có thể mở `claude` bình thường mà request vẫn đi qua proxy.

## 2.8.2 — Headroom/code-memory de-duplication

### Fixed

- Headroom launcher dùng `--code-memory none` vì AI-DEV-OS đã chọn `codebase-memory-mcp` làm code-memory chuẩn.
- Tránh để `headroom wrap claude` tự đăng ký thêm Serena và tạo hai graph/code-memory MCP cùng làm một việc.

## 2.8.1 — Runtime integration fixes

### Fixed

- `start-claude-headroom.ps1` không còn tự spawn proxy rồi poll `/stats`; launcher gọi thẳng `headroom wrap claude` upstream để dùng đúng lifecycle/config của Headroom.
- PowerShell launcher có UTF-8 BOM để Windows PowerShell 5.1 hiển thị tiếng Việt đúng.
- Machine setup mang theo fix cài `mattpocock-skills` từ marketplace upstream `mattpocock/skills` khi plugin chưa có trong marketplace cấu hình sẵn.
- Native Claude plugin command trên Windows PowerShell 5.1 không còn làm script chết trước fallback chỉ vì stderr.

## 2.8.0 — Upstream-first external AI stack

### Changed

- Machine setup mặc định cài **upstream thật** cho Ponytail, mattpocock/skills, Headroom, codebase-memory-mcp và Microsoft DAB/SQL MCP CLI.
- Ponytail không còn chỉ được mô phỏng bằng Simplicity Gate trên Claude Code; plugin upstream cung cấp persistence, hooks, subagent injection và các skill review/audit/debt/gain.
- mattpocock/skills được cài từ Claude Code official marketplace; `/grill-with-docs` là workflow ưu tiên cho task mơ hồ/decision-heavy trên Claude.
- AI-DEV-OS adapters tiếp tục làm fallback cho generic agents, không được coi là bản thay thế upstream khi Claude plugin đã có.
- Setup đảm bảo thư mục cài codebase-memory-mcp vào User PATH để CLI/UI gọi được từ terminal mới.
- SQL MCP/DAB chuyển thành machine capability mặc định; có `-SkipSqlServerMcp` nếu không muốn cài.
- Thêm `-SkipExternalAiStack` để opt-out toàn bộ external stack.

### Preserved

- Framework update và machine-tool installation vẫn tách biệt.
- Project knowledge, ordered docs và conflict-safe Knowledge Sync giữ nguyên.
- SQL MCP không tự tạo connection string/permission hoặc kết nối production.

## 2.7.0 — AI engineering stack integration

### Added

- Optional Headroom context-compression profile với MCP compress/retrieve/stats **và transparent proxy/wrap** cho automatic token savings sau pilot.
- Optional Microsoft SQL MCP Server profile qua Data API builder, test/dev + least-privilege/read-only baseline.
- Skills mới: `shape-task`, `tdd`, `resolve-merge-conflicts`, `domain-modeling` cho Claude và generic agent adapters.
- Claude MCP templates cho Headroom và SQL Server DAB.
- Machine setup flag `-WithSqlServerMcp` cài/verify Microsoft.DataApiBuilder 2.0.12 mà không tự cấu hình database.

### Changed

- Task Execution thêm Simplicity Gate: no-code/config → reuse → stdlib/platform → existing dependency → minimum new code.
- Plan/review contract kiểm tra test seam, code ownership cost, overengineering và dependency reuse rõ hơn.
- Context Retrieval biết dùng Headroom khi output lớn/noisy và SQL MCP như runtime evidence cho SQL Server.
- External engineering patterns được hấp thụ vào core thay vì cài chồng Ponytail/mattpocock skills nguyên bộ.
- codebase-memory-mcp tiếp tục là graph/code-intelligence profile, không bị thay bởi tool overlap.

### Safety

- Headroom không auto-install qua apply/update; proxy/wrap là opt-in machine profile và có launcher riêng.
- SQL MCP không tự tạo connection string, không expose database và không cho production/write mặc định.
- Durable knowledge vẫn đi qua conflict-safe Knowledge Sync của AI-DEV-OS.

## 2.6.1 — Update/apply hardening

### Fixed

- Sửa PowerShell Git helper dùng tên `$Args` làm mất tham số native command trên Windows PowerShell 5.1.
- Update migration từ chối path traversal/reparse point và kiểm tra collision trước mutation.
- Rollback không còn dùng `git clean -fd` trên toàn repository.
- Active docs/skills được kiểm tra để không quay lại legacy docs paths.
- Repo đã ở 2.6.0 vẫn nhận được hardening này qua version bump 2.6.1 thay vì bị updater coi là no-op.

### Security

- GitHub Actions dùng quyền `contents: read`, checkout pin full commit SHA và không persist credential.
- codebase-memory-mcp installer/release và Repomix được pin version/source.
- Thêm migration safety tests và security regression gate.


## 2.6.0 — Conflict-safe Knowledge Sync + Ordered Docs Migration

### Added

- Conflict-safe knowledge model: task discovery dùng entry-per-file thay vì append vào shared docs.
- Ordered docs layout cho repo apply mới:
  - `00-overview`
  - `01-development`
  - `02-modules`
  - `03-knowledge`
  - `04-operations`
  - `05-decisions`
  - `06-work`
- `.ai-dev-os/layouts.json` làm source of truth cho path mapping.
- `tools/migrate-docs-layout.ps1` để migrate repo cũ bằng inventory, collision preflight, `git mv`, hash verification và reference rewrite.
- Regression tests cho conflict-safe routing, ordered layout và deterministic migration.

### Changed

- `/update-ai-dev-os` không bootstrap lại repo khi upgrade.
- Repo legacy được tự migrate nguyên file sang ordered layout; project knowledge hiện có được preserve.
- Unknown project-specific docs dưới legacy roots vẫn được giữ bằng prefix mapping thay vì bị bỏ quên.
- Fix-bug, Knowledge Sync, module, operations, work và ADR routing không còn hướng task bình thường vào shared append-only files.
- ADR mới không dùng global sequence; task-generated decisions dùng entry-per-file.
- Shared canonical docs trở thành read-mostly và chỉ đổi khi canonical truth thật sự đổi.
- Version/state chỉ được ghi sau migration + verification PASS.

### Safety

- Destination khác nội dung → STOP trước mutation, không overwrite.
- Destination giống hệt → deduplicate có kiểm soát.
- Migration fail giữa chừng → rollback về clean pre-migration state.
- Không split/rewrite semantics của knowledge cũ bằng suy đoán.
- Không yêu cầu AI đọc lại toàn codebase để tái tạo docs, giảm token và tránh làm mất knowledge.

## 2.5.1 — Agent-aware apply

### Changed

- `/apply-ai-dev-os` bắt buộc chọn `claude`, `generic` hoặc `both` nếu user chưa chỉ rõ.
- Không còn mặc định Claude chỉ vì skill đang chạy trong Claude Code.
- Apply chỉ copy adapter đúng với profile đã chọn và bootstrap một lần.
- Thêm regression test cho agent-selection contract.



## 2.5.0 — One-command apply

### Added

- Personal Claude Code skill `/apply-ai-dev-os`.
- Canonical apply workflow cho repo chưa có AI-DEV-OS.
- Machine setup cài cả `/apply-ai-dev-os` và `/update-ai-dev-os`.

### Changed

- MCP setup đăng ký lại deterministic `codebase-memory-mcp` user-scope bằng đúng executable canonical.
- Third-party installer output không còn có thể lọt vào MCP command config.
- Framework version nâng lên `2.5.0`.



## 2.4.0 — Machine tooling setup

### Added

- `tools/setup-ai-dev-machine.ps1` để setup một lần trên Windows.
- Machine stack: ripgrep, ast-grep, Repomix, codebase-memory-mcp.
- Claude Code MCP user-scope cho codebase-memory-mcp.
- Static machine-setup verifier.

### Changed

- Context retrieval biết phân biệt tool đã cài với tool cần dùng cho task.
- CodeGraph vẫn không cài để tránh overlap với codebase-memory-mcp.
- Framework version nâng lên `2.4.0`.



## 2.3.0 — Global one-repo updater

### Added

- Personal Claude Code updater installer: `tools/install-personal-updater.ps1`.
- Managed-file ownership manifest: `.ai-dev-os/manifest.json`.
- Static updater verifier: `tools/tests/verify-updater.py`.
- Global launcher pattern: install once in `~/.claude/skills/`, use from every product repo.
- Automatic migration for `docs/ai/17-AI-USAGE-POLICY.md` → `docs/team/AI-USAGE-POLICY.md`.

### Changed

- `update-ai-dev-os` now pulls canonical local AI-DEV-OS source, creates a safe update branch, applies framework-owned files, semantically merges mixed files, verifies, then bumps VERSION.
- Framework version is now `2.3.0`.
- Product repositories no longer need manual file copying for normal framework upgrades.



## 2.2.0 — Context efficiency + framework lifecycle

### Added

- `.ai-dev-os/VERSION` để product repo biết baseline AI-DEV-OS đang dùng.
- `UPGRADE.md` và skill `update-ai-dev-os` cho migration an toàn, không overwrite project knowledge.
- `docs/ai/17-CONTEXT-RETRIEVAL.md` với Context Budget, retrieval escalation và session hygiene.
- `docs/ai/18-TOOL-ADOPTION.md` với Tool Adoption Gate.
- Optional tool profile: ripgrep, ast-grep, Repomix và codebase-memory-mcp.
- MCP template `templates/mcp/claude-codebase-memory.json`.
- Spec/implementation plan cho framework lifecycle và context efficiency.

### Changed

- Task Execution không scan toàn repository hoặc Git history theo mặc định.
- CODEBASE-MAP được xác định rõ là durable navigation map, không thay source/test/config.
- bootstrap-project phân biệt initial broad discovery với targeted refresh.
- Claude guide bổ sung `/clear`, `/compact`, subagent isolation và optional retrieval tools.
- README, START-HERE và APPLY-TO-PROJECT bổ sung versioned apply/upgrade workflow.
- Tool mới không được vào default stack chỉ vì popularity hoặc marketing claim.



### Added

- `START-HERE.md` làm cửa vào duy nhất cho người mới: kiểm tra/cài Git, VS Code, Claude Code, project toolchain, copy AI-DEV-OS core, verify context, bootstrap và xử lý `READY / PARTIAL / BLOCKED` trước task đầu tiên.
- `APPLY-TO-PROJECT.md` hướng dẫn bê AI-DEV-OS vào project mới/cũ mà không phải điền toàn bộ docs upfront.
- `USAGE.md` hướng dẫn cách dùng hằng ngày: giao task thế nào, AI tự đọc file nào, khi nào hỏi lại và khi nào refresh bootstrap.
- `CLAUDE-CODE-GUIDE.md` hướng dẫn cài và dùng Claude Code theo workflow thực tế với VS Code, CLI, Plan mode, Git/worktree, skills, subagents, hooks và AI-DEV-OS.
- `docs/README.md` làm documentation map và progressive context router.
- `docs/ai/16-TASK-EXECUTION.md` làm Task Execution Contract với Understanding Gate, Reuse Gate, Dependency Gate, Verification, Cleanup, Knowledge Sync và Production Gate.
- `docs/modules/` cho knowledge theo domain/module, tạo on demand.
- `docs/operations/` cho deployment, migration, rollback, monitoring và troubleshooting knowledge.
- `bootstrap-project` skill cho Claude Code và generic agent skills.
- Claude Code `change-reviewer` và `production-reviewer` subagents cho independent review khi phù hợp.

### Changed

- `README.md` giờ route người mới qua `START-HERE.md` thay vì tự chọn giữa nhiều tài liệu setup.
- `AGENTS.md` được rút xuống thành entry point cực ngắn.
- `CLAUDE.md` chỉ import `AGENTS.md` để tránh hai nguồn sự thật.
- `04-CODEBASE-MAP.md` được nâng thành nơi lưu canonical examples, reusable building blocks, sensitive/generated areas để phục vụ Reuse Gate.
- `06-CODING-STANDARDS.md` được mở rộng cho naming, structure, validation, error, logging, async/concurrency, database, API/data format, dependency policy, cleanup, comment và tool enforcement.
- `bootstrap-project` giờ scan config/tooling/CI/code/tests, phát hiện convention từ evidence lặp lại, tìm canonical examples/reuse sources và kết thúc bằng `READY / PARTIAL / BLOCKED`.
- Setup checklist bổ sung Project Readiness Gate và nêu rõ sau setup không cần nhắc AI đọc từng file mỗi task.
- Definition of Ready bắt buộc giải quyết material ambiguity và kiểm tra reuse trước implementation.
- Definition of Done bổ sung anti-overengineering, dependency, cleanup và anti-test-gaming checks.
- Change reviewer bổ sung kiểm tra duplicate/reuse, dependency, overengineering, test-gaming và stale artifact.
- AI System Maintenance bổ sung module/operations routing và cơ chế biến user clarification thành durable knowledge.
- `update-project-knowledge` skill trở thành bước Knowledge Sync rõ ràng trước Done.
- README được cập nhật theo trải nghiệm mục tiêu: apply → bootstrap → giao task ngắn → AI tự đọc đúng context → review-ready change.
- File index được đồng bộ với cấu trúc repository hiện tại.

## v1

Phiên bản nền đầu tiên gồm:

- `AGENTS.md`, `CLAUDE.md`, GitHub Copilot instructions.
- `docs/ai` cho project knowledge.
- `docs/work` cho research/spec/plan/tasks/verification.
- ADR templates.
- Codex/Claude skills cho research, plan, implement, bug fix, review, verify và knowledge maintenance.
- Prompt templates và work templates.
- Public contribution guide, MIT License, issue forms, PR template và security policy.
