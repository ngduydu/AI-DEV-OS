# Fix Bug

Sửa bug theo hướng root-cause, không patch triệu chứng.

1. Reproduce hoặc tìm evidence rõ ràng.
2. Trace flow để xác định nguyên nhân.
3. Kiểm tra xem behavior có phải business rule hay bug implementation.
4. Khi khả thi, tạo test fail trước fix.
5. Sửa nhỏ nhất giải quyết root cause.
6. Chạy regression test liên quan.
7. Kiểm tra side effect.
8. Ghi pitfall nếu đây là lỗi khó hiểu có khả năng lặp lại.
