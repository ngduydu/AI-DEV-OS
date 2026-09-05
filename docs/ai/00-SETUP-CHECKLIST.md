# Setup Checklist

Checklist dùng khi đưa AI-DEV-OS vào một repository thật. Không cần điền mọi file trước task đầu tiên.

## Phase 1 — Bootstrap vừa đủ để bắt đầu

Bắt buộc xác minh và điền ở mức repository hiện có:

- [ ] `01-PROJECT-CONTEXT.md` — project là gì, boundary chính, ai dùng.
- [ ] `02-PRODUCT.md` — behavior/product intent nếu đây là product repo.
- [ ] `03-ARCHITECTURE.md` — architecture hiện tại, không tưởng tượng tương lai.
- [ ] `04-CODEBASE-MAP.md` — entry point, module/thư mục chính, canonical examples.
- [ ] `06-CODING-STANDARDS.md` — convention thật sự của project.
- [ ] `07-COMMANDS.md` — build/run/test/lint/migration command thực tế.
- [ ] `08-TESTING.md` — test strategy và test location hiện tại.

Business rule và security rule nào đã rõ thì ghi ngay; phần chưa biết có thể để thiếu nếu không chặn task hiện tại.

## Phase 2 — Fill theo usage thực tế

Chỉ bổ sung khi có bằng chứng hoặc task bắt đầu chạm tới:

- [ ] `05-BUSINESS-RULES.md` và `docs/modules/<module>/`.
- [ ] `09-SECURITY.md`.
- [ ] `docs/operations/` cho deploy/migration/rollback/monitoring.
- [ ] `13-KNOWN-PITFALLS.md` từ lỗi/gotcha thật.
- [ ] ADR cho quyết định có trade-off đáng kể.
- [ ] Skill cho procedure đã lặp lại và ổn định.

## Với repository đã có code

Ưu tiên dùng skill `bootstrap-project` để:

```text
scan repository
→ detect stack/structure/commands/tests/conventions
→ fill docs từ evidence
→ đánh dấu UNKNOWN thật sự
→ hỏi chỉ khi ambiguity quan trọng không tự giải được
```

Không bắt developer viết lại knowledge mà codebase đã chứng minh được.

## Trước task đầu tiên

- [ ] `AGENTS.md` vẫn cực ngắn và trỏ về `docs/README.md`.
- [ ] `CLAUDE.md` chỉ import `AGENTS.md` nếu dùng Claude Code.
- [ ] Agent đọc `16-TASK-EXECUTION.md`.
- [ ] Những `UNKNOWN` có thể làm thay đổi behavior/data/security/architecture của task hiện tại đã được giải quyết.

## Không làm

- Không điền thông tin chỉ để file trông đầy.
- Không bịa architecture/business rule từ assumption.
- Không copy coding rule của framework nếu project không dùng.
- Không tạo hàng loạt module docs rỗng.
- Không bắt AI chạy command không tồn tại.
- Không đặt secret, token hoặc connection string thật vào docs.
- Không biến bootstrap thành một dự án documentation kéo dài nhiều ngày.

Xem thêm: `APPLY-TO-PROJECT.md`.