# Bắt đầu từ đây

Nếu đây là lần đầu bạn dùng AI-DEV-OS, **chỉ cần bắt đầu từ file này**.

Mục tiêu của onboarding là đưa một máy/project từ trạng thái chưa chuẩn bị gì tới trạng thái:

```text
Máy đủ công cụ
↓
Project có AI-DEV-OS core
↓
Claude đọc được project instructions
↓
Project knowledge được bootstrap/fill
↓
Bootstrap status: READY hoặc PARTIAL có scope rõ
↓
Có thể giao task thật
```

Không cần đọc toàn bộ repository trước khi bắt đầu. File này sẽ dẫn sang tài liệu chi tiết khi cần.

## 1. Chọn agent

### Dùng Claude Code

Đi tiếp theo guide này. Khi cần chi tiết về Claude Code, xem `CLAUDE-CODE-GUIDE.md`.

### Dùng agent khác

AI-DEV-OS vẫn dùng được thông qua:

```text
AGENTS.md
.agents/skills/
docs/
```

Không copy `.claude/` nếu agent đó không dùng format của Claude Code.

## 2. Kiểm tra máy

### Git

```powershell
git --version
```

Nếu có version → tiếp tục.

Nếu thiếu:

```powershell
winget install --id Git.Git -e
```

Sau đó mở terminal mới và chạy lại `git --version`.

### VS Code

```powershell
code --version
```

Nếu chưa cài:

```powershell
winget install --id Microsoft.VisualStudioCode -e
```

Nếu VS Code đã cài nhưng `code` chưa nằm trong PATH thì vẫn có thể dùng giao diện bình thường; đây không phải blocker.

### Claude Code Extension

Trong VS Code:

```text
Ctrl + Shift + X
→ tìm "Claude Code"
→ chọn extension của Anthropic
→ Install
→ mở Claude panel
→ Sign in
```

Chỉ dùng Extension là đủ để bắt đầu.

### Claude Code CLI — optional nhưng nên có khi dùng sâu

```powershell
claude --version
```

Nếu thiếu nhưng chỉ dùng Extension → chưa phải blocker.

Nếu muốn cài CLI:

```powershell
irm https://claude.ai/install.ps1 | iex
```

Hoặc stable channel:

```powershell
& ([scriptblock]::Create((irm https://claude.ai/install.ps1))) stable
```

Kiểm tra:

```powershell
claude --version
claude doctor
```

### GitHub CLI — optional

```powershell
gh --version
```

Nếu muốn cài:

```powershell
winget install --id GitHub.cli -e
gh auth login
```

## 3. Kiểm tra toolchain của project

AI-DEV-OS không thay thế toolchain của project.

Project có thể cần:

```text
.NET SDK
Node.js / npm / pnpm
Python
Java / Maven / Gradle
Docker
SQL tooling
```

Không cài bản mới nhất một cách ngẫu nhiên. Trước tiên đọc evidence trong repository:

```text
global.json
*.csproj / *.sln
package.json / lock file
.nvmrc
pyproject.toml / requirements.txt
pom.xml / build.gradle
Dockerfile / compose files
CI workflow
README hiện có
```

Sau đó cài **đúng version project yêu cầu**.

Ví dụ:

```text
global.json yêu cầu .NET 8
→ kiểm tra dotnet --list-sdks
→ thiếu thì cài .NET 8 SDK

.nvmrc = 22
→ dùng Node 22
→ không tự cài Node latest khác version
```

Nếu chưa biết cần tool nào, `bootstrap-project` phải phát hiện và báo `NOT VERIFIED`/`BLOCKED` thay vì đoán.

## 4. Xác định loại project

### Project đã có code

Đi tiếp bước 5.

### Project mới gần như trống

Trước khi code, chốt tối thiểu:

```text
Project làm gì?
Ai sử dụng?
MVP cần behavior nào?
Stack nào đã quyết định?
Architecture/boundary nào đã quyết định?
Convention nào đã chốt?
```

Điền những gì biết chắc vào:

