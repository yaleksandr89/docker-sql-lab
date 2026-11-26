# Contribuir

## Elija un idioma

| Русский | English | Español | 中文 | Français | Deutsch |
|---|---|---|---|---|---|
| [Русский](https://github.com/yaleksandr89/docker-sql-lab/blob/master/.github/CONTRIBUTING.md) | [English](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/en/CONTRIBUTING.md) | **Español** | [中文](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/zh/CONTRIBUTING.md) | [Français](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/fr/CONTRIBUTING.md) | [Deutsch](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/de/CONTRIBUTING.md) |

## Antes de empezar

Use GitHub Issues para errores reproducibles; discuta primero las preguntas y propuestas con el propietario. No publique contraseñas, datos reales ni detalles de vulnerabilidades.

## Límites de los cambios

Conserve los comandos Make públicos, la separación de SGBD, `demo` obligatoria, samples opcionales y permisos de `DB_USER`. Acuerde previamente cambios de imágenes, esquemas, permisos, red, imports y operaciones destructivas. No añada a Git archivos SQL de terceros descargados ni `.docker.env` locales.

## Comprobaciones

Trabaje en una copia desechable con datos sintéticos, nombre de proyecto Compose y puertos únicos. Verifique rutas de almacenamiento e identidad de la base antes de ejecutar comandos runtime.

```bash
make check-env
make config
make test-storage-paths
```

Para cambios de init, imágenes, imports o Adminer, ejecute las comprobaciones pertinentes en un laboratorio aislado. `clean-*` y `reinit-*` borran datos; no los use en un laboratorio de trabajo.

[Primeros pasos](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/es/guides/getting-started.md) · [Guía de operaciones](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/es/guides/operations.md).

## Pull Request

Cree una rama temática desde `master` y un commit firmado y coherente. Use Conventional Commits con descripción en ruso, por ejemplo `docs: уточнить порядок запуска`. Indique el cambio, impacto sobre datos y seguridad, comprobaciones realmente ejecutadas y cambios de documentación. Sincronice los seis idiomas; los tres workflows CI deben pasar antes del merge.
