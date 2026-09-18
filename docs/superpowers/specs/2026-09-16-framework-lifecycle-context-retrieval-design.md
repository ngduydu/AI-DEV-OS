# AI-DEV-OS Framework Lifecycle & Context Efficiency Design

Date: 2026-09-16

## Mục tiêu

AI-DEV-OS phải giải quyết đồng thời hai vấn đề khi được copy vào nhiều repository:

1. Task thường không được scan/read lại quá rộng, gây tốn context và quota.
2. Framework phải nâng cấp được mà không overwrite knowledge riêng đã bootstrap trong product repo.

Thiết kế bổ sung:

- Framework Lifecycle: version + ownership + upgrade.
- Context Efficiency: retrieval order + session hygiene + tool profiles.
- Tool Adoption Gate: chỉ đưa tool đủ trưởng thành vào recommended stack.

## Nguyên tắc nền

~~~text
Project docs / CODEBASE-MAP
→ navigation + durable knowledge

Search / structural tools / MCP
→ retrieval accelerator

Source / tests / config
→ ground truth
~~~

Nếu docs/index mâu thuẫn source hiện tại, source hiện tại thắng và knowledge/index phải được sửa.

## Context retrieval order

Task bình thường sau bootstrap:

~~~text
1. docs/README.md
2. docs/ai/04-CODEBASE-MAP.md
3. module/domain docs liên quan
4. standards / commands / testing cần cho task
5. đọc file trực tiếp nếu đã biết path
6. ripgrep targeted search
7. ast-grep nếu cần structural search
8. codebase-memory-mcp nếu enabled và cần graph/dependency/impact
9. đọc source + tests liên quan
10. broaden search chỉ khi evidence chưa đủ
11. Git history chỉ khi câu hỏi thực sự có tính lịch sử
~~~

Không load context chỉ để "hiểu thêm". Mỗi retrieval phải trả lời một câu hỏi cụ thể của task.

## Bootstrap vs task bình thường

Bootstrap lần đầu được phép scan rộng có kiểm soát để tạo project knowledge và CODEBASE-MAP.

Task bình thường không được bootstrap/scan lại toàn repo theo mặc định.

~~~text
Bootstrap
→ broad discovery một lần
→ durable project map

Task sau bootstrap
→ reuse map
→ targeted retrieval
→ broaden khi cần
~~~

Refresh bootstrap phải ưu tiên knowledge hiện có và chỉ refresh area stale.

## Session hygiene

Knowledge quan trọng phải nằm trong repo, không phụ thuộc chat dài.

~~~text
Task hoàn tất
→ Knowledge Sync
→ sang task độc lập mới: /clear

Cùng một task nhưng context đã lớn
→ /compact

Investigation lớn, độc lập
→ subagent/reviewer context riêng khi phù hợp
→ main session chỉ nhận kết quả cô đọng
~~~

Không giữ một session dài qua nhiều task độc lập chỉ để agent "nhớ project".

## Tool profiles

### STANDARD — mặc định

- CODEBASE-MAP.
- targeted file reading.
- ripgrep/text search.
- Claude Code Tool Search mặc định.
- /clear, /compact, subagent isolation khi phù hợp.

Đây là profile đủ để AI-DEV-OS hoạt động.

### LARGE-CODEBASE — optional

STANDARD cộng:

- ast-grep cho structural search.
- codebase-memory-mcp cho graph/symbol/dependency/impact nếu project phù hợp.

Không có MCP vẫn phải fallback an toàn về CODEBASE-MAP + targeted search + source.

### BOOTSTRAP / SNAPSHOT

Dùng Repomix khi cần:

- bootstrap nhanh một codebase;
- snapshot/handoff;
- external repository analysis;
- tạo một gói context có kiểm soát.

Repomix không phải everyday retrieval engine và không được pack toàn repo mỗi task.

## Tool responsibilities

### ripgrep

Default fast text search.

