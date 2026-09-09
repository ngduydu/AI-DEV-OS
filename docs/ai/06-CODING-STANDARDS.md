# Coding Standards

> Đây là nguồn sự thật cho convention toàn project. Chỉ ghi rule thật sự của project. Convention có thể enforce bằng formatter/linter/analyzer/test/CI thì ưu tiên enforce bằng tool thay vì chỉ nhắc trong Markdown.

## 1. Nguyên tắc chung

- Code dễ đọc hơn code "thông minh".
- Ưu tiên giải pháp nhỏ nhất giải quyết đúng yêu cầu hiện tại.
- Một unit nên có một trách nhiệm rõ.
- Ưu tiên pattern và building block đã tồn tại trong codebase.
- Không tạo abstraction/helper/core mới trước khi search implementation hiện có.
- Không duplicate business rule quan trọng ở nhiều nơi nếu có thể có một nguồn thực thi rõ ràng.
- Không refactor phần ngoài scope chỉ vì tiện thể.
- Không future-proof cho requirement chưa tồn tại.
- Error/log phải đủ context để debug nhưng không lộ dữ liệu nhạy cảm.

## 2. Project-specific values — phải fill/bootstrap

Các dòng dưới đây là **project-specific**, không được tự áp convention của project khác.

| Hạng mục | Convention của project | Evidence / canonical source |
|---|---|---|
| Language/style guide | | |
| Classes/types | | |
| Functions/methods | | |
| Variables/parameters | | |
| Constants/enums | | |
| Interfaces/abstractions | | |
| File/folder naming | | |
| Database/table/column | | |
| Stored procedure/function | | |
| API route/resource | | |
| DTO/request/response | | |
| Test naming | | |
| Date/time/timezone | | |
| Money/decimal | | |
| ID format | | |
| Null/optional values | | |
| Pagination/filter/sort | | |
| Error code/message | | |

Nếu repository chưa chứng minh được một convention và nó có thể ảnh hưởng behavior/public contract, hỏi user thay vì tự chọn.

## 3. Naming

- Tên phải mô tả intent/domain, không chỉ mô tả kiểu dữ liệu.
- Tránh viết tắt khó hiểu trừ abbreviation đã thành chuẩn của domain/project.
- Không dùng tên chung chung như `data`, `item`, `obj`, `temp`, `helper`, `manager` nếu có thể đặt tên thể hiện trách nhiệm rõ hơn.
- Boolean nên đọc được như một mệnh đề/trạng thái theo convention của ngôn ngữ/project.
- Cùng một khái niệm business phải dùng cùng một thuật ngữ xuyên suốt code, API, DB và docs khi có thể.
- Không đổi naming convention ngoài scope task chỉ để "đẹp hơn".

Project-specific naming rules được điền ở bảng `Project-specific values` phía trên.

## 4. Structure và dependency

Điền từ architecture/codebase thật:

- File mới đặt ở: ...
- Dependency direction: ...
- DTO/model/domain separation: ...
- Boundary giữa module/layer: ...
- Nơi đặt validation: ...
- Nơi đặt transaction orchestration: ...

Quy tắc chung:

- Không xuyên layer/module bằng shortcut nếu project đã có boundary rõ.
- Không đặt business logic ở presentation/controller/UI nếu architecture hiện tại tách business logic ra chỗ khác.
- Không tạo file mới khi một implementation hiện có là nơi canonical để mở rộng.
- Nếu thay đổi cần phá dependency direction hiện tại, coi đó là architecture decision và xử lý qua ADR/review phù hợp.

## 5. Reuse trước khi tạo mới

Trước khi tạo service/helper/component/validator/query/mapper/DTO pattern hoặc business logic mới:

1. Search tên domain và behavior tương tự.
2. Đọc `04-CODEBASE-MAP.md` và canonical examples liên quan.
3. Kiểm tra reusable building blocks hiện có.
4. Reuse/extend khi semantics phù hợp.
5. Chỉ tạo abstraction mới khi có lý do kỹ thuật rõ và không làm API/architecture phức tạp hơn vô ích.

