# 数据库与 samples

[← 返回 README](../README_zh.md)

## 语言

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/databases.md) | [English](../en/databases.md) | [Español](../es/databases.md) | **已选择** | [Français](../fr/databases.md) | [Deutsch](../de/databases.md) |

## 章节

| 入门 | 数据库与 samples | 检查与运维 | 诊断与故障排除 |
| --- | --- | --- | --- |
| [入门](getting-started.md) | **已选择** | [检查与运维](operations.md) | [诊断与故障排除](troubleshooting.md) |

<a id="section-demo"></a>
## 必需的 `demo` 数据库

两种数据库都会初始化 `demo`：

- MySQL：`demo.demo_users`
- PostgreSQL：`demo.public.demo_users`

表包含等价字段 `id`、`name`、`email` 和 `created_at`，以及相同的五名
用户 Alice、Bob、Carol、Dave 和 Eve；检查允许用户添加额外行。
`make check-env` 要求 `MYSQL_DATABASE=demo` 与 `POSTGRES_DATABASE=demo`。

<a id="section-optional-samples"></a>
## 可选 samples

| 数据库 | 可选数据库 | 准备命令 |
|---|---|---|
| MySQL | Chinook、Sakila | `make samples-mysql` |
| PostgreSQL | Pagila、Chinook | `make samples-postgres` |

<a id="section-sample-preparation"></a>
## 准备 samples

准备过程需要 `curl` 和 `git`；MySQL samples 还需要 `unzip` 与 `sha256sum`。

准备命令会下载并校验固定的 upstream 文件，但不会启动容器，也不会向
已初始化数据库导入数据。临时下载仅保存在本地，不提交到 Git，最终位于
`MYSQL_SAMPLES_DIR` 或 `POSTGRES_SAMPLES_DIR`。来源、完整性固定值和许可
见 [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)。

data 目录为空时：

```bash
make samples-mysql
make up-mysql

make samples-postgres
make up-postgres
```

官方 entrypoint 仅在相应 data 目录为空时处理 init 文件。要向已初始化
实例添加 samples，请先备份，再有意地只重新初始化对应数据库：

```bash
make samples-mysql
make reinit-mysql CONFIRM=1

make samples-postgres
make reinit-postgres CONFIRM=1
```

完全缺失的 sample 会被跳过，不影响创建 `demo`。不完整的 sample 集合或
意外存在的 sample 数据库会被拒绝，不会自动修复或删除。

<a id="section-storage-layout"></a>
## 存储目录结构

```text
data/
├── mysql/
└── postgres/

initdb/
├── mysql/
└── postgres/
```

| 数据库 | Data | Init | 可选 samples |
|---|---|---|---|
| MySQL | `MYSQL_DATA_DIR` (`./data/mysql`) | `MYSQL_INITDB_DIR` (`./initdb/mysql`) | `MYSQL_SAMPLES_DIR` (`./samples/mysql`) |
| PostgreSQL | `POSTGRES_DATA_DIR` (`./data/postgres`) | `POSTGRES_INITDB_DIR` (`./initdb/postgres`) | `POSTGRES_SAMPLES_DIR` (`./samples/postgres`) |

data 与 sample 路径可在 `.docker.env` 中修改，但必须通过 managed path
验证。entrypoint 仅在 data 目录为空时执行 init；修改 init 文件不会迁移
已有数据库。`make down` 不删除 bind mount 数据。不要手工编辑 `data/`
中的数据库文件，它们可能属于容器使用的数字 UID/GID。

<a id="section-initialization"></a>
## 初始化生命周期

> **重要:** MySQL 与 PostgreSQL 官方 entrypoints 仅对空 data 目录执行 init
文件。修改 init 不会迁移已有数据库；`make down` 会保留 bind-mounted
数据。

<a id="section-training-access"></a>
## 学习用户访问与 ownership

MySQL 在 init 时创建 `DB_USER`，并授予它所有非系统数据库的
访问权。PostgreSQL 创建独立的非 superuser `DB_USER`，不授予
createdb/createrole，并让它拥有 `demo`、`public` schema 和已加载
sample 对象。管理员 credentials 保持独立：`MYSQL_ROOT_PASSWORD`、
`POSTGRES_SUPERUSER` 与 `POSTGRES_SUPERUSER_PASSWORD`。不要手工编辑
`data/` 中由容器拥有的文件。

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[返回 README](../README_zh.md)
