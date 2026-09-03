# Commands

> Đây là nguồn sự thật cho AI về cách chạy project và verify thay đổi. Chỉ để lệnh đã kiểm tra thực tế.

## Setup

```bash
# TODO: lệnh cài dependency/setup
```

## Run local

```bash
# TODO
```

## Unit tests

```bash
# TODO
```

## Integration tests

```bash
# TODO
```

## Lint / static analysis

```bash
# TODO
```

## Format

```bash
# TODO
```

## Build

```bash
# TODO
```

## Database migration

```bash
# TODO
```

## Verification matrix

| Loại thay đổi | Check tối thiểu |
|---|---|
| Docs only | link/format check nếu có |
| Logic nhỏ | test liên quan + lint |
| Feature | test liên quan + integration/build |
| Database | migration validation + affected tests |
| Security/auth | tests + security review |

## Lệnh không được chạy tự động

- <Production deploy>
- <Destructive database command>
- <Khác>
