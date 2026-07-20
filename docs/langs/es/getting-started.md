# Primeros pasos

[← Volver al README](../README_es.md)

## Idioma

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/getting-started.md) | [English](../en/getting-started.md) | **Seleccionado** | [中文](../zh/getting-started.md) | [Français](../fr/getting-started.md) | [Deutsch](../de/getting-started.md) |

## Sección

| Primeros pasos | Bases y samples | Comprobaciones y operaciones | Diagnóstico |
| --- | --- | --- | --- |
| **Seleccionado** | [Bases y samples](databases.md) | [Comprobaciones y operaciones](operations.md) | [Diagnóstico](troubleshooting.md) |

<a id="section-requirements"></a>
## Requisitos

- Docker Engine o Docker Desktop con el comando `docker compose` v2.
- GNU Make, Bash y las utilidades Unix usadas por los scripts (`awk`, `sed`,
  `grep`, `find`, `realpath` y `stat`).
- Para descargar samples opcionales: `curl` y `git`; para MySQL también
  `unzip` y `sha256sum`.

Ejecute los comandos desde la raíz del repositorio. La rama predeterminada del
proyecto es `master`.

<a id="section-quick-start"></a>
## Inicio rápido

Cree `.docker.env` desde el ejemplo versionado, valide las rutas, cree los
directorios de trabajo e inicie el laboratorio completo:

```bash
make init
make up
```

`make up` inicia MySQL, PostgreSQL y Adminer. Con la configuración por defecto,
Adminer está en `http://127.0.0.1:8081`.

```bash
make status
make logs
make down
```

`make down` elimina los contenedores y la red, pero conserva los datos
bind-mounted.

<a id="section-startup-modes"></a>
## Modos de inicio

| Comando | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Inicia | Inicia | Inicia |
| `make up-no-ui` | Inicia | Inicia | Detiene |
| `make up-mysql` | Inicia | No inicia | No inicia |
| `make up-postgres` | No inicia | Inicia | No inicia |

Los comandos de un SGBD no detienen el otro ya activo; Adminer se gestiona aparte.

<details>
<summary>Tabla completa de modos de inicio</summary>

| Comando | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Inicia | Inicia | Inicia |
| `make up-no-ui` | Inicia o mantiene activo | Inicia o mantiene activo | Detiene si estaba activo |
| `make up-mysql` | Inicia | No inicia automáticamente | No inicia automáticamente |
| `make up-mysql-ui` | Inicia | No inicia automáticamente | Inicia |
| `make up-postgres` | No inicia automáticamente | Inicia | No inicia automáticamente |
| `make up-postgres-ui` | No inicia automáticamente | Inicia | Inicia |
| `make up-ui` | No cambia | No cambia | Inicia |
| `make down-ui` | No cambia | No cambia | Detiene |

Los comandos de un solo SGBD no detienen el otro si ya está activo. Adminer se
puede iniciar y detener por separado y no está ligado únicamente a MySQL.

</details>

<a id="section-connections"></a>
## Conexiones

### Adminer

Dentro de la red de Compose, Adminer ofrece dos servidores predefinidos:

```text
MySQL (mysql)
PostgreSQL (postgres)
```

Seleccione uno e introduzca `DB_USER`, `DB_PASSWORD` y una base como `demo`.
`mysql` y `postgres` son nombres internos de servicio, no hosts para clientes
de escritorio.

### Clientes en el host

| SGBD | Host predeterminado | Variable de puerto | Usuario | Base predeterminada |
|---|---|---|---|---|
| MySQL | `127.0.0.1` | `MYSQL_PORT` | `DB_USER` | `demo` |
| PostgreSQL | `127.0.0.1` | `POSTGRES_PORT` | `DB_USER` | `demo` |

DataGrip, DBeaver, PhpStorm y los CLI del host usan la dirección y el puerto
publicados. Si cambia `BIND_ADDRESS`, use la dirección accesible de esa interfaz.

### CLI dentro de los contenedores

Las contraseñas pasan por el entorno del contenedor y no quedan en el historial:

```bash
make mysql          # administrador MySQL, base demo
make mysql-user     # DB_USER, base demo
make postgres       # superusuario PostgreSQL, base demo
make postgres-user  # DB_USER, base demo
```

<a id="section-credentials"></a>
## Credenciales

`.docker.env` se crea a partir de [`.docker.env.example`](../../../.docker.env.example) y está ignorado por
Git. Guarde allí las contraseñas; no las codifique en Compose, SQL ni en
configuración de cliente versionada.

| Finalidad | Usuario | Contraseña |
|---|---|---|
| Usuario didáctico común | `DB_USER` | `DB_PASSWORD` |
| Administrador MySQL | `root` | `MYSQL_ROOT_PASSWORD` |
| Administrador/superusuario PostgreSQL | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` y `DB_USER` deben ser roles distintos. Use `DB_USER` para
los ejercicios habituales. Cambie las contraseñas de ejemplo antes de
compartir o publicar cualquier servicio.

<a id="section-network-exposure"></a>
## Puertos y `BIND_ADDRESS`

| Servicio | Variable | Valor de ejemplo |
|---|---|---|
| MySQL | `MYSQL_PORT` | `3306` |
| PostgreSQL | `POSTGRES_PORT` | `5432` |
| Adminer | `ADMINER_PORT` | `8081` |

Por defecto, los tres servicios solo se publican en loopback:

```env
BIND_ADDRESS=127.0.0.1
```

`127.0.0.1` es el valor local predeterminado. `BIND_ADDRESS=0.0.0.0` publica
los puertos en todas las interfaces. Para LAN o VPN, prefiera la dirección de
una interfaz concreta. Cambie este valor conscientemente y revise firewall,
fortaleza de contraseñas y confianza en la red.

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Volver al README](../README_es.md)
