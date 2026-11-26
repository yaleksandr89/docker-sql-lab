# Security Policy

## Choose a language

| Русский | English | Español | 中文 | Français | Deutsch |
|---|---|---|---|---|---|
| [Русский](https://github.com/yaleksandr89/docker-sql-lab/blob/master/.github/SECURITY.md) | **English** | [Español](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/es/SECURITY.md) | [中文](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/zh/SECURITY.md) | [Français](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/fr/SECURITY.md) | [Deutsch](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/de/SECURITY.md) |

## Supported versions

Security fixes are considered for the current state of `master` and the latest published release. Older versions may have different network settings; verify data compatibility before upgrading.

| Version | Supported |
|---|---|
| `master` | Yes |
| Latest published release | Yes |

## Lab security boundaries

This is a local MySQL, PostgreSQL and Adminer learning lab for synthetic data, not a production deployment. Ports are published on `127.0.0.1` by default; changing `BIND_ADDRESS` can expose services externally. Use trusted networks and separate administrative and training credentials (`DB_USER`). Example passwords are for local learning only. Trusted plain SQL import is not a sandbox and may execute partially; `clean-*` and `reinit-*` intentionally delete data with explicit `CONFIRM=1`.

Security issues include, in particular:

- unintended service exposure or bypass of expected separation between training and administrative privileges;
- bypass of storage-path, symlink or destructive-operation confirmation checks;
- unsafe handling of parameters, database names or paths during imports and Make commands;
- unintended deletion, overwrite or disclosure of data, passwords or local configuration;
- bypass of sample provenance or integrity checks, or image, Adminer plugin or CI issues affecting lab security.

Report ordinary bugs through [GitHub Issues](https://github.com/yaleksandr89/docker-sql-lab/issues), questions and ideas through [GitHub Discussions](https://github.com/yaleksandr89/docker-sql-lab/discussions). If an issue is in an upstream component, specify its exact version and impact on the lab; report defects in the component itself to its maintainers under their rules as well.

## Reporting a vulnerability

Prefer GitHub Private Vulnerability Reporting: open **Security and quality → Report a vulnerability**. If unavailable, request a private communication channel in GitHub Discussions without publishing technical vulnerability details.

Do not publish passwords, tokens, local or production configurations, real data, full logs, working exploits or sensitive details before coordinated disclosure. Use only synthetic data or sanitized fragments.

## What to include in the report

- Affected release, branch or commit, and MySQL, PostgreSQL, Adminer, Docker and Compose versions when relevant.
- Launch mode (MySQL, PostgreSQL, both, with or without Adminer), affected Make command and intended access boundary.
- Minimal reproduction steps, expected and actual behavior.
- Sanitized request, response or log fragments and a possible fix, if known.

## Report handling

Reports are reviewed as availability allows; no fixed SLA is promised. Coordinate disclosure with the maintainer. Once confirmed, fixes and affected-version information are published as part of coordinated disclosure. No vulnerability reward program is claimed.