Dùng khi biết symbol/name/domain term, string/config key hoặc file pattern.

Không cần MCP nếu text search đã tìm đúng nơi.

### ast-grep

Structural search/refactor tool.

Dùng khi câu hỏi phụ thuộc syntax/AST, ví dụ tìm một pattern code thay vì text thuần.

Không dùng cho SQL/XML legacy nếu query AST không mang lại lợi ích rõ.

### codebase-memory-mcp

Optional local code intelligence graph cho codebase lớn.

Dùng cho symbol discovery, caller/callee, dependency navigation, impact/blast radius, architecture overview và cross-module navigation.

Không dùng để thay việc đọc source logic thật.

Manual project config tương thích Claude Code:

~~~json
{
  "mcpServers": {
    "codebase-memory-mcp": {
      "command": "codebase-memory-mcp",
      "args": []
    }
  }
}
~~~

Project phải cài binary riêng và verify bằng /mcp. Không auto-install tool khi upgrade AI-DEV-OS.

### Repomix

Optional snapshot/context packing utility.

Không load packed whole-repo output vào mọi task.

## Legacy / unsupported areas

Graph/AST tooling không được coi là coverage toàn repo.

Với SQL scripts/stored procedures, XML metadata/controllers, generated/vendor code hoặc DSL riêng, ưu tiên CODEBASE-MAP + targeted search/read nếu tool không hiểu semantic relationship đủ tốt.

## Git history policy

Git history không nằm trong default task path.

Chỉ dùng khi snapshot hiện tại không trả lời được câu hỏi lịch sử, ví dụ tại sao design/API tồn tại, regression bắt đầu từ commit nào, behavior đã đổi ra sao, hoặc compatibility/migration decision đến từ đâu.

Không đọc lịch sử commit rộng chỉ để hiểu codebase.

## Tool Adoption Gate

Tool không được đưa vào recommended/default stack chỉ vì claim marketing hoặc vì mới nổi.

Đánh giá tối thiểu:

1. Community adoption: có usage/community đáng kể; GitHub stars là một tín hiệu, không phải bằng chứng duy nhất.
2. Maintenance: repository còn active, release/issue được xử lý.
3. Maturity: không chỉ viral ngắn hạn; scope và failure mode đủ rõ.
4. Security: review trust boundary, advisories, filesystem/network/write capability.
5. Platform: phù hợp Windows/team environment.
6. Evidence: lợi ích phải liên quan pain thực tế; claim tiết kiệm token ưu tiên benchmark/thử nghiệm thực tế.
7. Overlap: không cài tool thứ hai nếu capability hiện có đã đủ.
8. Exit path: tool optional phải có fallback để project không bị lock-in.

Tool nhỏ/experimental có thể được ghi ở research notes nhưng không trở thành default dependency.

## Stack được chấp nhận cho rollout này

Recommended:

- ripgrep: default search.
- ast-grep: optional structural search.
- Repomix: optional bootstrap/snapshot.
- codebase-memory-mcp: optional pilot cho large codebase.
- Sourcegraph MCP: enterprise alternative khi tổ chức đã có Sourcegraph; không nằm trong default install.

Không đưa vào default ở version này:

- CodeGraph.
- grepai.
- RTK.
- Serena.

Lý do chung: overlap, maturity/evidence/security hoặc chưa cần thiết cho pain hiện tại. Có thể đánh giá lại qua Tool Adoption Gate sau.

## Framework Lifecycle

### Version marker

Product repo đã apply AI-DEV-OS có:

~~~text
.ai-dev-os/
└── VERSION
~~~

Baseline của rollout này:

~~~text
2.2.0
~~~

### Ownership

Framework-owned, có thể update có kiểm soát:

- CLAUDE.md.
- phần framework của AGENTS.md.
- docs/ai/16-TASK-EXECUTION.md.
- docs/ai/17-CONTEXT-RETRIEVAL.md.
- docs/ai/18-TOOL-ADOPTION.md.
- generic skills/reviewer agents.
- framework templates.

