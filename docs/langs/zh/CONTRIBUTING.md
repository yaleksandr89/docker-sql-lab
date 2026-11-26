# 参与贡献

## 选择语言

| Русский | English | Español | 中文 | Français | Deutsch |
|---|---|---|---|---|---|
| [Русский](https://github.com/yaleksandr89/docker-sql-lab/blob/master/.github/CONTRIBUTING.md) | [English](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/en/CONTRIBUTING.md) | [Español](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/es/CONTRIBUTING.md) | **中文** | [Français](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/fr/CONTRIBUTING.md) | [Deutsch](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/de/CONTRIBUTING.md) |

## 开始之前

可复现的错误请通过 [GitHub Issues](https://github.com/yaleksandr89/docker-sql-lab/issues) 报告；问题与建议请在 [GitHub Discussions](https://github.com/yaleksandr89/docker-sql-lab/discussions) 中讨论。重大变更需先与所有者商定。不要公开密码、真实数据或漏洞细节。

## 变更边界

保留公共 Make 命令、数据库服务隔离、必需的 `demo`、可选样本及 `DB_USER` 权限。镜像版本、数据库结构、权限、网络访问、导入和删除数据等变更需提前商定。不要将下载的第三方 SQL 或本地 `.docker.env` 提交到 Git。

## 检查

在一次性工作副本中使用合成数据、唯一的 Compose 项目名称和端口。运行命令前确认实际存储路径和数据库身份。

```bash
make check-env
make config
make test-storage-paths
```

涉及初始化、镜像、导入或 Adminer 时，在隔离环境中运行相关检查。`clean-*` 和 `reinit-*` 会删除数据；不要在正在使用的实验环境中执行。

[入门](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/zh/guides/getting-started.md) · [运维指南](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/zh/guides/operations.md).

## Pull Request

从 `master` 创建主题分支，并提交一个逻辑完整的签名 commit。使用带俄语描述的 Conventional Commits，例如 `docs: уточнить порядок запуска`。在 PR 中说明变更、数据与安全影响、实际执行的检查和文档变更。同步全部六种语言；合并前须通过三个 CI 工作流。

[作者网站](https://yaleksandr89.github.io/)
