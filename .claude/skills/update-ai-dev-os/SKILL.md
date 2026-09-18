---
name: update-ai-dev-os
description: Use when a repository already contains AI-DEV-OS files and needs to adopt a newer framework baseline, migrate an unversioned install, or reconcile framework changes without losing project-specific knowledge.
---

# Update AI-DEV-OS

Mục tiêu: nâng framework **an toàn**, không copy đè project knowledge.

## Khi dùng

Dùng khi:

- repo đã apply AI-DEV-OS và framework source có version mới;
- repo cũ chưa có `.ai-dev-os/VERSION`;
- cần nhận execution/context/skill changes mới.

Không dùng để bootstrap project knowledge lần đầu.

## Upgrade flow

~~~text
Read current VERSION
↓
Read target UPGRADE.md
↓
Inventory current AI-DEV-OS files
↓
Classify ownership
├─ framework-owned → update có kiểm soát
├─ project-owned   → preserve
└─ mixed           → merge + review conflict
↓
Verify
↓
Update VERSION cuối cùng
~~~

## Ownership rule

Project-owned knowledge không được overwrite tự động:

- project context/product;
- architecture decisions;
- CODEBASE-MAP content;
- business rules;
- project coding conventions;
- commands/testing;
- module/operations docs;
- ADRs;
- project custom skills.

Framework-owned thường gồm execution contract, context/tool policy, generic adapter/skills/agents và framework templates.

Mixed file phải diff/merge.

## Legacy / unversioned

Nếu `.ai-dev-os/VERSION` chưa tồn tại:

1. coi repo là legacy install;
2. detect những AI-DEV-OS artifacts đã có;
3. preserve project-owned content;
4. áp migration hướng dẫn trong `UPGRADE.md`;
5. không bootstrap full lại chỉ vì thiếu version marker;
6. chỉ tạo VERSION sau verification.

## Optional tools

Không tự:

- cài codebase-memory-mcp;
- cài ast-grep;
- cài Repomix;
- sửa global agent config;
- bật MCP;
- overwrite `.mcp.json`.

Nếu target version giới thiệu optional tool, report nó như lựa chọn riêng.

## Conflict

Nếu project đã customize framework-owned/mixed file và merge không rõ:

~~~text
CONFLICT
Path: ...
Framework change: ...
Project customization: ...
Decision needed: ...
~~~

Dừng phần conflict đó; không đoán và không copy đè.

## Verification

Trước khi bump VERSION:

- expected framework files tồn tại;
- project-owned knowledge còn nguyên;
- mixed conflicts đã resolve hoặc report;
- optional tool không bị auto-enabled;
- docs không yêu cầu capability project chưa có;
- migration-specific checks trong UPGRADE.md đã pass.

Chỉ sau đó cập nhật `.ai-dev-os/VERSION`.

## Report

~~~text
From:
- <version | legacy-unversioned>

To:
- <target version>

Updated:
- ...

Preserved:
- ...

Conflicts:
- ...

Optional tools:
- enabled / unchanged / not installed

Verification:
- ...

Version:
- updated / not updated
~~~
