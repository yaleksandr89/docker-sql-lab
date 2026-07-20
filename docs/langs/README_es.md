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
| `make up-no-ui` | Inicia | Inicia | Detiene |
| `make up-mysql` | Inicia | No inicia | No inicia |
| `make up-postgres` | No inicia | Inicia | No inicia |

Los comandos de un SGBD no detienen el otro ya activo; Adminer se gestiona aparte.

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

## Credenciales resumidas

| Finalidad | Usuario | Contraseña |
|---|---|---|
| Usuario didáctico común | `DB_USER` | `DB_PASSWORD` |
| Administrador MySQL | `root` | `MYSQL_ROOT_PASSWORD` |
| Superusuario PostgreSQL | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` y `DB_USER` deben ser roles distintos. Use el usuario didáctico común para ejercicios normales y cambie las contraseñas de ejemplo antes de publicar servicios.

## Bases y comprobaciones clave

Ambos SGBD crean la base obligatoria `demo` con una tabla `demo_users` equivalente. Los samples opcionales son Chinook y Sakila para MySQL, y Pagila y Chinook para PostgreSQL. Prepararlos no los importa en datos ya inicializados.

Estas comprobaciones estáticas no requieren bases activas:

```bash
make check-env
make config
make test-storage-paths
```

Tras iniciar ambos SGBD, `make check` verifica el acceso de `DB_USER` y `make test-sql-imports` ejercita los targets públicos de importación de confianza. Las páginas detalladas documentan comandos, límites y el orden operativo seguro.

Los directorios data, init y samples de MySQL y PostgreSQL están separados y se configuran mediante `.docker.env`. El validador de managed paths rechaza ubicaciones fuera de `data/` o `samples/`, componentes symlink, solapamientos y directorios reservados. Un sample totalmente ausente se omite; un conjunto parcial o una base inesperada se rechazan sin reparación automática.

La preparación descarga archivos upstream fijados, comprueba su integridad y los conserva localmente; procedencia y licencias están en `THIRD_PARTY_NOTICES.md`. Los controles runtime también verifican las filas obligatorias de `demo`, lectura/escritura del usuario didáctico y samples instalados.

## Seguridad y ciclo de vida

- `BIND_ADDRESS=127.0.0.1` publica servicios solo en loopback.
- `BIND_ADDRESS=0.0.0.0` los publica en todas las interfaces; configure
  conscientemente firewall, credentials robustas y confianza de red.
- Los entrypoints oficiales ejecutan init solo con un data directory vacío.
- `make mysql-import` y `make postgres-import` aceptan únicamente SQL de
  confianza. No crean un sandbox: puede haber ejecución parcial sin rollback
  automático completo. Haga backup antes de una importación importante.
- `make dump` y `make restore` cubren solo MySQL `demo`; no hay target
  integrado de backup para PostgreSQL.
- Todos los targets `clean-*` y `reinit-*` son destructivos y exigen
  exactamente `CONFIRM=1`.

## Documentación

- [Primeros pasos](es/getting-started.md)
- [Bases y samples](es/databases.md)
- [Comprobaciones y operaciones](es/operations.md)
- [Diagnóstico](es/troubleshooting.md)

## Licencias y avisos de terceros

Docker SQL Lab usa la licencia MIT: [LICENSE.md](../../LICENSE.md). Los samples
mantienen sus licencias upstream; fuentes, revisiones fijadas, integridad y
textos están en
[THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).

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
