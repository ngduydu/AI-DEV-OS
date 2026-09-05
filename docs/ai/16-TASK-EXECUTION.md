# Task Execution Contract

Đây là contract mặc định cho mọi thay đổi trong repository.

Mục tiêu không phải tạo thêm ceremony. Mục tiêu là để agent tạo ra change ở trạng thái **Review Ready / Production Candidate**: đã hiểu đủ, reuse đúng, có verification, knowledge không thất lạc và rủi ro production đã được xem xét.

## Flow

```text
Receive Task
↓
Classify
↓
Load Relevant Context
↓
Inspect Existing Code / Tests
↓
Understanding Gate
↓
Reuse Gate
↓
Plan nếu cần
↓
Implement
↓
Verify
↓
Independent Review nếu phù hợp
↓
Knowledge Sync
↓
Production Gate
↓
Report
```

## 1. Classify task

Process phải tỷ lệ với độ phức tạp.

### Small

Thay đổi cục bộ, behavior rõ, rủi ro thấp.

```text
Understand → Inspect → Change → Verify → Sync → Report
```

Không cần tạo work folder nếu không giúp ích.

### Medium

Feature/bug chạm nhiều file, có business rule hoặc regression risk đáng kể.

```text
Understand → Research vừa đủ → Plan → Implement → Verify → Review → Sync → Report
```

### Large / Risky

Architecture, auth/security/payment, migration dữ liệu, cross-cutting change, refactor lớn hoặc codebase chưa hiểu rõ.

```text
Research → Spec → Plan → Tasks → Implement theo phase → Verify → Independent Review → Production Gate
```

Dùng `docs/work/` khi artifacts giúp giữ context, review hoặc handoff.

## 2. Load Relevant Context

Trước khi sửa code:

1. Đọc `docs/README.md`.
2. Xác định module/khu vực bị ảnh hưởng.
3. Đọc docs liên quan, không load toàn bộ docs.
4. Đọc code và test hiện có trước khi đề xuất implementation.
5. Search các implementation/pattern tương tự.

Không đưa ra kết luận về code chưa đọc hoặc behavior repository chưa chứng minh.

## 3. Understanding Gate

**Không bắt đầu implementation nếu còn ambiguity quan trọng có thể thay đổi behavior, dữ liệu, API/public contract, architecture, security hoặc Acceptance Criteria.**

Khi gặp điểm chưa rõ:

```text
Tự tìm trong docs/code/test/history trước
↓
Có bằng chứng đủ mạnh?
├── Có → tiếp tục
└── Không → hỏi người giao việc
             ↓
             nhận câu trả lời
             ↓
             lưu knowledge bền vững vào docs phù hợp
             ↓
             tiếp tục
```

Không hỏi những thứ agent có thể tự xác định an toàn từ convention hoặc codebase.

Ví dụ phải hỏi nếu repository chưa chứng minh được:

- business rule nào đúng trong hai behavior khác nhau;
- dữ liệu nào được phép xóa/thay đổi;
- backward compatibility có bắt buộc không;
- auth/permission mong muốn;
- Acceptance Criteria có hai cách hiểu dẫn tới implementation khác nhau.

## 4. Reuse Gate

Trước khi tạo mới service/helper/component/validator/query/DTO pattern/business logic:

1. Search implementation tương tự.
2. Đọc canonical pattern hiện có.
3. Ưu tiên reuse hoặc extend nếu semantics phù hợp.
4. Không tạo abstraction mới chỉ để "sạch hơn" hoặc vì agent quen pattern khác.
5. Nếu vẫn cần tạo mới, phải có lý do kỹ thuật rõ ràng.

Không duplicate business rule quan trọng ở nhiều nơi nếu có thể có một nguồn thực thi rõ ràng.

## 5. Plan

Task nhỏ có thể implement ngay sau khi qua hai gate trên.

Task vừa/lớn cần plan đủ để trả lời:

