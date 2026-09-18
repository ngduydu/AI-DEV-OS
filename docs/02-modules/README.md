# Module Documentation

Thư mục này chứa canonical knowledge theo từng domain/module để agent chỉ cần load context của phần đang sửa.

Không tạo sẵn hàng loạt folder rỗng. Khi một module bắt đầu có đủ business rule/workflow riêng, có thể tạo:

```text
docs/modules/<module>/
```

Tùy nhu cầu, canonical module docs có thể có:

```text
overview.md
business-rules.md
workflows.md
data-model.md
api.md
```

Không bắt buộc đủ các file trên.

## Khi agent làm task trong module

1. Đọc module docs hiện có.
2. Đọc implementation/test thực tế.
3. Discovery bền vững mới của task mặc định ghi file riêng tại:
   `docs/knowledge/modules/<module>/entries/<entry-id>-<topic>.md`.
4. Chỉ sửa canonical module docs khi chính task làm thay đổi canonical contract/rule/workflow tương ứng.
5. Nếu behavior quan trọng không thể suy ra an toàn, hỏi user trước khi implement.
6. Nếu một rule áp dụng toàn project, không duplicate vào từng module.

Không append discovery của task vào một shared module file chỉ để "cập nhật tài liệu".

## Khi nào không cần module docs?

- module quá nhỏ và không có rule riêng;
- nội dung đã được mô tả đủ ở canonical project docs;
- tài liệu chỉ lặp lại code mà không giúp agent ra quyết định tốt hơn.

Mục tiêu là **context locality** và giảm conflict giữa branch, không phải documentation coverage 100%.
