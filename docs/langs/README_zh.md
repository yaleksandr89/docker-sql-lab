<p align="center">
  <img
    src="../assets/docker-sql-lab-cover.png"
    alt="Docker SQL Lab — 本地 MySQL 与 PostgreSQL 实验环境"
    width="100%"
  >
</p>

# Docker SQL Lab

## 选择语言

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../../README.md) | [English](README_en.md) | [Español](README_es.md) | **已选择** | [Français](README_fr.md) | [Deutsch](README_de.md) |

这是一个基于 Docker Compose 的本地环境，用于学习和比较 MySQL 与
PostgreSQL。两种数据库既可独立运行，也可同时运行；仅在需要浏览器
界面时启用 Adminer。

## 技术栈与固定版本

- MySQL 9.7.1 LTS
- PostgreSQL 18.4
- Adminer 5.4.2 Docker Official Image
- Docker Compose v2
- GNU Make 和 Bash，用于项目命令及初始化脚本

镜像版本固定在 `.docker.env` 中。在将本项目用于生产环境之前，必须
单独评估凭据、网络暴露、存储、备份和运维要求。

## 主要功能

- MySQL 与 PostgreSQL 相互独立，也可以同时运行。
- Adminer 为可选组件，可连接两种数据库，不依赖某个特定数据库服务。
- 每种数据库都有必需的 `demo` 数据库和相同的五个示例用户。
- 可选 samples：MySQL 使用 Sakila 和 Chinook；PostgreSQL 使用 Pagila 和 Chinook。
- 每种数据库的 data、init 和 sample bind mount 相互分离。
- 两种数据库共用学习凭据，管理员凭据彼此独立。
- 提供静态配置检查、managed storage path 保护、runtime 访问检查和
  trusted SQL import smoke-test。
- 清理与重新初始化等破坏性命令必须显式确认。

## 要求

- Docker Engine 或 Docker Desktop，并支持 `docker compose` v2 命令。
- GNU Make、Bash，以及脚本使用的 Unix 工具：`awk`、`sed`、`grep`、
  `find`、`realpath` 和 `stat`。
- 下载可选 samples 需要 `curl` 和 `git`；MySQL 还需要 `unzip` 与
  `sha256sum`。

请在仓库根目录执行命令。项目默认分支为 `master`。

## 快速开始

从受版本控制的示例创建 `.docker.env`，验证路径，创建工作目录并启动
完整环境：

```bash
make init
make up
```

`make up` 会启动 MySQL、PostgreSQL 和 Adminer。默认配置下，Adminer
地址为 `http://127.0.0.1:8081`。

```bash
make status
make logs
make down
```

`make down` 删除容器和网络，但保留 bind-mounted 数据。

## 启动模式

| 命令 | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | 启动 | 启动 | 启动 |
| `make up-no-ui` | 启动或保持运行 | 启动或保持运行 | 若运行则停止 |
| `make up-mysql` | 启动 | 不自动启动 | 不自动启动 |
| `make up-mysql-ui` | 启动 | 不自动启动 | 启动 |
| `make up-postgres` | 不自动启动 | 启动 | 不自动启动 |
| `make up-postgres-ui` | 不自动启动 | 启动 | 启动 |
| `make up-ui` | 不改变 | 不改变 | 启动 |
| `make down-ui` | 不改变 | 不改变 | 停止 |

单数据库命令不会停止已经运行的另一种数据库。Adminer 可以单独启停，
并非只服务于 MySQL。

## 连接

### Adminer

在 Compose 网络内，Adminer 提供两个预设服务器：

```text
MySQL (mysql)
PostgreSQL (postgres)
```

选择服务器后，使用 `DB_USER`、`DB_PASSWORD` 和数据库名（如 `demo`）
登录。`mysql` 与 `postgres` 是 Compose 内部服务名，不是桌面客户端的
主机名。

### 主机客户端

| 数据库 | 默认主机 | 端口变量 | 用户 | 默认数据库 |
|---|---|---|---|---|
| MySQL | `127.0.0.1` | `MYSQL_PORT` | `DB_USER` | `demo` |
| PostgreSQL | `127.0.0.1` | `POSTGRES_PORT` | `DB_USER` | `demo` |

DataGrip、DBeaver、PhpStorm 和主机 CLI 使用发布的地址与端口。如果修改
`BIND_ADDRESS`，请按需改用对应接口可达的地址。

### 容器内 CLI

Make targets 通过容器环境传递密码，不会把密码写入 shell history：

