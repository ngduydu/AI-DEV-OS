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

Comment giải thích **tại sao**, không lặp lại code đang làm gì.

## Canonical examples

Xem `04-CODEBASE-MAP.md`.
