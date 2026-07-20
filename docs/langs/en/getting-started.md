# Getting started

[← Back to README](../README_en.md)

[Русский](../ru/getting-started.md) | **English — Selected** | [Español](../es/getting-started.md) | [中文](../zh/getting-started.md) | [Français](../fr/getting-started.md) | [Deutsch](../de/getting-started.md)

**Pages in this language:** **Getting started** · [Databases and samples](databases.md) · [Validation and operations](operations.md) · [Troubleshooting](troubleshooting.md)

<a id="section-requirements"></a>
## Requirements

- Docker Engine or Docker Desktop with the `docker compose` v2 command.
- GNU Make, Bash, and standard Unix tools used by the scripts (`awk`, `sed`,
  `grep`, `find`, `realpath`, and `stat`).
- For optional sample downloads: `curl` and `git`; MySQL samples additionally
  require `unzip` and `sha256sum`.

Run project commands from the repository root. The default project branch is
`master`.

<a id="section-quick-start"></a>
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

<a id="section-startup-modes"></a>
## Startup modes

| Command | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Starts | Starts | Starts |
| `make up-no-ui` | Starts | Starts | Stops |
| `make up-mysql` | Starts | Does not start | Does not start |
| `make up-postgres` | Does not start | Starts | Does not start |

Single-DBMS commands do not stop the other running database; Adminer is managed separately.

<details>
<summary>Full startup-mode table</summary>

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

</details>

<a id="section-connections"></a>
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

<a id="section-credentials"></a>
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

<a id="section-network-exposure"></a>
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

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Back to README](../README_en.md)
