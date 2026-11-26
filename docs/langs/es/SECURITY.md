# Política de seguridad

## Elegir idioma

| Русский | English | Español | 中文 | Français | Deutsch |
|---|---|---|---|---|---|
| [Русский](https://github.com/yaleksandr89/docker-sql-lab/blob/master/.github/SECURITY.md) | [English](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/en/SECURITY.md) | **Español** | [中文](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/zh/SECURITY.md) | [Français](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/fr/SECURITY.md) | [Deutsch](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/de/SECURITY.md) |

## Versiones compatibles

Se consideran correcciones de seguridad para el estado actual de `master` y la última versión publicada. Las versiones anteriores pueden tener otra configuración de red; compruebe la compatibilidad de los datos antes de actualizar.

| Versión | Compatible |
|---|---|
| `master` | Sí |
| Última versión publicada | Sí |

## Límites de seguridad del laboratorio

Este laboratorio local de MySQL, PostgreSQL y Adminer utiliza datos sintéticos; no es un despliegue de producción. Los puertos se publican en `127.0.0.1` por defecto; cambiar `BIND_ADDRESS` puede exponer los servicios al exterior. Use redes de confianza y credenciales administrativas y de aprendizaje separadas (`DB_USER`). Las contraseñas de ejemplo son solo para el aprendizaje local. La importación de SQL plano de confianza no es un sandbox y puede ejecutarse parcialmente; `clean-*` y `reinit-*` eliminan datos intencionadamente con `CONFIRM=1` explícito.

Entre los problemas de seguridad se incluyen:

- exposición no prevista de servicios o elusión de la separación entre privilegios de aprendizaje y administración;
- elusión de comprobaciones de rutas de almacenamiento, enlaces simbólicos o confirmación de operaciones destructivas;
- tratamiento inseguro de parámetros, nombres de bases de datos o rutas en importaciones y comandos Make;
- eliminación, sobrescritura o divulgación no prevista de datos, contraseñas o configuración local;
- elusión de comprobaciones de procedencia o integridad de muestras, o problemas de imágenes, plugins de Adminer o CI que afecten a la seguridad.

Comunique errores ordinarios en [GitHub Issues](https://github.com/yaleksandr89/docker-sql-lab/issues), preguntas e ideas en [GitHub Discussions](https://github.com/yaleksandr89/docker-sql-lab/discussions). Si el problema está en un componente upstream, indique su versión exacta y el impacto en el laboratorio; informe también de los defectos del propio componente a sus mantenedores según sus reglas.

## Cómo informar de una vulnerabilidad

Se prefiere GitHub Private Vulnerability Reporting: abra **Security and quality → Report a vulnerability**. Si no está disponible, solicite un canal privado en GitHub Discussions sin publicar detalles técnicos de la vulnerabilidad.

No publique contraseñas, tokens, configuraciones locales o de producción, datos reales, logs completos, exploits funcionales ni detalles sensibles antes de la divulgación coordinada. Utilice solo datos sintéticos o fragmentos saneados.

## Qué incluir en el informe

- Release, branch o commit afectado y versiones de MySQL, PostgreSQL, Adminer, Docker y Compose cuando sean pertinentes.
- Modo de ejecución (MySQL, PostgreSQL, ambos, con o sin Adminer), comando Make afectado y límite de acceso previsto.
- Pasos mínimos de reproducción y comportamiento esperado y real.
- Fragmentos saneados de solicitudes, respuestas o logs y una posible solución, si se conoce.

## Gestión del informe

Los informes se revisan según la disponibilidad; no se promete un SLA fijo. Coordine la divulgación con el mantenedor. Una vez confirmado el problema, las correcciones y la información sobre versiones afectadas se publican mediante divulgación coordinada. No se declara un programa de recompensas por vulnerabilidades.
