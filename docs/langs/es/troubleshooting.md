# Diagnóstico

[← Volver al README](../README_es.md)

[Русский](../ru/troubleshooting.md) | [English](../en/troubleshooting.md) | **Español — Seleccionado** | [中文](../zh/troubleshooting.md) | [Français](../fr/troubleshooting.md) | [Deutsch](../de/troubleshooting.md)

**Páginas de este idioma:** [Primeros pasos](getting-started.md) · [Bases y samples](databases.md) · [Comprobaciones y operaciones](operations.md) · **Diagnóstico**

Primero reúna diagnósticos y después corrija la causa concreta. Si aún
hace falta reinicializar, cree un backup y use `reinit-... CONFIRM=1` solo
como última medida deliberada.

Detalles canónicos del ciclo de vida y las operaciones: [bases](databases.md#section-initialization) · [operaciones](operations.md#section-clean-reinitialize).

<a id="section-configuration"></a>
## Falla la configuración o la validación de rutas

Ejecute `make check-env`. Los data paths deben estar estrictamente bajo
`data/` y los samples bajo `samples/`; no pueden contener symlinks, solaparse
ni usar directorios reservados. Corrija `.docker.env` y ejecute `make config`.

<a id="section-readiness"></a>
## Un servicio no está listo

```bash
make status
make log SERVICE=mysql
make log SERVICE=postgres
```

Compruebe Docker, el puerto, `.docker.env` y los logs antes de tocar datos.

<a id="section-init-samples"></a>
## No aparecen cambios de init o samples

Es normal si data ya estaba inicializado. Revise las rutas y la preparación,
haga backup y use `reinit-... CONFIRM=1` solo como último paso deliberado.

<a id="section-sample-integrity"></a>
## Un sample está incompleto o tiene propietario inesperado

El loader no sobrescribe ni repara bases inesperadas. Repita
`make samples-mysql` o `make samples-postgres`, inspeccione el error y preserve
los datos antes de reinicializar.

<a id="section-connections-troubleshooting"></a>
## Un cliente no conecta

Los clientes del host usan la dirección publicada y `MYSQL_PORT` o
`POSTGRES_PORT`; Adminer usa `mysql` o `postgres` dentro de Compose. Revise
`BIND_ADDRESS`, firewall, base seleccionada y credenciales `DB_USER`.

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Volver al README](../README_es.md)