```bash
make mysql          # MySQL 管理员，demo 数据库
make mysql-user     # DB_USER，demo 数据库
make postgres       # PostgreSQL 超级用户，demo 数据库
make postgres-user  # DB_USER，demo 数据库
```

## 凭据

`.docker.env` 从 `.docker.env.example` 创建，并被 Git 忽略。密码应保存在
该文件中，不要硬编码进受版本控制的 Compose、SQL 或客户端配置。

| 用途 | 用户设置 | 密码设置 |
|---|---|---|
| 两种数据库共用的学习用户 | `DB_USER` | `DB_PASSWORD` |
| MySQL 管理员 | `root` | `MYSQL_ROOT_PASSWORD` |
| PostgreSQL 管理员/超级用户 | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` 与 `DB_USER` 必须是不同角色。日常练习应使用学习
用户。对外共享或发布服务前，请替换示例密码。

## 端口与 `BIND_ADDRESS`

| 服务 | 端口变量 | 示例默认值 |
|---|---|---|
| MySQL | `MYSQL_PORT` | `3306` |
| PostgreSQL | `POSTGRES_PORT` | `5432` |
| Adminer | `ADMINER_PORT` | `8081` |

默认情况下，三个服务只绑定 loopback：

```env
BIND_ADDRESS=127.0.0.1
```

`127.0.0.1` 是本地默认值。`BIND_ADDRESS=0.0.0.0` 会在所有网络接口上
发布端口。LAN 或 VPN 访问应优先使用具体接口的地址。修改时必须明确
评估 firewall、密码强度和网络可信度。

## 学习数据库

### 必需的 `demo` 数据库

两种数据库都会初始化 `demo`：

- MySQL：`demo.demo_users`
- PostgreSQL：`demo.public.demo_users`

表包含等价字段 `id`、`name`、`email` 和 `created_at`，以及相同的五名
用户 Alice、Bob、Carol、Dave 和 Eve；检查允许用户添加额外行。
`make check-env` 要求 `MYSQL_DATABASE=demo` 与 `POSTGRES_DATABASE=demo`。

### 可选 samples

| 数据库 | 可选数据库 | 准备命令 |
|---|---|---|
| MySQL | Chinook、Sakila | `make samples-mysql` |
| PostgreSQL | Pagila、Chinook | `make samples-postgres` |

准备命令会下载并校验固定的 upstream 文件，但不会启动容器，也不会向
已初始化数据库导入数据。临时下载仅保存在本地，不提交到 Git，最终位于
`MYSQL_SAMPLES_DIR` 或 `POSTGRES_SAMPLES_DIR`。来源、完整性固定值和许可
见 [THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md)。

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

## 公共 Make targets

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

## Data 与 init 生命周期

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

## 备份、清理与重新初始化

内置 targets 只覆盖配置的 MySQL `demo` 数据库：

```bash
make dump
make restore
```

`make dump` 写入 `backup/demo.sql`；`make restore` 读取该文件并重新应用
MySQL 学习 grants。PostgreSQL 数据应使用独立备份流程。

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

## 诊断与故障排除

### 配置或 storage path 验证失败

运行 `make check-env`。data paths 必须严格位于 `data/` 内，samples 必须
位于 `samples/` 内；不得包含 symlink、互相重叠或使用 reserved
directories。修正 `.docker.env` 后运行 `make config`。

### 服务未就绪

```bash
make status
make log SERVICE=mysql
make log SERVICE=postgres
```

在修改数据前，检查 Docker、端口、`.docker.env` 与日志。

### init 修改或 samples 未出现

如果 data 已初始化，这是预期行为。检查路径与准备命令，备份重要数据，
仅在明确需要时最后使用 `reinit-... CONFIRM=1`。

### sample 不完整或所有者异常

loader 不会覆盖或修复意外数据库。重新运行 `make samples-mysql` 或
`make samples-postgres` 并检查错误；重新初始化前先保留所需数据。

### 客户端无法连接

主机客户端使用发布地址及 `MYSQL_PORT` 或 `POSTGRES_PORT`；Adminer 在
Compose 网络中使用 `mysql` 或 `postgres`。检查 `BIND_ADDRESS`、
firewall、数据库选择和非管理员 `DB_USER` 凭据。

## 许可与第三方声明

Docker SQL Lab 使用 MIT License，见 [LICENSE.md](../../LICENSE.md)。
可选 samples 保留 upstream 许可；来源、固定 revision、完整性信息和许可
文本见 [THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md)。
