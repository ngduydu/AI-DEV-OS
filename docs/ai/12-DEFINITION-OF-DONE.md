# Definition of Done

`Code xong` không đồng nghĩa `Done`.

Một change chỉ được gọi là Done khi behavior đúng, verification có evidence, knowledge được đồng bộ và các production risk liên quan đã được xem xét.

## Checklist chung

- [ ] Behavior đúng Acceptance Criteria.
- [ ] Không còn ambiguity quan trọng bị che bằng assumption.
- [ ] Không có thay đổi ngoài scope chưa giải thích.
- [ ] Đã search/reuse implementation hiện có trước khi tạo mới.
- [ ] Code tuân theo convention dự án.
- [ ] Test liên quan pass.
- [ ] Build/lint/static checks phù hợp pass.
- [ ] Regression risk đã được xem xét.
- [ ] Security impact đã được xem xét nếu liên quan.
- [ ] Migration/data compatibility/rollback đã được xử lý nếu liên quan.
- [ ] Config/environment/deployment impact đã được xem xét nếu liên quan.
- [ ] Logging/monitoring/operability đã được xem xét nếu behavior production cần quan sát.
- [ ] Medium/Large hoặc high-risk change đã được review độc lập khi khả thi.
- [ ] Knowledge Sync đã chạy: docs/module/ADR/pitfall/skill được cập nhật nếu cần.
- [ ] Không đưa secret hoặc debug artifact vào commit.
- [ ] Kết quả verification được báo bằng bằng chứng thực tế.

## Knowledge Sync bắt buộc

Trước khi kết thúc task, phải trả lời một trong hai:

```text
Knowledge Sync:
- Updated: <file/path>
```

hoặc:

```text
Knowledge Sync: no durable changes
```

Không để business rule hoặc project knowledge quan trọng chỉ tồn tại trong chat.

## Production status

Final report phải phân biệt rõ:

- `Production Candidate` — các gate liên quan đã được xử lý/verify, chờ human review/merge/deploy process.
- `Blocked` — còn blocker/risk cần xử lý.
- `Not applicable` — task không phải executable production change.

Không gọi `Production Ready` nếu còn check quan trọng chưa chạy hoặc production risk chưa được giải quyết.

## Nếu không thể hoàn thành một check

Không đánh dấu pass. Ghi:

```text
NOT VERIFIED: <check>
Reason: <lý do>
Impact: <rủi ro>
```

Human review vẫn là gate cuối trước merge/deploy; checklist này nhằm đưa change tới trạng thái review được nhanh và đáng tin cậy hơn.