Project-owned, không overwrite tự động:

- project context.
- product.
- project architecture decisions.
- CODEBASE-MAP content.
- business rules.
- project coding conventions.
- commands/testing.
- module/operations docs.
- ADRs.
- project custom skills.

Mixed ownership phải merge bằng diff/evidence, không copy đè.

### Upgrade rule

Sai:

~~~text
copy lại toàn bộ docs/
~~~

Đúng:

~~~text
read .ai-dev-os/VERSION
→ read UPGRADE.md
→ classify framework/project/mixed files
→ apply safe framework changes
→ merge mixed files
→ preserve project knowledge
→ verify
→ bump VERSION
~~~

Unversioned existing install được coi là legacy install.

Không yêu cầu bootstrap toàn repo lại nếu knowledge hiện có vẫn đáng tin cậy.

## update-ai-dev-os skill

Skill upgrade phải đọc current version và UPGRADE.md, detect project customizations, preserve project-owned knowledge, apply framework-owned changes, report conflicts thay vì overwrite, không tự bật/cài optional tool, verify, và chỉ bump VERSION sau khi migration thành công.

## Bootstrap changes

bootstrap-project phải:

- cho phép broad discovery ở initial bootstrap.
- refresh theo targeted stale area nếu project đã có knowledge.
- không đọc Git history mặc định.
- có thể dùng MCP tương thích nếu project đã bật, nhưng không yêu cầu.
- xây CODEBASE-MAP để task sau không rediscover toàn repo.

## Existing project migration

Project đã apply nhưng chưa có .ai-dev-os/VERSION:

~~~text
Legacy / unversioned
→ preserve project docs
→ add lifecycle/context rules
→ optional tool decision
→ verify
→ add VERSION
~~~

Không copy đè project docs.

## Files dự kiến

~~~text
.ai-dev-os/VERSION
UPGRADE.md
docs/ai/04-CODEBASE-MAP.md
docs/ai/14-AI-SYSTEM-MAINTENANCE.md
docs/ai/16-TASK-EXECUTION.md
docs/ai/17-CONTEXT-RETRIEVAL.md
docs/ai/18-TOOL-ADOPTION.md
.claude/skills/bootstrap-project/SKILL.md
.agents/skills/bootstrap-project/SKILL.md
.claude/skills/update-ai-dev-os/SKILL.md
.agents/skills/update-ai-dev-os/SKILL.md
templates/mcp/claude-codebase-memory.json
README.md
START-HERE.md
APPLY-TO-PROJECT.md
CLAUDE-CODE-GUIDE.md
docs/README.md
FILE-INDEX.md
CHANGELOG.md
~~~

## Verification

Framework:

- all referenced paths exist.
- JSON template parses.
- Claude/generic mirrored skill content stays equivalent.
- no rule makes MCP mandatory.
- no upgrade rule overwrites project knowledge.
- VERSION is exact.

Representative scenarios:

- known-file task: direct read, no repo scan.
- symbol/string task: targeted ripgrep.
- structural pattern task: ast-grep when available.
- dependency/impact task in large repo: graph may be used.
- SQL/XML legacy task: targeted search/read fallback.
- historical question: Git history allowed.
- new independent task after completed task: /clear encouraged.

## Non-goals

Không xây package manager riêng, background auto-updater, hard token accounting engine, custom MCP server, mandatory MCP, automatic optional-tool installation, destructive conflict merge, hoặc nhiều overlapping retrieval tools trong default stack.

## Decision summary

AI-DEV-OS chuyển từ:

~~~text
copy template một lần
~~~

sang:

~~~text
versioned framework baseline
+ protected project knowledge
+ controlled upgrades
+ context-efficient retrieval
+ optional mature retrieval tools
~~~

Mục tiêu là kéo dài quota bằng cách giảm rediscovery và context rác, không đánh đổi correctness hoặc lock project vào một tool.
