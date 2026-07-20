# Проверки и операции

[← Вернуться к README](../../../README.md)

**Русский — Выбран** | [English](../en/operations.md) | [Español](../es/operations.md) | [中文](../zh/operations.md) | [Français](../fr/operations.md) | [Deutsch](../de/operations.md)

**Разделы этого языка:** [Начало работы](getting-started.md) · [Базы и samples](databases.md) · **Проверки и операции** · [Диагностика](troubleshooting.md)

<a id="section-make-targets"></a>
## Команды Makefile

Ключевые targets: `make init`, `make up`, `make down`, `make check`,
`make test-storage-paths`, `make test-sql-imports`, `make mysql-import` и
`make postgres-import`. Trusted SQL не является sandbox, может выполниться
частично и не получает гарантии automatic rollback; перед важным импортом
нужен backup. Встроенные backup targets покрывают только MySQL `demo`, не
PostgreSQL. `clean-*` и `reinit-*` destructive и требуют точного
`CONFIRM=1`.

<details>
<summary>Полный справочник публичных Make-целей</summary>

Краткий список команд выводит `make help`.

| Команда | Назначение |
|---|---|
| `make init` | Создать `.docker.env`, проверить managed paths и создать рабочие каталоги |
| `make check-env` | Проверить обязательные env-значения, разделение ролей, имена баз и managed paths |
| `make pull` | Загрузить три закреплённых container images |
| `make config` | Проверить развёрнутую Compose-конфигурацию |
| `make up`, `make up-no-ui` | Запустить обе СУБД с Adminer или без него |
| `make up-mysql`, `make up-mysql-ui` | Запустить MySQL, опционально с Adminer |
| `make up-postgres`, `make up-postgres-ui` | Запустить PostgreSQL, опционально с Adminer |
| `make up-ui`, `make down-ui` | Запустить или остановить только Adminer |
| `make down` | Остановить стенд без удаления bind-mounted данных |
| `make status` | Показать состояние сервисов |
| `make logs` | Следить за логами всех сервисов |
| `make log SERVICE=postgres` | Следить за логом одного сервиса; также работает `make log postgres` |
| `make in SERVICE=postgres` | Открыть shell сервиса; также работает `make in postgres` |
| `make mysql`, `make mysql-user` | Открыть MySQL как администратор или `DB_USER` |
| `make postgres`, `make postgres-user` | Открыть PostgreSQL как superuser или `DB_USER` |
| `make samples-mysql`, `make samples-postgres` | Подготовить проверенные optional samples |
| `make check-mysql-access`, `make check-postgres-access` | Проверить доступ учебного пользователя к одной запущенной СУБД |
| `make check` | Проверить Compose и доступ `DB_USER` к двум запущенным СУБД |
| `make test-storage-paths` | Проверить защиту managed storage paths без Docker runtime |
| `make test-sql-imports` | Выполнить smoke-test двух публичных trusted SQL import targets |
| `make mysql-import FILE=... DATABASE=...` | Импортировать доверенный plain SQL в существующую MySQL-базу от `DB_USER` |
| `make postgres-import FILE=... DATABASE=...` | Импортировать доверенный plain SQL в существующую PostgreSQL-базу от `DB_USER` |
| `make dump`, `make restore` | Создать или восстановить dump настроенной MySQL-базы `demo` |
| `make clean-{mysql,postgres,all} CONFIRM=1` | Удалить выбранные managed data-каталоги |
| `make reinit-{mysql,postgres,all} CONFIRM=1` | Удалить, пересоздать и проверить выбранные базы |

</details>

<a id="section-validation"></a>
## Проверки

### Статические и локальные проверки

```bash
make check-env
make config
make test-storage-paths
```

`make check-env` создаёт `.docker.env` из примера, если файла ещё нет, затем
проверяет обязательные настройки и managed paths. `make config` проверяет
развёрнутую Compose-модель.

