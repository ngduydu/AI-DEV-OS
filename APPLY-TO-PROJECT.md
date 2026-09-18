# Apply AI-DEV-OS to a Project

Tài liệu này hướng dẫn cách đưa AI-DEV-OS vào một repository thật mà không biến việc setup thành một dự án documentation riêng.

Mục tiêu:

```text
Chọn đúng adapter theo AI đang dùng
→ copy đúng thành phần
→ bootstrap từ code thật
→ review knowledge ban đầu
→ giao task bình thường
→ project knowledge tự giàu dần sau mỗi task
```

Sau khi setup xong, xem `USAGE.md` để biết cách giao task hằng ngày.

## 1. Copy những gì?

Không copy toàn bộ AI-DEV-OS vào project.

Trước tiên xác định project sẽ dùng agent nào.

### 1.1. Core dùng chung

Hai thành phần này dùng cho mọi agent:

```text
.ai-dev-os/VERSION
UPGRADE.md
AGENTS.md
docs/
```

Tác dụng:

| Thành phần | Dùng để làm gì? |
|---|---|
| `.ai-dev-os/VERSION` | Ghi baseline framework để sau này biết cần upgrade từ version nào. |
| `UPGRADE.md` | Hướng dẫn nâng framework mà không overwrite project knowledge. |
| `AGENTS.md` | Entry point ngắn chứa các rule chung cho AI: phải đọc documentation map, tuân Task Execution Contract, không đoán requirement quan trọng, reuse trước khi tạo mới và phải verify trước khi báo Done. |
| `docs/` | Knowledge lâu dài của project: project context, product, architecture, codebase map, coding convention, command, testing, business rule, module knowledge, operations, ADR và task artifacts khi cần. |

### 1.2. Nếu project dùng Claude Code

Copy thêm:

```text
CLAUDE.md
.claude/skills/
```

Nếu muốn Claude dùng reviewer/subagent độc lập, copy thêm:

```text
.claude/agents/
```

Cấu trúc tối thiểu:

```text
MyProject/
├── .ai-dev-os/
│   └── VERSION
├── UPGRADE.md
├── AGENTS.md
├── CLAUDE.md
├── docs/
└── .claude/
    ├── skills/
    └── agents/       # optional
```

**Không cần copy `.agents/skills/` nếu project chỉ dùng Claude Code.**

Tác dụng:

| Thành phần | Dùng để làm gì? |
|---|---|
| `CLAUDE.md` | Entry point riêng của Claude Code. Trong AI-DEV-OS nó import `AGENTS.md`, để rule chung chỉ có một nguồn. |
| `.claude/skills/` | Các workflow có thể tái sử dụng của Claude Code, ví dụ bootstrap project, research codebase, fix bug, plan, implement, review, verify và sync knowledge. |
| `.claude/agents/` | Các subagent chuyên trách, hiện dùng chủ yếu cho independent change review và production review. Không bắt buộc cho task nhỏ. |

### 1.3. Nếu project dùng agent khác

Copy:

```text
AGENTS.md
docs/
.agents/skills/
```

Không cần copy:

```text
CLAUDE.md
.claude/
```

trừ khi project thực sự dùng thêm Claude Code.

`.agents/skills/` là adapter skill dành cho agent hỗ trợ convention đó.

### 1.4. Nếu project dùng cả Claude Code và agent khác

Mới copy cả hai adapter:

```text
AGENTS.md
CLAUDE.md
docs/
.claude/skills/
.claude/agents/       # optional
.agents/skills/
```

### 1.5. Những thứ không cần copy mặc định

Các file sau phục vụ chính repository AI-DEV-OS hoặc dùng để tham khảo:

```text
LICENSE
CONTRIBUTING.md
CHANGELOG.md
FILE-INDEX.md
START-HERE.md
CLAUDE-CODE-GUIDE.md
.github/ISSUE_TEMPLATE/
prompts/
templates/
```

Chỉ mang `prompts/` hoặc `templates/` sang product repo nếu team thực sự muốn dùng chúng.

## 2. Skill là gì?

Skill không phải package/library được cài vào application.

Có thể hiểu đơn giản:

```text
Skill
= một workflow + instruction có thể tái sử dụng cho AI
```

Ví dụ AI-DEV-OS đang có các skill:

```text
bootstrap-project
research-codebase
plan-change
implement-plan
fix-bug
review-change
verify-change
update-project-knowledge
```

Với Claude Code, mỗi skill nằm ở:

```text
.claude/skills/<ten-skill>/SKILL.md
```

Ví dụ:

```text
.claude/skills/bootstrap-project/SKILL.md
```

Bạn có thể:

- dùng các skill có sẵn trong AI-DEV-OS;
- sửa skill để phù hợp workflow team;
- tự tạo skill mới khi có một procedure/domain workflow lặp lại đủ nhiều để đáng chuẩn hóa.

