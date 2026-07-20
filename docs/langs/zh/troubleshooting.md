# 诊断与故障排除

[← 返回 README](../README_zh.md)

## 语言

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/troubleshooting.md) | [English](../en/troubleshooting.md) | [Español](../es/troubleshooting.md) | **已选择** | [Français](../fr/troubleshooting.md) | [Deutsch](../de/troubleshooting.md) |

## 章节

| 入门 | 数据库与 samples | 检查与运维 | 诊断与故障排除 |
| --- | --- | --- | --- |
| [入门](getting-started.md) | [数据库与 samples](databases.md) | [检查与运维](operations.md) | **已选择** |

先收集诊断信息，再针对原因修正。若仍需重新初始化，请先做
backup，并仅将确认后的 `reinit-... CONFIRM=1` 作为有意的最后手段。

生命周期与运维的规范说明：[数据库](databases.md#section-initialization) · [运维](operations.md#section-clean-reinitialize)。

<a id="section-configuration"></a>
## 配置或 storage path 验证失败

运行 `make check-env`。data paths 必须严格位于 `data/` 内，samples 必须
位于 `samples/` 内；不得包含 symlink、互相重叠或使用 reserved
directories。修正 `.docker.env` 后运行 `make config`。

<a id="section-readiness"></a>
## 服务未就绪

```bash
make status
make log SERVICE=mysql
make log SERVICE=postgres
```

在修改数据前，检查 Docker、端口、`.docker.env` 与日志。

<a id="section-init-samples"></a>
## init 修改或 samples 未出现

如果 data 已初始化，这是预期行为。检查路径与准备命令，备份重要数据，
仅在明确需要时最后使用 `reinit-... CONFIRM=1`。

<a id="section-sample-integrity"></a>
## sample 不完整或所有者异常

loader 不会覆盖或修复意外数据库。重新运行 `make samples-mysql` 或
`make samples-postgres` 并检查错误；重新初始化前先保留所需数据。

<a id="section-connections-troubleshooting"></a>
## 客户端无法连接

主机客户端使用发布地址及 `MYSQL_PORT` 或 `POSTGRES_PORT`；Adminer 在
Compose 网络中使用 `mysql` 或 `postgres`。检查 `BIND_ADDRESS`、
firewall、数据库选择和非管理员 `DB_USER` 凭据。

[返回 README](../README_zh.md)
