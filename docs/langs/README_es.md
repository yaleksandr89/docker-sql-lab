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

Entorno local basado en Docker Compose para aprender y comparar MySQL y
PostgreSQL. Puede ejecutar cada SGBD por separado, ambos a la vez y añadir
Adminer solo cuando necesite una interfaz web.

## Stack

- MySQL 9.7.1 LTS
- PostgreSQL 18.4
- Adminer 5.4.2 Docker Official Image
- Docker Compose v2
- GNU Make y Bash para los comandos del proyecto y los scripts de inicialización

Las versiones de las imágenes están fijadas en `.docker.env`. No use este
laboratorio como plantilla de producción sin revisar credenciales, exposición
de red, almacenamiento, copias de seguridad y operación.

## Funciones principales

- Servicios MySQL y PostgreSQL independientes que también funcionan juntos.
- Adminer opcional y compartido por ambos SGBD, sin depender de uno concreto.
- Una base obligatoria `demo` en cada SGBD con los mismos cinco usuarios de ejemplo.
- Samples opcionales: Sakila y Chinook para MySQL; Pagila y Chinook para PostgreSQL.
- Directorios bind-mounted de data, init y samples separados por SGBD.
- Credenciales didácticas comunes y credenciales administrativas separadas.
- Validaciones estáticas, protección de managed storage paths, comprobaciones
  runtime y smoke-test de importación de SQL de confianza.
- Confirmación explícita para los comandos destructivos de limpieza y reinicialización.

## Requisitos

- Docker Engine o Docker Desktop con el comando `docker compose` v2.
- GNU Make, Bash y las utilidades Unix usadas por los scripts (`awk`, `sed`,
  `grep`, `find`, `realpath` y `stat`).
- Para descargar samples opcionales: `curl` y `git`; para MySQL también
  `unzip` y `sha256sum`.

Ejecute los comandos desde la raíz del repositorio. La rama predeterminada del
proyecto es `master`.

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

## Modos de inicio

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

## Credenciales

`.docker.env` se crea a partir de `.docker.env.example` y está ignorado por
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

## Bases didácticas

### Bases `demo` obligatorias

Ambos SGBD inicializan `demo`:

- MySQL: `demo.demo_users`
- PostgreSQL: `demo.public.demo_users`

Las tablas tienen campos equivalentes `id`, `name`, `email` y `created_at`, y
los mismos cinco usuarios: Alice, Bob, Carol, Dave y Eve. Las comprobaciones
admiten filas adicionales. `make check-env` exige `MYSQL_DATABASE=demo` y
`POSTGRES_DATABASE=demo`.

### Samples opcionales

| SGBD | Bases opcionales | Preparación |
|---|---|---|
| MySQL | Chinook, Sakila | `make samples-mysql` |
| PostgreSQL | Pagila, Chinook | `make samples-postgres` |

La preparación descarga y verifica archivos upstream fijados, pero no inicia
contenedores ni importa en una base ya inicializada. Las descargas temporales
son locales, no se versionan y quedan bajo `MYSQL_SAMPLES_DIR` o
`POSTGRES_SAMPLES_DIR`. Procedencia, hashes y licencias están en
[THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).

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

## Targets públicos de Make

`make help` muestra la lista resumida.

| Comando | Función |
|---|---|
| `make init` | Crear `.docker.env`, validar rutas y crear directorios |
| `make check-env` | Validar variables, roles, bases y managed paths |
| `make pull` | Descargar las tres imágenes fijadas |
| `make config` | Validar la configuración Compose expandida |
| `make up`, `make up-no-ui` | Iniciar ambos SGBD con o sin Adminer |
| `make up-mysql`, `make up-mysql-ui` | Iniciar MySQL, opcionalmente con Adminer |
| `make up-postgres`, `make up-postgres-ui` | Iniciar PostgreSQL, opcionalmente con Adminer |
| `make up-ui`, `make down-ui` | Iniciar o detener solo Adminer |
| `make down` | Detener sin borrar los datos bind-mounted |
| `make status`, `make logs` | Mostrar estado o seguir todos los logs |
| `make log SERVICE=postgres` | Seguir un servicio; también `make log postgres` |
| `make in SERVICE=postgres` | Abrir un shell; también `make in postgres` |
| `make mysql`, `make mysql-user` | Abrir MySQL como admin o `DB_USER` |
| `make postgres`, `make postgres-user` | Abrir PostgreSQL como superusuario o `DB_USER` |
| `make samples-mysql`, `make samples-postgres` | Preparar samples verificados |
| `make check-mysql-access`, `make check-postgres-access` | Comprobar un SGBD activo |
| `make check` | Validar Compose y acceso de `DB_USER` a ambos SGBD |
| `make test-storage-paths` | Probar la protección de managed paths sin Docker runtime |
| `make test-sql-imports` | Smoke-test de los dos imports SQL públicos |
| `make mysql-import FILE=... DATABASE=...` | Importar plain SQL en MySQL como `DB_USER` |
| `make postgres-import FILE=... DATABASE=...` | Importar plain SQL en PostgreSQL como `DB_USER` |
| `make dump`, `make restore` | Exportar o restaurar `demo` de MySQL |
| `make clean-{mysql,postgres,all} CONFIRM=1` | Borrar data directories seleccionados |
| `make reinit-{mysql,postgres,all} CONFIRM=1` | Borrar, recrear y comprobar bases |

