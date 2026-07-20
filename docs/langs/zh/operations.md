# 检查与运维

[← 返回 README](../README_zh.md)

## 语言

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/operations.md) | [English](../en/operations.md) | [Español](../es/operations.md) | **已选择** | [Français](../fr/operations.md) | [Deutsch](../de/operations.md) |

## 章节

| 入门 | 数据库与 samples | 检查与运维 | 诊断与故障排除 |
| --- | --- | --- | --- |
| [入门](getting-started.md) | [数据库与 samples](databases.md) | **已选择** | [诊断与故障排除](troubleshooting.md) |

<a id="section-make-targets"></a>
## 公共 Make targets

公共 targets 及其实现位于 [`Makefile`](../../../Makefile)。

关键 targets 包括 `make init`、`make up`、`make down`、
`make check`、`make test-storage-paths`、`make test-sql-imports`、
`make mysql-import` 和 `make postgres-import`。Trusted SQL 不是
sandbox，可能 partial execution，且不保证 automatic rollback；重要导入
前先做 backup。内置 backup targets 仅覆盖 MySQL `demo`，不覆盖
PostgreSQL。`clean-*` 与 `reinit-*` 是 destructive 操作，并要求精确
`CONFIRM=1`。

<details>
<summary>📋 完整公共 Make targets 参考</summary>

`make help` 显示简要命令列表。

| 命令 | 用途 |
|---|---|
| `make init` | 创建 `.docker.env`、验证 managed paths、创建目录 |
| `make check-env` | 检查 env、角色分离、数据库名与 managed paths |
| `make pull` | 拉取三个固定版本的镜像 |
| `make config` | 验证展开后的 Compose 配置 |
| `make up`、`make up-no-ui` | 启动两个数据库，启用或不启用 Adminer |
| `make up-mysql`、`make up-mysql-ui` | 启动 MySQL，可选 Adminer |
| `make up-postgres`、`make up-postgres-ui` | 启动 PostgreSQL，可选 Adminer |
| `make up-ui`、`make down-ui` | 仅启动或停止 Adminer |
| `make down` | 停止环境但不删除 bind-mounted 数据 |
| `make status`、`make logs` | 查看状态或跟踪所有日志 |
| `make log SERVICE=postgres` | 跟踪单个服务；也支持 `make log postgres` |
| `make in SERVICE=postgres` | 打开服务 shell；也支持 `make in postgres` |
| `make mysql`、`make mysql-user` | 以管理员或 `DB_USER` 打开 MySQL |
| `make postgres`、`make postgres-user` | 以超级用户或 `DB_USER` 打开 PostgreSQL |
| `make samples-mysql`、`make samples-postgres` | 准备已校验的 samples |
| `make check-mysql-access`、`make check-postgres-access` | 检查一个运行中的数据库 |
| `make check` | 验证 Compose 及 `DB_USER` 对两种数据库的访问 |
| `make test-storage-paths` | 无需 Docker runtime 测试 managed path 保护 |
| `make test-sql-imports` | smoke-test 两个公共 SQL import targets |
| `make mysql-import FILE=... DATABASE=...` | 以 `DB_USER` 向 MySQL 导入 plain SQL |
| `make postgres-import FILE=... DATABASE=...` | 以 `DB_USER` 向 PostgreSQL 导入 plain SQL |
| `make dump`、`make restore` | 备份或恢复 MySQL `demo` |
| `make clean-{mysql,postgres,all} CONFIRM=1` | 删除选定的 data 目录 |
| `make reinit-{mysql,postgres,all} CONFIRM=1` | 删除、重建并检查数据库 |

</details>

<a id="section-validation"></a>
## 检查

### 静态与本地检查

```bash
make check-env
make config
make test-storage-paths
```

`make check-env` 在缺失时创建 `.docker.env`，然后验证配置与 managed
paths。`make config` 验证展开后的 Compose 模型。`make test-storage-paths`
不需要 Docker runtime；它测试项目外路径、symlink 组件、路径重叠/嵌套
以及 reserved directories。

### Runtime 检查

```bash
make up-no-ui
make check
make test-sql-imports
make down
```

`make check` 验证必需的 `demo` 数据和 `DB_USER` 的实际访问，也检查已安装
的可选 samples。`make test-sql-imports` 要求两种数据库都已启动；它调用
公共 `mysql-import` 与 `postgres-import`，在 `demo` 中创建唯一命名的临时
表，以 `DB_USER` 验证 marker rows，并且只删除这些表。这是 trusted import
工作流的 smoke-test，不是 sandbox，也不能证明不可信 SQL 的安全性。

<a id="section-storage-path-safety"></a>
## Storage path 安全

`make check-env` 会运行
[`scripts/validate-storage-paths.sh`](../../../scripts/validate-storage-paths.sh)。Data
paths 必须严格位于 `data/` 内，sample paths 必须严格位于
`samples/` 内；symlink、相同、嵌套、重叠和 reserved paths 都会被拒绝。
`make test-storage-paths` 无需 Docker runtime 即可测试这些规则。

<a id="section-sql-imports"></a>
## Trusted SQL 导入

```bash
make mysql-import FILE=path/to/file.sql DATABASE=demo
make postgres-import FILE=path/to/file.sql DATABASE=demo
```

两个 targets 都遵循以下规则：

- `FILE` 与 `DATABASE` 必填。
- 文件必须是存在、可读、非空的本地 plain SQL。
- 数据库必须已存在；禁止系统数据库。
- import 以 `DB_USER` 执行，不创建数据库，也不授予 grants。
- `DATABASE` 只选择初始连接，不创建 sandbox。
- qualified names、client/session commands 及真实 grants 可能影响其他
  可访问对象。
- 可能发生 partial execution；不承诺自动 rollback。
- 重要导入前必须备份。
- 不处理 gzip、archives 或 PostgreSQL custom-format backups。

<a id="section-backup"></a>
## 备份

内置 targets 只覆盖配置的 MySQL `demo` 数据库：

```bash
make dump
make restore
```

`make dump` 写入 `backup/demo.sql`；`make restore` 读取该文件并重新应用
MySQL 学习 grants。PostgreSQL 数据应使用独立备份流程。

<a id="section-clean-reinitialize"></a>
## 清理与重新初始化

> **警告：** 所有 `clean-*` 和 `reinit-*` 命令都是破坏性的，并且要求
> 精确确认 `CONFIRM=1`。

```bash
make clean-mysql CONFIRM=1
make clean-postgres CONFIRM=1
make clean-all CONFIRM=1

make reinit-mysql CONFIRM=1
make reinit-postgres CONFIRM=1
make reinit-all CONFIRM=1
```

单数据库命令只删除对应 data 目录；`all` 会删除两种数据库的数据。配置、
init、samples 和 backups 会保留。reinit 随后启动并检查所选数据库；
`reinit-all` 启动两者但不启用 Adminer。

[返回 README](../README_zh.md)
