# 入门

[← 返回 README](../README_zh.md)

## 语言

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/getting-started.md) | [English](../en/getting-started.md) | [Español](../es/getting-started.md) | **已选择** | [Français](../fr/getting-started.md) | [Deutsch](../de/getting-started.md) |

## 章节

| 入门 | 数据库与 samples | 检查与运维 | 诊断与故障排除 |
| --- | --- | --- | --- |
| **已选择** | [数据库与 samples](databases.md) | [检查与运维](operations.md) | [诊断与故障排除](troubleshooting.md) |

<a id="section-requirements"></a>
## 要求

- Docker Engine 或 Docker Desktop，并使用 Docker Compose v2。
- GNU Make、Bash 和基本 Unix 命令行工具。
- 推荐环境：Linux；使用 Docker Desktop 的 macOS；或使用 Docker Desktop
  与 WSL2 的 Windows。

请在仓库根目录执行命令。项目默认分支为 `master`。

<a id="section-quick-start"></a>
## 快速开始

`make init` 会根据 [`.docker.env.example`](../../../.docker.env.example)
创建本地 `.docker.env`，验证受控存储路径并创建工作目录。然后启动完整环境：

```bash
make init
make up
```

`make up` 会启动 MySQL、PostgreSQL 和 Adminer。默认配置下，Adminer
地址为 `http://127.0.0.1:8081`。

使用 `make up-no-ui` 可启动两种数据库而不启动 Adminer。首次初始化时
始终创建必需的 `demo` 数据库；示例数据集是可选的。如需在首次初始化时
加载它们，请在第一次 `make up` 前完成准备。对于已经初始化的数据目录，
仅在需要保留自己的数据时才在确认重新初始化前备份。准确步骤见
[初始化生命周期](databases.md#section-initialization)。

```bash
make status
make logs
make down
```

`make down` 删除容器和网络，但保留 bind-mounted 数据。

<a id="section-startup-modes"></a>
## 启动模式

| 命令 | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | 启动 | 启动 | 启动 |
| `make up-no-ui` | 启动 | 启动 | 停止 |
| `make up-mysql` | 启动 | 不启动 | 不启动 |
| `make up-postgres` | 不启动 | 启动 | 不启动 |

单数据库命令不会停止另一种已运行的数据库；Adminer 可单独管理。

<details>
<summary>📋 完整启动模式表</summary>

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

</details>

<a id="section-connections"></a>
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

<a id="section-credentials"></a>
## 凭据

`.docker.env` 从 [`.docker.env.example`](../../../.docker.env.example) 创建，并被 Git 忽略。密码应保存在
该文件中，不要硬编码进受版本控制的 Compose、SQL 或客户端配置。

| 用途 | 用户设置 | 密码设置 |
|---|---|---|
| 两种数据库共用的学习用户 | `DB_USER` | `DB_PASSWORD` |
| MySQL 管理员 | `root` | `MYSQL_ROOT_PASSWORD` |
| PostgreSQL 管理员/超级用户 | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` 与 `DB_USER` 必须是不同角色。日常练习应使用学习
用户。对外共享或发布服务前，请替换示例密码。

<a id="section-network-exposure"></a>
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

[返回 README](../README_zh.md)