Không reuse chỉ vì tên giống nhau nếu semantics khác.

## 6. Error handling

Project phải điền:

- Exception/error type chuẩn: ...
- Boundary chuyển exception thành response/result: ...
- Error response format: ...
- Retry policy nếu có: ...

Quy tắc chung:

- Không swallow exception im lặng.
- Không `catch` chỉ để log rồi throw lại nếu framework/global handler đã làm việc đó và không thêm context hữu ích.
- Error message phải có context đủ để debug nhưng không chứa secret/token/password/PII không cần thiết.
- Phân biệt lỗi input/validation, business rule, dependency/infrastructure và unexpected error nếu project có contract tương ứng.
- Không trả stack trace/internal exception detail ra public boundary trừ môi trường/debug policy cho phép rõ ràng.

## 7. Validation

Project phải điền:

- Input validation nằm ở: ...
- Business validation nằm ở: ...
- Validation message/code format: ...
- Validation dùng chung được reuse từ: ...

Quy tắc chung:

- Validate tại boundary phù hợp; không duplicate cùng một validation ở nhiều layer nếu không có lý do.
- Validation business/invariant phải nằm gần business behavior/source of truth, không chỉ ở UI.
- Không thêm defensive validation cho trạng thái mà framework/type system/internal invariant đã đảm bảo không thể xảy ra.
- Validation public input/external dependency phải rõ và có test phù hợp.

## 8. Logging

Project phải điền:

- Logger/framework: ...
- Structured logging convention: ...
- Correlation/request/job ID: ...
- Log level guideline: ...

Quy tắc chung:

- Log event có giá trị vận hành/debug, không log mọi dòng code.
- Log phải có context định danh đủ để trace flow khi phù hợp.
- Không log password/token/secret hoặc PII không cần thiết.
- Không để debug/temporary log sau khi task hoàn thành.
- Không dùng log thay cho error handling hoặc monitoring cần thiết.

## 9. Async / concurrency / idempotency

Project phải điền:

- Async convention: ...
- Cancellation convention: ...
- Concurrency control: ...
- Idempotency strategy nếu có: ...

Quy tắc chung:

- Không block async bằng `.Result`, `.Wait()` hoặc tương đương nếu stack/project dùng async end-to-end.
- Propagate cancellation khi boundary/project convention yêu cầu.
- Shared mutable state/concurrent update phải có strategy rõ khi có race risk.
- Retryable external operation phải xem xét idempotency để tránh duplicate side effect.
- Không thêm lock/retry/concurrency mechanism nếu không có risk thực tế.

## 10. Database / data access

Project phải điền:

- Data access pattern/ORM/query layer: ...
- Transaction rule: ...
- Migration rule: ...
- Naming rule: ...
- Query convention: ...
- Soft delete/audit rule nếu có: ...

Quy tắc chung:

- Ưu tiên query chỉ lấy dữ liệu/cột cần thiết; tránh `SELECT *` trong production query trừ khi project có lý do rõ.
- Không tạo query/business calculation trùng logic đã có canonical implementation.
- Transaction boundary phải bao phủ đúng unit of work, không mở transaction rộng hơn cần thiết.
- Schema/data destructive change phải có migration/rollback/recovery strategy tương ứng.
- Query mới/chỉnh lớn trên đường hot path phải xem xét index/cardinality/performance khi liên quan.
- Không chỉnh production database trực tiếp ngoài deployment/migration process của project.

## 11. API / public contract / data format

Project phải điền khi có public/internal API contract:

- Request/response envelope: ...
- Error format: ...
- HTTP/status/result convention: ...
- Versioning/backward compatibility: ...
- Date/time/timezone format: ...
- Money/decimal serialization: ...
- Enum representation: ...
- Pagination/filter/sort: ...
- Null/empty behavior: ...

Quy tắc chung:

