# Task Execution Contract

Đây là contract mặc định cho mọi thay đổi trong repository.

Mục tiêu không phải tạo thêm ceremony. Mục tiêu là để agent tạo ra change ở trạng thái **Review Ready / Production Candidate**: đã hiểu đủ, reuse đúng, tuân convention, có verification, knowledge không thất lạc và rủi ro production đã được xem xét.

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

Dùng `docs/06-work/` khi artifacts giúp giữ context, review hoặc handoff.

## 2. Load Relevant Context

Trước khi sửa code:

1. Đọc `docs/README.md`.
2. Đọc `04-CODEBASE-MAP.md` để xác định area/canonical/reuse source trước khi search rộng.
3. Đọc module docs và standards/commands/testing liên quan, không load toàn bộ docs.
4. Nếu đã biết file/path thì đọc trực tiếp.
5. Nếu chưa biết, search có mục tiêu theo `17-CONTEXT-RETRIEVAL.md`: text search → structural search → graph/MCP nếu phù hợp → broaden search khi evidence chưa đủ.
6. Đọc source và test hiện có trước khi đề xuất implementation.

Task bình thường sau bootstrap **không scan lại toàn repository theo mặc định**.

Git history không nằm trong default retrieval path.

Không đưa ra kết luận về code chưa đọc hoặc behavior repository chưa chứng minh.

## 3. Understanding Gate

**Không bắt đầu implementation nếu còn ambiguity quan trọng có thể thay đổi behavior, dữ liệu, API/public contract, architecture, security hoặc Acceptance Criteria.**

Khi gặp điểm chưa rõ:

```text
Tự tìm trong docs/code/test theo retrieval policy trước; chỉ dùng history khi câu hỏi thật sự cần historical evidence
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

Trước khi tạo mới service/helper/component/validator/query/mapper/DTO pattern/business logic:

1. Đọc canonical examples/reusable building blocks trong `04-CODEBASE-MAP.md` nếu có.
2. Search implementation tương tự bằng domain term và behavior, không chỉ tên class dự kiến.
3. Đọc canonical pattern hiện có.
4. Ưu tiên reuse hoặc extend nếu semantics phù hợp.
5. Không tạo abstraction mới chỉ để "sạch hơn" hoặc vì agent quen pattern khác.
6. Nếu vẫn cần tạo mới, phải có lý do kỹ thuật rõ ràng.

Không duplicate business rule quan trọng ở nhiều nơi nếu có thể có một nguồn thực thi rõ ràng.

Không reuse chỉ vì tên giống nhau nếu semantics khác.

## 5. Dependency Gate

Trước khi thêm package/library/service bên ngoài:

1. Search dependency/building block hiện có.
2. Kiểm tra project/platform standard library có đủ không.
3. Chỉ thêm dependency nếu capability cần thiết không được đáp ứng hợp lý bằng code hiện có.
4. Nêu lý do kỹ thuật và impact maintenance/security/license nếu project yêu cầu.
5. Không upgrade dependency ngoài scope task trừ khi bắt buộc để hoàn thành change an toàn.

Dependency ảnh hưởng architecture/public contract/deployment phải được xem như decision/risk tương ứng.

## 6. Plan

Task nhỏ có thể implement ngay sau khi qua các gate trên.

Task vừa/lớn cần plan đủ để trả lời:

- file/module nào thay đổi;
- behavior nào thay đổi;
- data/API contract nào bị ảnh hưởng;
- implementation nào sẽ reuse/extend;
- dependency mới có cần không;
- test nào chứng minh đúng;
- migration/rollback có cần không;
- rủi ro chính là gì.

Không plan vượt quá scope task.

## 7. Implement

- Bám đúng scope và Acceptance Criteria.
- Theo convention thật của project.
- Ưu tiên thay đổi nhỏ, dễ review, dễ rollback.
- Không refactor phần không liên quan chỉ vì tiện thể.
- Không future-proof cho requirement chưa tồn tại.
- Không tạo abstraction cho one-off nếu không có repetition/complexity thực tế.
- Không hard-code secret hoặc dữ liệu nhạy cảm.
- Không hard-code output chỉ để test hiện tại pass.
- Với schema/data destructive, phải thiết kế rollback/recovery hoặc nêu rõ vì sao không thể rollback.

## 8. Verify

Verification là evidence, không phải cảm giác.

1. Chạy check nhỏ nhất đủ chứng minh behavior mới.
2. Chạy check rộng hơn theo `docs/01-development/commands.md` và `docs/01-development/testing.md` khi phù hợp.
3. Bug fix nên có reproduction/regression test khi khả thi.
4. Không nói `pass` nếu chưa chạy.
5. Check không chạy được phải báo `NOT VERIFIED`, lý do và impact.
6. Không sửa/xóa test đúng chỉ để né failure; nếu test sai, phải giải thích bằng evidence.
7. Test phải xác minh behavior, không chỉ implementation detail vô nghĩa.

## 9. Cleanup Gate

Trước review/Done:

- không để dead code/commented-out code do task tạo ra;
- không để temp script/file/debug output/logging nếu không phải artifact có chủ đích;
- không để TODO mơ hồ kiểu `fix later`;
- không để stale comment/docs do behavior vừa đổi;
- không format/refactor hàng loạt file ngoài scope;
- không để duplicate helper/business logic mà Reuse Gate lẽ ra phải phát hiện.

## 10. Independent Review

Không cần spawn reviewer cho mọi typo nhỏ.

Với task Medium/Large hoặc rủi ro đáng kể, ưu tiên review bằng context mới sau implementation.

Claude Code có thể dùng:

- `.claude/agents/change-reviewer.md` để tìm correctness/regression/duplication/convention/overengineering/test-gaming issues;
- `.claude/agents/production-reviewer.md` cho security, migration, config, compatibility, observability và rollback.

Reviewer chỉ đưa findings có bằng chứng, ưu tiên lỗi có khả năng gây sai behavior hoặc production incident hơn style preference.

## 11. Knowledge Sync — bắt buộc

### Conflict-safe Knowledge Sync

Trước khi Done, kiểm tra knowledge vừa học có giá trị cho task sau không.

**Rule mặc định: knowledge phát hiện trong task → mặc định tạo file riêng trong `docs/03-knowledge/`.**

Không append vào shared canonical file chỉ để ghi lại discovery của task.

```text
business rule discovery
→ docs/03-knowledge/business-rules/entries/<entry-id>-<rule>.md