Không nên tạo skill cho mọi task nhỏ.

## 3. Project đã có code: chạy bootstrap-project như thế nào?

Sau khi copy đúng thành phần vào project, với Claude Code làm như sau.

### Bước 1: Mở đúng repository root

Ví dụ:

```text
D:\Projects\MyProject
```

Không chỉ mở riêng `src/`.

Tại root nên thấy:

```text
AGENTS.md
CLAUDE.md
docs/
.claude/
```

### Bước 2: Mở Claude Code

Trong VS Code:

```text
mở Claude Code sidebar
→ tạo conversation/session mới
```

### Bước 3: Kiểm tra Claude nhận project instructions

Trong **ô chat Claude Code**, gõ:

```text
/context
```

Kiểm tra `CLAUDE.md` xuất hiện trong project memory/context.

Nếu không thấy, dừng lại và kiểm tra đang mở đúng repo root.

### Bước 4: Chạy bootstrap-project

Trong **ô chat Claude Code**, gõ:

```text
/bootstrap-project
```

rồi Enter.

Đây là **Claude Code Skill**, không phải lệnh PowerShell/CMD/Terminal.

Đúng:

```text
Claude Code chat:
> /bootstrap-project
```

Sai:

```powershell
/bootstrap-project
```

Skill được lấy từ:

```text
.claude/skills/bootstrap-project/SKILL.md
```

Nếu khi gõ `/` không thấy `bootstrap-project`:

1. Kiểm tra file `.claude/skills/bootstrap-project/SKILL.md` có tồn tại.
2. Đảm bảo VS Code đang mở repo root.
3. Reload VS Code hoặc mở Claude session mới nếu vừa copy `.claude/` vào project.
4. Gõ `/` lại.

Nếu vẫn chưa hiện, giao trực tiếp:

```text
Hãy dùng skill bootstrap-project trong
.claude/skills/bootstrap-project/SKILL.md
để bootstrap project này.
```

### Bước 5: Claude bootstrap project

Claude phải tự scan:

```text
existing docs
→ project/package files
→ config/tooling
→ CI
→ application structure
→ representative code
→ tests
→ migrations/schema/scripts
```

Sau đó fill/update knowledge có bằng chứng thật, chủ yếu:

```text
docs/ai/01-PROJECT-CONTEXT.md
docs/ai/02-PRODUCT.md
docs/ai/03-ARCHITECTURE.md
docs/ai/04-CODEBASE-MAP.md
docs/ai/06-CODING-STANDARDS.md
docs/ai/07-COMMANDS.md
docs/ai/08-TESTING.md
```

Không viết lại toàn bộ tài liệu bằng tay nếu repository đã chứa đủ evidence để AI tự tổng hợp.

### Bước 6: Xử lý kết quả

Bootstrap kết thúc bằng:

```text
READY
PARTIAL
hoặc
BLOCKED
```

- `READY`: đủ knowledge để bắt đầu giao task.
- `PARTIAL`: chỉ một số area đủ an toàn; Claude phải nêu safe scope và phần còn thiếu.
- `BLOCKED`: thiếu knowledge/tooling quan trọng; xử lý blocker trước khi làm feature.

Review nhanh diff docs, trả lời material UNKNOWN nếu Claude hỏi, rồi commit bootstrap knowledge riêng nếu có thể.

Ví dụ:

```text
docs: bootstrap project knowledge
```

## 4. Project mới chưa có code

Chỉ điền mức tối thiểu đủ để bắt đầu:

- `docs/ai/01-PROJECT-CONTEXT.md`
- `docs/ai/02-PRODUCT.md`
- `docs/ai/03-ARCHITECTURE.md` ở mức đã quyết định
- `docs/ai/06-CODING-STANDARDS.md` với convention thật sự đã chốt
- `docs/ai/07-COMMANDS.md` khi đã có lệnh build/run/test
- `docs/ai/08-TESTING.md` khi test strategy đã rõ

Không tạo nội dung giả để lấp đầy template. Module, operation, ADR, pitfall và skill chỉ xuất hiện khi project thực sự cần.

## 5. Knowledge tăng dần theo task

Ban đầu docs có thể rất ít. Điều đó bình thường.

```text
Task chạm module Contract
→ tạo/cập nhật docs/modules/contracts/

Phát hiện business rule mới
→ lưu vào module hoặc business rules phù hợp

Chọn giải pháp có trade-off đáng kể
→ ADR

Phát hiện gotcha lặp lại
→ Known Pitfalls

Có procedure ổn định dùng nhiều lần
→ Skill

Thay đổi cách deploy/migrate/rollback
→ docs/operations/
```

