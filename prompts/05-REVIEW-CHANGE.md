# Review Change

Review diff như một reviewer độc lập.

Ưu tiên tìm lỗi, không ưu tiên khen.

Kiểm tra:

- correctness/business rule;
- regression;
- error handling;
- auth/authorization/security;
- data consistency/transaction/concurrency;
- migration/compatibility;
- test coverage của behavior mới;
- unnecessary complexity;
- scope creep;
- docs mismatch.

Mỗi finding phải có:

- Severity: Critical/High/Medium/Low
- File/path và vị trí cụ thể nếu có
- Vấn đề
- Tại sao nguy hiểm
- Cách sửa đề xuất

Nếu không tìm thấy issue đáng kể, nói rõ các vùng đã kiểm tra và giới hạn của review.
