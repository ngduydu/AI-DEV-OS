# Coding Standards

> Chỉ ghi convention thật sự của dự án. Formatter/linter nên enforce những gì có thể enforce tự động.

## Nguyên tắc

- Code dễ đọc hơn code "thông minh".
- Một unit nên có một trách nhiệm rõ.
- Ưu tiên pattern đã tồn tại trong codebase.
- Không tạo abstraction trước nhu cầu thực tế.
- Không duplicate business rule quan trọng ở nhiều nơi nếu có thể tránh.
- Error phải có ngữ cảnh đủ để debug nhưng không lộ dữ liệu nhạy cảm.

## Naming

- Classes/types: ...
- Functions/methods: ...
- Variables: ...
- Database: ...
- API: ...

## Structure

- File mới đặt ở: ...
- Dependency direction: ...
- DTO/model/domain separation: ...

## Error handling

- ...

## Logging

- Log điều gì: ...
- Không log: password/token/secret/PII không cần thiết.

## Async/concurrency

- ...

## Database

- Transaction rule: ...
- Migration rule: ...
- Query rule: ...

## Comment

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
- Nếu cần comment dài để giải thích cả một workflow/business rule, cân nhắc đưa knowledge bền vững vào docs/module docs và để comment trỏ tới lý do cốt lõi.
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

## Canonical examples

Xem `04-CODEBASE-MAP.md`.
