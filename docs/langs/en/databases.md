# Databases and samples

[← Back to README](../README_en.md)

## Language

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/databases.md) | **Selected** | [Español](../es/databases.md) | [中文](../zh/databases.md) | [Français](../fr/databases.md) | [Deutsch](../de/databases.md) |

## Section

| Getting started | Databases and samples | Validation and operations | Troubleshooting |
| --- | --- | --- | --- |
| [Getting started](getting-started.md) | **Selected** | [Validation and operations](operations.md) | [Troubleshooting](troubleshooting.md) |

<a id="section-demo"></a>
## Required `demo` databases

Both DBMSs initialize a required database named `demo`:

- MySQL: `demo.demo_users`
- PostgreSQL: `demo.public.demo_users`

The tables have equivalent `id`, `name`, `email`, and `created_at` fields and
contain the same five required example users: Alice, Bob, Carol, Dave, and Eve.
The access checks allow additional user-created rows.

The default database names are enforced by `make check-env` through
`MYSQL_DATABASE=demo` and `POSTGRES_DATABASE=demo`.

<a id="section-optional-samples"></a>
## Optional samples

| DBMS | Optional databases | Preparation command |
|---|---|---|
| MySQL | `chinook`, `sakila` | `make samples-mysql` |
| PostgreSQL | `pagila`, `chinook` | `make samples-postgres` |

<a id="section-sample-preparation"></a>
## Sample preparation

Preparation requires `curl` and `git`; MySQL samples additionally require `unzip` and `sha256sum`.

The preparation commands download and verify pinned upstream files but do not
start containers or import into an initialized database. Downloads are local,
are excluded from Git, and are stored under `MYSQL_SAMPLES_DIR` or
`POSTGRES_SAMPLES_DIR`. Their provenance, integrity pins, and license terms are
documented in
[`THIRD_PARTY_NOTICES.md`](../../../THIRD_PARTY_NOTICES.md).

See [Initialization lifecycle](#section-initialization) for when preparation
must occur and how an initialized DBMS can be reinitialized.

A completely absent optional sample is skipped and does not prevent the
required `demo` database from being created. A partial sample set or an
unexpected existing sample database is rejected instead of being repaired or
deleted automatically.

<a id="section-storage-layout"></a>
## Storage layout

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
managed storage-path validation. See
[Initialization lifecycle](#section-initialization) for the rules governing
the init directories.

Do not edit database files inside `data/` manually. Container-owned files may
use numeric UID/GID values that differ from the host user.

<a id="section-initialization"></a>
## Initialization lifecycle

> **Important:** Official MySQL and PostgreSQL entrypoints run init files only
> for an empty data directory. Adding files after initialization does not
> change an existing database. `make down` preserves data, while confirmed
> reinitialization deletes all data for the selected DBMS; a backup is required
> beforehand.

For first initialization with sample datasets, prepare them before the first
start:

```bash
make samples-mysql
make up-mysql

make samples-postgres
make up-postgres
```

For an initialized DBMS, create a backup and then use only its matching
confirmed reinitialization:

```bash
make samples-mysql
make reinit-mysql CONFIRM=1

make samples-postgres
make reinit-postgres CONFIRM=1
```

<a id="section-training-access"></a>
## Training access and ownership

MySQL creates `DB_USER` and grants it access to every non-system
database found during init. PostgreSQL creates a separate, non-superuser
`DB_USER` without createdb/createrole privileges and makes it owner of
`demo`, the `public` schema, and loaded sample objects. Administrative
credentials remain separate: `MYSQL_ROOT_PASSWORD`, `POSTGRES_SUPERUSER`,
and `POSTGRES_SUPERUSER_PASSWORD`. Do not edit container-owned files in
`data/` manually.

[Back to README](../README_en.md)
