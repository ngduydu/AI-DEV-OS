# AI-DEV-OS Framework Lifecycle & Context Retrieval Design

Date: 2026-09-16

## 1. Mục tiêu

Thiết kế AI-DEV-OS theo hướng có thể áp dụng lâu dài cho nhiều repository mà không gặp hai vấn đề:

1. Mỗi task lại phải đọc/search quá rộng, tốn context/token và dễ làm loãng reasoning.
2. AI-DEV-OS thay đổi theo thời gian nhưng các project đã copy framework không biết đang dùng version nào, cần cập nhật gì và file nào tuyệt đối không được overwrite.

Thiết kế này bổ sung hai capability mới:

- Context Retrieval Layer: context budget + exploration policy + optional MCP/CodeGraph.
- Framework Lifecycle Layer: version + upgrade/migration strategy cho các repository đã apply.

Mục tiêu cuối:

~~~text
Task
→ load context có kiểm soát
→ navigation nhanh
→ đọc source thật cần thiết
→ implement/verify

AI-DEV-OS update
→ biết project đang ở version nào
→ biết thay đổi nào cần migrate
→ không overwrite project knowledge
~~~

## 2. Nguyên tắc thiết kế

### 2.1. Source hiện tại vẫn là ground truth

Không dùng documentation, CodeGraph hay MCP như nguồn sự thật thay source code/test/config đang tồn tại.

~~~text
Project docs / CODEBASE-MAP
→ navigation + durable knowledge

MCP / CodeGraph
→ retrieval accelerator

Source / tests / config
→ ground truth
~~~

Nếu documentation/index mâu thuẫn source hiện tại, source hiện tại thắng và knowledge/index phải được cập nhật.

### 2.2. MCP/CodeGraph là optional integration

AI-DEV-OS phải hoạt động đầy đủ khi không có MCP hoặc CodeGraph.

Fallback bắt buộc:

~~~text
Không có CodeGraph
→ CODEBASE-MAP
→ targeted search
→ source reading
~~~

### 2.3. Bootstrap được phép rộng; task thường phải hẹp

Bootstrap lần đầu là bước cố ý trả chi phí discovery tương đối lớn để tạo project knowledge và codebase map.

Sau bootstrap, task bình thường không được scan lại toàn repository theo mặc định.

~~~text
Bootstrap
→ broad discovery hợp lý
→ tạo CODEBASE-MAP + project knowledge

Task sau bootstrap
→ reuse map/knowledge
→ targeted retrieval
→ chỉ broaden search khi evidence chưa đủ
~~~

### 2.4. Framework-owned và project-owned phải tách rõ

Không được upgrade framework bằng cách copy đè toàn bộ docs/.

Project knowledge được bootstrap từ codebase là tài sản của project và phải được bảo toàn.

## 3. Context Retrieval Layer

### 3.1. Retrieval order mặc định

Mọi task sau bootstrap ưu tiên context theo thứ tự:

~~~text
1. docs/README.md
2. docs/ai/04-CODEBASE-MAP.md
3. module/domain docs liên quan nếu có
4. coding standards / commands / testing theo nhu cầu task
5. MCP / CodeGraph nếu query dependency/symbol/impact phù hợp
6. targeted path/symbol/domain search
7. đọc source + tests liên quan
8. broaden search khi các bước trên chưa đủ
9. Git history chỉ khi cần historical evidence
~~~

Không load file chỉ để "hiểu thêm".

Mỗi retrieval phải phục vụ một câu hỏi cụ thể của task.

### 3.2. Git history policy

Git history không nằm trong default context path.

Chỉ dùng khi snapshot hiện tại không trả lời được câu hỏi có tính lịch sử, ví dụ:

- tại sao một design/API tồn tại;
- behavior thay đổi từ commit nào;
- regression bắt đầu ở đâu;
- convention hiện tại được hình thành vì migration/compatibility nào.

Không chạy lịch sử commit rộng chỉ để "hiểu codebase".

### 3.3. MCP / CodeGraph usage policy

Dùng CodeGraph/MCP khi task cần:

- symbol discovery;
- caller/callee;
- dependency navigation;
- impact analysis;
- architecture relationship;
- semantic code navigation.

Không dùng CodeGraph khi:

- file đích đã biết rõ;
- cần đọc logic chi tiết của một file;
- cần xác minh behavior bằng test/config/source;
- ngôn ngữ/file type không được graph hỗ trợ đầy đủ.

### 3.4. Unsupported / legacy areas

CodeGraph không được coi là coverage toàn repo.

Với repository có XML metadata, SQL scripts/stored procedures, generated/vendor files hoặc DSL riêng:

~~~text
CODEBASE-MAP
+ targeted search/read
+ project-specific docs
~~~

vẫn là đường chính nếu graph không index semantic relationship đủ tốt.

### 3.5. Context Budget rule

