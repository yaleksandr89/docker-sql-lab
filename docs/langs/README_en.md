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

A local Docker Compose lab for practicing SQL and exploring and comparing
MySQL and PostgreSQL. Run either DBMS independently or both together. A compact
`demo` database is created automatically, while optional Sakila, Pagila, and
Chinook datasets provide ready-to-query training data. Enable Adminer only
when you need it.

## Screencasts

The recordings use PhpStorm. DataGrip, DBeaver, Adminer, or another
MySQL/PostgreSQL client will work instead. The screencasts are recorded in Russian.

| Scenario | Yandex Disk | Google Drive | What it shows |
|---|---|---|---|
| First start with required `demo`, then add training databases | [Watch](https://disk.yandex.ru/i/Kj4TcMSBuIDVeA "docker-sql-lab-demo-then-training-databases.mp4") | [Watch](https://drive.google.com/file/d/1HzYWbMuBEobXlbGQYNfHYVAq95TLqEPf/view?usp=sharing "docker-sql-lab-demo-then-training-databases.mp4") | Start MySQL and PostgreSQL with required `demo`; check them; prepare Sakila, Pagila, and Chinook; confirm reinitialization; check again and run SQL queries. |
| First start with training databases prepared in advance | [Watch](https://disk.yandex.ru/i/nFgJZto8agbdWw "docker-sql-lab-training-databases-first-start.mp4") | [Watch](https://drive.google.com/file/d/1nKiGrJ4QINLCQcRk-k6vfTakpWsw-JS7/view?usp=sharing "docker-sql-lab-training-databases-first-start.mp4") | Prepare Sakila, Pagila, and Chinook before the first start; initialize required `demo` and the training databases together; check access and run SQL queries. |

## Stack

- MySQL 9.7.1 LTS
- PostgreSQL 18.4
- Adminer 5.4.2 Docker Official Image
- Docker Compose v2
- GNU Make and Bash for project commands and initialization scripts

Pinned defaults are defined in
[`.docker.env.example`](../../.docker.env.example); `make init` creates the
local `.docker.env` from it. Services are defined in
[`docker-compose.yml`](../../docker-compose.yml).

<details>
<summary>⚠️ Important: this is a training environment</summary>

This project is not a production-ready template. External use requires
separate decisions about credentials, network exposure, storage, backups, and
operations.

</details>

## Features

- MySQL and PostgreSQL run independently or together.
- A required `demo` database in each DBMS contains equivalent seed rows.
- Optional Sakila and Chinook are available for MySQL; Pagila and Chinook for
  PostgreSQL.
- Adminer is a separate optional UI shared by both DBMSs.
- Each DBMS has separate bind-mounted data, init, and sample directories.
- Configuration and access checks, trusted SQL imports, and destructive
  commands are collected in the [`Makefile`](../../Makefile).

## Requirements

1. Docker Engine or Docker Desktop with Docker Compose v2.
2. GNU Make, Bash, and the basic Unix CLI utilities used by the scripts.

Recommended environments: Linux; macOS with Docker Desktop; Windows with
Docker Desktop and WSL2. Run commands from the repository root. The project's
default branch is `master`.

## Quick start

```bash
make init
make up
```

`make init` creates the local `.docker.env` from the tracked
[`.docker.env.example`](../../.docker.env.example), validates managed paths,
and creates working directories. On the first container start, the official
entrypoints initialize both DBMSs. Even without optional samples, you get
working MySQL and PostgreSQL instances with the required `demo` database and
seed rows.

`make up` starts MySQL, PostgreSQL, and Adminer; `make up-no-ui` starts both
DBMSs without Adminer. With the defaults, Adminer is available at
`http://127.0.0.1:8081`.

For startup modes, connections, and credentials, see
[Getting started](en/getting-started.md).

### Want ready-made training data?

Optional samples are not required: `demo` is always created; MySQL supports Sakila and Chinook, while PostgreSQL supports Pagila and Chinook.

**First start with empty data directories**

```bash
make init
make samples-mysql
make samples-postgres
make up
```

Prepare samples before the first initialization; the official entrypoints load them alongside `demo`.

> **Warning:** reinitialization deletes the selected DBMS data. Back up only
> custom data you need to keep; a one-off lab with no valuable changes needs no backup.

<details>
<summary>📦 The lab has run before: add or reuse samples</summary>

**Initialized without samples.** A regular `make up` does not apply new init/sample files. If you need to preserve important data, back it up, then use the appropriate option:

- MySQL: `make samples-mysql`, then `make reinit-mysql CONFIRM=1`.
- PostgreSQL: `make samples-postgres`, then `make reinit-postgres CONFIRM=1`.
- Both DBMSs: `make samples-mysql`, `make samples-postgres`, then `make reinit-all CONFIRM=1`.

> **Warning:** `reinit-*` deletes the selected DBMS data and runs only with the exact `CONFIRM=1`.

**Samples already installed.** Use the regular `make up` or a selected `make up-*`: no repeated download or reinitialization is needed, and databases persist in bind-mounted storage.

</details>

Details: [Databases and samples](en/databases.md).

## Startup modes

| Command | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Starts | Starts | Starts |
| `make up-no-ui` | Starts | Starts | Stops |
| `make up-mysql` | Starts | Does not start | Does not start |
| `make up-postgres` | Does not start | Starts | Does not start |

A single-DBMS command does not stop the other running DBMS; Adminer is managed
separately. The complete target list is in the [`Makefile`](../../Makefile).

## Connections and available databases

Inside the Compose network, Adminer uses `mysql` and `postgres`. Host clients
use `127.0.0.1` with the configured `MYSQL_PORT` or `POSTGRES_PORT`. Sign in
for routine work with `DB_USER` and `DB_PASSWORD`.

| DBMS | Always available | After optional sample initialization |
|---|---|---|
| MySQL | `demo` | `sakila`, `chinook` |
| PostgreSQL | `demo` | `pagila`, `chinook` |

Optional database names are valid only after actual initialization. Details:
[startup and connections](en/getting-started.md) ·
[databases and samples](en/databases.md).

## Credentials at a glance

| Purpose | User | Password |
|---|---|---|
| Shared training user | `DB_USER` | `DB_PASSWORD` |
| MySQL administrator | `root` | `MYSQL_ROOT_PASSWORD` |
| PostgreSQL superuser | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` and `DB_USER` must be different roles. Use the training
user for exercises, and replace example passwords before publishing services.

## Databases and key checks

Both `demo` databases contain an equivalent `demo_users` table with five rows.
These static checks do not require running DBMSs:

```bash
make check-env
make config
make test-storage-paths
```

After startup, `make check` verifies `demo` and `DB_USER` access;
`make test-sql-imports` exercises the public trusted import targets. For the
safe order and limitations, see
[Validation and operations](en/operations.md).

## Safety and lifecycle

- `BIND_ADDRESS=127.0.0.1` publishes services only on loopback.
- `BIND_ADDRESS=0.0.0.0` exposes them on every interface; configure the
  firewall, strong credentials, and network trust first.
- Official entrypoints run init only for an empty data directory.
- `make mysql-import` and `make postgres-import` accept trusted SQL only.
  This is not a sandbox: partial execution is possible without a guaranteed
  full automatic rollback.
  Review the SQL file and create a suitable backup before an important import.
- Built-in `make dump` and `make restore` cover only MySQL `demo`; there is no
  built-in PostgreSQL backup target.
- Every `clean-*` and `reinit-*` command is destructive and requires the exact
  `CONFIRM=1`.

Safe sequences: [Validation and operations](en/operations.md). For failures,
collect evidence first: [Troubleshooting](en/troubleshooting.md).

## Training data licenses

Optional sample datasets retain the licenses and notices of their upstream
projects. Provenance, pinned revisions, integrity information, and license
texts are in
[`THIRD_PARTY_NOTICES.md`](../../THIRD_PARTY_NOTICES.md).

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
