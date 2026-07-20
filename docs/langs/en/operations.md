# Validation and operations

[← Back to README](../README_en.md)

## Language

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/operations.md) | **Selected** | [Español](../es/operations.md) | [中文](../zh/operations.md) | [Français](../fr/operations.md) | [Deutsch](../de/operations.md) |

## Section

| Getting started | Databases and samples | Validation and operations | Troubleshooting |
| --- | --- | --- | --- |
| [Getting started](getting-started.md) | [Databases and samples](databases.md) | **Selected** | [Troubleshooting](troubleshooting.md) |

<a id="section-make-targets"></a>
## Make targets

Public targets and their implementation are in the [`Makefile`](../../../Makefile).

Key targets include `make init`, `make up`, `make down`, `make check`,
`make test-storage-paths`, `make test-sql-imports`, `make mysql-import`,
and `make postgres-import`. Trusted SQL is not a sandbox, may execute
partially, and has no guaranteed automatic rollback; create a backup before an
important import. Built-in backup targets cover MySQL `demo` only, not
PostgreSQL. `clean-*` and `reinit-*` are destructive and require exact
`CONFIRM=1`.

<details>
<summary>Complete public Make target reference</summary>

Run `make help` for the concise command list.

| Command | Purpose |
|---|---|
| `make init` | Create `.docker.env`, validate managed paths, and create required working directories |
| `make check-env` | Check required environment values, role separation, database names, and managed paths |
| `make pull` | Pull the three pinned container images |
| `make config` | Validate the expanded Compose configuration |
| `make up`, `make up-no-ui` | Start both DBMSs with or without Adminer |
| `make up-mysql`, `make up-mysql-ui` | Start MySQL, optionally with Adminer |
| `make up-postgres`, `make up-postgres-ui` | Start PostgreSQL, optionally with Adminer |
| `make up-ui`, `make down-ui` | Start or stop only Adminer |
| `make down` | Stop the lab without deleting bind-mounted data |
| `make status` | Show service status |
| `make logs` | Follow logs for all services |
| `make log SERVICE=postgres` | Follow one service log; `make log postgres` is also supported |
| `make in SERVICE=postgres` | Open a service shell; `make in postgres` is also supported |
| `make mysql`, `make mysql-user` | Open MySQL as administrator or `DB_USER` |
| `make postgres`, `make postgres-user` | Open PostgreSQL as superuser or `DB_USER` |
| `make samples-mysql`, `make samples-postgres` | Prepare verified optional samples |
| `make check-mysql-access`, `make check-postgres-access` | Verify training-user access to one running DBMS |
| `make check` | Validate Compose and check `DB_USER` access to both running DBMSs |
| `make test-storage-paths` | Test managed storage-path protection without Docker runtime |
| `make test-sql-imports` | Smoke-test both public trusted SQL import targets |
| `make mysql-import FILE=... DATABASE=...` | Import trusted plain SQL into an existing MySQL database as `DB_USER` |
| `make postgres-import FILE=... DATABASE=...` | Import trusted plain SQL into an existing PostgreSQL database as `DB_USER` |
| `make dump`, `make restore` | Dump or restore the configured MySQL `demo` database |
| `make clean-{mysql,postgres,all} CONFIRM=1` | Delete selected managed data directories |
| `make reinit-{mysql,postgres,all} CONFIRM=1` | Delete, recreate, and check selected databases |

</details>

<a id="section-validation"></a>
## Validation

### Static and local checks

```bash
make check-env
make config
make test-storage-paths
```

`make check-env` creates `.docker.env` from the example if it is absent, then
validates required settings and managed paths. `make config` validates the
expanded Compose model.

`make test-storage-paths` does not require the Docker runtime. It exercises the
guards for paths outside the project, symbolic-link components, overlapping or
nested managed paths, and reserved directories. The same validator protects
the configured MySQL/PostgreSQL data and sample locations during normal setup.

### Runtime checks

Start both databases without Adminer, check training access, exercise imports,
and stop the services:

```bash
make up-no-ui
make check
make test-sql-imports
make down
```

`make check` verifies the required `demo` data and actual `DB_USER` access in
both DBMSs. It also checks supported optional samples when they are installed.

`make test-sql-imports` requires both DBMSs to be running. It invokes the
public `mysql-import` and `postgres-import` targets, creates uniquely named
temporary smoke tables in `demo`, verifies marker rows as `DB_USER`, and
removes only those tables. It tests the trusted SQL import workflow; it does
not prove that untrusted SQL is safe or sandboxed.

<a id="section-storage-path-safety"></a>
## Storage-path safety

`make check-env` runs `scripts/validate-storage-paths.sh`. Data paths
must be strict descendants of `data/`, and sample paths of `samples/`.
Symlink components, equal, nested, overlapping, and reserved paths are
rejected. `make test-storage-paths` exercises these rules without Docker
runtime.

<a id="section-sql-imports"></a>
## Trusted SQL imports

Import only trusted local plain SQL files:

```bash
make mysql-import FILE=path/to/file.sql DATABASE=demo
make postgres-import FILE=path/to/file.sql DATABASE=demo
```

For both targets:

- `FILE` and `DATABASE` are required.
- The file must be a readable, non-empty regular file.
- The database name must start with a lowercase ASCII letter and contain only
  lowercase ASCII letters, digits, or `_`; system databases are rejected.
- The database must already exist and accept a connection from `DB_USER`.
- Import runs as `DB_USER`, never as MySQL root or PostgreSQL superuser.
- The target neither creates a database nor grants access.
- Archives, gzip streams, and PostgreSQL custom-format backups are not
  supported by these targets.

`DATABASE` selects the initial connection database; it does not create a
sandbox. Qualified names, session or client commands, and the actual grants of
`DB_USER` may permit access to other objects. SQL may modify or delete anything
that role can access.

An import may complete partially. Neither target promises an automatic full
rollback after an error. Review the file and create an appropriate backup
before an important import.

<a id="section-backup"></a>
## Backup

The built-in backup targets cover only the configured MySQL `demo` database:

```bash
make dump
make restore
```

`make dump` writes `backup/demo.sql` with the default configuration.
`make restore` reads that file and reapplies MySQL training grants. Use a
separate PostgreSQL backup procedure when PostgreSQL data must be preserved.

<a id="section-clean-reinitialize"></a>
## Clean and reinitialize

> **Warning:** Every `clean-*` and `reinit-*` command below is destructive and
> requires the exact opt-in `CONFIRM=1`.

```bash
make clean-mysql CONFIRM=1
make clean-postgres CONFIRM=1
make clean-all CONFIRM=1

make reinit-mysql CONFIRM=1
make reinit-postgres CONFIRM=1
make reinit-all CONFIRM=1
```

The single-DBMS commands delete only that DBMS data directory. The `all`
variants delete both database data directories. Configuration, init files,
optional sample downloads, and backups are preserved. Reinitialization then
starts and checks the selected DBMSs; `reinit-all` starts both without Adminer.

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Back to README](../README_en.md)
