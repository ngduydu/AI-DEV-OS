# Known Pitfalls

## Legacy / canonical router

File này tồn tại để giữ compatibility với knowledge cũ và làm route cho pitfall.

**Không thêm pitfall mới trực tiếp vào file này** trong task bình thường.

Pitfall mới mặc định tạo file riêng tại:

```text
docs/knowledge/pitfalls/entries/<entry-id>-<failure-mode>.md
```

Xem policy đầy đủ tại:

```text
docs/knowledge/README.md
```

## Existing entries

Các pitfall đã tồn tại từ trước 2.6.0 vẫn hợp lệ và phải được preserve khi upgrade.

Không split/rewrite semantics của knowledge cũ bằng suy đoán. Layout migration có thể `git mv` nguyên file sang ordered path nhưng phải giữ nguyên content.

Nếu project hiện có các entry bên dưới, updater phải giữ nguyên chúng khi semantic merge.

## Khi nào file này được sửa?

Chỉ sửa khi:

- routing/policy canonical thay đổi;
- đang làm knowledge-maintenance có chủ đích;
- cần chỉnh/xóa một pitfall cũ đã trở thành stale và task thực sự có scope đó.

Không append discovery mới của task vào đây.
