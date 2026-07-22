<p align="center">
  <img
    src="../assets/docker-sql-lab-cover.png"
    alt="Docker SQL Lab — entorno local de MySQL y PostgreSQL"
    width="100%"
  >
</p>

# Docker SQL Lab

## Elija un idioma

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../../README.md) | [English](README_en.md) | **Seleccionado** | [中文](README_zh.md) | [Français](README_fr.md) | [Deutsch](README_de.md) |

Un laboratorio local con Docker Compose para practicar SQL y conocer y comparar
MySQL y PostgreSQL. Puede iniciar cada SGBD por separado o ambos a la vez.
La base compacta `demo` se crea automáticamente; los datasets opcionales
Sakila, Pagila y Chinook ofrecen datos listos para consultar. Active Adminer
solo cuando lo necesite.

## Videotutoriales

Las grabaciones usan PhpStorm; también sirven DataGrip, DBeaver, Adminer u otro
cliente MySQL/PostgreSQL. Los screencasts están grabados en ruso.

| Escenario | Yandex Disk | Google Drive | Qué muestra |
|---|---|---|---|
| Primer inicio con `demo` obligatoria y posterior adición de bases didácticas | [Ver](https://disk.yandex.ru/i/Kj4TcMSBuIDVeA "docker-sql-lab-demo-then-training-databases.mp4") | [Ver](https://drive.google.com/file/d/1HzYWbMuBEobXlbGQYNfHYVAq95TLqEPf/view?usp=sharing "docker-sql-lab-demo-then-training-databases.mp4") | Inicia MySQL y PostgreSQL con `demo` obligatoria; comprueba; prepara Sakila, Pagila y Chinook; confirma la reinicialización; vuelve a comprobar y ejecuta consultas SQL. |
| Primer inicio con las bases didácticas preparadas de antemano | [Ver](https://disk.yandex.ru/i/nFgJZto8agbdWw "docker-sql-lab-training-databases-first-start.mp4") | [Ver](https://drive.google.com/file/d/1nKiGrJ4QINLCQcRk-k6vfTakpWsw-JS7/view?usp=sharing "docker-sql-lab-training-databases-first-start.mp4") | Prepara Sakila, Pagila y Chinook antes del primer inicio; inicializa juntas `demo` obligatoria y las bases didácticas; comprueba el acceso y ejecuta consultas SQL. |

## Stack

- MySQL 9.7.1 LTS
- PostgreSQL 18.4
- Adminer 5.4.2 Docker Official Image
- Docker Compose v2
- GNU Make y Bash para los comandos y scripts de inicialización

Los valores predeterminados fijados se definen en
[`.docker.env.example`](../../.docker.env.example); `make init` crea desde él
el `.docker.env` local. Los servicios se definen en
[`docker-compose.yml`](../../docker-compose.yml).

<details>
<summary>⚠️ Importante: este es un entorno didáctico</summary>

El proyecto no es una plantilla lista para producción. El uso externo exige
decisiones propias sobre credenciales, exposición de red, almacenamiento,
backups y operación.

</details>

## Funciones principales

- MySQL y PostgreSQL funcionan por separado o juntos.
- Cada SGBD incluye una base `demo` obligatoria con los mismos seed rows.
- MySQL admite Sakila y Chinook opcionales; PostgreSQL, Pagila y Chinook.
- Adminer es una interfaz opcional e independiente para ambos SGBD.
- Cada SGBD tiene directorios bind-mounted separados para datos, init y samples.
- Las comprobaciones, imports SQL de confianza y acciones destructivas se
  centralizan en el [`Makefile`](../../Makefile).

## Requisitos

1. Docker Engine o Docker Desktop con Docker Compose v2.
2. GNU Make, Bash y las utilidades Unix CLI básicas usadas por los scripts.

Entornos recomendados: Linux; macOS con Docker Desktop; Windows con Docker
Desktop y WSL2. Ejecute los comandos desde la raíz del repositorio. La rama
predeterminada del proyecto es `master`.

## Inicio rápido

```bash
make init
make up
```

`make init` crea el `.docker.env` local desde
[`.docker.env.example`](../../.docker.env.example), valida las rutas gestionadas
y crea los directorios de trabajo. En el primer arranque, los entrypoints
oficiales inicializan ambos SGBD. Sin samples opcionales seguirá teniendo MySQL
y PostgreSQL operativos con `demo` y sus seed rows.

`make up` inicia MySQL, PostgreSQL y Adminer; `make up-no-ui` inicia ambos SGBD
sin Adminer. Por defecto, Adminer está en `http://127.0.0.1:8081`.

Modos, conexiones y credenciales:
[Primeros pasos](es/getting-started.md).

### ¿Necesita datos didácticos preparados?

Los samples son opcionales: `demo` se crea siempre; MySQL ofrece Sakila y Chinook, y PostgreSQL, Pagila y Chinook.

**Primer arranque con directorios de datos vacíos**

```bash
make init
make samples-mysql
make samples-postgres
make up
```

Prepare los samples antes de la primera inicialización; los entrypoints los cargarán junto con `demo`.

> **Advertencia:** la reinicialización elimina los datos del SGBD elegido. Haga
> backup solo de los datos propios que quiera conservar; un laboratorio puntual sin cambios valiosos no lo necesita.

<details>
<summary>📦 El laboratorio ya se inició: añadir o reutilizar samples</summary>

**Inicializado sin samples.** `make up` no aplica nuevos archivos init/sample. Si necesita conservar datos importantes, haga backup y use la opción adecuada:

- MySQL: `make samples-mysql` y después `make reinit-mysql CONFIRM=1`.
- PostgreSQL: `make samples-postgres` y después `make reinit-postgres CONFIRM=1`.
- Ambos SGBD: `make samples-mysql`, `make samples-postgres` y después `make reinit-all CONFIRM=1`.

> **Advertencia:** `reinit-*` elimina los datos seleccionados y solo se ejecuta con `CONFIRM=1` exacto.

**Samples ya instalados.** Use `make up` o el `make up-*` elegido: no repita download ni reinit; las bases persisten en el almacenamiento bind-mounted.

</details>

Detalles: [Bases y samples](es/databases.md).

## Modos de inicio

| Comando | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Inicia | Inicia | Inicia |
| `make up-no-ui` | Inicia | Inicia | Detiene |
| `make up-mysql` | Inicia | No inicia | No inicia |
| `make up-postgres` | No inicia | Inicia | No inicia |

Un comando de un solo SGBD no detiene al otro; Adminer se gestiona aparte. La
lista completa está en el [`Makefile`](../../Makefile).

## Conexiones y bases disponibles

Dentro de Compose, Adminer usa `mysql` y `postgres`. Los clientes del host usan
`127.0.0.1` y `MYSQL_PORT` o `POSTGRES_PORT`. Para el trabajo habitual, use
`DB_USER` y `DB_PASSWORD`.

| SGBD | Siempre disponible | Tras inicializar samples opcionales |
|---|---|---|
| MySQL | `demo` | `sakila`, `chinook` |
| PostgreSQL | `demo` | `pagila`, `chinook` |

Las bases opcionales solo existen tras su inicialización real. Detalles:
[inicio y conexiones](es/getting-started.md) ·
[bases y samples](es/databases.md).

## Credenciales resumidas

| Finalidad | Usuario | Contraseña |
|---|---|---|
| Usuario didáctico común | `DB_USER` | `DB_PASSWORD` |
| Administrador MySQL | `root` | `MYSQL_ROOT_PASSWORD` |
| Superusuario PostgreSQL | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` y `DB_USER` deben ser roles distintos. Use el usuario
didáctico para ejercicios y cambie las contraseñas de ejemplo antes de publicar.

## Bases y comprobaciones clave

Ambas `demo` contienen una tabla `demo_users` equivalente con cinco filas.
Estas comprobaciones no requieren SGBD en ejecución:

```bash
make check-env
make config
make test-storage-paths
```

Tras el arranque, `make check` valida `demo` y el acceso de `DB_USER`;
`make test-sql-imports` prueba los imports públicos de confianza. Orden y
límites: [Comprobaciones y operaciones](es/operations.md).

## Seguridad y ciclo de vida

- `BIND_ADDRESS=127.0.0.1` publica solo en loopback.
- `BIND_ADDRESS=0.0.0.0` expone todos los interfaces; configure antes firewall,
  credenciales robustas y una red de confianza.
- Los entrypoints oficiales ejecutan init solo con datos vacíos.
- `make mysql-import` y `make postgres-import` aceptan únicamente SQL de
  confianza. No son un sandbox: puede haber ejecución parcial sin rollback
  automático completo.
  Antes de un import importante, revise el archivo SQL y cree un backup adecuado.
- `make dump` y `make restore` cubren solo `demo` de MySQL; no hay target de
  backup integrado para PostgreSQL.
- Cada comando `clean-*` y `reinit-*` es destructivo y exige `CONFIRM=1` exacto.

Secuencias seguras: [Comprobaciones y operaciones](es/operations.md).
Ante fallos, reúna primero diagnósticos: [Diagnóstico](es/troubleshooting.md).

## Licencias de los datos didácticos

Los datasets opcionales conservan las licencias y avisos de sus proyectos
upstream. Procedencia, revisiones fijadas, integridad y textos están en
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
