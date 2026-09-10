# Changelog

Các thay đổi đáng chú ý của AI-DEV-OS được ghi lại tại đây.

Dự án vẫn đang được kiểm nghiệm qua usage thực tế; workflow và structure chỉ nên thay đổi khi giúp agent làm task đáng tin cậy hơn.

## Unreleased

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
