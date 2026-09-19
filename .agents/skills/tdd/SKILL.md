---
name: tdd
description: Test-driven development for a feature or bug fix using small red-green slices. Invoke when the user explicitly wants test-first/TDD or the task is being executed under a test-first plan.
disable-model-invocation: true
---

# TDD

Mục tiêu: dùng test để khóa behavior, không dùng test để khóa implementation detail.

## Loop

Làm theo vertical slice:

```text
một behavior nhỏ
→ viết test qua public/stable seam
→ chạy và thấy RED đúng lý do
→ viết implementation tối thiểu để GREEN
→ chạy lại
→ lặp behavior tiếp theo
→ review/simplify sau khi behavior đã xanh
```

Không viết toàn bộ test cho một feature rồi mới implement toàn bộ.

## Test seam

Ưu tiên seam cao và ổn định nhất đã có sẵn:

1. public API / command / service contract;
2. module boundary;
3. integration seam project đang dùng;
4. unit seam chỉ khi đó là contract thật.

Không tạo interface/factory/helper chỉ để test nếu production design không cần.

## Rules

- RED phải chứng minh test có khả năng fail vì behavior thiếu/sai.
- GREEN chỉ thêm code đủ cho slice hiện tại.
- Không anticipation cho test chưa viết.
- Expected value phải đến từ spec/example/rule độc lập, không tính lại bằng cùng logic implementation.
- Test phải sống sót qua refactor nếu behavior không đổi.
- Bug fix: reproduction test trước fix khi khả thi.
- Không mock cả thế giới nếu project đã có integration harness đơn giản hơn.
- Reuse fixture/helper/test pattern hiện có trước khi tạo mới.
- Sau mỗi GREEN, kiểm tra Simplicity Gate trong Task Execution Contract.

## Khi dừng TDD

Dừng/đổi chiến lược khi:

- chưa hiểu behavior cần khóa;
- không có stable seam mà việc tạo seam mới sẽ làm architecture xấu đi;
- task là migration/manual operation không thể chứng minh hữu ích bằng automated test;
- chi phí harness lớn hơn rủi ro của change.

Khi đó báo rõ verification thay thế.
