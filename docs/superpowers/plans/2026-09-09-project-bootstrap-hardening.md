# Project Bootstrap Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Làm AI-DEV-OS đủ gọn để áp vào nhiều project nhưng đủ chặt để sau bootstrap, agent có thể nhận task ngắn và tạo change ở trạng thái Review Ready / Production Candidate với convention, reuse, verification và knowledge sync đúng dự án.

**Architecture:** Giữ `AGENTS.md`/`CLAUDE.md` tối giản. Dùng `docs/README.md` làm router, `docs/ai/*` làm global project knowledge, `docs/modules/*` làm context theo module, `bootstrap-project` làm cơ chế tự khám phá/fill knowledge từ evidence, và Task Execution Contract làm execution gate. Không tạo thêm nhiều lớp docs mới nếu knowledge đã có nơi canonical.

**Tech Stack:** Markdown repository conventions, Claude Code skills/subagents, GitHub workflow.

**Spec:** Yêu cầu đã chốt trong cuộc trao đổi: áp template vào project → fill/bootstrap tối thiểu → giao task ngắn → AI tự đọc đúng context, hỏi khi ambiguity quan trọng, reuse code cũ, tuân convention, verify, review, sync docs và kiểm tra production readiness.

## Global Constraints

- `AGENTS.md` và `CLAUDE.md` phải tiếp tục cực ngắn.
- Không hard-code convention của một stack/project tưởng tượng vào global template.
- Convention nào có thể infer từ code/config/tooling phải để `bootstrap-project` tự phát hiện trước khi hỏi user.
- Không tạo docs/folder rỗng chỉ để đủ cấu trúc.
- User clarification bền vững phải được persist vào canonical docs.
- Existing implementation phải được search trước khi tạo abstraction/code mới.
- Evidence trước completion claim.
- Human review vẫn là gate cuối trước merge/deploy.

---

### Task 1: Hoàn thiện Coding Standards template

**Files:**
- Modify: `docs/ai/06-CODING-STANDARDS.md`

**Interfaces:**
- Consumes: `docs/ai/04-CODEBASE-MAP.md`, `docs/ai/16-TASK-EXECUTION.md`
- Produces: canonical nơi lưu convention toàn project và các trường project-specific cần bootstrap/fill.

- [ ] Mở rộng convention cho naming, structure/dependency, reuse, error handling, validation, logging, async/concurrency, database/data access, API/data format, dependency policy, code cleanup và comments.
- [ ] Phân biệt rõ `Project-specific values` với nguyên tắc generic để template không áp sai convention lên project.
- [ ] Thêm rule: tool-enforceable conventions phải ưu tiên formatter/linter/analyzer/tests/CI hơn lời nhắc Markdown.
- [ ] Giữ comment convention đã bổ sung và đảm bảo không khuyến khích comment rác.
- [ ] Verify file không còn placeholder mơ hồ ở các mục cốt lõi; placeholder chỉ tồn tại nơi project thật phải điền.

### Task 2: Nâng Codebase Map thành bản đồ reuse/canonical examples

**Files:**
- Modify: `docs/ai/04-CODEBASE-MAP.md`

**Interfaces:**
- Consumes: codebase thực của project khi bootstrap.
- Produces: canonical examples và reusable building blocks cho Reuse Gate.

- [ ] Bổ sung bảng reusable building blocks: shared services, helpers, validators, components, utilities, data access, cross-cutting infrastructure.
- [ ] Mở rộng canonical examples: endpoint/controller, use case/service, validation, mapping/DTO, data access/query, transaction, background job, UI component, unit/integration test nếu project có.
- [ ] Ghi rule agent phải inspect canonical example phù hợp trước khi tạo code mới.
- [ ] Thêm vùng generated/vendor/sensitive code để tránh sửa sai.

### Task 3: Làm bootstrap-project tự phát hiện convention và readiness

**Files:**
- Modify: `.claude/skills/bootstrap-project/SKILL.md`
- Modify: `.agents/skills/bootstrap-project/SKILL.md`

**Interfaces:**
- Consumes: repository code/config/tests/scripts/docs.
- Produces: project knowledge đã fill và trạng thái `READY / PARTIAL / BLOCKED`.

