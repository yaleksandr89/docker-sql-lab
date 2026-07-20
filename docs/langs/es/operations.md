# Comprobaciones y operaciones

[← Volver al README](../README_es.md)

[Русский](../ru/operations.md) | [English](../en/operations.md) | **Español — Seleccionado** | [中文](../zh/operations.md) | [Français](../fr/operations.md) | [Deutsch](../de/operations.md)

**Páginas de este idioma:** [Primeros pasos](getting-started.md) · [Bases y samples](databases.md) · **Comprobaciones y operaciones** · [Diagnóstico](troubleshooting.md)

<a id="section-make-targets"></a>
## Targets públicos de Make

Targets clave: `make init`, `make up`, `make down`, `make check`,
`make test-storage-paths`, `make test-sql-imports`, `make mysql-import` y
`make postgres-import`. El SQL de confianza no es un sandbox, puede
ejecutarse parcialmente y no ofrece rollback automático completo; haga backup
antes de un import importante. Los backups integrados solo cubren MySQL
`demo`, no PostgreSQL. `clean-*` y `reinit-*` son destructivos y exigen
`CONFIRM=1` exacto.

<details>
<summary>Referencia completa de targets públicos de Make</summary>

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

</details>

<a id="section-validation"></a>
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

<a id="section-storage-path-safety"></a>
## Seguridad de storage paths

`make check-env` ejecuta `scripts/validate-storage-paths.sh`. Los data
paths deben estar estrictamente bajo `data/` y los sample paths bajo
`samples/`; se rechazan symlinks, rutas iguales, anidadas, solapadas o
reservadas. `make test-storage-paths` prueba estas reglas sin Docker runtime.

<a id="section-sql-imports"></a>
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

<a id="section-backup"></a>
## Backup

Los targets integrados cubren solo la base MySQL `demo` configurada:

```bash
make dump
make restore
```

`make dump` escribe `backup/demo.sql`; `make restore` lo lee y reaplica los
grants didácticos de MySQL. Use otro procedimiento para PostgreSQL.

<a id="section-clean-reinitialize"></a>
## Limpieza y reinicialización

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

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Volver al README](../README_es.md)
