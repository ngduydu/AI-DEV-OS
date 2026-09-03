# Implement Plan

Thực hiện plan đã được chấp nhận.

Quy tắc:

1. Đọc lại plan và các docs được reference.
2. Làm từng phase, không tự mở rộng scope.
3. Sau mỗi phase chạy verification đã định nghĩa nếu khả thi.
4. Nếu phát hiện assumption của plan sai, dừng phần đó và cập nhật plan trước khi tiếp tục.
5. Không "fix tiện" vấn đề không liên quan.
6. Sau cùng chạy final checks, review diff và cập nhật `VERIFICATION.md` nếu dùng work folder.
7. Báo rõ check nào thực sự đã chạy.
