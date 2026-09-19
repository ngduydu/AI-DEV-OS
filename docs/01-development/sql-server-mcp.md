# SQL Server MCP

Mục tiêu: cho AI agent truy cập SQL Server theo một contract **có kiểm soát**, phục vụ đọc dữ liệu/schema logic cần thiết cho task mà không biến database thành vùng agent được tự do chạy SQL.

## Implementation khuyến nghị

AI-DEV-OS ưu tiên **Microsoft SQL MCP Server qua Data API builder (DAB)**.

Lý do:

- do Microsoft duy trì;
- MCP surface sinh từ entity configuration thay vì để model tự NL2SQL trực tiếp;
- có RBAC/policy;
- hỗ trợ table, view và stored procedure;
- hỗ trợ stdio cho local agent;
- có telemetry và deployment path rõ khi cần production.

Baseline đã review cho AI-DEV-OS: `Microsoft.DataApiBuilder 2.0.12`.

Không khóa project vào version này mãi mãi; nâng version phải qua Tool Adoption/Security review.

## Default posture

SQL MCP là **optional theo project**, không phải core dependency.

Mặc định:

```text
development/test database
→ read-only role
→ allowlist entity cần thiết
→ agent đọc/aggregate/execute stored procedure được phép
```

Không mặc định:

```text
production
DDL
unrestricted SQL
write/delete
sa/sysadmin credential
connection string trong repository
```

## Security rules bắt buộc

1. Không commit connection string, password, token hoặc secret.
2. Dùng environment variable hoặc secret provider: `@env('MSSQL_CONNECTION_STRING')`.
3. Database login dành cho agent phải least privilege.
4. Chỉ expose table/view/stored procedure cần cho workflow.
5. Với local Claude Code, ưu tiên role riêng như `ai-readonly`.
6. Production access cần user/team phê duyệt rõ; không suy ra từ việc test/dev đã kết nối.
7. Schema/DDL vẫn đi qua SQL migration/script/review bình thường, không giao cho MCP mặc định.
8. Query/result có dữ liệu nhạy cảm phải tuân security/privacy policy của project.
9. Không dùng MCP result thay source-of-truth về schema migration đang nằm trong Git.
10. Nếu MCP unavailable, fallback về SQL file/source/docs thay vì chặn task.

## Setup machine tool

Nếu team muốn dùng SQL MCP:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\setup-ai-dev-machine.ps1 -WithSqlServerMcp
```

Flag này chỉ cài/verify DAB CLI trên máy.

Nó **không**:

- tạo connection string;
- sửa database;
- tự expose table/view/SP;
- tự đăng ký một database cụ thể ở user scope.

Database configuration là project-specific.

## Setup project

Ví dụ khởi tạo local/test config:

```powershell
$env:MSSQL_CONNECTION_STRING = "<set outside git>"

dab init `
  --database-type mssql `
  --connection-string "@env('MSSQL_CONNECTION_STRING')" `
  --host-mode Development `
  --config dab-config.json
```

Bật MCP trong `dab-config.json` và chỉ bật tool cần thiết. Read-only baseline:

```json
{
  "runtime": {
    "mcp": {
      "enabled": true,
      "dml-tools": {
        "describe-entities": true,
        "read-records": true,
        "aggregate-records": true,
        "execute-entity": true,
        "create-record": false,
        "update-record": false,
        "delete-record": false
      }
    }
  }
}
```

Nếu project không cần stored procedure qua MCP, tắt cả `execute-entity`.

Sau đó expose từng entity cần thiết với quyền tối thiểu.

Ví dụ read-only:

```powershell
dab add Products `
  --config dab-config.json `
  --source dbo.Products `
  --source.type table `
  --permissions "ai-readonly:read" `
  --description "Product inventory exposed for development diagnostics."
```

Với stored procedure có contract ổn định, có thể expose như custom MCP tool thay vì để agent tạo raw SQL.

## Claude Code

Template tham khảo:

```text
templates/mcp/claude-sql-server-dab.json
```

Khi dùng:

- merge entry vào MCP config hiện hữu;
- không overwrite config khác;
- bảo đảm `dab-config.json` của project dùng secret qua environment;
- verify bằng `/mcp`.

## Khi agent được phép dùng SQL MCP?

Phù hợp:

- kiểm tra dữ liệu test để reproduce bug;
- xác minh row/state transition;
- đọc metadata/entity đã expose;
- aggregate dữ liệu phục vụ diagnosis;
- gọi stored procedure read/diagnostic đã được allowlist.

Không phù hợp mặc định:

- sửa live data;
- chạy DDL;
- mass update/delete;
- thay migration script;
- suy luận business rule chỉ từ snapshot data.

## Ground truth

```text
SQL MCP
→ runtime evidence / diagnostic accelerator

SQL source + migration + stored procedure trong Git
→ implementation ground truth

Project docs
→ durable rule/context
```
