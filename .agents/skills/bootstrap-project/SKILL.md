---
name: bootstrap-project
description: Apply or refresh AI-DEV-OS in an existing or new repository. Use when project docs are missing, stale, newly copied from the template, or when onboarding a codebase so agents can work reliably with minimal manual setup.
---

# Bootstrap Project

Mục tiêu: tạo **minimum reliable project knowledge** từ evidence thật của repository để sau đó user có thể giao task ngắn và agent tự làm đúng workflow.

Không viết documentation cho đẹp. Không bịa convention. Không hỏi user những gì repository có thể tự chứng minh.

## 1. Scan evidence trước khi hỏi

Ưu tiên đọc/search theo thứ tự:

1. Existing docs: `README`, architecture, ADR, runbook, module docs.
2. Project/package files: solution/project/package manifests, dependency declarations.
3. Tooling/config: `.editorconfig`, formatter/linter/analyzer config, tsconfig/build config, test config.
4. CI/CD: workflow/pipeline files, build/test/lint/security commands.
5. Application entry points và project/module structure.
6. Representative implementation ở nhiều khu vực, không lấy một file bất thường làm chuẩn.
7. Tests, migrations, schema, scripts, config mẫu.
8. Git/history chỉ khi cần giải thích convention/decision mà snapshot hiện tại chưa đủ.

Phải tìm được bằng chứng cho:

- project/product purpose;
- tech stack và dependency chính;
- architecture/dependency direction hiện tại;
- entry points/module boundaries;
- build/run/test/lint/format/migration commands;
- test framework/test locations;
- coding/naming/error/logging/validation conventions;
- API/data/database convention nếu tồn tại;
- canonical examples;
- reusable building blocks;
- business rules/invariants rõ;
- deployment/operations artifacts;
- sensitive/generated/vendor areas.

## 2. Detect convention từ pattern lặp lại

Không suy ra convention từ một file duy nhất nếu repository có nhiều implementation để đối chiếu.

Một convention được coi là **Confirmed** khi có ít nhất một trong các nguồn mạnh:

- config/tooling enforce trực tiếp;
- docs/ADR hiện hành;
- nhiều implementation nhất quán;
- tests/public contract chứng minh behavior;
- user xác nhận rõ.

Nếu codebase không nhất quán, ghi conflict thay vì tự chọn một style ngẫu nhiên.

## 3. Fill minimum docs

Cập nhật trước các file có ích ngay:

- `docs/ai/01-PROJECT-CONTEXT.md`
- `docs/ai/02-PRODUCT.md` nếu là product repo và có evidence
- `docs/ai/03-ARCHITECTURE.md`
- `docs/ai/04-CODEBASE-MAP.md`
- `docs/ai/06-CODING-STANDARDS.md`
- `docs/ai/07-COMMANDS.md`
- `docs/ai/08-TESTING.md`

Bổ sung `05-BUSINESS-RULES.md`, `09-SECURITY.md`, `docs/modules/`, `docs/operations/` chỉ khi project thực sự có knowledge để ghi.

Không bắt buộc mọi template field phải đầy trước task đầu tiên.

## 4. Populate Codebase Map để phục vụ Reuse Gate

`04-CODEBASE-MAP.md` phải có nếu repository cho phép xác định:

- entry points;
- module/folder boundaries;
- canonical endpoint/controller/API example;
- canonical service/use-case example;
- validation example;
- data access/query example;
- unit/integration test example;
- reusable services/helpers/components/validators/mappers/infrastructure;
- sensitive/generated/vendor areas.

Mục tiêu là để agent task sau **search và reuse trước khi tạo mới**.

Nếu chưa có canonical example cho một pattern, để trống hoặc ghi `Not established`; không chọn bừa.

## 5. Populate Coding Standards từ evidence

`06-CODING-STANDARDS.md` phải phân biệt:

- generic engineering rule của AI-DEV-OS;
- convention thật của project;
- rule được tool enforce;
- convention chưa xác định.

Cố gắng fill khi có evidence:

- naming;
- file/folder placement;
- dependency direction;
- error handling;
- validation;
- logging;
- async/concurrency;
- database/data access;
- API/data format;
- comments;
- dependency/package policy;
- formatter/linter/analyzer/test/CI enforcement.

Không copy convention từ project/template khác chỉ vì cùng technology stack.

## 6. Verify commands

Đọc scripts/CI/config trước.

Với command an toàn và môi trường cho phép, chạy/xác minh để phân biệt:

- `Confirmed and executed`
- `Confirmed from repository config/CI but not executed here`
- `Unknown / not verified`

Không ghi một command đoán được như fact.

Không tự chạy:

- production deploy;
- destructive DB/data command;
- secret rotation;
- irreversible external action.

## 7. Xử lý Unknown

Phân loại:

### Confirmed
Repository/user chứng minh được → ghi vào canonical docs.

### Unknown but non-blocking
Không ảnh hưởng task đầu tiên/behavior quan trọng → có thể để thiếu.

### Unknown and material
Có thể thay đổi behavior, data, public contract, architecture, security, destructive operation hoặc Acceptance Criteria → hỏi user.

Agent phải search đủ trước khi hỏi. Không hỏi user chỉ để họ chép lại codebase cho agent.

## 8. Preserve existing knowledge

Nếu project đã có docs:

- không overwrite mù quáng;
- giữ knowledge vẫn đúng;
- sửa stale/contradictory content khi có evidence mạnh;
- nêu conflict không thể tự giải quyết;
- tránh duplicate cùng một rule ở nhiều file;
- không biến inference yếu thành source of truth.

## 9. Module và Operations docs theo nhu cầu

Không scaffold hàng chục folder rỗng.

Chỉ tạo `docs/modules/<module>/` khi module có business rule/workflow/data/API knowledge riêng đáng giữ.

Chỉ tạo `docs/operations/` content khi có deploy/migration/rollback/monitoring/troubleshooting knowledge thật.

## 10. Project Readiness Gate

Trước khi báo bootstrap xong, tự kiểm tra:

### READY
Có thể bắt đầu giao task nếu agent có thể xác định đáng tin cậy:

- project purpose/boundary;
- stack/architecture chính;
- code/module location;
- project conventions quan trọng;
- canonical examples/reuse sources ở mức codebase hiện có;
- build/test/verification commands hoặc trạng thái chưa-execute rõ ràng;
- material unknowns đã được giải quyết hoặc task đầu tiên chưa phụ thuộc vào chúng.

### PARTIAL
Có thể làm một số task, nhưng một số area còn thiếu knowledge. Phải nêu rõ scope nào an toàn và scope nào cần bootstrap/clarification thêm.

### BLOCKED
Thiếu material knowledge khiến agent có nguy cơ đoán sai ngay cả với task dự kiến tiếp theo.

Không dùng `READY` chỉ vì đã fill nhiều file.

## 11. Report

Báo ngắn gọn:

```text
Bootstrap status: READY / PARTIAL / BLOCKED

Updated:
- <docs>

Canonical examples / reuse sources:
- <paths>

Commands:
- <confirmed/executed/not verified>

Material unknowns:
- <only important unknowns>

Next usage:
- Giao task bình thường theo USAGE.md
```

Sau bootstrap, **không chạy bootstrap lại mỗi task**. Mọi task tiếp tục theo `docs/ai/16-TASK-EXECUTION.md`.