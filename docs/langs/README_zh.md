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
| `make up-no-ui` | 启动 | 启动 | 停止 |
| `make up-mysql` | 启动 | 不启动 | 不启动 |
| `make up-postgres` | 不启动 | 启动 | 不启动 |

单数据库命令不会停止另一种已运行的数据库；Adminer 可单独管理。

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

## 凭据概览

| 用途 | 用户 | 密码 |
|---|---|---|
| 两种数据库共用的学习用户 | `DB_USER` | `DB_PASSWORD` |
| MySQL 管理员 | `root` | `MYSQL_ROOT_PASSWORD` |
| PostgreSQL 超级用户 | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` 与 `DB_USER` 必须是不同角色。日常练习应使用共用学习用户；发布服务前请替换示例密码。

## 数据库与关键检查

两种数据库都会创建必需的 `demo`，其中包含等价的 `demo_users` 表。MySQL 的可选 samples 是 Chinook 与 Sakila，PostgreSQL 的是 Pagila 与 Chinook。准备 samples 不会将其导入已初始化的数据。

以下静态检查不要求数据库正在运行：

```bash
make check-env
make config
make test-storage-paths
```

启动两种数据库后，`make check` 验证 `DB_USER` 访问，`make test-sql-imports` 测试公共 trusted import targets。下方详细文档列出了全部命令、限制与安全操作顺序。

MySQL 与 PostgreSQL 的 data、init 和 sample 目录彼此分离，并通过 `.docker.env` 配置。Managed path validator 会拒绝 `data/` 或 `samples/` 之外的位置、symlink 组件、路径重叠以及 reserved directories。可选 sample 完全缺失时会被跳过；若文件集合不完整或 sample 数据库意外存在，则会报错且不会自动修复。

Sample 准备命令下载固定 revision 的 upstream 文件、校验 integrity，并只保存在本地；来源与许可见 `THIRD_PARTY_NOTICES.md`。Runtime 检查还会验证 `demo` 必需行、学习用户的读写访问以及已安装 samples。所有数据库连接都应优先使用 `DB_USER`，仅在管理操作确实需要时才使用独立的管理员 credentials。

## 安全与生命周期

- `BIND_ADDRESS=127.0.0.1` 仅在 loopback 发布服务。
- `BIND_ADDRESS=0.0.0.0` 会在所有接口发布服务；必须明确配置 firewall、
  强 credentials，并确认网络可信度。
- 官方 entrypoints 仅对空 data 目录执行 init。
- `make mysql-import` 与 `make postgres-import` 只接受 trusted SQL。
  它们不创建 sandbox；可能 partial execution，且不保证完整 automatic
  rollback。重要导入前先做 backup。
- 内置 `make dump` 和 `make restore` 仅覆盖 MySQL `demo`；
  PostgreSQL 没有内置 backup target。
- 所有 `clean-*` 与 `reinit-*` 都是 destructive 操作，并要求精确的
  `CONFIRM=1`。

## 文档

- [开始使用](zh/getting-started.md)
- [数据库与 samples](zh/databases.md)
- [检查与运维](zh/operations.md)
- [诊断与故障排除](zh/troubleshooting.md)

## 许可与第三方声明

Docker SQL Lab 使用 MIT License，见 [LICENSE.md](../../LICENSE.md)。
可选 samples 保留 upstream 许可；来源、固定 revision、完整性信息和许可
文本见 [THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md)。

<p align="center">
  <a href="https://yaleksandr89.github.io/" title="yaleksandr89.github.io">
    <img
      src="../assets/ya-logo-dark-50px.png"
      alt="YA"
      width="32"
    >
  </a>
  <br>
  <a href="https://yaleksandr89.github.io/">yaleksandr89.github.io</a>
</p>