pitfall discovery
→ docs/03-knowledge/pitfalls/entries/<entry-id>-<failure-mode>.md

module discovery
→ docs/03-knowledge/modules/<module>/entries/<entry-id>-<topic>.md

operations discovery
→ docs/03-knowledge/operations/<system>/entries/<entry-id>-<topic>.md
```

Không có central index/summary/changelog phải update sau mỗi task. Trước khi ghi durable artifact, chạy Conflict Surface Gate trong `docs/03-knowledge/README.md`: nếu change chỉ là append item/link/registry vào shared file thì tạo entry riêng.

Chỉ sửa shared canonical docs khi **canonical truth thực sự thay đổi**, ví dụ architecture, project-wide rule, coding convention, command chính thức hoặc canonical implementation thay đổi do chính task này.

Nếu user giải thích một durable rule để gỡ ambiguity, persist rule đó theo conflict-safe routing thay vì mặc định append vào `05-BUSINESS-RULES.md` hoặc `13-KNOWN-PITFALLS.md`.

Existing knowledge từ trước 2.6.0 tiếp tục được đọc; không di chuyển hoặc tách knowledge cũ tự động.

Nếu không có durable knowledge mới, report ngắn gọn:

```text
Knowledge Sync: no durable changes
```

Policy đầy đủ: `docs/03-knowledge/README.md`.


## 12. Production Gate

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

## 13. Final Report

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
Project đã có dependency phù hợp → không thêm cái mới.
Chưa verify → không nói Done.
Không game test để lấy màu xanh.
Knowledge mới → không để chết trong chat.
Risk production chưa xử lý → không gọi Production Ready.
```

## 14. Context Efficiency Gate

Trước khi mở rộng investigation:

- câu hỏi hiện tại có thể trả lời bằng file/path đã biết không?
- CODEBASE-MAP có route đúng area không?
- targeted search đã đủ chưa?
- structural/graph tool có thật sự cần không?
- context vừa load có phục vụ task hiện tại không?

Khi task độc lập hoàn tất và durable knowledge đã Knowledge Sync, với Claude Code nên dùng `/clear` trước task độc lập tiếp theo. Nếu vẫn cùng task nhưng context đã lớn, dùng `/compact`.

Investigation lớn có thể dùng subagent context riêng khi việc đó giúp giữ main context nhỏ.

Chi tiết: `docs/01-development/context-retrieval.md`.
