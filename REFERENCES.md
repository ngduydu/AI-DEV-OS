# References & Research Notes

Snapshot nghiên cứu: 2026-09-02.

> GitHub star chỉ là tín hiệu adoption/community, không phải bằng chứng chất lượng tuyệt đối. Bộ khung này ưu tiên tài liệu chính thức trước, sau đó mới lấy pattern từ repo cộng đồng.

## Official guidance

### OpenAI — Codex / AGENTS.md / harness engineering

- Introducing Codex: https://openai.com/index/introducing-codex/
- Harness engineering: https://openai.com/index/harness-engineering/
- Unrolling the Codex agent loop: https://openai.com/index/unrolling-the-codex-agent-loop/
- OpenAI Codex GitHub: https://github.com/openai/codex

Điểm lấy vào bộ khung:

- `AGENTS.md` cung cấp persistent repo instructions.
- Nested instructions có scope theo thư mục.
- Context là tài nguyên hữu hạn.
- `AGENTS.md` nên là map, còn repository docs là system of record.
- Agent phải có môi trường/test rõ và evidence verification.
- Skills nên dùng progressive disclosure: metadata → SKILL.md → references/scripts khi cần.

### Anthropic — Claude Code

- Memory / CLAUDE.md: https://code.claude.com/docs/en/memory
- Best practices: https://code.claude.com/docs/en/best-practices
- Skills: https://code.claude.com/docs/en/slash-commands
- `.claude` directory: https://code.claude.com/docs/en/claude-directory
- Anthropic Skills repository: https://github.com/anthropics/skills

Điểm lấy vào bộ khung:

- `CLAUDE.md` cho persistent project context.
- Giữ instruction ngắn, cụ thể; rule dài nên tách.
- Claude Code có thể import `AGENTS.md` từ `CLAUDE.md`.
- Skills dành cho procedure/reusable workflow và chỉ load khi cần.
- Rule/instruction chỉ là hướng dẫn; boundary bắt buộc phải enforce bằng permissions/hooks/tooling khi cần.

### GitHub Copilot

- Custom instructions: https://docs.github.com/en/copilot/how-tos/configure-custom-instructions-in-your-ide
- Response customization: https://docs.github.com/en/copilot/concepts/prompting/response-customization
- Customization cheat sheet: https://docs.github.com/en/copilot/reference/customization-cheat-sheet
- Awesome Copilot: https://github.com/github/awesome-copilot

Điểm lấy vào bộ khung:

- `.github/copilot-instructions.md` cho repo-wide context.
- Path-specific instructions chỉ nên dùng khi thật sự cần.
- Instructions nên ngắn, self-contained, không conflict.
- Prompt files dành cho task-specific reusable prompt, khác với always-on rules.

### Cursor

- Rules: https://cursor.com/docs/rules

Điểm lấy vào bộ khung:

- Cursor đọc `AGENTS.md`.
- Rule theo path hữu ích cho monorepo/framework nhưng không nên bật mọi thứ toàn cục.
- Rule nên ngắn, focused và reference canonical code thay vì copy cả implementation vào prompt.

---

## High-adoption repositories / methods reviewed

### obra/superpowers — ~260K+ stars

https://github.com/obra/superpowers

Pattern đáng học:

- brainstorming/design before non-trivial implementation;
- plan-driven work;
- TDD/debugging/verification disciplines;
- reusable skills;
- verification before claiming completion.

Không copy nguyên bộ vì process có thể nặng với task nhỏ. Bộ này dùng process theo mức S/M/L.

### anthropics/skills — ~150K+ stars

https://github.com/anthropics/skills

Pattern đáng học:

- `SKILL.md` là unit capability;
- metadata ngắn, body load on demand;
- supporting references/scripts chỉ load khi cần.

### github/spec-kit — ~130K+ stars

https://github.com/github/spec-kit

Pattern đáng học:

```text
Spec → Plan → Tasks → Implement
```

Mỗi phase tạo Markdown artifact làm input cho phase sau. Bộ này bổ sung `Research` trước Spec khi codebase/behavior chưa đủ rõ và `Verification` sau Implement.

### openai/codex — ~90K+ stars

https://github.com/openai/codex

Pattern đáng học:

- repo instructions;
- skills;
- tests/evidence;
- concise code-review skills;
- context management.

### hesreallyhim/awesome-claude-code — ~50K+ stars

https://github.com/hesreallyhim/awesome-claude-code

Dùng làm nguồn khảo sát hệ sinh thái skills/agents/hooks/configs, không dùng làm source of truth thay official docs.

### bmad-code-org/BMAD-METHOD — ~48K+ stars

https://github.com/bmad-code-org/BMAD-METHOD

Pattern đáng học:

- workflow theo vai trò;
- structured AI-driven development;
- scale process theo độ phức tạp.

Bộ này chủ động ít ceremony hơn cho team nhỏ/solo developer.

### github/awesome-copilot — ~38K+ stars

https://github.com/github/awesome-copilot

Pattern đáng học:

- tách instructions, prompts, agents, skills theo mục đích;
- có nhiều customization mẫu theo công nghệ/task.

### eyaltoledano/claude-task-master — ~28K+ stars

https://github.com/eyaltoledano/claude-task-master

Pattern đáng học:

- task có dependency;
- test strategy là field của task;
- task decomposition cho work lớn.

### agentsmd/agents.md — ~23K+ stars

https://github.com/agentsmd/agents.md

Pattern đáng học:

- `AGENTS.md` như README dành cho agent;
- project structure, commands, conventions, testing, security;
- nested scope.

### numman-ali/openskills — ~10K+ stars

https://github.com/numman-ali/openskills

Pattern đáng học:

- skills là static instructions/resources, không cần MCP cho mọi workflow;
- portable skills giữa nhiều agent.

### snarktank/ai-dev-tasks — ~8K+ stars

https://github.com/snarktank/ai-dev-tasks

Pattern đáng học:

- PRD → task generation;
- Markdown artifacts đơn giản có thể hiệu quả hơn hệ thống phức tạp.

### HumanLayer — Advanced Context Engineering

https://github.com/humanlayer/advanced-context-engineering-for-coding-agents

Pattern đáng học:

```text
Research → Plan → Implement
```

và quản lý context có chủ ý. Bộ này kết hợp pattern đó với Spec Kit thành:

```text
Research → Spec → Plan → Tasks → Implement → Verification
```

nhưng chỉ dùng đầy đủ cho task lớn/rủi ro cao.

---

## Kết luận thiết kế

Bộ khung chọn các nguyên tắc sau:

1. **Repository là memory chung**, không dựa vào chat history.
2. **Map, not manual**: root instructions ngắn, docs chi tiết on-demand.
3. **Progressive disclosure**: always-on rules → docs → skills → references khi cần.
4. **Spec/plan artifacts cho việc phức tạp**, không vibe-code task lớn.
5. **Research trước plan** khi chưa hiểu code hiện tại.
6. **Verification là artifact/bằng chứng**, không phải câu nói của AI.
7. **Process adaptive**, tránh ceremony cho task nhỏ.
8. **Recurring correction → durable knowledge**, recurring procedure → Skill.
9. **Rules are guidance, tooling is enforcement** cho security/format/test bắt buộc.
10. **Một nguồn sự thật**, adapter cho từng AI phải càng mỏng càng tốt.
