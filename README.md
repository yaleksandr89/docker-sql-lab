<p align="center">
  <img
    src="docs/assets/docker-sql-lab-cover.png"
    alt="Docker SQL Lab — локальный стенд MySQL и PostgreSQL"
    width="100%"
  >
</p>

# Docker SQL Lab

## Выберите язык

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| **Выбран** | [English](docs/langs/README_en.md) | [Español](docs/langs/README_es.md) | [中文](docs/langs/README_zh.md) | [Français](docs/langs/README_fr.md) | [Deutsch](docs/langs/README_de.md) |

Локальный стенд на Docker Compose для изучения и сравнения MySQL и PostgreSQL.
Каждую СУБД можно запускать независимо, обе можно использовать одновременно,
а Adminer подключать только при необходимости браузерного UI.

## Стек

- MySQL 9.7.1 LTS
- PostgreSQL 18.4
- Adminer 5.4.2 Docker Official Image
- Docker Compose v2
- GNU Make и Bash для команд проекта и init-скриптов

Версии образов закреплены в `.docker.env`. Не используйте стенд как шаблон
production-развёртывания без отдельного анализа учётных данных, сетевой
доступности, хранения данных, резервного копирования и эксплуатации.

## Основные возможности

- Независимые сервисы MySQL и PostgreSQL, которые также работают одновременно.
- Общий для двух СУБД опциональный Adminer без зависимости от конкретного
  сервиса базы данных.
- Обязательная база `demo` в каждой СУБД с одинаковыми пятью пользователями.
- Опциональные Sakila и Chinook для MySQL, Pagila и Chinook для PostgreSQL.
- Раздельные bind-mounted data-, init- и sample-каталоги каждой СУБД.
- Общие учебные credentials и отдельные credentials администраторов СУБД.
- Статические проверки конфигурации, защита managed storage paths, runtime-
  проверки доступа и smoke-test импорта доверенного SQL.
- Явное подтверждение destructive-команд очистки и переинициализации.

## Требования

- Docker Engine или Docker Desktop с командой `docker compose` v2.
- GNU Make, Bash и стандартные Unix-утилиты, используемые скриптами (`awk`,
  `sed`, `grep`, `find`, `realpath` и `stat`).
- Для загрузки optional samples: `curl` и `git`; для MySQL samples также нужны
  `unzip` и `sha256sum`.

Выполняйте команды из корня репозитория. Ветка проекта по умолчанию — `master`.

## Быстрый старт

Создайте `.docker.env` из отслеживаемого примера, проверьте настроенные пути,
создайте рабочие каталоги и запустите полный стенд:

```bash
make init
make up
```

`make up` запускает MySQL, PostgreSQL и Adminer. С конфигурацией по умолчанию
Adminer доступен по адресу `http://127.0.0.1:8081`.

Полезные следующие команды:

```bash
make status
make logs
make down
```

`make down` удаляет контейнеры и сеть, но сохраняет bind-mounted данные СУБД.

## Режимы запуска

| Команда | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Запускает | Запускает | Запускает |
| `make up-no-ui` | Запускает или оставляет активным | Запускает или оставляет активным | Останавливает, если запущен |
| `make up-mysql` | Запускает | Не запускает автоматически | Не запускает автоматически |
| `make up-mysql-ui` | Запускает | Не запускает автоматически | Запускает |
| `make up-postgres` | Не запускает автоматически | Запускает | Не запускает автоматически |
| `make up-postgres-ui` | Не запускает автоматически | Запускает | Запускает |
| `make up-ui` | Не меняет состояние | Не меняет состояние | Запускает |
| `make down-ui` | Не меняет состояние | Не меняет состояние | Останавливает |

Команды одиночного запуска не останавливают другую уже работающую СУБД.
Adminer можно запускать и останавливать отдельно; он не привязан только к
MySQL.

## Подключения

### Adminer

Внутри Compose-сети Adminer предлагает два заранее заданных сервера:

```text
MySQL (mysql)
PostgreSQL (postgres)
```

Выберите сервер, затем укажите `DB_USER`, `DB_PASSWORD` и имя базы, например
`demo`. Имена сервисов `mysql` и `postgres` работают внутри Compose-сети; для
desktop-клиентов на хосте это не адреса серверов.

### Клиенты на хосте

DataGrip, DBeaver, PhpStorm и host CLI подключаются через опубликованный адрес
и порт:

| СУБД | Хост по умолчанию | Переменная порта | Пользователь | База по умолчанию |
|---|---|---|---|---|
| MySQL | `127.0.0.1` | `MYSQL_PORT` | `DB_USER` | `demo` |
| PostgreSQL | `127.0.0.1` | `POSTGRES_PORT` | `DB_USER` | `demo` |

Если вы изменили `BIND_ADDRESS`, при необходимости используйте вместо
`127.0.0.1` доступный адрес этого интерфейса.

### CLI в контейнерах

Make-targets передают пароли через environment контейнера и не помещают их в
историю shell:

```bash
make mysql          # администратор MySQL, база demo
make mysql-user     # DB_USER, база demo
make postgres       # superuser PostgreSQL, база demo
make postgres-user  # DB_USER, база demo
```

## Учётные данные

При копировании `.docker.env.example` создаётся `.docker.env`; этот файл
исключён из Git. Храните пароли в нём и не хардкодьте их в Compose, SQL или
отслеживаемой конфигурации клиентов.

