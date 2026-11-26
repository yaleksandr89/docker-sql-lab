# 安全政策

## 选择语言

| Русский | English | Español | 中文 | Français | Deutsch |
|---|---|---|---|---|---|
| [Русский](https://github.com/yaleksandr89/docker-sql-lab/blob/master/.github/SECURITY.md) | [English](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/en/SECURITY.md) | [Español](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/es/SECURITY.md) | **中文** | [Français](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/fr/SECURITY.md) | [Deutsch](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/de/SECURITY.md) |

## 支持的版本

安全修复将针对 `master` 的当前状态及最新发布版本进行评估。旧版本可能具有不同的网络设置；升级前请检查数据兼容性。

| 版本 | 支持 |
|---|---|
| `master` | 是 |
| 最新发布版本 | 是 |

## 实验环境的安全边界

本项目是使用合成数据的 MySQL、PostgreSQL 和 Adminer 本地学习环境，不是生产部署。默认端口发布至 `127.0.0.1`；修改 `BIND_ADDRESS` 可能使服务对外开放。请使用可信网络及独立的管理员和学习用户凭据（`DB_USER`）。示例密码仅供本地学习使用。导入可信纯 SQL 并非沙箱，可能只执行部分语句；`clean-*` 和 `reinit-*` 在明确指定 `CONFIRM=1` 时会有意删除数据。

安全问题尤其包括：

- 服务意外暴露或绕过学习用户与管理员之间的权限隔离;
- 绕过存储路径、符号链接或破坏性操作确认检查;
- 导入或执行 Make 命令时不安全地处理参数、数据库名或路径;
- 意外删除、覆盖或泄露数据、密码或本地配置;
- 绕过样本来源或完整性检查，或影响实验环境安全的镜像、Adminer 插件或 CI 问题.

普通错误请通过 [GitHub Issues](https://github.com/yaleksandr89/docker-sql-lab/issues) 报告，疑问和想法请通过 [GitHub Discussions](https://github.com/yaleksandr89/docker-sql-lab/discussions) 交流。如果问题来自上游组件，请注明其确切版本和对实验环境的影响；组件自身的缺陷也应依照其维护者的规则报告。

## 如何报告漏洞

优先使用 GitHub Private Vulnerability Reporting：打开 **Security and quality → Report a vulnerability**。如果不可用，请在 GitHub Discussions 请求私下沟通渠道，不要公开漏洞技术细节。

在协调披露前，不要公开密码、令牌、本地或生产配置、真实数据、完整日志、可用的漏洞利用程序或敏感细节。仅使用合成数据或已清理的片段。

## 报告应包含什么

- 受影响的 release、branch 或 commit，以及相关的 MySQL、PostgreSQL、Adminer、Docker 和 Compose 版本。
- 运行模式（MySQL、PostgreSQL、两者、是否启用 Adminer）、受影响的 Make 命令及预期访问边界。
- 最小复现步骤、预期行为和实际行为。
- 已清理的请求、响应或日志片段，以及已知的可能修复方案。

## 报告处理

报告将在条件允许时审查，不承诺固定 SLA。请与维护者协调披露。问题确认后，修复和受影响版本信息将通过协调披露发布。本项目未声明漏洞奖励计划。
