# Setup Checklist

Checklist dùng khi đưa AI-DEV-OS vào một repository thật. Không cần điền mọi file trước task đầu tiên.

## Phase 1 — Bootstrap vừa đủ để bắt đầu

Bắt buộc xác minh và điền ở mức repository hiện có:

- [ ] `01-PROJECT-CONTEXT.md` — project là gì, boundary chính, ai dùng.
- [ ] `02-PRODUCT.md` — behavior/product intent nếu đây là product repo.
- [ ] `03-ARCHITECTURE.md` — architecture hiện tại, không tưởng tượng tương lai.
- [ ] `04-CODEBASE-MAP.md` — entry point, module/thư mục chính, canonical examples và reusable building blocks.
- [ ] `06-CODING-STANDARDS.md` — convention thật sự của project, project-specific values và tool enforcement.
- [ ] `07-COMMANDS.md` — build/run/test/lint/format/migration command thực tế và trạng thái đã verify.
- [ ] `08-TESTING.md` — test strategy, test location và minimum verification hiện tại.

Business rule và security rule nào đã rõ thì ghi ngay; phần chưa biết có thể để thiếu nếu không chặn task hiện tại.

## Phase 2 — Fill theo usage thực tế

Chỉ bổ sung khi có bằng chứng hoặc task bắt đầu chạm tới:

- [ ] `05-BUSINESS-RULES.md` và `docs/modules/<module>/`.
- [ ] `09-SECURITY.md`.
- [ ] `docs/operations/` cho deploy/migration/rollback/monitoring/troubleshooting.
- [ ] `13-KNOWN-PITFALLS.md` từ lỗi/gotcha thật.
- [ ] ADR cho quyết định có trade-off đáng kể.
- [ ] Skill cho procedure đã lặp lại và ổn định.

## Với repository đã có code

Ưu tiên dùng skill `bootstrap-project` để:

```text
scan docs/config/tooling/CI/code/tests
→ detect stack/architecture/commands/conventions
→ find canonical examples + reusable building blocks
→ fill docs từ evidence
→ classify Confirmed / Unknown
→ hỏi chỉ khi ambiguity quan trọng không tự giải được
→ Project Readiness Gate
```

Không bắt developer viết lại knowledge mà codebase đã chứng minh được.

## Project Readiness Gate

Trước task đầu tiên, bootstrap phải báo một trong ba trạng thái:

- `READY` — đủ context để giao task bình thường.
- `PARTIAL` — chỉ một số khu vực đủ context; phải nêu rõ scope an toàn.
- `BLOCKED` — thiếu material knowledge có thể làm AI đoán sai ngay task tiếp theo.

Không dùng số file đã điền làm tiêu chí readiness.

### READY tối thiểu khi

- [ ] Agent hiểu project purpose/boundary.
- [ ] Agent biết stack/architecture/dependency direction chính.
- [ ] Agent tìm được code/module liên quan nhanh.
- [ ] Convention cốt lõi đã được xác định hoặc conflict đã được nêu rõ.
- [ ] Canonical examples/reuse sources đã được ghi ở mức codebase hiện có.
- [ ] Build/test/verify commands đã được xác định; command chưa chạy phải ghi rõ `not executed`.
- [ ] Material UNKNOWN liên quan task dự kiến đã được giải quyết.

## Trước mỗi task bình thường

Bạn **không cần nhắc AI đọc từng file**.

Với Claude Code, flow phải là:

```text
CLAUDE.md
→ AGENTS.md
→ docs/README.md
→ 16-TASK-EXECUTION.md
→ docs/module/code/test liên quan
```

Chi tiết cách dùng hằng ngày: `USAGE.md`.

## Không làm

- Không điền thông tin chỉ để file trông đầy.
- Không bịa architecture/business rule/convention từ assumption.
- Không copy coding rule của framework/project khác nếu repository chưa chứng minh.
- Không chọn một file bất thường làm canonical convention.
- Không tạo hàng loạt module docs rỗng.
- Không bắt AI chạy command không tồn tại.
- Không ghi command chưa verify như một fact đã chạy thành công.
- Không đặt secret, token hoặc connection string thật vào docs.
- Không biến bootstrap thành một dự án documentation kéo dài nhiều ngày.

Xem thêm:

- `APPLY-TO-PROJECT.md` — cách áp framework vào project.
- `USAGE.md` — cách giao task hằng ngày.