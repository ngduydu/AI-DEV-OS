# Codebase Map

> Mục tiêu: giúp người mới và AI tìm đúng chỗ nhanh, reuse đúng và không phải nghiên cứu lại toàn bộ repository cho mỗi task.

## Repository tree mức cao

```text
src/
  ...
tests/
  ...
docs/
  ...
```

## Khu vực chính

| Path | Trách nhiệm | Khi nào sửa |
|---|---|---|
| `...` | | |

## Entry points

| Loại | File/Path | Ghi chú |
|---|---|---|
| Application start | | |
| HTTP/API | | |
| Database | | |
| Background jobs | | |
| Configuration | | |
| Auth/security | | |
| Deployment | | |

## Reusable building blocks

Trước khi tạo implementation mới, search và kiểm tra các building block hiện có.

| Loại | File/Path chuẩn | Dùng cho | Lưu ý |
|---|---|---|---|
| Shared service | | | |
| Helper/utility | | | |
| Validator | | | |
| Mapper | | | |
| Repository/data access | | | |
| Query/specification | | | |
| Transaction/unit of work | | | |
| UI component | | | |
| Cross-cutting infrastructure | | | |
| Integration client | | | |

Không thêm item vào bảng nếu chưa có implementation thật và chưa xác nhận nó là reusable/canonical.

## Canonical examples

Khi AI cần tạo code mới, ưu tiên đọc implementation đã được xem là chuẩn cho đúng pattern đó.

| Pattern | File mẫu | Vì sao là canonical |
|---|---|---|
| Endpoint/controller | | |
| Service/use case | | |
| Domain/business logic | | |
| Validation | | |
| DTO/request/response | | |
| Mapping | | |
| Repository/data access | | |
| Query | | |
| Transaction | | |
| Background job/worker | | |
| Integration client | | |
| UI component/page | | |
| Unit test | | |
| Integration test | | |
| Error handling | | |
| Logging | | |

Không bắt buộc project có đủ mọi pattern. Chỉ điền những pattern thực sự tồn tại.

## Cách dùng Canonical Examples

Trước khi tạo code mới:

1. Xác định pattern cần tạo.
2. Đọc canonical example tương ứng nếu có.
3. Search implementation tương tự gần module đang sửa.
4. Reuse/extend building block hiện có nếu semantics phù hợp.
5. Chỉ tạo pattern/abstraction mới nếu repository chưa có giải pháp phù hợp và có lý do kỹ thuật rõ.

Nếu canonical example đã lỗi thời hoặc không còn đại diện cho code tốt hiện tại, cập nhật bảng thay vì tiếp tục nhân bản pattern cũ.

## Module map

| Module/domain | Path chính | Docs | Dependency quan trọng |
|---|---|---|---|
| | | | |

Module có business rule/workflow riêng nên có docs trong `docs/modules/<module>/` khi knowledge đó giúp task sau làm đúng hơn.

## Khu vực nhạy cảm

| Path/khu vực | Risk | Rule trước khi sửa |
|---|---|---|
| | | |

Ví dụ: production migration, auth, payment, permission, shared contract, generated code.

## Generated/vendor code

Không chỉnh bằng tay trừ khi project quy định khác:

- ...

## Deprecated / tránh dùng cho code mới

| Pattern/File | Lý do | Thay bằng |
|---|---|---|
| | | |

Không xóa code deprecated ngoài scope task nếu chưa có plan/migration rõ.

## Bootstrap rule

Skill `bootstrap-project` phải fill file này từ evidence thật bằng cách:

- scan repository tree;
- xác định entry points/module boundaries;
- search nhiều implementation tương tự;
- chọn canonical examples dựa trên pattern được dùng nhất quán và còn active;
- tìm building blocks đang được reuse thực tế;
- đánh dấu conflict/unknown thay vì chọn ngẫu nhiên.

Không lấy một file bất thường hoặc legacy làm chuẩn chỉ vì tìm thấy đầu tiên.