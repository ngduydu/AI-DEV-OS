---
name: bootstrap-project
description: Apply or refresh AI-DEV-OS in an existing or new repository. Use when project docs are missing, stale, newly copied from the template, or when onboarding a codebase so agents can work reliably with minimal manual setup.
---

# Bootstrap Project

Mục tiêu: tạo **minimum reliable project knowledge** từ evidence thật của repository, không viết documentation cho đẹp.

## 1. Inspect trước khi ghi

Đọc/search đủ để xác định:

- project/product purpose nếu repository thể hiện được;
- tech stack và dependency chính;
- entry point và project/module structure;
- architecture/dependency direction hiện tại;
- build/run/test/lint/migration commands;
- test framework và test locations;
- coding/naming/error/logging conventions có bằng chứng;
- business rules/invariants rõ từ code/test/docs;
- deployment/operations artifacts đang tồn tại.

Ưu tiên code, test, config, scripts và existing docs làm evidence.

## 2. Fill minimum docs

Cập nhật trước các file có ích ngay:

- `docs/ai/01-PROJECT-CONTEXT.md`
- `docs/ai/02-PRODUCT.md` nếu là product repo và có evidence
- `docs/ai/03-ARCHITECTURE.md`
- `docs/ai/04-CODEBASE-MAP.md`
- `docs/ai/06-CODING-STANDARDS.md`
- `docs/ai/07-COMMANDS.md`
- `docs/ai/08-TESTING.md`

Bổ sung business/security/module/operations docs khi repository thực sự có knowledge để ghi.

## 3. Không bịa để lấp template

Phân biệt:

- **Confirmed**: repository chứng minh được → ghi.
- **Unknown but non-blocking**: chưa cần cho task hiện tại → có thể bỏ trống hoặc ghi ngắn gọn nếu việc theo dõi có giá trị.
- **Unknown and material**: có thể thay đổi behavior/data/architecture/security → hỏi user trước khi dùng làm assumption.

Không biến inference yếu thành fact.

## 4. Preserve existing knowledge

Nếu project đã có docs:

- không overwrite mù quáng;
- giữ confirmed knowledge vẫn đúng;
- sửa stale/contradictory content khi có evidence;
- nêu conflict không thể tự giải quyết;
- tránh duplicate cùng một rule ở nhiều file.

## 5. Create module/operations docs on demand

Không scaffold hàng chục folder rỗng.

Chỉ tạo `docs/modules/<module>/` khi module có context riêng đáng giữ.
Chỉ tạo file trong `docs/operations/` khi có deploy/migration/rollback/monitoring knowledge thật.

## 6. Validate bootstrap

Trước khi kết thúc, kiểm tra agent có thể trả lời:

- Project này làm gì?
- Stack/architecture hiện tại là gì?
- Code liên quan nằm ở đâu?
- Pattern/convention nên reuse là gì?
- Build/test bằng command nào?
- Những unknown nào có thể chặn task tiếp theo?

Không tuyên bố command/test là đúng nếu chưa xác minh từ repository hoặc chưa chạy khi có thể chạy an toàn.

## 7. Report

Báo ngắn gọn:

```text
Bootstrapped:
- <docs updated>

Evidence:
- <code/config/tests/scripts inspected>

Unknowns:
- <material unknowns only>

Ready for tasks:
- Yes / Blocked by ...
```

Sau bootstrap, mọi task tiếp tục theo `docs/ai/16-TASK-EXECUTION.md`.