# Codebase Intelligence

Mục tiêu: dùng `codebase-memory-mcp` như lớp code intelligence cho cả AI và developer, đặc biệt ở codebase lớn/legacy/cross-module.

## Dùng để làm gì?

AI có thể dùng graph thay cho việc mở hàng loạt file khi cần:

- function/class/symbol nằm ở đâu;
- caller/callee của một function;
- function nào đang được dùng bởi file/module nào;
- dependency direction;
- route/entry point;
- impact/blast radius của một thay đổi;
- cross-module/cross-service relationship;
- dead-code candidate;
- architecture overview.

Graph là retrieval accelerator. Source/test hiện tại vẫn là ground truth cuối cùng.

## Khi nào AI nên ưu tiên codebase-memory?

Nếu câu hỏi là kiểu:

~~~text
function này được gọi ở đâu?
đổi method này ảnh hưởng chỗ nào?
module này phụ thuộc module nào?
route này đi qua những function nào?
cho tôi sơ đồ area này
~~~

và MCP đã Connected + repo đã index:

~~~text
codebase-memory graph
→ mở đúng source/test liên quan
→ verify conclusion
~~~

Không grep/read hàng chục file trước nếu graph đã trả lời đúng câu hỏi structural.

Nếu graph stale/coverage thiếu:

~~~text
re-index hoặc fallback
→ targeted search
→ source/test
~~~

## Graph UI cho người

Built-in UI có thể mở trực tiếp:

~~~powershell
codebase-memory-mcp --ui=true --port=9749
~~~

Sau đó mở:

~~~text
http://localhost:9749
~~~

UI dùng để xem trực quan graph, module, function/class, call relationship và các liên kết mà index đã phát hiện.

UI là công cụ khám phá/review, không thay code review hoặc source.

## Index policy

Không auto-index mọi repository trên máy.

Upstream mặc định:

~~~text
auto_index = false
auto_watch = true
watcher_enabled = true
~~~

AI-DEV-OS giữ nguyên nguyên tắc **index có chủ đích**.

### Profile cân bằng — khuyến nghị

~~~text
auto_index = false
auto_watch = true
watcher_enabled = true
~~~

Ý nghĩa:

- repo mới không tự bị index chỉ vì mở Claude;
- repo đã chủ động index có thể được watcher cập nhật khi session sử dụng;
- không phải scan toàn bộ workspace.

Kiểm tra config:

~~~powershell
codebase-memory-mcp config list
~~~

Index repo khi thật sự cần bằng MCP/agent, ví dụ yêu cầu:

~~~text
Index this project
~~~

### Profile ít tài nguyên

Máy yếu hoặc làm nhiều repo song song:

~~~powershell
codebase-memory-mcp config set auto_index false
codebase-memory-mcp config set auto_watch false
~~~

Khi cần graph, index/re-index thủ công.

Muốn tắt hẳn background watcher:

~~~powershell
codebase-memory-mcp config set watcher_enabled false
codebase-memory-mcp daemon stop
~~~

Lần session sau daemon sẽ khởi động không có watcher.

Khi cần bật lại:

~~~powershell
codebase-memory-mcp config set watcher_enabled true
codebase-memory-mcp config set auto_watch true
codebase-memory-mcp daemon stop
~~~

## Resource rule

Không đánh đổi máy dev chỉ để graph luôn "fresh".

Ưu tiên:

~~~text
repo lớn/đang làm active
→ index + watcher nếu hữu ích

repo nhỏ/task cục bộ
→ direct read / rg thường đủ

nhiều repo hoặc máy thiếu RAM/CPU
→ low-resource profile
→ manual index khi cần
~~~

Nếu indexing/watcher gây CPU/RAM/disk đáng kể, giảm profile trước; không tắt toàn bộ AI-DEV-OS retrieval.

## Security

`codebase-memory-mcp` đọc source và lưu graph/cache local.

- không index thư mục chứa credential/secret cố ý;
- có thể dùng `CBM_ALLOWED_ROOT` để giới hạn root được index;
- không dùng graph output để suy ra secret/credential;
- không coi graph stale là source of truth;
- index/cache không được commit vào product repository.

## AI + human workflow

~~~text
AI cần hiểu structural relationship
→ query graph

Human muốn nhìn kiến trúc/call graph
→ mở UI

Cả hai cần xác nhận logic thật
→ mở source/test

Knowledge bền vững mới
→ Knowledge Sync
~~~
