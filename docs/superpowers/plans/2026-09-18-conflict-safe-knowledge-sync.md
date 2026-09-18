# Conflict-safe Knowledge Sync — Implementation Plan

## Mục tiêu

Loại bỏ conflict rác khi nhiều task/branch song song cùng Knowledge Sync vào shared docs.

## Thiết kế

- Knowledge phát hiện trong task mặc định ghi thành file mới dưới `docs/knowledge/`.
- Không có central index phải append sau mỗi task.
- Shared canonical docs chỉ sửa khi canonical truth thật sự thay đổi.
- `docs/ai/13-KNOWN-PITFALLS.md` trở thành legacy/router; giữ nguyên entry cũ, không append entry mới.
- Existing project knowledge không bị split/move tự động trong upgrade.
- `/update-ai-dev-os` từ 2.5.x lên 2.6.0 tự apply policy mới bằng managed/mixed files.
- Current in-flight branches không bắt buộc rebase/update giữa task; migration chạy khi repo clean.

## File chính

- `docs/knowledge/README.md` — policy mới.
- `docs/ai/05-BUSINESS-RULES.md` — canonical-only rule.
- `docs/ai/13-KNOWN-PITFALLS.md` — legacy/read-only aggregation rule.
- `docs/ai/14-AI-SYSTEM-MAINTENANCE.md` — routing mới.
- `docs/ai/16-TASK-EXECUTION.md` — Knowledge Sync conflict-safe.
- `docs/README.md` — retrieval route.
- `.claude/skills/update-project-knowledge/SKILL.md` + generic mirror.
- bootstrap skills — tạo/nhận biết `docs/knowledge/`.
- `UPGRADE.md` + updater skill — migration 2.6.0.
- manifest/version/changelog.

## Verification

- Static regression test xác nhận:
  - version/manifest 2.6.0;
  - knowledge root tồn tại;
  - task skill mặc định tạo isolated file;
  - shared append bị cấm;
  - 13 không nhận entry mới;
  - updater có migration 2.6.0 và preserve existing content;
  - Claude/generic skill mirror giữ cùng policy.
- Windows CI chạy test + PowerShell parser.
