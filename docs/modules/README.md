# Module Documentation

Thư mục này chứa knowledge theo từng domain/module để agent chỉ cần load context của phần đang sửa.

Không tạo sẵn hàng loạt folder rỗng. Khi một module bắt đầu có đủ business rule/workflow riêng, tạo:

```text
docs/modules/<module>/
```

Tùy nhu cầu, module có thể có:

```text
overview.md          # module làm gì, boundary, dependency chính
business-rules.md    # rule bền vững
workflows.md         # flow/state transition quan trọng
data-model.md        # entity/relationship/invariant nếu cần
api.md               # public contract nếu module có API đáng kể
```

Không bắt buộc đủ 5 file. Một module nhỏ có thể chỉ cần `README.md` hoặc `business-rules.md`.

## Khi agent làm task trong module

1. Đọc module docs hiện có.
2. Đọc implementation/test thực tế.
3. Nếu docs thiếu nhưng code chứng minh được, bổ sung knowledge khi task kết thúc.
4. Nếu behavior quan trọng không thể suy ra an toàn, hỏi user trước khi implement.
5. Nếu một rule áp dụng toàn project, đặt ở global docs thay vì duplicate vào từng module.

## Khi nào không cần module docs?

- module quá nhỏ và không có rule riêng;
- nội dung đã được mô tả đủ ở canonical project docs;
- tài liệu chỉ lặp lại code mà không giúp agent ra quyết định tốt hơn.

Mục tiêu là **context locality**, không phải documentation coverage 100%.