Для `make test-storage-paths` Docker runtime не требуется. Тест проверяет
защиту от путей за пределами проекта, symlink-компонентов, пересекающихся или
вложенных managed paths и зарезервированных каталогов. Тот же validator
защищает настроенные data- и sample-каталоги MySQL/PostgreSQL при обычной
инициализации.

### Runtime-проверки

Запустите обе СУБД без Adminer, проверьте учебный доступ и imports, затем
остановите сервисы:

```bash
make up-no-ui
make check
make test-sql-imports
make down
```

`make check` проверяет обязательные данные `demo` и фактический доступ
`DB_USER` в обеих СУБД. Если установлены поддерживаемые optional samples, они
также проверяются.

Для `make test-sql-imports` обе СУБД должны быть запущены. Тест вызывает
публичные targets `mysql-import` и `postgres-import`, создаёт уникальные
временные smoke-таблицы в `demo`, проверяет marker rows от имени `DB_USER` и
удаляет только эти таблицы. Это проверка trusted SQL import workflow, а не
доказательство безопасности или sandbox для недоверенного SQL.

<a id="section-storage-path-safety"></a>
## Безопасность storage paths

`make check-env` запускает `scripts/validate-storage-paths.sh`.
Data paths должны быть строго внутри `data/`, sample paths — внутри
`samples/`; symlink-компоненты, совпадающие, вложенные, пересекающиеся и
зарезервированные пути отклоняются. `make test-storage-paths` проверяет эти
ограничения без Docker runtime.

<a id="section-sql-imports"></a>
## Импорт доверенных SQL-файлов

Импортируйте только доверенные локальные plain SQL-файлы:

```bash
make mysql-import FILE=path/to/file.sql DATABASE=demo
make postgres-import FILE=path/to/file.sql DATABASE=demo
```

Для обоих targets:

- `FILE` и `DATABASE` обязательны.
- Файл должен быть существующим, читаемым и непустым обычным файлом.
- Имя базы должно начинаться со строчной ASCII-буквы и содержать только
  строчные ASCII-буквы, цифры или `_`; системные базы запрещены.
- База должна существовать и принимать подключение от `DB_USER`.
- Import выполняется от `DB_USER`, а не от MySQL root или PostgreSQL superuser.
- Target не создаёт базу и не выдаёт grants.
- Targets не обрабатывают архивы, gzip-потоки и PostgreSQL backups в custom
  format.

`DATABASE` выбирает начальную базу подключения, но не создаёт sandbox.
Qualified names (полные имена объектов), session/client commands и реальные
grants роли `DB_USER` могут разрешить доступ к другим объектам. SQL способен
изменить или удалить всё, к чему у этой роли есть доступ.

Import может выполниться частично. Ни один target не обещает автоматический
полный rollback после ошибки. Перед важным импортом изучите файл и создайте
подходящий backup.

<a id="section-backup"></a>
## Backup

Встроенные backup-targets работают только с настроенной MySQL-базой `demo`:

```bash
make dump
make restore
```

С конфигурацией по умолчанию `make dump` записывает `backup/demo.sql`.
`make restore` читает этот файл и повторно применяет учебные MySQL grants. Для
сохранения PostgreSQL используйте отдельную процедуру резервного копирования.

<a id="section-clean-reinitialize"></a>
## Очистка и переинициализация

> **Внимание:** все перечисленные ниже `clean-*` и `reinit-*` команды
> destructive и требуют точного подтверждения `CONFIRM=1`.

```bash
make clean-mysql CONFIRM=1
make clean-postgres CONFIRM=1
make clean-all CONFIRM=1

make reinit-mysql CONFIRM=1
make reinit-postgres CONFIRM=1
make reinit-all CONFIRM=1
```

Одиночные команды удаляют только data-каталог выбранной СУБД. Варианты `all`
удаляют data-каталоги обеих СУБД. Конфигурация, init-файлы, загруженные
optional samples и backups сохраняются. Затем reinit запускает и проверяет
выбранные СУБД; `reinit-all` запускает обе без Adminer.

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Вернуться к README](../../../README.md)
