# Changelog

Các thay đổi đáng chú ý của AI-DEV-OS được ghi lại tại đây.

Dự án vẫn đang được kiểm nghiệm qua usage thực tế; workflow và structure chỉ nên thay đổi khi giúp agent làm task đáng tin cậy hơn.

## Unreleased

### Added

- `APPLY-TO-PROJECT.md` hướng dẫn bê AI-DEV-OS vào project mới/cũ mà không phải điền toàn bộ docs upfront.
- `docs/README.md` làm documentation map và progressive context router.
- `docs/ai/16-TASK-EXECUTION.md` làm Task Execution Contract với Understanding Gate, Reuse Gate, Verification, Knowledge Sync và Production Gate.
- `docs/modules/` cho knowledge theo domain/module, tạo on demand.
- `docs/operations/` cho deployment, migration, rollback, monitoring và troubleshooting knowledge.
- `bootstrap-project` skill cho Claude Code và generic agent skills.
- Claude Code `change-reviewer` và `production-reviewer` subagents cho independent review khi phù hợp.

### Changed

- `AGENTS.md` được rút xuống thành entry point cực ngắn.
- `CLAUDE.md` chỉ import `AGENTS.md` để tránh hai nguồn sự thật.
- Definition of Ready bắt buộc giải quyết material ambiguity và kiểm tra reuse trước implementation.
- Definition of Done bắt buộc Knowledge Sync và phân biệt Production Candidate/Blocked.
- AI System Maintenance bổ sung module/operations routing và cơ chế biến user clarification thành durable knowledge.
- `update-project-knowledge` skill trở thành bước Knowledge Sync rõ ràng trước Done.
- Setup checklist chuyển sang progressive bootstrap: fill minimum reliable knowledge trước, phần còn lại phát triển theo usage.
- README được cập nhật theo mục tiêu v2: agent nhận task → hiểu → reuse → implement → verify → review → sync → production gate.
- File index được đồng bộ và sửa số lượng file.

## v1

Phiên bản nền đầu tiên gồm:

- `AGENTS.md`, `CLAUDE.md`, GitHub Copilot instructions.
- `docs/ai` cho project knowledge.
- `docs/work` cho research/spec/plan/tasks/verification.
- ADR templates.
- Codex/Claude skills cho research, plan, implement, bug fix, review, verify và knowledge maintenance.
- Prompt templates và work templates.
- Public contribution guide, MIT License, issue forms, PR template và security policy.