- Không thay public contract ngoài scope mà không đánh giá compatibility.
- Cùng một loại endpoint/result phải theo canonical format của project.
- Không phát minh response envelope/error format mới nếu project đã có format chuẩn.
- Contract quan trọng phải có test/schema/docs phù hợp với cách project đang quản lý contract.

## 12. Dependency / package policy

- Trước khi thêm package/library, kiểm tra project đã có dependency/building block giải quyết được chưa.
- Không thêm dependency chỉ để tránh viết một đoạn code nhỏ, rõ và ổn định.
- Dependency mới phải có lý do: capability cần thiết, maintenance/security phù hợp, license phù hợp nếu project yêu cầu.
- Không upgrade dependency ngoài scope task trừ khi bắt buộc để hoàn thành change an toàn.
- Nếu dependency ảnh hưởng architecture/public API/deployment, xem xét ADR/production review.

## 13. Code cleanup

Trước khi Done:

- Không để dead code/commented-out code do task tạo ra.
- Không để temporary script/file/debug output nếu không phải artifact có chủ đích.
- Không để TODO mơ hồ kiểu `fix later`.
- Không đổi format hàng loạt file ngoài scope nếu formatter không bắt buộc.
- Không hard-code giá trị chỉ để test pass.
- Không sửa/xóa test đúng chỉ để né regression; nếu test sai, phải giải thích evidence.

## 14. Comment

Nguyên tắc chính:

> Code phải tự đọc được. Những quyết định hoặc logic không hiển nhiên phải có comment giải thích lý do.

### Bắt buộc comment khi

- Business logic phức tạp hoặc không thể hiểu rõ chỉ bằng tên biến/hàm và cấu trúc code.
- Có workaround/hack do giới hạn của hệ thống, framework, dependency hoặc bên thứ ba.
- Có quyết định dễ bị người sau "sửa nhầm" vì lý do không thể hiện trực tiếp trong code.
- Có thuật toán, query hoặc xử lý dữ liệu phức tạp cần giải thích ý đồ.
- Có side effect, risk hoặc thứ tự xử lý đặc biệt mà việc thay đổi có thể gây lỗi.
- Có TODO tạm thời: phải ghi rõ lý do tồn tại và điều kiện/khi nào cần xử lý.

### Không comment khi

- Code đã tự giải thích được bằng naming và structure rõ ràng.
- Comment chỉ lặp lại chính xác code đang làm gì.
- Comment chỉ mô tả syntax hoặc hành động hiển nhiên.
- Comment đã lỗi thời hoặc không còn đúng với implementation.

### Cách viết comment

- Ưu tiên giải thích **WHY** hơn **WHAT**.
- Viết ngắn, cụ thể và đúng với behavior hiện tại.
- Nếu cần comment dài để giải thích cả workflow/business rule, đưa knowledge bền vững vào docs/module docs và để comment chỉ giữ lý do gần code.
- Khi sửa code, cập nhật hoặc xóa comment liên quan nếu behavior đã thay đổi.

Ví dụ không tốt:

```text
// Tăng i lên 1
i++
```

Ví dụ tốt:

```text
// Dùng counter cuối kỳ đã chốt thay vì thời điểm nhập dữ liệu
// vì phí thuê được tính theo kỳ đối soát với khách hàng.
```

## 15. Canonical examples

Không chỉ mô tả convention bằng chữ. `04-CODEBASE-MAP.md` phải trỏ tới implementation được coi là chuẩn cho các pattern quan trọng của project.

Khi tạo code mới, agent phải ưu tiên đọc canonical example phù hợp trước.

## 16. Tool enforcement

Điền những rule được máy enforce:

| Rule | Tool/config | Command |
|---|---|---|
| Format | | |
| Lint/static analysis | | |
| Naming/analyzer | | |
| Unit/integration tests | | |
| Architecture/dependency checks | | |
| API/schema contract checks | | |
| Secret/security scan | | |

Nếu một rule có thể kiểm tra tự động nhưng project chưa có tool, ghi nhận ở đây hoặc backlog; không giả vờ Markdown có thể enforce tuyệt đối.