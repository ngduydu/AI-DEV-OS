# Refactor

Refactor phải giữ behavior trừ khi spec nói khác.

Trước khi sửa:

1. Xác định pain cụ thể của code hiện tại.
2. Xác định behavior cần giữ và test bảo vệ.
3. Chọn thay đổi nhỏ nhất làm code rõ hơn.
4. Không tạo abstraction chỉ để giảm vài dòng duplicate chưa ổn định.
5. Không đổi public contract nếu không cần.
6. Tách refactor khỏi feature khi có thể để review dễ hơn.

Sau sửa: chạy regression tests và so sánh public behavior.
