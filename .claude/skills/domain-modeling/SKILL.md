---
name: domain-modeling
description: Resolve ambiguous domain terminology and hard-to-reverse domain/architecture decisions, then persist only the durable result into AI-DEV-OS glossary, decision entries, or conflict-safe knowledge.
disable-model-invocation: true
---

# Domain Modeling

Dùng khi vấn đề nằm ở **ngôn ngữ/domain model**, không chỉ implementation.

Ví dụ:

- cùng một từ đang mang hai nghĩa;
- code và người dùng đang dùng thuật ngữ khác nhau;
- boundary/entity bị trộn;
- một quyết định domain/architecture khó đảo ngược cần ADR.

## Process

1. Đọc terminology hiện có trong `docs/00-overview/glossary.md`, module docs và code liên quan.
2. Tìm evidence trong source/test để xem từ đang được dùng thế nào.
3. Đưa ra scenario/edge case làm lộ ambiguity.
4. Chốt canonical term, nghĩa, alias cần tránh và boundary/invariant liên quan.
5. Persist ngay khi truth đã rõ.

## Routing

Canonical terminology thực sự đổi:

```text
docs/00-overview/glossary.md
```

Architecture/public contract khó đảo ngược:

```text
docs/05-decisions/entries/<entry-id>-<decision>.md
```

Business/domain discovery của một task nhưng chưa cần promote thành canonical glossary:

```text
docs/03-knowledge/business-rules/entries/<entry-id>-<topic>.md
```

Không tạo một hệ thống `CONTEXT.md` song song với AI-DEV-OS.

## Discipline

- Glossary là glossary, không biến thành running spec.
- Một term nên định nghĩa được trong 1–2 câu.
- Không ghi assumption thành canonical truth.
- Nếu user nói một rule mâu thuẫn code hiện tại, surface contradiction trước khi sửa code/docs.
- ADR chỉ cho decision có trade-off đáng kể, impact rộng hoặc khó đổi.
- Không append knowledge task bình thường vào shared file chỉ để lưu lịch sử.
