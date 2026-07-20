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
| `make up-no-ui` | Starts or keeps running | Starts or keeps running | Stops if running |
| `make up-mysql` | Starts | Does not start automatically | Does not start automatically |
| `make up-mysql-ui` | Starts | Does not start automatically | Starts |
| `make up-postgres` | Does not start automatically | Starts | Does not start automatically |
| `make up-postgres-ui` | Does not start automatically | Starts | Starts |
| `make up-ui` | Does not change | Does not change | Starts |
| `make down-ui` | Does not change | Does not change | Stops |

The single-service commands do not stop another database that is already
running. Adminer can be started and stopped separately and is not tied to
MySQL alone.

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

## Credentials

Copying `.docker.env.example` creates `.docker.env`; the latter is ignored by
Git. Keep passwords there and do not hardcode them in Compose, SQL, or client
configuration committed to the repository.

| Purpose | User setting | Password setting |
|---|---|---|
| Shared training user for both DBMSs | `DB_USER` | `DB_PASSWORD` |
| MySQL administrator | `root` | `MYSQL_ROOT_PASSWORD` |
| PostgreSQL administrator/superuser | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` and `DB_USER` must be different roles. Use the shared
training user for normal exercises; do not use root or superuser credentials
for routine work. Replace the example passwords before sharing access or
publishing any service beyond the local machine.

## Ports and `BIND_ADDRESS`

The host-side ports are configured in `.docker.env`:

| Service | Port variable | Example default |
|---|---|---|
| MySQL | `MYSQL_PORT` | `3306` |
| PostgreSQL | `POSTGRES_PORT` | `5432` |
| Adminer | `ADMINER_PORT` | `8081` |

All three services publish only on loopback by default:

```env
BIND_ADDRESS=127.0.0.1
```

This is the safe default for a local lab. Setting `BIND_ADDRESS=0.0.0.0`
publishes the configured ports on every network interface. For VPN or LAN
access, prefer the address of the specific interface. Change the binding only
deliberately, after considering firewall rules, password strength, and trust
in every connected network.

## Databases

### Required `demo` databases

Both DBMSs initialize a required database named `demo`:

- MySQL: `demo.demo_users`
- PostgreSQL: `demo.public.demo_users`

The tables have equivalent `id`, `name`, `email`, and `created_at` fields and
contain the same five required example users: Alice, Bob, Carol, Dave, and Eve.
The access checks allow additional user-created rows.

The default database names are enforced by `make check-env` through
`MYSQL_DATABASE=demo` and `POSTGRES_DATABASE=demo`.

### Optional samples

| DBMS | Optional databases | Preparation command |
|---|---|---|
| MySQL | Chinook, Sakila | `make samples-mysql` |
| PostgreSQL | Pagila, Chinook | `make samples-postgres` |

The preparation commands download and verify pinned upstream files but do not
start containers or import into an initialized database. Downloads are local,
are excluded from Git, and are stored under `MYSQL_SAMPLES_DIR` or
`POSTGRES_SAMPLES_DIR`. Their provenance, integrity pins, and license terms are
documented in [THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).

For a DBMS with an empty data directory:

```bash
make samples-mysql
make up-mysql

make samples-postgres
make up-postgres
```

Official image entrypoints process init files only when the corresponding data
directory is empty. To add samples to an already initialized DBMS, first back
up anything important and then deliberately reinitialize only that DBMS:

```bash
make samples-mysql
make reinit-mysql CONFIRM=1

make samples-postgres
make reinit-postgres CONFIRM=1
```

A completely absent optional sample is skipped and does not prevent the
required `demo` database from being created. A partial sample set or an
unexpected existing sample database is rejected instead of being repaired or
deleted automatically.

## Make targets

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

## Data and initialization lifecycle

The default bind-mounted storage is separated by DBMS:

```text
data/
├── mysql/
└── postgres/

initdb/
├── mysql/
└── postgres/
```

The related `.docker.env` settings are separate as well:

| DBMS | Data | Init | Optional samples |
|---|---|---|---|
| MySQL | `MYSQL_DATA_DIR` (`./data/mysql`) | `MYSQL_INITDB_DIR` (`./initdb/mysql`) | `MYSQL_SAMPLES_DIR` (`./samples/mysql`) |
| PostgreSQL | `POSTGRES_DATA_DIR` (`./data/postgres`) | `POSTGRES_INITDB_DIR` (`./initdb/postgres`) | `POSTGRES_SAMPLES_DIR` (`./samples/postgres`) |

Data and sample locations can be changed through `.docker.env`, subject to
managed storage-path validation.

The official MySQL and PostgreSQL entrypoints run their respective init
directory only for an empty data directory. Adding or editing an init file does
not migrate an existing database. `make down` does not delete data from either
bind mount.

Do not edit database files inside `data/` manually. Container-owned files may
use numeric UID/GID values that differ from the host user.

## Backup, clean, and reinitialize

The built-in backup targets cover only the configured MySQL `demo` database:

```bash
make dump
make restore
```

`make dump` writes `backup/demo.sql` with the default configuration.
`make restore` reads that file and reapplies MySQL training grants. Use a
separate PostgreSQL backup procedure when PostgreSQL data must be preserved.

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

## Troubleshooting

### Configuration or storage-path validation fails

Run `make check-env` and read the rejected variable and path in the error.
Managed data paths must be strictly inside the project `data/` tree; sample
paths must be inside `samples/`. They cannot contain symbolic-link components,
overlap one another, or use reserved project directories. Correct
`.docker.env`, then rerun `make check-env` and `make config`.

### A service does not become ready

Check the service state and logs before changing data:

```bash
make status
make log SERVICE=mysql
make log SERVICE=postgres
```

Confirm that Docker is running, the configured host port is available, and
`.docker.env` contains all required values. Fix the specific configuration or
port conflict and start the service again.

### Init changes or optional samples do not appear

This is expected when the data directory is already initialized. Verify the
configured data and sample paths and confirm that the preparation command
succeeded. If existing data matters, back it up. Use the matching
`reinit-... CONFIRM=1` command only as a deliberate last step; it deletes that
DBMS's data.

### An optional sample is incomplete or has unexpected ownership

The loader intentionally refuses to overwrite or repair an unexpected
database. Re-run the appropriate `make samples-mysql` or
`make samples-postgres` preparation command and inspect the error. Preserve any
needed data before considering a confirmed reinitialization.

### A client cannot connect

Host clients use the published host address and `MYSQL_PORT` or
`POSTGRES_PORT`, not the Compose service name. Adminer uses `mysql` or
`postgres` inside the Compose network. Confirm `BIND_ADDRESS`, firewall rules,
the selected database, and the non-administrative `DB_USER` credentials.

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
