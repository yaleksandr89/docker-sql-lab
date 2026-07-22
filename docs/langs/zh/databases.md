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
| MySQL | `chinook`、`sakila` | `make samples-mysql` |
| PostgreSQL | `pagila`、`chinook` | `make samples-postgres` |

<a id="section-sample-preparation"></a>
## 准备 samples

准备过程需要 `curl` 和 `git`；MySQL samples 还需要 `unzip` 与 `sha256sum`。

准备命令会下载并校验固定的 upstream 文件，但不会启动容器，也不会向
已初始化数据库导入数据。临时下载仅保存在本地，不提交到 Git，最终位于
`MYSQL_SAMPLES_DIR` 或 `POSTGRES_SAMPLES_DIR`。来源、完整性固定值和许可
见 [`THIRD_PARTY_NOTICES.md`](../../../THIRD_PARTY_NOTICES.md)。

准备时机以及重新初始化现有数据库的方法见
[初始化生命周期](#section-initialization)。

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
验证。init 目录的应用规则见[初始化生命周期](#section-initialization)。
不要手工编辑 `data/` 中的数据库文件，它们可能属于容器使用的数字 UID/GID。

<a id="section-initialization"></a>
## 初始化生命周期

> **重要：** MySQL 与 PostgreSQL 官方 entrypoints 仅对空 data 目录执行
> init 文件。初始化后添加文件不会改变已有数据库。`make down` 会保留
> 数据，而确认后的重新初始化会删除所选数据库当前的数据，并根据最新 init
> 脚本重新创建数据库。只有需要保留自己的数据时才需备份；没有重要改动的
> 一次性学习环境不要求备份。

如需在首次初始化时包含 samples，请在第一次启动前准备：

```bash
make samples-mysql
make up-mysql

make samples-postgres
make up-postgres
```

对于已经初始化的数据库，如有需要请先保留自己的数据，然后只执行对应的确认重新初始化：

```bash
make samples-mysql
make reinit-mysql CONFIRM=1

make samples-postgres
make reinit-postgres CONFIRM=1
```

<a id="section-training-access"></a>
## 学习用户访问与 ownership

MySQL 在 init 时创建 `DB_USER`，并授予它所有非系统数据库的
访问权。PostgreSQL 创建独立的非 superuser `DB_USER`，不授予
createdb/createrole，并让它拥有 `demo`、`public` schema 和已加载
sample 对象。管理员 credentials 保持独立：`MYSQL_ROOT_PASSWORD`、
`POSTGRES_SUPERUSER` 与 `POSTGRES_SUPERUSER_PASSWORD`。不要手工编辑
`data/` 中由容器拥有的文件。

[返回 README](../README_zh.md)