```text
docs/ai/01-PROJECT-CONTEXT.md
docs/ai/02-PRODUCT.md
docs/ai/03-ARCHITECTURE.md
docs/ai/06-CODING-STANDARDS.md
```

Phần chưa biết quan trọng thì Claude phải hỏi; phần chưa cần thì để thiếu.

## 5. Copy AI-DEV-OS vào project

### Nếu dùng Claude Code

Copy vào root repository:

```text
AGENTS.md
CLAUDE.md
docs/
.claude/skills/
.claude/agents/
```

Nếu muốn compatibility với agent khác, copy thêm:

```text
.agents/skills/
```

Cấu trúc mong muốn:

```text
MyProduct/
├── .git/
├── AGENTS.md
├── CLAUDE.md
├── .claude/
│   ├── skills/
│   └── agents/
├── .agents/                  # optional
├── docs/
├── src/
└── tests/
```

Thông thường không cần copy:

```text
LICENSE
CONTRIBUTING.md
CHANGELOG.md của AI-DEV-OS
SECURITY.md của public template
FILE-INDEX.md
.github/ISSUE_TEMPLATE/
prompts/
templates/
START-HERE.md
CLAUDE-CODE-GUIDE.md
```

`APPLY-TO-PROJECT.md` giải thích chi tiết hơn phần này.

## 6. Verify cấu trúc

Mở **repo root**, không mở riêng `src/`.

Tại root nên có:

```text
.git/
AGENTS.md
CLAUDE.md
docs/
.claude/
```

Nếu project mới chưa có Git:

```powershell
git init
```

Sau đó mở root bằng VS Code.

## 7. Verify Claude nhận project instructions

Trong Claude Code:

```text
/context
```

Kiểm tra `CLAUDE.md` có xuất hiện trong project memory/context hay không.

Nếu có → tiếp tục.

Nếu không:

```text
STOP
→ kiểm tra VS Code đang mở đúng repo root
→ kiểm tra CLAUDE.md nằm ở root
→ kiểm tra CLAUDE.md import AGENTS.md
→ reload VS Code / Claude session
```

Không giao task thật nếu project instructions chưa được load.

## 8. Chạy bootstrap-project

Trong Claude Code:

```text
/bootstrap-project
```

Nếu skill chưa hiện thành slash command, giao trực tiếp:

```text
Bootstrap project này theo skill bootstrap-project.
Tự scan docs, code, tests, config, tooling và CI.
Fill project knowledge từ evidence thật.
Tìm canonical examples và reusable building blocks.
Chỉ hỏi tôi những UNKNOWN quan trọng không thể xác định an toàn từ repository.
Kết thúc bằng READY / PARTIAL / BLOCKED và nêu evidence.
```

Claude phải tự tìm:

```text
project purpose
stack
architecture
module boundaries
coding conventions
build/run/test/lint commands
canonical examples
reusable building blocks
business rules có evidence
security/operations artifacts
material UNKNOWN/conflict
```

## 9. Xử lý kết quả bootstrap

### READY

Project đủ context để bắt đầu giao task.

### PARTIAL

Claude phải nói rõ:

```text
Area nào làm được an toàn
Area nào còn thiếu knowledge/tooling
Cần cài/thêm/trả lời gì
```

Ví dụ:

```text
Bootstrap status: PARTIAL

PASS:
- project structure
- coding convention
- build command

WARN:
- integration tests chưa chạy vì Docker chưa được cài

Safe scope:
- application logic

Blocked scope:
- integration changes phụ thuộc Docker
```

### BLOCKED

Không code tiếp.

Claude phải báo blocker cụ thể và cách giải quyết nếu xác định được.

Ví dụ:

```text
BLOCKED: .NET SDK 8 không tồn tại trên máy
Evidence: global.json yêu cầu 8.0.x; dotnet --list-sdks không có 8.0
Next: cài .NET 8 SDK rồi chạy verification lại
```

## 10. Nếu thiếu tool/dependency trong lúc làm

