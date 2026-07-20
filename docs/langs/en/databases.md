# Databases and samples

[← Back to README](../README_en.md)

[Русский](../ru/databases.md) | **English — Selected** | [Español](../es/databases.md) | [中文](../zh/databases.md) | [Français](../fr/databases.md) | [Deutsch](../de/databases.md)

**Pages in this language:** [Getting started](getting-started.md) · **Databases and samples** · [Validation and operations](operations.md) · [Troubleshooting](troubleshooting.md)

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
| MySQL | Chinook, Sakila | `make samples-mysql` |
| PostgreSQL | Pagila, Chinook | `make samples-postgres` |

<a id="section-sample-preparation"></a>
## Sample preparation

The preparation commands download and verify pinned upstream files but do not
start containers or import into an initialized database. Downloads are local,
are excluded from Git, and are stored under `MYSQL_SAMPLES_DIR` or
`POSTGRES_SAMPLES_DIR`. Their provenance, integrity pins, and license terms are
documented in [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md).

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
managed storage-path validation.

The official MySQL and PostgreSQL entrypoints run their respective init
directory only for an empty data directory. Adding or editing an init file does
not migrate an existing database. `make down` does not delete data from either
bind mount.

Do not edit database files inside `data/` manually. Container-owned files may
use numeric UID/GID values that differ from the host user.

<a id="section-initialization"></a>
## Initialization lifecycle

> **Important:** Official MySQL and PostgreSQL entrypoints run init files only for an
empty data directory. Editing init files does not migrate an existing
database, and `make down` preserves bind-mounted data.

<a id="section-training-access"></a>
## Training access and ownership

MySQL creates `DB_USER` and grants it access to every non-system
database found during init. PostgreSQL creates a separate, non-superuser
`DB_USER` without createdb/createrole privileges and makes it owner of
`demo`, the `public` schema, and loaded sample objects. Administrative
credentials remain separate: `MYSQL_ROOT_PASSWORD`, `POSTGRES_SUPERUSER`,
and `POSTGRES_SUPERUSER_PASSWORD`. Do not edit container-owned files in
`data/` manually.

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Back to README](../README_en.md)
