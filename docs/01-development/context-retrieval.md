# Context Retrieval

Mục tiêu: giúp agent lấy **đúng context, đủ context, ít context thừa** cho task hiện tại.

Đây là policy mặc định sau khi project đã bootstrap.

## Retrieval order

~~~text
docs/README.md
↓
docs/ai/04-CODEBASE-MAP.md
↓
module/domain docs liên quan
↓
standards / commands / testing cần cho task
↓
biết file/path rồi?
├─ Có → đọc trực tiếp
└─ Không
   ↓
   targeted text search / ripgrep
   ↓
   cần structural pattern?
   → ast-grep nếu có
   ↓
   codebase lớn + cần graph/dependency/impact?
   → codebase-memory-mcp nếu máy đã setup + MCP Connected
   ↓
   đọc source + tests liên quan
   ↓
   vẫn thiếu evidence?
   → broaden search
   ↓
   câu hỏi lịch sử?
   → Git history
~~~

Không load context chỉ để "hiểu thêm".

Mỗi lần search/read phải phục vụ một câu hỏi cụ thể của task.

## Ground truth

~~~text
CODEBASE-MAP / docs
→ navigation + durable knowledge

Search / graph / MCP
→ retrieval accelerator

Source / tests / config hiện tại
→ ground truth
~~~

Nếu docs hoặc graph stale, sửa knowledge/index theo source hiện tại.

## STANDARD profile

Dùng mặc định cho mọi project:

- đọc CODEBASE-MAP trước khi search rộng;
- đọc file trực tiếp khi đã biết path;
- targeted text search, ưu tiên `rg` nếu có;
- chỉ broaden search khi evidence chưa đủ;
- Git history không nằm trong default path;
- giữ Tool Search của Claude Code bật;
- task độc lập mới → `/clear` sau khi Knowledge Sync;
- cùng task nhưng context lớn → `/compact`;
- investigation lớn có thể đưa sang subagent context riêng.

Không cần MCP để dùng profile này.

## LARGE-CODEBASE profile

Dùng thêm khi repository lớn/legacy/monorepo hoặc cross-module navigation khó:

- `ast-grep` cho structural search khi text search không đủ;
- `codebase-memory-mcp` cho symbol, caller/callee, dependency, impact/blast radius, architecture overview.

MCP là optional. Nếu MCP lỗi hoặc chưa cài:

~~~text
CODEBASE-MAP
→ targeted search
→ source
~~~

## BOOTSTRAP / SNAPSHOT profile

`Repomix` có thể dùng khi cần:

- bootstrap/snapshot repository;
- handoff một phần codebase;
- external repo analysis;
- tạo context package có giới hạn.

Không pack toàn repository cho mọi task.

## ripgrep

Default text search.

Phù hợp khi biết:

- symbol/name/domain term;
- string/config key;
- file extension/path pattern.

Ví dụ:

~~~bash
rg "ContractStatus" src
rg "ma_vt" Database App_Data
~~~

Nếu search text đã tìm đúng nơi, không cần gọi MCP.

## ast-grep

Dùng khi cần structural/syntax-aware search.

Ví dụ phù hợp:

- tìm mọi call theo AST;
- tìm một pattern API usage;
- refactor theo cấu trúc syntax.

Không ép dùng cho SQL/XML nếu text search/source read đơn giản hơn.

## codebase-memory-mcp

Optional local MCP/code-intelligence layer cho codebase lớn.

Dùng khi cần:

- symbol discovery;
- callers/callees;
- dependency navigation;
- impact analysis;
- cross-module architecture;
- codebase overview.

Không dùng graph để thay việc đọc logic source thật.

Nếu project bật tool này, verify trong Claude Code bằng:

~~~text
/mcp
~~~

Nếu không Connected, fallback về STANDARD profile.

## Legacy SQL / XML / DSL

Với SQL stored procedure, XML metadata/controller, generated/vendor code hoặc DSL:

- dùng CODEBASE-MAP để biết area;
- targeted search/read;
- chỉ dùng graph/AST khi tool thực sự hiểu file type đó đủ tốt.

Không giả định tool coverage = repository coverage.

## Git history

Chỉ dùng khi task hỏi hoặc thực sự cần historical evidence, ví dụ:

- tại sao API/design tồn tại;
- regression bắt đầu từ commit nào;
- behavior đổi ở đâu;
- compatibility/migration decision xuất phát từ đâu.

Không đọc commit history rộng chỉ để "hiểu codebase".

## Session hygiene

Sau task hoàn tất:

~~~text
Verify
→ Knowledge Sync
→ task độc lập tiếp theo
→ /clear
~~~

Nếu vẫn cùng task nhưng context dài:

~~~text
/compact
~~~

Không kéo một chat qua nhiều task độc lập chỉ để agent nhớ project; durable knowledge phải nằm trong repository.

## Escalation rule

Chỉ nâng mức retrieval khi mức trước chưa đủ bằng chứng:

~~~text
direct read
→ text search
→ structural search
→ graph
→ broad search
→ history
~~~

Mục tiêu là giảm rediscovery/context rác mà không giảm correctness.


## Machine tooling 2.4.0

Team có thể setup tool một lần trên mỗi máy từ repository AI-DEV-OS:

~~~powershell
powershell -ExecutionPolicy Bypass -File .\tools\setup-ai-dev-machine.ps1
~~~

Script này nằm ở **AI-DEV-OS source**, không copy vào product repository.

Sau setup, các tool có thể sẵn sàng trên mọi repo của máy:

- `ripgrep`;
- `ast-grep`;
- `Repomix`;
- `codebase-memory-mcp` qua Claude MCP user-scope.

Có tool sẵn **không có nghĩa task nào cũng phải gọi**. Vẫn dùng escalation order của tài liệu này.

Trước khi dùng graph/memory cho một repo mới, xác nhận MCP Connected và index/coverage của repo đã sẵn sàng. Nếu chưa, fallback về CODEBASE-MAP + targeted search + source.
