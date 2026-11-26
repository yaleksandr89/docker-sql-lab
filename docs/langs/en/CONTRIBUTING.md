# Contributing

## Choose language

| Русский | English | Español | 中文 | Français | Deutsch |
|---|---|---|---|---|---|
| [Русский](https://github.com/yaleksandr89/docker-sql-lab/blob/master/.github/CONTRIBUTING.md) | **English** | [Español](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/es/CONTRIBUTING.md) | [中文](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/zh/CONTRIBUTING.md) | [Français](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/fr/CONTRIBUTING.md) | [Deutsch](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/de/CONTRIBUTING.md) |

## Before starting

Report reproducible bugs through [GitHub Issues](https://github.com/yaleksandr89/docker-sql-lab/issues); discuss questions and ideas in [GitHub Discussions](https://github.com/yaleksandr89/docker-sql-lab/discussions). Agree on substantial changes with the owner first. Do not publish passwords, real data or vulnerability details.

Vulnerabilities: [security policy](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/en/SECURITY.md).

## Change boundaries

Preserve public Make commands, DBMS separation, required `demo`, optional samples and `DB_USER` privileges. Agree on image versions, schema, privileges, network access, imports and destructive operations before changing them. Do not commit third-party SQL downloads or local `.docker.env` files.

## Checks

Work in a disposable checkout with synthetic data, a unique Compose project name and ports. Verify actual storage paths and database identity before runtime commands.

```bash
make check-env
make config
make test-storage-paths
```

For init, image, import or Adminer changes, run the relevant checks in an isolated lab. `clean-*` and `reinit-*` delete data; never use them against a working lab.

[Getting started](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/en/guides/getting-started.md) · [Operations guide](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/en/guides/operations.md).

## Pull Request

Create a topic branch from `master` and a single coherent signed commit. Use Conventional Commits with a Russian description, e.g. `docs: уточнить порядок запуска`. In the PR describe the change, its data/security impact, checks actually run and documentation changes. Synchronize all six locales; all three CI workflows must pass before merge.

[Author’s website](https://yaleksandr89.github.io/)
