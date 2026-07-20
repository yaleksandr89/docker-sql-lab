# Bases y samples

[← Volver al README](../README_es.md)

## Idioma

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/databases.md) | [English](../en/databases.md) | **Seleccionado** | [中文](../zh/databases.md) | [Français](../fr/databases.md) | [Deutsch](../de/databases.md) |

## Sección

| Primeros pasos | Bases y samples | Comprobaciones y operaciones | Diagnóstico |
| --- | --- | --- | --- |
| [Primeros pasos](getting-started.md) | **Seleccionado** | [Comprobaciones y operaciones](operations.md) | [Diagnóstico](troubleshooting.md) |

<a id="section-demo"></a>
## Bases `demo` obligatorias

Ambos SGBD inicializan `demo`:

- MySQL: `demo.demo_users`
- PostgreSQL: `demo.public.demo_users`

Las tablas tienen campos equivalentes `id`, `name`, `email` y `created_at`, y
los mismos cinco usuarios: Alice, Bob, Carol, Dave y Eve. Las comprobaciones
admiten filas adicionales. `make check-env` exige `MYSQL_DATABASE=demo` y
`POSTGRES_DATABASE=demo`.

<a id="section-optional-samples"></a>
## Samples opcionales

| SGBD | Bases opcionales | Preparación |
|---|---|---|
| MySQL | Chinook, Sakila | `make samples-mysql` |
| PostgreSQL | Pagila, Chinook | `make samples-postgres` |

<a id="section-sample-preparation"></a>
## Preparación de samples

La preparación requiere `curl` y `git`; los samples MySQL también necesitan `unzip` y `sha256sum`.

La preparación descarga y verifica archivos upstream fijados, pero no inicia
contenedores ni importa en una base ya inicializada. Las descargas temporales
son locales, no se versionan y quedan bajo `MYSQL_SAMPLES_DIR` o
`POSTGRES_SAMPLES_DIR`. Procedencia, hashes y licencias están en
[THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md).

Para un data directory vacío:

```bash
make samples-mysql
make up-mysql

make samples-postgres
make up-postgres
```

Los entrypoints oficiales procesan init solo con el data directory vacío. Para
añadir samples a una instancia existente, haga backup y reinicialice
deliberadamente solo ese SGBD:

```bash
make samples-mysql
make reinit-mysql CONFIRM=1

make samples-postgres
make reinit-postgres CONFIRM=1
```

Un sample ausente se omite y no impide crear `demo`. Un conjunto parcial o una
base inesperada se rechazan sin reparación ni borrado automático.

<a id="section-storage-layout"></a>
## Estructura de almacenamiento

```text
data/
├── mysql/
└── postgres/

initdb/
├── mysql/
└── postgres/
```

| SGBD | Data | Init | Samples opcionales |
|---|---|---|---|
| MySQL | `MYSQL_DATA_DIR` (`./data/mysql`) | `MYSQL_INITDB_DIR` (`./initdb/mysql`) | `MYSQL_SAMPLES_DIR` (`./samples/mysql`) |
| PostgreSQL | `POSTGRES_DATA_DIR` (`./data/postgres`) | `POSTGRES_INITDB_DIR` (`./initdb/postgres`) | `POSTGRES_SAMPLES_DIR` (`./samples/postgres`) |

Las rutas data y samples son configurables en `.docker.env` y están sujetas a
validación. Los entrypoints ejecutan init únicamente si el data directory está
vacío; editar init no migra una base existente. `make down` no borra los bind
mounts. No edite manualmente los archivos de `data/`; pueden pertenecer a
UID/GID numéricos del contenedor.

<a id="section-initialization"></a>
## Inicialización y ciclo de vida

> **Importante:** Los entrypoints oficiales de MySQL y PostgreSQL ejecutan init solo si el
data directory está vacío. Cambiar init no migra una base existente y
`make down` conserva los datos bind-mounted.

<a id="section-training-access"></a>
## Acceso didáctico y ownership

MySQL crea `DB_USER` y le concede acceso a todas las bases no
sistémicas encontradas durante init. PostgreSQL crea un `DB_USER` separado,
sin superuser/createdb/createrole, y lo hace propietario de `demo`, de
`public` y de los objetos sample. Las credenciales administrativas siguen
separadas: `MYSQL_ROOT_PASSWORD`, `POSTGRES_SUPERUSER` y
`POSTGRES_SUPERUSER_PASSWORD`. No edite manualmente archivos de `data/`.

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Volver al README](../README_es.md)
