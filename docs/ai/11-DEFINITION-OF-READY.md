# Definition of Ready

Một task đủ Ready để implement khi agent đã nghiên cứu đủ và không còn phải đoán phần cốt lõi.

`Ready` không có nghĩa là user phải viết requirement dài. Agent có trách nhiệm tự đọc docs/code/test và giải quyết những gì repository đã có thể trả lời.

## Checklist

- [ ] WHY — tại sao cần thay đổi?
- [ ] WHO — ai bị ảnh hưởng/sử dụng?
- [ ] WHAT — behavior mong muốn là gì?
- [ ] SCOPE — làm gì?
- [ ] NON-SCOPE — không làm gì nếu cần chặn scope creep?
- [ ] BUSINESS RULE — rule ảnh hưởng implementation đã rõ?
- [ ] ACCEPTANCE CRITERIA — thế nào được coi là đúng?
- [ ] DEPENDENCY — dependency/integration liên quan đã biết?
- [ ] RISK — auth/data/payment/migration/concurrency/compatibility có liên quan không?
- [ ] REUSE — đã search implementation/pattern tương tự trong codebase?
- [ ] VERIFY — biết sẽ kiểm tra bằng test/check nào?

## Understanding Gate

Nếu còn ambiguity có thể làm thay đổi behavior, dữ liệu, API/public contract, architecture, security hoặc Acceptance Criteria:

1. Tự tìm trong docs, code, test và history trước.
2. Nếu vẫn không có bằng chứng đủ mạnh, hỏi người giao việc.
3. Không implement phần phụ thuộc vào assumption đó trước khi có câu trả lời.
4. Nếu câu trả lời là knowledge bền vững, cập nhật docs phù hợp để task sau không phải hỏi lại.

Không hỏi những chi tiết agent có thể tự quyết an toàn theo convention/codebase.

Task nhỏ không cần brief dài, nhưng cũng không được bỏ qua ambiguity quan trọng.