- file/module nào thay đổi;
- behavior nào thay đổi;
- data/API contract nào bị ảnh hưởng;
- test nào chứng minh đúng;
- migration/rollback có cần không;
- rủi ro chính là gì.

Không plan vượt quá scope task.

## 6. Implement

- Bám đúng scope và Acceptance Criteria.
- Theo convention thật của project.
- Ưu tiên thay đổi nhỏ, dễ review, dễ rollback.
- Không refactor phần không liên quan chỉ vì tiện thể.
- Không hard-code secret hoặc dữ liệu nhạy cảm.
- Với schema/data destructive, phải thiết kế rollback hoặc nêu rõ vì sao không thể rollback.

## 7. Verify

Verification là evidence, không phải cảm giác.

1. Chạy check nhỏ nhất đủ chứng minh behavior mới.
2. Chạy check rộng hơn theo `docs/ai/07-COMMANDS.md` và `docs/ai/08-TESTING.md` khi phù hợp.
3. Bug fix nên có reproduction/regression test khi khả thi.
4. Không nói `pass` nếu chưa chạy.
5. Check không chạy được phải báo `NOT VERIFIED`, lý do và impact.

## 8. Independent Review

Không cần spawn reviewer cho mọi typo nhỏ.

Với task Medium/Large hoặc rủi ro đáng kể, ưu tiên review bằng context mới sau implementation.

Claude Code có thể dùng:

- `.claude/agents/change-reviewer.md` để tìm correctness/regression/duplication/convention issues;
- `.claude/agents/production-reviewer.md` cho security, migration, config, compatibility, observability và rollback.

Reviewer chỉ đưa findings có bằng chứng, ưu tiên lỗi có khả năng gây sai behavior hoặc production incident hơn style preference.

## 9. Knowledge Sync — bắt buộc

Trước khi Done, kiểm tra knowledge vừa học có giá trị cho task sau không.

| Knowledge | Nơi lưu |
|---|---|
| Rule áp dụng gần như mọi task | giữ tối thiểu trong entry point hoặc global docs |
| Project knowledge chung | `docs/ai/` |
| Knowledge/business rule của module | `docs/modules/<module>/` |
| Deploy/migration/rollback/monitoring | `docs/operations/` |
| Quyết định có trade-off đáng kể | `docs/decisions/` ADR |
| Gotcha khó nhớ/lặp lại | `docs/ai/13-KNOWN-PITFALLS.md` |
| Procedure ổn định dùng lặp lại | Skill |
| Context chỉ có giá trị cho task này | `docs/work/` |

Nếu user đã giải thích một rule bền vững để gỡ ambiguity, không để câu trả lời đó chết trong chat.

Nếu không có durable knowledge mới, report ngắn gọn: `Knowledge Sync: no durable changes`.

## 10. Production Gate

Trước khi gọi change là Production Candidate, đánh giá những mục liên quan:

- backward compatibility;
- database/schema/data migration;
- rollback/recovery;
- config/environment/secret;
- auth/security/privacy;
- concurrency/idempotency nếu liên quan;
- performance/capacity nếu liên quan;
- logging/metrics/alerts/observability;
- dependency/integration failure;
- deployment order hoặc feature flag nếu cần.

Không phải task nào cũng cần mọi mục. Nhưng mục có liên quan không được bỏ qua chỉ vì test local pass.

Nếu có production risk chưa được giải quyết hoặc chưa xác minh, không báo `Production Ready`; nêu rõ blocker/risk.

## 11. Final Report

Báo ngắn gọn và dựa trên evidence:

```text
Changed:
- ...

Verified:
- ...

Review:
- ...

Knowledge Sync:
- ...

Production:
- Candidate / Blocked / Not applicable
- remaining risks nếu có
```

Không tuyên bố mạnh hơn bằng chứng hiện có.

## Nguyên tắc cuối

```text
Không hiểu đủ → không đoán.
Chưa tìm code cũ → không tạo mới.
Chưa verify → không nói Done.
Knowledge mới → không để chết trong chat.
Risk production chưa xử lý → không gọi Production Ready.
```