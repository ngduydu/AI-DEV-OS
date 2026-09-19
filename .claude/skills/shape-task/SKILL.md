---
name: shape-task
description: Turn a vague or decision-heavy engineering request into a shared, approved spec and implementation plan by researching facts first and interviewing the user only about decisions. Use before implementation when the task is not yet precise enough to code safely.
disable-model-invocation: true
---

# Shape Task

Mục tiêu: user chỉ cần mô tả task ở mức tự nhiên. Agent phải tự tìm facts, hỏi đúng decision, chốt shared understanding rồi mới lập spec/plan.

Không implement trong skill này.

## 1. Nhận task ngắn

Ví dụ user chỉ cần nói:

~~~text
Sửa luồng đồng bộ tồn kho web.
~~~

Không yêu cầu user viết prompt dài/spec hoàn chỉnh trước.

## 2. Tách FACT và DECISION

Phân loại mọi unknown:

~~~text
FACT
→ agent tự tìm trong docs/code/test/config/database/tooling

DECISION
→ user/domain owner phải quyết
~~~

Không hỏi user những gì repository hoặc tool có thể chứng minh được.

Dùng retrieval phù hợp:

- docs/CODEBASE-MAP;
- direct read / rg / ast-grep;
- codebase-memory-mcp cho callers/callees/dependency/impact nếu Connected;
- SQL MCP khi task cần runtime SQL evidence và project đã cấu hình an toàn;
- source/test/config là ground truth.

## 3. Lập decision tree

Sau khi facts đủ:

1. liệt kê các quyết định còn mở;
2. xác định dependency giữa các quyết định;
3. chỉ hỏi frontier hiện tại — những câu có thể quyết ngay mà không phụ thuộc câu chưa trả lời;
4. mỗi round hỏi toàn bộ frontier, đánh số rõ;
5. mỗi câu phải có phương án khuyến nghị + lý do ngắn.

Format:

~~~text
Q1 — <quyết định>
<ngữ cảnh ngắn>

Khuyến nghị: <phương án>
Lý do: <1-3 câu>

Q2 — ...
~~~

Không nhồi câu hỏi phụ thuộc nhau vào cùng một round.

## 4. Sau mỗi round

Câu trả lời của user phải:

- cập nhật shared understanding;
- mở khóa các decision tiếp theo;
- phát hiện contradiction nếu có;
- không bị silently reinterpret.

Nếu user trả lời bằng business rule bền vững, giữ lại để Knowledge Sync sau implementation hoặc ghi vào spec nếu cần cho task.

Tiếp tục round cho tới khi không còn material decision chưa chốt.

Material decision gồm ít nhất:

- behavior/acceptance;
- dữ liệu được thay đổi/xóa;
- public/API contract;
- compatibility;
- architecture/boundary;
- security/permission;
- migration/rollback;
- test seam quan trọng.

## 5. Chốt shared understanding

Trước khi viết plan, tóm tắt ngắn:

- Problem;
- Desired behavior;
- In scope;
- Out of scope;
- Decisions đã chốt;
- Assumptions còn lại (nếu có);
- Risks đáng kể.

Yêu cầu user xác nhận hoặc sửa nếu task còn decision quan trọng.

Không code trước bước này.

## 6. Sinh spec và plan

Với task Medium/Large, dùng folder riêng:

~~~text
docs/06-work/<task-id>/
~~~

Tạo/cập nhật:

~~~text
SPEC.md
PLAN.md
~~~

Spec tập trung behavior/decision, không nhồi implementation detail dễ stale.

Plan phải nêu:

- module/area sẽ chạm;
- canonical implementation/reuse source;
- test/verification seam;
- phase thực hiện;
- migration/rollback nếu có;
- risk;
- verification command/check.

Dùng Simplicity Gate trước khi chốt plan:

~~~text
no-code/config
→ reuse
→ stdlib/platform
→ existing dependency
→ minimum new code
~~~

## 7. Approval Gate

Kết thúc bằng READY FOR IMPLEMENTATION chỉ khi:

- facts quan trọng đã được research;
- material decisions đã chốt;
- spec/plan nhất quán;
- user đã xác nhận shared understanding/plan hoặc đã nói rõ làm theo plan.

Sau đó mới chuyển sang implement-plan.

## Khi không cần Shape Task

Không dùng cho:

- typo;
- rename cục bộ;
- config nhỏ rõ ràng;
- bug đã có reproduction + expected behavior rõ;
- task đã có spec/plan được approve.

Task nhỏ không cần ceremony.
