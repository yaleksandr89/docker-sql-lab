# Troubleshooting

[← Back to README](../README_en.md)

## Language

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/troubleshooting.md) | **Selected** | [Español](../es/troubleshooting.md) | [中文](../zh/troubleshooting.md) | [Français](../fr/troubleshooting.md) | [Deutsch](../de/troubleshooting.md) |

## Section

| Getting started | Databases and samples | Validation and operations | Troubleshooting |
| --- | --- | --- | --- |
| [Getting started](getting-started.md) | [Databases and samples](databases.md) | [Validation and operations](operations.md) | **Selected** |

Collect diagnostics first, then correct the specific cause. If a
reinitialization is still required, create a backup and use confirmed
`reinit-... CONFIRM=1` only as a deliberate last resort.

Canonical lifecycle and operational details: [databases](databases.md#section-initialization) · [operations](operations.md#section-clean-reinitialize).

<a id="section-configuration"></a>
## Configuration or storage-path validation fails

Run `make check-env` and read the rejected variable and path in the error.
Managed data paths must be strictly inside the project `data/` tree; sample
paths must be inside `samples/`. They cannot contain symbolic-link components,
overlap one another, or use reserved project directories. Correct
`.docker.env`, then rerun `make check-env` and `make config`.

<a id="section-readiness"></a>
## A service does not become ready

Check the service state and logs before changing data:

```bash
make status
make log SERVICE=mysql
make log SERVICE=postgres
```

Confirm that Docker is running, the configured host port is available, and
`.docker.env` contains all required values. Fix the specific configuration or
port conflict and start the service again.

<a id="section-init-samples"></a>
## Init changes or optional samples do not appear

This is expected when the data directory is already initialized. Verify the
configured data and sample paths and confirm that the preparation command
succeeded. If existing data matters, back it up. Use the matching
`reinit-... CONFIRM=1` command only as a deliberate last step; it deletes that
DBMS's data.

<a id="section-sample-integrity"></a>
## An optional sample is incomplete or has unexpected ownership

The loader intentionally refuses to overwrite or repair an unexpected
database. Re-run the appropriate `make samples-mysql` or
`make samples-postgres` preparation command and inspect the error. Preserve any
needed data before considering a confirmed reinitialization.

<a id="section-connections-troubleshooting"></a>
## A client cannot connect

Host clients use the published host address and `MYSQL_PORT` or
`POSTGRES_PORT`, not the Compose service name. Adminer uses `mysql` or
`postgres` inside the Compose network. Confirm `BIND_ADDRESS`, firewall rules,
the selected database, and the non-administrative `DB_USER` credentials.

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Back to README](../README_en.md)
