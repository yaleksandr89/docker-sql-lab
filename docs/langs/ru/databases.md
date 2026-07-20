# Базы и samples

[← Вернуться к README](../../../README.md)

## Язык

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| **Выбран** | [English](../en/databases.md) | [Español](../es/databases.md) | [中文](../zh/databases.md) | [Français](../fr/databases.md) | [Deutsch](../de/databases.md) |

## Раздел

| Начало работы | Базы и samples | Проверки и операции | Диагностика |
| --- | --- | --- | --- |
| [Начало работы](getting-started.md) | **Выбран** | [Проверки и операции](operations.md) | [Диагностика](troubleshooting.md) |

<a id="section-demo"></a>
## Обязательные базы `demo`

Обе СУБД инициализируют обязательную базу с именем `demo`:

- MySQL: `demo.demo_users`
- PostgreSQL: `demo.public.demo_users`

Таблицы содержат эквивалентные поля `id`, `name`, `email`, `created_at` и
одинаковые пять обязательных пользователей: Alice, Bob, Carol, Dave и Eve.
Проверки допускают дополнительные строки, созданные пользователем.

Имена баз по умолчанию задаются как `MYSQL_DATABASE=demo` и
`POSTGRES_DATABASE=demo`; `make check-env` требует именно эти значения.

<a id="section-optional-samples"></a>
## Необязательные учебные базы

| СУБД | Необязательные базы | Команда подготовки |
|---|---|---|
| MySQL | Chinook, Sakila | `make samples-mysql` |
| PostgreSQL | Pagila, Chinook | `make samples-postgres` |

<a id="section-sample-preparation"></a>
## Подготовка samples

Для подготовки нужны `curl` и `git`; MySQL samples дополнительно требуют `unzip` и `sha256sum`.

Команды подготовки загружают и проверяют закреплённые upstream-файлы, но не
запускают контейнеры и не импортируют данные в уже инициализированную СУБД.
Загрузки остаются локальными, исключаются из Git и сохраняются в
`MYSQL_SAMPLES_DIR` или `POSTGRES_SAMPLES_DIR`. Происхождение, integrity pins и
лицензии описаны в [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md).

Для СУБД с пустым data-каталогом:

```bash
make samples-mysql
make up-mysql

make samples-postgres
make up-postgres
```

Официальные entrypoints образов обрабатывают init-файлы только при пустом
data-каталоге соответствующей СУБД. Чтобы добавить samples в уже
инициализированную СУБД, сначала сохраните важные данные, затем осознанно
переинициализируйте только её:

```bash
make samples-mysql
make reinit-mysql CONFIRM=1

make samples-postgres
make reinit-postgres CONFIRM=1
```

Полностью отсутствующий optional sample пропускается и не мешает создать
обязательную `demo`. Частичный набор sample-файлов или неожиданная существующая
sample-база отклоняются без автоматического исправления или удаления.

<a id="section-storage-layout"></a>
## Структура хранения

Bind-mounted storage по умолчанию разделён по СУБД:

```text
data/
├── mysql/
└── postgres/

initdb/
├── mysql/
└── postgres/
```

Связанные настройки `.docker.env` также разделены:

| СУБД | Данные | Init | Optional samples |
|---|---|---|---|
| MySQL | `MYSQL_DATA_DIR` (`./data/mysql`) | `MYSQL_INITDB_DIR` (`./initdb/mysql`) | `MYSQL_SAMPLES_DIR` (`./samples/mysql`) |
| PostgreSQL | `POSTGRES_DATA_DIR` (`./data/postgres`) | `POSTGRES_INITDB_DIR` (`./initdb/postgres`) | `POSTGRES_SAMPLES_DIR` (`./samples/postgres`) |

Data- и sample-пути можно изменить через `.docker.env` с учётом проверки
managed storage paths.

Официальные entrypoints MySQL и PostgreSQL выполняют соответствующий
init-каталог только для пустого data-каталога. Добавление или изменение
init-файла не мигрирует существующую базу. `make down` не удаляет данные ни из
одного bind mount.

Не редактируйте файлы СУБД внутри `data/` вручную. Container-owned файлы могут
иметь числовые UID/GID, отличающиеся от пользователя хоста.

<a id="section-initialization"></a>
## Инициализация и жизненный цикл

> **Важно:** Официальные entrypoints MySQL и PostgreSQL выполняют init-файлы только
при пустом data-каталоге. Изменение init-файлов не мигрирует уже созданную
базу, а `make down` не удаляет bind-mounted данные.

<a id="section-training-access"></a>
## Доступ учебного пользователя и ownership

MySQL создаёт `DB_USER` и выдаёт ему права на все пользовательские
базы, обнаруженные во время init. PostgreSQL создаёт отдельную роль
`DB_USER` без superuser/createdb/createrole и назначает её владельцем
`demo`, схемы `public` и загруженных sample-объектов. Административные
credentials остаются отдельными: `MYSQL_ROOT_PASSWORD`,
`POSTGRES_SUPERUSER` и `POSTGRES_SUPERUSER_PASSWORD`. Не редактируйте
container-owned файлы в `data/` вручную.

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Вернуться к README](../../../README.md)