## Comprobaciones

### Estáticas y locales

```bash
make check-env
make config
make test-storage-paths
```

`make check-env` crea `.docker.env` si falta y valida valores y rutas.
`make config` valida el modelo Compose expandido. `make test-storage-paths` no
requiere Docker runtime: prueba rutas fuera del proyecto, componentes symlink,
rutas solapadas o anidadas y directorios reservados.

### Runtime

```bash
make up-no-ui
make check
make test-sql-imports
make down
```

`make check` verifica `demo` y el acceso real de `DB_USER` en ambos SGBD,
además de samples instalados. `make test-sql-imports` requiere ambos SGBD,
invoca `mysql-import` y `postgres-import`, crea tablas temporales con nombres
únicos en `demo`, comprueba marker rows como `DB_USER` y elimina solo esas
tablas. Es un smoke-test del flujo de trusted imports; no es un sandbox ni una
prueba de seguridad para SQL no confiable.

## Importación de SQL de confianza

```bash
make mysql-import FILE=path/to/file.sql DATABASE=demo
make postgres-import FILE=path/to/file.sql DATABASE=demo
```

Para ambos targets:

- `FILE` y `DATABASE` son obligatorios.
- El archivo debe existir, ser legible, no estar vacío y ser plain SQL local.
- La base debe existir; las bases de sistema están prohibidas.
- El import se ejecuta como `DB_USER`; no crea la base ni concede grants.
- `DATABASE` elige la conexión inicial, pero no crea un sandbox.
- Nombres cualificados, comandos client/session y los grants reales pueden
  afectar otros objetos accesibles.
- Puede producirse una ejecución parcial; no se promete rollback automático.
- Haga backup antes de una importación importante.
- gzip, archivos y backups PostgreSQL custom-format no están soportados.

## Ciclo de vida de data e init

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

## Backup, limpieza y reinicialización

Los targets integrados cubren solo la base MySQL `demo` configurada:

```bash
make dump
make restore
```

`make dump` escribe `backup/demo.sql`; `make restore` lo lee y reaplica los
grants didácticos de MySQL. Use otro procedimiento para PostgreSQL.

> **Advertencia:** todos los targets `clean-*` y `reinit-*` son destructivos y
> exigen la confirmación exacta `CONFIRM=1`.

```bash
make clean-mysql CONFIRM=1
make clean-postgres CONFIRM=1
make clean-all CONFIRM=1

make reinit-mysql CONFIRM=1
make reinit-postgres CONFIRM=1
make reinit-all CONFIRM=1
```

Los targets individuales borran solo los datos del SGBD elegido; los de tipo
`all` borran ambos. Conservan configuración, init, samples y backups. La
reinicialización vuelve a iniciar y comprobar los SGBD seleccionados;
`reinit-all` inicia ambos sin Adminer.

## Diagnóstico y solución de problemas

### Falla la configuración o la validación de rutas

Ejecute `make check-env`. Los data paths deben estar estrictamente bajo
`data/` y los samples bajo `samples/`; no pueden contener symlinks, solaparse
ni usar directorios reservados. Corrija `.docker.env` y ejecute `make config`.

### Un servicio no está listo

```bash
make status
make log SERVICE=mysql
make log SERVICE=postgres
```

Compruebe Docker, el puerto, `.docker.env` y los logs antes de tocar datos.

### No aparecen cambios de init o samples

Es normal si data ya estaba inicializado. Revise las rutas y la preparación,
haga backup y use `reinit-... CONFIRM=1` solo como último paso deliberado.

### Un sample está incompleto o tiene propietario inesperado

El loader no sobrescribe ni repara bases inesperadas. Repita
`make samples-mysql` o `make samples-postgres`, inspeccione el error y preserve
los datos antes de reinicializar.

### Un cliente no conecta

Los clientes del host usan la dirección publicada y `MYSQL_PORT` o
`POSTGRES_PORT`; Adminer usa `mysql` o `postgres` dentro de Compose. Revise
`BIND_ADDRESS`, firewall, base seleccionada y credenciales `DB_USER`.

## Licencias y avisos de terceros

Docker SQL Lab usa la licencia MIT: [LICENSE.md](../../LICENSE.md). Los samples
mantienen sus licencias upstream; fuentes, revisiones fijadas, integridad y
textos están en
[THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).

---

<p align="center">
  <a href="https://yaleksandr89.github.io/" title="yaleksandr89.github.io">
    <img
      src="../assets/ya-logo-dark-50px.png"
      alt="YA"
      width="32"
    >
  </a>
  <br>
  <strong>Александр Юрченко</strong> ·
  <a href="https://yaleksandr89.github.io/">yaleksandr89.github.io</a>
</p>
