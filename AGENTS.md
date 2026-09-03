# Agent Guide

Đây là bản đồ làm việc cho AI coding agent trong repository này. Giữ file này ngắn. Kiến thức chi tiết nằm trong `docs/`.

## 1. Trước khi thay đổi code

1. Đọc yêu cầu hiện tại và xác định phạm vi.
2. Đọc các file code liên quan trước khi đề xuất thay đổi.
3. Đọc tài liệu phù hợp trong `docs/ai/`:
   - sản phẩm: `docs/ai/02-PRODUCT.md`
   - kiến trúc: `docs/ai/03-ARCHITECTURE.md`
   - codebase map: `docs/ai/04-CODEBASE-MAP.md`
   - business rules: `docs/ai/05-BUSINESS-RULES.md`
   - coding standards: `docs/ai/06-CODING-STANDARDS.md`
   - lệnh build/test: `docs/ai/07-COMMANDS.md`
   - testing: `docs/ai/08-TESTING.md`
   - security: `docs/ai/09-SECURITY.md`
4. Không suy đoán business rule nếu repository chưa chứng minh được.

## 2. Chọn mức quy trình phù hợp

- Thay đổi nhỏ, cục bộ: hiểu → sửa → verify.
- Thay đổi nhiều file hoặc có business rule: brief/plan → implement → verify.
- Thay đổi lớn, chưa rõ codebase, kiến trúc hoặc rủi ro cao: research → spec → plan → tasks → implement → verification.

Xem `docs/work/README.md`.

## 3. Khi triển khai

- Bám đúng scope; không refactor phần không liên quan chỉ vì "tiện thể".
- Ưu tiên pattern đã tồn tại trong repository trước khi tạo abstraction mới.
- Không tạo framework/core/helper mới nếu chưa chứng minh có nhu cầu tái sử dụng.
- Giữ thay đổi nhỏ, dễ review và dễ rollback.
- Không hard-code secret, credential hoặc dữ liệu nhạy cảm.
- Với migration/schema/data destructive, phải nêu rõ rủi ro và rollback.

## 4. Verification là bắt buộc

Sau khi sửa:

1. Chạy kiểm tra nhỏ nhất nhưng đủ chứng minh thay đổi đúng.
2. Sau đó chạy các check rộng hơn được quy định trong `docs/ai/07-COMMANDS.md` nếu phù hợp.
3. Không nói "pass" nếu chưa thực sự chạy.
4. Nếu không chạy được, nói chính xác check nào chưa chạy và lý do.
5. Bug fix nên có reproduction/test chống regression khi khả thi.

## 5. Hoàn thành công việc

Trước khi kết thúc:

- đối chiếu Acceptance Criteria;
- kiểm tra diff ngoài scope;
- kiểm tra test/build/lint phù hợp;
- cập nhật docs nếu behavior/architecture/business rule thay đổi;
- tạo ADR nếu có quyết định kiến trúc đáng kể;
- ghi lại pitfall mới nếu phát hiện lỗi khó nhớ.

Definition of Done: `docs/ai/12-DEFINITION-OF-DONE.md`.

## 6. Cách báo cáo kết quả

Báo ngắn gọn:

- đã thay đổi gì;
- file/khu vực chính;
- đã verify bằng gì;
- còn rủi ro hoặc việc chưa làm nào;
- không tuyên bố kết quả mạnh hơn bằng chứng hiện có.

## 7. Nguồn sự thật

Khi tài liệu mâu thuẫn với code hoặc giữa các tài liệu với nhau:

1. Không tự chọn ngẫu nhiên.
2. Xác minh từ code/test/history nếu có thể.
3. Nêu rõ mâu thuẫn.
4. Sửa nguồn tài liệu lỗi thời khi phạm vi task cho phép.

Không biến `AGENTS.md` thành tài liệu chi tiết. Hãy cập nhật `docs/ai/` hoặc skill phù hợp.
