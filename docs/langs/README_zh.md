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

用于练习 SQL、了解并比较 MySQL 与 PostgreSQL 的本地 Docker Compose
实验环境。两种数据库既可单独启动，也可同时运行。精简的 `demo`
数据库会自动创建；可选的 Sakila、Pagila 和 Chinook 数据集提供开箱即用
的查询练习数据。仅在需要时启用 Adminer。

## 技术栈与固定版本

- MySQL 9.7.1 LTS
- PostgreSQL 18.4
- Adminer 5.4.2 Docker Official Image
- Docker Compose v2
- GNU Make 与 Bash，用于项目命令和初始化脚本

固定的默认值定义在
[`.docker.env.example`](../../.docker.env.example)；`make init` 会据此创建
本地 `.docker.env`。服务定义在
[`docker-compose.yml`](../../docker-compose.yml)。

<details>
<summary>⚠️ 重要：这是学习环境</summary>

本项目不是可直接用于 production 的模板。对外使用前，必须另行设计
credentials、网络暴露、存储、备份与运维方案。

</details>

## 主要功能

- MySQL 与 PostgreSQL 可单独运行，也可同时运行。
- 每种数据库都有必需的 `demo`，并包含相同的 seed rows。
- MySQL 可选 Sakila 和 Chinook；PostgreSQL 可选 Pagila 和 Chinook。
- Adminer 是供两种数据库共用、独立启用的可选界面。
- 两种数据库分别使用 bind-mounted data、init 与 sample 目录。
- 配置与访问检查、可信 SQL 导入和 destructive 操作集中在
  [`Makefile`](../../Makefile)。

## 要求

1. Docker Engine 或带有 `docker compose` v2 的 Docker Desktop。
2. GNU Make、Bash 以及脚本使用的基础 Unix CLI 工具。

推荐环境：Linux；装有 Docker Desktop 的 macOS；Docker Desktop +
WSL2 的 Windows。所有命令都从仓库根目录执行。项目默认分支为
`master`。

## 快速开始

```bash
make init
make up
```

`make init` 从受版本控制的
[`.docker.env.example`](../../.docker.env.example) 创建本地 `.docker.env`，
检查 managed paths 并创建工作目录。首次启动容器时，官方 entrypoints
会初始化两种数据库。即使不安装可选 samples，MySQL 与 PostgreSQL
仍可正常使用，并都包含必需的 `demo` 与 seed rows。

`make up` 启动 MySQL、PostgreSQL 和 Adminer；`make up-no-ui` 只启动两种
数据库。默认可通过 `http://127.0.0.1:8081` 访问 Adminer。

启动模式、连接与凭据详见：[入门](zh/getting-started.md)。

### 需要现成的练习数据吗？

Samples 并非必需：`demo` 始终创建；MySQL 支持 Sakila 和 Chinook，PostgreSQL 支持 Pagila 和 Chinook。

**首次启动，data 目录为空**

```bash
make init
make samples-mysql
make samples-postgres
make up
```

请在首次初始化前准备 samples；官方 entrypoints 会将它们与 `demo` 一起载入。

> **警告：** 如果 data 目录已在没有 samples 时初始化，添加 samples 需要先做 backup，并明确确认 destructive reinit。

<details>
<summary>📦 环境已启动过：添加或继续使用 samples</summary>

**已在没有 samples 时初始化。** 普通的 `make up` 不会应用新增的 init/sample 文件。请先备份重要数据，再选择对应方式：

- MySQL：`make samples-mysql`，然后 `make reinit-mysql CONFIRM=1`。
- PostgreSQL：`make samples-postgres`，然后 `make reinit-postgres CONFIRM=1`。
- 两种数据库：`make samples-mysql`、`make samples-postgres`，然后 `make reinit-all CONFIRM=1`。

> **警告：** `reinit-*` 会删除所选数据库的数据，且只有准确提供 `CONFIRM=1` 才会执行。

**Samples 已安装。** 直接使用 `make up` 或所选的 `make up-*`：无需重复 download 或 reinit，数据库会保留在 bind-mounted storage 中。

</details>

详见：[数据库与 samples](zh/databases.md)。

## 启动模式

| 命令 | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | 启动 | 启动 | 启动 |
| `make up-no-ui` | 启动 | 启动 | 停止 |
| `make up-mysql` | 启动 | 不启动 | 不启动 |
| `make up-postgres` | 不启动 | 启动 | 不启动 |

单数据库命令不会停止另一个已运行的数据库；Adminer 单独管理。完整
targets 列表见 [`Makefile`](../../Makefile)。

## 连接与可用数据库

在 Compose 网络内，Adminer 使用 `mysql` 和 `postgres`。宿主机客户端
使用 `127.0.0.1` 以及配置的 `MYSQL_PORT` 或 `POSTGRES_PORT`。日常练习
使用 `DB_USER` 和 `DB_PASSWORD`。

| 数据库 | 始终可用 | 可选 samples 初始化后 |
|---|---|---|
| MySQL | `demo` | `sakila`、`chinook` |
| PostgreSQL | `demo` | `pagila`、`chinook` |

可选数据库只有在实际初始化后才存在。详见：
[启动与连接](zh/getting-started.md) ·
[数据库与 samples](zh/databases.md)。

## 凭据概览

| 用途 | 用户 | 密码 |
|---|---|---|
| 共用学习用户 | `DB_USER` | `DB_PASSWORD` |
| MySQL 管理员 | `root` | `MYSQL_ROOT_PASSWORD` |
| PostgreSQL superuser | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` 与 `DB_USER` 必须是不同角色。练习时使用学习用户；
对外发布服务前请替换示例密码。

## 数据库与关键检查

两种 `demo` 都包含等价的 `demo_users` 表和五行数据。以下静态检查
无需启动数据库：

```bash
make check-env
make config
make test-storage-paths
```

启动后，`make check` 检查 `demo` 与 `DB_USER` 访问；
`make test-sql-imports` 测试公开的可信导入 targets。顺序与限制详见：
[检查与运维](zh/operations.md)。

## 安全与生命周期

- `BIND_ADDRESS=127.0.0.1` 仅在 loopback 上发布服务。
- `BIND_ADDRESS=0.0.0.0` 会暴露所有网络接口；请先配置 firewall、
  强凭据与可信网络。
- 官方 entrypoints 仅在 data 为空时执行 init。
- `make mysql-import` 与 `make postgres-import` 只接受可信 SQL。它们不是
  sandbox：可能部分执行，且不保证完整自动 rollback。
  重要导入前，请检查 SQL 文件并创建合适的 backup。
- 内置 `make dump` 与 `make restore` 只覆盖 MySQL `demo`；没有内置
  PostgreSQL backup target。
- 所有 `clean-*` 与 `reinit-*` 都是 destructive 操作，并且必须准确提供
  `CONFIRM=1`。

安全操作顺序：[检查与运维](zh/operations.md)。出现问题时先收集诊断：
[诊断与故障排除](zh/troubleshooting.md)。

## 练习数据许可证

可选数据集保留各 upstream 项目的许可证与 notices。来源、固定
revision、完整性信息与许可证文本见
[`THIRD_PARTY_NOTICES.md`](../../THIRD_PARTY_NOTICES.md)。

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