Không cài package/tool ngẫu nhiên chỉ vì Claude đề xuất.

Flow chuẩn:

```text
Task cần tool/dependency
↓
Search project config/docs/CI trước
↓
Project đã định version/tool chưa?
├── Có → dùng đúng cái đó
└── Không → xác định đây là project dependency hay local tool
↓
Có building block hiện tại thay được không?
├── Có → reuse
└── Không → mới xem xét cài/thêm
```

Claude phải nêu:

```text
Thiếu gì
Evidence nào chứng minh cần
Version nào phù hợp
Cài ở máy hay thêm vào project
Ảnh hưởng CI/team/deploy không
Cách verify sau khi cài
```

Ví dụ tốt:

```text
Thiếu: .NET 8 SDK
Evidence: global.json yêu cầu 8.0.4xx
Scope: local development tool
Install: .NET 8 SDK
Verify: dotnet --list-sdks + dotnet build
```

## 11. Commit bootstrap knowledge

Sau khi docs đã được fill/review:

```text
review diff
↓
resolve material UNKNOWN
↓
commit bootstrap knowledge
```

Nên tách bootstrap khỏi feature đầu tiên nếu có thể.

Ví dụ commit:

```text
docs: bootstrap project knowledge
```

## 12. Giao task đầu tiên

Từ đây không cần prompt dài.

Ví dụ:

```text
Sửa lỗi khi hủy hợp đồng nhưng máy chưa chuyển về Available.
```

Claude phải tự đi theo:

```text
CLAUDE.md
↓
AGENTS.md
↓
docs/README.md
↓
relevant docs/code/tests
↓
Understand
↓
Reuse
↓
Implement
↓
Verify
↓
Review
↓
Knowledge Sync
↓
Production Gate
↓
Report
```

Cách dùng hằng ngày chi tiết: `USAGE.md`.

## 13. Git workflow từ task đầu tiên

Không làm trực tiếp trên `main`.

```text
main
↓
tạo branch task
↓
Claude làm việc
↓
verify
↓
review diff
↓
commit
↓
PR
↓
CI
↓
human review
↓
merge
```

Nguyên tắc:

```text
1 task = 1 branch
1 PR = 1 task
```

Task vừa/lớn: dùng Plan mode trước khi implement.

Chi tiết: `CLAUDE-CODE-GUIDE.md`.

## 14. Checklist hoàn tất onboarding

```text
[ ] Git hoạt động
[ ] VS Code mở đúng repo root
[ ] Claude Code Extension đã cài và sign in
[ ] Claude CLI nếu cần đã hoạt động
[ ] Project toolchain đúng version đã có hoặc blocker đã ghi rõ
[ ] AGENTS.md ở repo root
[ ] CLAUDE.md ở repo root
[ ] docs/ tồn tại
[ ] .claude/skills/ tồn tại
[ ] .claude/agents/ tồn tại nếu dùng independent review
[ ] /context thấy CLAUDE.md
[ ] bootstrap-project đã chạy
[ ] Material UNKNOWN đã resolve hoặc scope còn lại ghi rõ
[ ] Build/test/verification commands có evidence
[ ] Bootstrap status READY hoặc PARTIAL với safe scope rõ
[ ] Bootstrap knowledge đã review/commit
[ ] Git branch/PR workflow đã sẵn sàng
```

## 15. Sau onboarding đọc gì?

Không cần đọc tất cả.

```text
START-HERE.md
    ↓ onboarding xong
USAGE.md
    ↓ cần dùng Claude sâu hơn
CLAUDE-CODE-GUIDE.md
```

Các tài liệu còn lại chủ yếu dành cho agent và tra cứu khi cần:

```text
APPLY-TO-PROJECT.md
→ chi tiết cách bê framework vào project

docs/README.md
→ router project knowledge

docs/ai/16-TASK-EXECUTION.md
→ execution contract
```

Từ đây, mỗi task bình thường chỉ cần mô tả yêu cầu. Không cần nhắc Claude đọc từng file.
