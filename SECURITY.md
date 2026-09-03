# Security Policy

AI-DEV-OS chủ yếu chứa documentation, templates, prompts và agent workflows. Tuy vậy, thay đổi trong các file này vẫn có thể gây rủi ro nếu chúng khuyến khích AI xử lý secret sai cách, thực thi command nguy hiểm hoặc bỏ qua kiểm soát bảo mật.

## Báo cáo vấn đề bảo mật

Không đăng công khai:

- secret hoặc credential thật;
- token/API key;
- dữ liệu nội bộ của công ty;
- exploit chi tiết có thể gây hại trực tiếp;
- thông tin nhạy cảm lấy từ repository khác.

Nếu vấn đề có thể được mô tả an toàn mà không tiết lộ dữ liệu nhạy cảm, hãy tạo issue và mô tả behavior ở mức tối thiểu cần thiết.

Nếu vấn đề cần trao đổi riêng, ưu tiên GitHub Security / private vulnerability reporting khi repository đã bật tính năng này.

## Phạm vi đáng báo cáo

Ví dụ:

- Instruction khiến agent có khả năng lộ hoặc commit secret.
- Workflow khuyến khích chạy command phá hoại mà không có guardrail.
- Template mặc định chứa credential hoặc dữ liệu nhạy cảm.
- Prompt/skill hướng agent bỏ qua authentication, authorization hoặc verification theo cách không an toàn.
- Hướng dẫn có thể dẫn tới supply-chain hoặc dependency risk rõ ràng.

## Không thuộc security report

Các nội dung sau thường nên tạo bug/proposal bình thường:

- typo;
- wording chưa rõ;
- workflow dài;
- context bị nạp thừa;
- feature request;
- khác biệt về style hoặc preference.

## Nguyên tắc cho contributor

Không commit secret, credential hoặc dữ liệu thật vào example.

Khi cần minh họa, dùng placeholder rõ ràng:

```text
YOUR_API_KEY
example.com
user@example.com
```

Không dùng dữ liệu có vẻ giả nhưng thực chất là credential đã từng tồn tại.
