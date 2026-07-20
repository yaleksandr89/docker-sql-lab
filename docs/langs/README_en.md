<p align="center">
  <img
    src="../assets/docker-sql-lab-cover.png"
    alt="Docker SQL Lab"
    width="100%"
  >
</p>

# Docker SQL Lab

## Choose a language

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../../README.md) | **Selected** | [Español](README_es.md) | [中文](README_zh.md) | [Français](README_fr.md) | [Deutsch](README_de.md) |

A local Docker Compose environment for learning and comparing MySQL and
PostgreSQL. Run either database independently, run both together, and add
Adminer only when you need a browser UI.

## Stack

- MySQL 9.7.1 LTS
- PostgreSQL 18.4
- Adminer 5.4.2 Docker Official Image
- Docker Compose v2
- GNU Make and Bash for the project commands and initialization scripts

The image versions are pinned in `.docker.env`. Do not use this lab as a
production deployment template without reviewing its credentials, exposure,
storage, backup, and operational requirements.

## Features

- Independent MySQL and PostgreSQL services that can also run together.
- Optional Adminer shared by both databases; it has no dependency on a
  particular database service.
- A required `demo` database in each DBMS with the same five example users.
- Optional Sakila and Chinook samples for MySQL, and Pagila and Chinook for
  PostgreSQL.
- Separate bind-mounted data, init, and sample directories for each DBMS.
- Shared training credentials with separate database administrator
  credentials.
- Static configuration checks, managed storage-path validation, runtime
  access checks, and a trusted SQL import smoke-test.
- Explicit confirmation for destructive clean and reinitialization commands.

## Requirements

- Docker Engine or Docker Desktop with the `docker compose` v2 command.
- GNU Make, Bash, and standard Unix tools used by the scripts (`awk`, `sed`,
  `grep`, `find`, `realpath`, and `stat`).
- For optional sample downloads: `curl` and `git`; MySQL samples additionally
  require `unzip` and `sha256sum`.

Run project commands from the repository root. The default project branch is
`master`.

## Quick start

Create `.docker.env` from the tracked example, validate the configured paths,
create the working directories, and start the full lab:

```bash
make init
make up
```

`make up` starts MySQL, PostgreSQL, and Adminer. With the default configuration,
open Adminer at `http://127.0.0.1:8081`.

Useful follow-up commands:

```bash
make status
make logs
make down
```

`make down` removes the containers and network but preserves the bind-mounted
database data.

## Startup modes

| Command | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Starts | Starts | Starts |
| `make up-no-ui` | Starts | Starts | Stops |
| `make up-mysql` | Starts | Does not start | Does not start |
| `make up-postgres` | Does not start | Starts | Does not start |

Single-DBMS commands do not stop the other running database; Adminer is managed separately.

## Connections

### Adminer

Adminer provides two predefined server choices inside the Compose network:

```text
MySQL (mysql)
PostgreSQL (postgres)
```

Select a server, then sign in with `DB_USER`, `DB_PASSWORD`, and a database
name such as `demo`. The service names `mysql` and `postgres` work inside the
Compose network; they are not host names for desktop clients.

### Host clients

DataGrip, DBeaver, PhpStorm, and host CLI tools connect through the published
address and port:

| DBMS | Host with default settings | Port variable | User | Default database |
|---|---|---|---|---|
| MySQL | `127.0.0.1` | `MYSQL_PORT` | `DB_USER` | `demo` |
| PostgreSQL | `127.0.0.1` | `POSTGRES_PORT` | `DB_USER` | `demo` |

If you change `BIND_ADDRESS`, use that reachable interface address instead of
`127.0.0.1` where appropriate.

### Container CLI

The Make targets pass passwords through the container environment instead of
placing them in shell history:

```bash
make mysql          # MySQL administrator, demo database
make mysql-user     # DB_USER, demo database
make postgres       # PostgreSQL superuser, demo database
make postgres-user  # DB_USER, demo database
```

## Credentials at a glance

| Purpose | User | Password |
|---|---|---|
| Shared training user for both DBMSs | `DB_USER` | `DB_PASSWORD` |
| MySQL administrator | `root` | `MYSQL_ROOT_PASSWORD` |
| PostgreSQL superuser | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` and `DB_USER` must be different roles. Use the shared training user for routine exercises and replace example passwords before publishing services.

## Databases and key checks

Both DBMSs create a required `demo` database with an equivalent `demo_users` table. Optional samples are Chinook and Sakila for MySQL, and Pagila and Chinook for PostgreSQL. Preparing samples does not import them into initialized data.

These static checks do not require running databases:

```bash
make check-env
make config
make test-storage-paths
```

After both DBMSs start, `make check` verifies `DB_USER` access and `make test-sql-imports` exercises the public trusted import targets. The detailed pages below document every command, limitation, and safe operating sequence.

MySQL and PostgreSQL data, init, and sample directories remain separate and are configured through `.docker.env`. The managed-path validator rejects locations outside `data/` or `samples/`, symlink components, overlaps, and reserved directories. A completely absent optional sample is skipped; a partial set or unexpected existing sample database is rejected without automatic repair.

Sample preparation downloads pinned upstream files, verifies integrity, and keeps them local; provenance and licensing are in `THIRD_PARTY_NOTICES.md`. Runtime checks also verify required `demo` rows, training-user read/write access, and any installed samples.

## Safety and lifecycle

- `BIND_ADDRESS=127.0.0.1` publishes services only on loopback.
- `BIND_ADDRESS=0.0.0.0` publishes them on every interface; configure the
  firewall, strong credentials, and network trust deliberately.
- Official entrypoints run init only for an empty data directory.
- `make mysql-import` and `make postgres-import` accept trusted SQL only.
  They do not create a sandbox: partial execution is possible without a
  guaranteed full automatic rollback. Back up important data first.
- Built-in `make dump` and `make restore` cover only MySQL `demo`; there
  is no built-in PostgreSQL backup target.
- Every `clean-*` and `reinit-*` target is destructive and requires the
  exact confirmation `CONFIRM=1`.

## Documentation

- [Getting started](en/getting-started.md)
- [Databases and samples](en/databases.md)
- [Validation and operations](en/operations.md)
- [Troubleshooting](en/troubleshooting.md)

## Licenses and third-party notices

Docker SQL Lab is licensed under the MIT License; see
[LICENSE.md](../../LICENSE.md). Optional sample databases retain their upstream
licenses and notices; see [THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md) for
sources, pinned revisions, integrity information, and license text.

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
