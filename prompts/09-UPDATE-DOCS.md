# Update Project Knowledge

Đọc thay đổi vừa hoàn thành và xác định knowledge nào cần được lưu lâu dài.

Mặc định với knowledge phát hiện trong task:

- business rule/behavior → `docs/03-knowledge/business-rules/entries/<entry-id>-<slug>.md`;
- pitfall/gotcha → `docs/03-knowledge/pitfalls/entries/<entry-id>-<slug>.md`;
- module discovery → `docs/03-knowledge/modules/<module>/entries/<entry-id>-<slug>.md`;
- operations discovery → `docs/03-knowledge/operations/<system>/entries/<entry-id>-<slug>.md`;
- architectural/public-contract decision → `docs/05-decisions/entries/<entry-id>-<slug>.md`;
- recurring procedure → Skill;
- chỉ thuộc task hiện tại → giữ trong `docs/06-work/<task-id>/`.

Không append vào shared summary/index/changelog/list chỉ để persist discovery.
Không dùng global sequence cho file mới.
Chỉ sửa shared canonical docs khi chính task làm thay đổi canonical truth tương ứng.
Không update tài liệu chỉ để thay đổi timestamp.