| Назначение | Настройка пользователя | Настройка пароля |
|---|---|---|
| Общий учебный пользователь двух СУБД | `DB_USER` | `DB_PASSWORD` |
| Администратор MySQL | `root` | `MYSQL_ROOT_PASSWORD` |
| Администратор/superuser PostgreSQL | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` и `DB_USER` должны быть разными ролями. Для обычных
упражнений используйте общего учебного пользователя, а не root или superuser.
Замените пароли из примера до предоставления общего доступа или публикации
любого сервиса за пределами локального компьютера.

## Порты и `BIND_ADDRESS`

Порты хоста настраиваются в `.docker.env`:

| Сервис | Переменная порта | Значение примера |
|---|---|---|
| MySQL | `MYSQL_PORT` | `3306` |
| PostgreSQL | `POSTGRES_PORT` | `5432` |
| Adminer | `ADMINER_PORT` | `8081` |

По умолчанию все три сервиса публикуются только на loopback:

```env
BIND_ADDRESS=127.0.0.1
```

Это безопасный default для локального стенда. Значение
`BIND_ADDRESS=0.0.0.0` публикует настроенные порты на всех сетевых интерфейсах.
Для доступа через VPN или LAN предпочтительнее адрес конкретного интерфейса.
Меняйте binding осознанно, учитывая правила firewall, надёжность паролей и
доверие ко всем подключённым сетям.

## Учебные базы

### Обязательные базы `demo`

Обе СУБД инициализируют обязательную базу с именем `demo`:

- MySQL: `demo.demo_users`
- PostgreSQL: `demo.public.demo_users`

Таблицы содержат эквивалентные поля `id`, `name`, `email`, `created_at` и
одинаковые пять обязательных пользователей: Alice, Bob, Carol, Dave и Eve.
Проверки допускают дополнительные строки, созданные пользователем.

Имена баз по умолчанию задаются как `MYSQL_DATABASE=demo` и
`POSTGRES_DATABASE=demo`; `make check-env` требует именно эти значения.

### Необязательные учебные базы

| СУБД | Необязательные базы | Команда подготовки |
|---|---|---|
| MySQL | Chinook, Sakila | `make samples-mysql` |
| PostgreSQL | Pagila, Chinook | `make samples-postgres` |

Команды подготовки загружают и проверяют закреплённые upstream-файлы, но не
запускают контейнеры и не импортируют данные в уже инициализированную СУБД.
Загрузки остаются локальными, исключаются из Git и сохраняются в
`MYSQL_SAMPLES_DIR` или `POSTGRES_SAMPLES_DIR`. Происхождение, integrity pins и
лицензии описаны в [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

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

## Команды Makefile

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

## Жизненный цикл данных и init

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

## Backup, очистка и переинициализация

Встроенные backup-targets работают только с настроенной MySQL-базой `demo`:

```bash
make dump
make restore
```

С конфигурацией по умолчанию `make dump` записывает `backup/demo.sql`.
`make restore` читает этот файл и повторно применяет учебные MySQL grants. Для
сохранения PostgreSQL используйте отдельную процедуру резервного копирования.

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

## Диагностика и решение проблем

### Ошибка конфигурации или storage-path validation

Выполните `make check-env` и найдите в ошибке отклонённую переменную и путь.
Managed data paths должны находиться строго внутри каталога проекта `data/`, а
sample paths — внутри `samples/`. Они не могут содержать symlink-компоненты,
пересекаться между собой или использовать зарезервированные каталоги проекта.
Исправьте `.docker.env`, затем повторите `make check-env` и `make config`.

### Сервис не переходит в состояние готовности

До изменения данных проверьте состояние и логи:

```bash
make status
make log SERVICE=mysql
make log SERVICE=postgres
```

Убедитесь, что Docker запущен, настроенный host port свободен, а
`.docker.env` содержит обязательные значения. Исправьте конкретную настройку
или конфликт порта и снова запустите сервис.

### Изменения init или optional samples не появились

Для уже инициализированного data-каталога это ожидаемое поведение. Проверьте
настроенные data- и sample-пути и успешность команды подготовки. Если
существующие данные важны, сохраните их. Используйте соответствующую команду
`reinit-... CONFIRM=1` только как осознанную последнюю меру: она удаляет данные
этой СУБД.

### Optional sample неполон или имеет неожиданного владельца

Loader намеренно не перезаписывает и не исправляет неожиданную базу. Повторите
подходящую подготовку `make samples-mysql` или `make samples-postgres` и
изучите ошибку. Сохраните нужные данные, прежде чем рассматривать
переинициализацию с подтверждением.

### Клиент не подключается

Клиенты на хосте используют опубликованный host address и `MYSQL_PORT` или
`POSTGRES_PORT`, а не имя Compose-сервиса. Adminer использует `mysql` или
`postgres` внутри Compose-сети. Проверьте `BIND_ADDRESS`, firewall, выбранную
базу и неадминистративные credentials `DB_USER`.

## Лицензии и сторонние компоненты

Docker SQL Lab распространяется по лицензии MIT; см.
[LICENSE.md](LICENSE.md). Optional sample-базы сохраняют upstream-лицензии и
уведомления; источники, закреплённые ревизии, integrity information и тексты
лицензий приведены в [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

---

<p align="center">
  <a href="https://yaleksandr89.github.io/" title="yaleksandr89.github.io">
    <img
      src="docs/assets/ya-logo-dark-50px.png"
      alt="YA"
      width="32"
    >
  </a>
  <br>
  <strong>Александр Юрченко</strong> ·
  <a href="https://yaleksandr89.github.io/">yaleksandr89.github.io</a>
</p>
