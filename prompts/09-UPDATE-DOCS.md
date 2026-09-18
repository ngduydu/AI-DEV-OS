# Update Project Knowledge

Đọc thay đổi vừa hoàn thành và xác định knowledge nào cần được lưu lâu dài.

Mặc định với knowledge phát hiện trong task:

- business rule/behavior → `docs/knowledge/business-rules/entries/<entry-id>-<slug>.md`;
- pitfall/gotcha → `docs/knowledge/pitfalls/entries/<entry-id>-<slug>.md`;
- module discovery → `docs/knowledge/modules/<module>/entries/<entry-id>-<slug>.md`;
- operations discovery → `docs/knowledge/operations/<system>/entries/<entry-id>-<slug>.md`;
- architectural/public-contract decision → `docs/decisions/entries/<entry-id>-<slug>.md`;
- recurring procedure → Skill;
- chỉ thuộc task hiện tại → giữ trong `docs/work/<task-id>/`.

Không append vào shared summary/index/changelog/list chỉ để persist discovery.
Không dùng global sequence cho file mới.
Chỉ sửa shared canonical docs khi chính task làm thay đổi canonical truth tương ứng.
Không update tài liệu chỉ để thay đổi timestamp.
