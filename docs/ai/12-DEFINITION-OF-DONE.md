# Definition of Done

`Code xong` không đồng nghĩa `Done`.

## Checklist chung

- [ ] Behavior đúng Acceptance Criteria.
- [ ] Không có thay đổi ngoài scope chưa giải thích.
- [ ] Code tuân theo convention dự án.
- [ ] Test liên quan pass.
- [ ] Build/lint/static checks phù hợp pass.
- [ ] Regression risk đã được xem xét.
- [ ] Security impact đã được xem xét.
- [ ] Migration/rollback đã được xử lý nếu cần.
- [ ] Docs/business rule/ADR được cập nhật nếu behavior hoặc quyết định thay đổi.
- [ ] Không đưa secret hoặc debug artifact vào commit.
- [ ] Kết quả verification được báo bằng bằng chứng thực tế.

## Nếu không thể hoàn thành một check

Không đánh dấu pass. Ghi:

```text
NOT VERIFIED: <check>
Reason: <lý do>
Impact: <rủi ro>
```