Không giữ knowledge quan trọng chỉ trong chat.

## 6. Cách giao task sau khi setup

Không cần prompt dài. Ví dụ:

```text
Sửa lỗi không cập nhật trạng thái máy khi hủy hợp đồng.
```

Sau khi setup đúng, không cần nhắc AI đọc từng file.

Với Claude Code:

```text
Bạn giao task
↓
CLAUDE.md
↓
AGENTS.md
↓
docs/README.md
↓
docs/ai/16-TASK-EXECUTION.md
↓
docs/module/code/test liên quan
```

Agent tiếp tục:

```text
Load context
→ Understanding Gate
→ Reuse Gate
→ Plan nếu cần
→ Implement
→ Verify
→ Review
→ Knowledge Sync
→ Production Gate
→ Report
```

Nếu requirement quan trọng chưa rõ, agent phải tự tìm trong repo trước; vẫn không đủ bằng chứng thì hỏi lại thay vì đoán.

Hướng dẫn chi tiết cách dùng hằng ngày: `USAGE.md`.

## 7. Khi nào setup được coi là đủ?

Không cần mọi file đều đầy.

Setup đủ khi AI có thể trả lời đáng tin cậy:

- Project này giải quyết việc gì?
- Kiến trúc và stack hiện tại là gì?
- Code liên quan thường nằm ở đâu?
- Convention chính là gì?
- Canonical example/building block nào nên reuse?
- Build/run/test bằng lệnh nào?
- Business rule của task hiện tại nằm ở đâu?
- Điều gì chưa biết và có cần hỏi trước khi implement không?

## 8. Sau một thời gian sử dụng

Định kỳ sau milestone lớn:

- xóa knowledge lỗi thời;
- gộp rule trùng;
- kiểm tra docs có mâu thuẫn code không;
- chuyển procedure lặp lại thành Skill;
- bổ sung module/operations docs từ những gì đã học thật;
- refresh canonical examples/building blocks;
- giữ `AGENTS.md` và `CLAUDE.md` cực ngắn.

Nguyên tắc cuối cùng:

> Bootstrap vừa đủ để bắt đầu. Mỗi task làm project hiểu chính nó tốt hơn.


## 9. Project đã apply AI-DEV-OS rồi thì update thế nào?

Không copy lại toàn bộ framework.

Nếu project chưa có `.ai-dev-os/VERSION`, coi là **legacy / unversioned**.

Flow:

~~~text
preserve project knowledge
→ lấy UPGRADE.md + framework files của target version
→ chạy /update-ai-dev-os hoặc làm theo UPGRADE.md
→ resolve conflict nếu có
→ verify
→ cập nhật VERSION
~~~

Không bootstrap full lại chỉ vì framework đổi version.

### Project-owned tuyệt đối không copy đè

Ví dụ:

- project context/product;
- architecture decisions;
- CODEBASE-MAP đã bootstrap;
- business rules;
- commands/testing;
- module/operations docs;
- ADR;
- custom skills.

### Tool tối ưu context có bắt buộc không?

Không.

Core vẫn chạy bằng:

~~~text
CODEBASE-MAP
→ targeted search
→ source/test
~~~

Với codebase lớn có thể chọn profile trong `docs/ai/17-CONTEXT-RETRIEVAL.md`: ripgrep mặc định, ast-grep/Repomix/codebase-memory-mcp khi thật sự có lợi.


## 10. Apply tự động bằng Claude Code

Sau khi máy đã chạy setup AI-DEV-OS một lần, không cần copy file thủ công nữa.

Mở repository cần apply bằng Claude Code và chạy:

~~~text
/apply-ai-dev-os
~~~

Skill sẽ tự:

~~~text
canonical AI-DEV-OS source
→ preflight source + target
→ tạo branch riêng nếu đang main/master
→ copy core + Claude adapter + project knowledge scaffold
→ không copy repo-meta/docs superpowers
→ chạy bootstrap-project ngay
→ READY / PARTIAL / BLOCKED
~~~

Nếu repo đã có AI-DEV-OS thì không dùng lệnh này; dùng:

~~~text
/update-ai-dev-os
~~~


## 11. Chọn agent khi apply

`/apply-ai-dev-os` không mặc định Claude.

Nếu chưa chỉ rõ agent, skill phải hỏi:

~~~text
1. claude  - Claude Code
2. generic - agent dùng AGENTS.md + .agents/skills
3. both    - dùng cả hai adapter
~~~

Mapping:

~~~text
claude
→ core + CLAUDE.md + .claude/skills + .claude/agents

generic
→ core + .agents/skills

both
→ core + Claude adapter + generic adapter
~~~

Nếu user đã nói rõ `claude`, `generic` hoặc `both` trong yêu cầu thì dùng luôn, không hỏi lại.