Agent phải ưu tiên:

- path cụ thể hơn glob rộng;
- symbol/domain query cụ thể hơn full-tree search;
- canonical examples hơn đọc nhiều implementation ngẫu nhiên;
- module docs hơn load toàn docs;
- short-lived subagent/research context cho investigation lớn khi phù hợp.

Không có hard token number trong core vì model/tool khác nhau có context window khác nhau.

Policy được biểu diễn bằng retrieval order và escalation rule, không bằng quota cố định.

## 4. Codebase Map role

docs/ai/04-CODEBASE-MAP.md được định nghĩa rõ là durable navigation map / compressed project knowledge, không phải snapshot thay thế source code.

Nó phải giúp agent trả lời nhanh:

- area/module nằm đâu;
- canonical implementation nào nên đọc;
- reusable building block nào tồn tại;
- path nào sensitive/generated/vendor;
- loại task nào nên vào area nào.

Task sau phải dùng map này để giảm rediscovery.

Nếu map stale:

~~~text
source evidence
→ sửa CODEBASE-MAP
→ tiếp tục task
~~~

## 5. Optional CodeGraph MCP Integration

### 5.1. Integration model

~~~text
Claude Code
    ↓ MCP
CodeGraph MCP server
    ↓
local graph/index
    ↓
project source
~~~

Không đưa MCP call vào mọi task bắt buộc.

### 5.2. Repository distribution

AI-DEV-OS cung cấp:

- tài liệu cài đặt/verify;
- project config template;
- usage policy;
- troubleshooting/fallback.

Không commit active .mcp.json vào mọi product repo một cách bắt buộc.

Đề xuất cấu trúc:

~~~text
templates/
└── mcp/
    └── claude-codegraph.json
~~~

Khi project chọn bật integration:

~~~text
copy template
→ .mcp.json
→ cài CodeGraph
→ verify MCP connection
→ index project
~~~

Nếu project đã có .mcp.json, merge config thay vì overwrite.

### 5.3. Security

MCP server config không được hard-code secret.

External MCP server cần được review về:

- data sent ra ngoài;
- auth scope;
- write permissions;
- command execution;
- trust boundary.

CodeGraph local được ưu tiên cho code retrieval vì giảm việc gửi source sang dịch vụ ngoài, nhưng user/team vẫn phải review tool trước khi dùng.

## 6. Framework Lifecycle Layer

### 6.1. Version marker

Project đã apply AI-DEV-OS có version marker nhỏ:

~~~text
.ai-dev-os/
└── VERSION
~~~

Ví dụ:

~~~text
2.2.0
~~~

Version marker dùng để biết project đang dùng baseline framework nào. Nó không chứa project knowledge.

### 6.2. Upgrade guide

AI-DEV-OS source có:

~~~text
UPGRADE.md
~~~

Mỗi version có migration note ngắn:

~~~text
## 2.2.0

Framework changes:
- Context retrieval policy
- Optional CodeGraph MCP

Required/Recommended:
- update Task Execution Contract
- update bootstrap skill

Project-owned files:
- do not overwrite CODEBASE-MAP content
- do not overwrite business rules/project context

Optional:
- enable CodeGraph MCP
~~~

### 6.3. Ownership categories

Framework-owned, có thể update từ framework nếu project chưa customize:

- CLAUDE.md;
- phần lớn AGENTS.md;
- docs/ai/16-TASK-EXECUTION.md;
- generic framework skills;
- generic reviewer agents;
- framework docs/template files.

Project-owned, không được overwrite tự động:

- 01-PROJECT-CONTEXT.md;
- 02-PRODUCT.md;
- project decisions trong 03-ARCHITECTURE.md;
- 04-CODEBASE-MAP.md;
- 05-BUSINESS-RULES.md;
- project-specific phần của 06-CODING-STANDARDS.md;
- 07-COMMANDS.md;
- 08-TESTING.md;
- module docs;
- operations docs;
- ADRs;
- project custom skills.

Mixed ownership: một số file có cả framework rule và project customization. Upgrade phải merge bằng evidence/diff, không overwrite mù quáng.

### 6.4. Upgrade rule

Workflow sai:

~~~text
copy lại docs/
~~~

Workflow đúng:

~~~text
read current project VERSION
→ read UPGRADE.md changes
→ classify files: framework/project/mixed
→ apply framework-owned changes
→ merge mixed files
→ preserve project-owned knowledge
→ verify
→ bump VERSION
~~~

## 7. Update skill

Thiết kế thêm skill update-ai-dev-os.

Mục đích: hỗ trợ nâng project đã apply framework.

Skill phải:

1. đọc .ai-dev-os/VERSION;
2. đọc target upgrade instruction;
3. detect project customizations;
4. không overwrite project-owned knowledge;
5. apply safe framework changes;
6. report conflict cần human quyết định;
7. verify expected files/rules;
8. chỉ update VERSION sau khi migration thành công.

