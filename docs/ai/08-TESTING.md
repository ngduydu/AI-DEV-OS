# Testing Strategy

## Mục tiêu

Test phải chứng minh behavior quan trọng, không chỉ tăng coverage.

## Test pyramid của dự án

- Unit: ...
- Integration: ...
- End-to-end: ...

## Rule cho feature mới

- Acceptance Criteria quan trọng phải có test hoặc bước verify rõ ràng.
- Ưu tiên test tại boundary mang lại độ tin cậy cao nhất với chi phí hợp lý.
- Không mock mọi thứ nếu integration test đơn giản và đáng tin hơn.

## Rule cho bug fix

Khi khả thi:

```text
Reproduce failure
→ thêm test thể hiện bug
→ sửa
→ test pass
→ chạy regression liên quan
```

Nếu không thể tự động hóa test, ghi rõ manual verification.

## Test naming

...

## Test data

- Không dùng secret/PII production.
- Test phải độc lập hoặc có cleanup rõ ràng.

## Flaky tests

Không rerun đến khi xanh rồi bỏ qua nguyên nhân. Nếu test flaky:

1. xác định mức độ liên quan;
2. ghi nhận rõ;
3. sửa nếu thuộc scope hoặc mở việc riêng.

## Coverage

Coverage target: <Chưa xác định>.

Coverage không thay thế chất lượng assertion.