- [ ] Bắt bootstrap scan config/tooling trước: `.editorconfig`, formatter/linter/analyzer config, package/project files, CI, test config, migration scripts.
- [ ] Bắt bootstrap phát hiện convention thực tế từ nhiều ví dụ, không lấy một file bất thường làm chuẩn.
- [ ] Bắt bootstrap tìm canonical examples và reusable building blocks, ghi vào `04-CODEBASE-MAP.md`.
- [ ] Bắt bootstrap fill `06-CODING-STANDARDS.md` bằng confirmed project conventions.
- [ ] Bắt bootstrap chạy/xác minh safe commands khi có thể và không ghi command chưa verify như fact.
- [ ] Bắt bootstrap hỏi user chỉ với unknown material không infer an toàn được.
- [ ] Thêm Project Readiness Gate với điều kiện READY cụ thể.
- [ ] Đồng bộ nội dung Claude và generic agent skill.

### Task 4: Rút quy trình apply thành quick-start thật sự

**Files:**
- Modify: `APPLY-TO-PROJECT.md`
- Modify: `docs/ai/00-SETUP-CHECKLIST.md`
- Modify: `docs/README.md`

**Interfaces:**
- Consumes: bootstrap skill và global docs.
- Produces: hướng dẫn cho project mới/cũ mà người dùng có thể làm nhanh.

- [ ] Thêm Quick Start cho project có code: copy core → bootstrap → review unknowns → commit bootstrap → giao task.
- [ ] Thêm Quick Start cho project mới: chỉ fill các quyết định đã biết; để knowledge tăng dần theo code.
- [ ] Nêu rõ minimum information trước task đầu tiên và những gì không cần điền trước.
- [ ] Thêm convention/canonical example/readiness vào checklist.
- [ ] Route rõ Coding Standards + Codebase Map cho task tạo code mới.

### Task 5: Siết chất lượng task và Definition of Done

**Files:**
- Modify: `docs/ai/16-TASK-EXECUTION.md`
- Modify: `docs/ai/12-DEFINITION-OF-DONE.md`
- Modify: `.claude/agents/change-reviewer.md`

**Interfaces:**
- Consumes: coding standards, codebase map, task requirements.
- Produces: change sạch, không over-engineering, không test-gaming, không artifact rác.

- [ ] Thêm dependency gate: không thêm package/library nếu project đã có giải pháp phù hợp; dependency mới phải có lý do.
- [ ] Thêm anti-overengineering: không refactor ngoài scope, không abstraction cho one-off, không future-proofing giả định.
- [ ] Thêm anti-test-gaming: test xác minh solution, không hard-code cho test cases hoặc sửa test đúng để né lỗi.
- [ ] Thêm cleanup: không để temp scripts/debug output/commented-out code/stale TODO sau task.
- [ ] Change reviewer kiểm tra các lỗi trên cùng duplicate/reuse/convention.
- [ ] DoD có checklist tương ứng.

### Task 6: Cập nhật public docs và metadata

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Modify: `FILE-INDEX.md`
- Modify: `.github/pull_request_template.md`

**Interfaces:**
- Consumes: toàn bộ thay đổi Tasks 1–5.
- Produces: repo self-describing và PR template phản ánh quality gates.

- [ ] README mô tả rõ promise: apply → bootstrap → task execution → progressive knowledge.
- [ ] Changelog ghi bootstrap/convention/canonical/readiness hardening.
- [ ] PR checklist thêm reuse/canonical convention/cleanup/verification/knowledge sync khi liên quan.
- [ ] Recount file index từ tree thực, không đoán số file.

### Task 7: Verification toàn bộ thay đổi

**Files:**
- Inspect: toàn bộ diff của branch so với `main`.

**Interfaces:**
- Consumes: branch hoàn chỉnh.
- Produces: bằng chứng trước khi cập nhật PR.

- [ ] Fetch lại các file trọng yếu từ branch: `06-CODING-STANDARDS.md`, `04-CODEBASE-MAP.md`, bootstrap skill, `APPLY-TO-PROJECT.md`, `16-TASK-EXECUTION.md`.
- [ ] Search branch/diff cho mâu thuẫn: placeholder ngoài vị trí project-specific, rule trùng, path sai, file index sai.
- [ ] Compare branch với `main` và kiểm tra chỉ thay đổi scope AI-DEV-OS hardening.
- [ ] Cập nhật PR #2 title/body để phản ánh toàn bộ scope mới.
- [ ] Chỉ báo hoàn thành sau khi có evidence từ fetch/compare.