Không tự merge destructive conflict.

Không tự cài optional tool nếu user/team chưa chọn bật.

## 8. Bootstrap changes

bootstrap-project sẽ được bổ sung:

- broad scan chỉ dành cho bootstrap/refresh thực sự;
- ưu tiên existing CODEBASE-MAP khi refresh;
- không dùng Git history trừ khi cần giải thích decision/convention;
- nếu CodeGraph MCP khả dụng, có thể dùng để tăng tốc navigation nhưng source vẫn phải verify;
- bootstrap report ghi retrieval/tool limitations nếu liên quan.

Bootstrap không biến CodeGraph thành requirement để đạt READY.

## 9. Existing projects migration

Các project đã apply AI-DEV-OS trước version marker vẫn nâng được.

~~~text
.ai-dev-os/VERSION không tồn tại
→ Legacy / unversioned install
~~~

Migration đầu tiên:

1. detect AI-DEV-OS files hiện hữu;
2. preserve project-owned docs;
3. apply framework lifecycle/context changes;
4. optional enable CodeGraph;
5. tạo .ai-dev-os/VERSION sau khi verify.

Không yêu cầu bootstrap toàn repository lại nếu project knowledge hiện tại vẫn đáng tin cậy.

Có thể refresh targeted area nếu CODEBASE-MAP stale.

## 10. Compatibility

Không có MCP:

~~~text
docs
→ CODEBASE-MAP
→ targeted search
→ source
~~~

Có Claude Code nhưng không CodeGraph: không bị giảm capability core.

Agent khác Claude: context policy và lifecycle là agent-agnostic; chỉ config MCP adapter/template là tool-specific.

Legacy project: không yêu cầu project phải có modern build/test stack để sử dụng context policy.

## 11. Files dự kiến thay đổi/thêm

~~~text
.ai-dev-os/VERSION
UPGRADE.md
docs/ai/04-CODEBASE-MAP.md
docs/ai/14-AI-SYSTEM-MAINTENANCE.md
docs/ai/16-TASK-EXECUTION.md
docs/ai/17-CONTEXT-RETRIEVAL.md
.claude/skills/bootstrap-project/SKILL.md
.claude/skills/update-ai-dev-os/SKILL.md
.agents/skills/update-ai-dev-os/SKILL.md
templates/mcp/claude-codegraph.json
README.md
START-HERE.md
APPLY-TO-PROJECT.md
FILE-INDEX.md
CHANGELOG.md
~~~

Nếu generic-agent adapter không hỗ trợ cùng skill convention trong thực tế, implementation plan phải xác minh trước khi thêm bản tương ứng.

## 12. Verification strategy

Framework verification:

- markdown/reference path check;
- ensure new files được index;
- ensure docs không contradict nhau;
- verify default flow không yêu cầu MCP;
- verify no secret trong MCP template.

Migration verification dùng fixture đại diện project đã apply:

~~~text
project-owned docs đã được bootstrap
+ custom rule
+ no VERSION
~~~

Xác nhận:

- project knowledge không bị mất;
- framework rules được cập nhật;
- VERSION được tạo/cập nhật;
- optional MCP không được tự bật;
- conflicts được report thay vì overwrite.

Context retrieval verification dùng vài task đại diện:

- known-file bug;
- cross-module dependency question;
- legacy SQL/XML task;
- historical reasoning task.

Expected:

- known-file task không scan toàn repo;
- dependency task được phép dùng graph;
- SQL/XML fallback dùng targeted search;
- Git history chỉ được dùng ở historical task.

## 13. Non-goals

Version đầu không xây:

- package manager riêng cho AI-DEV-OS;
- auto-update service nền;
- registry/plugin marketplace;
- custom MCP server của AI-DEV-OS;
- hard token accounting engine;
- bắt buộc CodeGraph cho mọi project;
- auto-merge mọi project customization.

## 14. Rollout order

~~~text
1. Framework version + ownership/upgrade rules
2. Context retrieval policy
3. Bootstrap update
4. update-ai-dev-os skill
5. Optional CodeGraph MCP template/docs
6. Onboarding docs
7. Migration test bằng project legacy đã apply
~~~

Lý do: lifecycle phải tồn tại trước khi framework tạo thêm thay đổi cần phân phối sang các project cũ.

## 15. Decision summary

AI-DEV-OS chuyển từ mô hình:

~~~text
copy template một lần
~~~

sang:

~~~text
versioned framework baseline
+ project-owned durable knowledge
+ controlled upgrades
+ context-efficient retrieval
+ optional retrieval accelerators
~~~

CodeGraph/MCP là accelerator, không phải core dependency.

Project knowledge không bị overwrite khi framework nâng version.

Source code/test/config luôn là ground truth.
