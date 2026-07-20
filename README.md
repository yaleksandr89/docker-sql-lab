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

Локальный Docker Compose-стенд для практики SQL и знакомства с MySQL и
PostgreSQL. Каждую СУБД можно запускать отдельно или обе вместе. Компактная
`demo` создаётся автоматически, а optional Sakila, Pagila и Chinook дают
готовые данные для упражнений. Adminer подключается только при необходимости.

## Стек

- MySQL 9.7.1 LTS
- PostgreSQL 18.4
- Adminer 5.4.2 Docker Official Image
- Docker Compose v2
- GNU Make и Bash для команд проекта и init-скриптов

Закреплённые значения по умолчанию заданы в
[`.docker.env.example`](.docker.env.example); `make init` создаёт из него
локальный `.docker.env`. Сервисы описаны в
[`docker-compose.yml`](docker-compose.yml).

<details>
<summary>⚠️ Важно: это учебное окружение</summary>

Проект не является готовым production template. Для внешнего использования
нужны отдельные решения по credentials, network exposure, storage, backup и
operations.

</details>

## Основные возможности

- MySQL и PostgreSQL работают независимо или одновременно.
- Обязательная `demo` в каждой СУБД содержит одинаковые seed rows.
- Optional Sakila и Chinook доступны для MySQL, Pagila и Chinook — для
  PostgreSQL.
- Adminer — отдельный optional UI для обеих СУБД.
- Data-, init- и sample-каталоги СУБД разделены и подключены как bind mounts.
- Проверки конфигурации и доступа, trusted SQL imports и destructive-команды
  собраны в [`Makefile`](Makefile).

## Требования

1. Docker Engine или Docker Desktop с `docker compose` v2.
2. GNU Make, Bash и базовые Unix CLI utilities, используемые скриптами.

Рекомендуемая среда: Linux; macOS с Docker Desktop; Windows с Docker Desktop
и WSL2. Выполняйте команды из корня репозитория. Ветка проекта по умолчанию —
`master`.

## Быстрый старт

```bash
make init
make up
```

`make init` создаёт локальный `.docker.env` из отслеживаемого
[`.docker.env.example`](.docker.env.example), проверяет managed paths и
создаёт рабочие каталоги. При первом запуске official entrypoints
инициализируют обе СУБД. Даже без optional samples вы получите рабочие MySQL и
PostgreSQL с обязательной `demo` и seed rows.

`make up` запускает MySQL, PostgreSQL и Adminer; `make up-no-ui` — обе СУБД
без Adminer. С настройками по умолчанию Adminer доступен по адресу
`http://127.0.0.1:8081`.

Подробно о запуске, подключениях и credentials:
[Начало работы](docs/langs/ru/getting-started.md).

### Нужны готовые учебные данные?

Optional samples не обязательны: `demo` создаётся всегда; для MySQL доступны Sakila и Chinook, для PostgreSQL — Pagila и Chinook.

**Первый запуск, data-каталоги пусты**

```bash
make init
make samples-mysql
make samples-postgres
make up
```

Samples подготавливаются до первой инициализации; official entrypoints загрузят их вместе с `demo`.

> **Внимание:** если data-каталог уже инициализирован без samples, их добавление требует backup и подтверждённого destructive reinit.

<details>
<summary>Стенд уже запускался: добавить или повторно использовать samples</summary>

**Уже инициализировано без samples.** Обычный `make up` новые init/sample files не применит. Сначала сохраните важные данные, затем выполните нужный вариант:

- MySQL: `make samples-mysql`, затем `make reinit-mysql CONFIRM=1`.
- PostgreSQL: `make samples-postgres`, затем `make reinit-postgres CONFIRM=1`.
- Обе СУБД: `make samples-mysql`, `make samples-postgres`, затем `make reinit-all CONFIRM=1`.

> **Внимание:** `reinit-*` удаляет данные выбранной СУБД и выполняется только с точным `CONFIRM=1`.

**Samples уже установлены.** Используйте обычный `make up` или выбранный `make up-*`: повторные download и reinit не нужны, базы сохраняются в bind-mounted storage.

</details>

Подробнее: [Базы и samples](docs/langs/ru/databases.md).

## Режимы запуска

| Команда | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Запускает | Запускает | Запускает |
| `make up-no-ui` | Запускает | Запускает | Останавливает |
| `make up-mysql` | Запускает | Не запускает | Не запускает |
| `make up-postgres` | Не запускает | Запускает | Не запускает |

Команды одной СУБД не останавливают уже работающую другую; Adminer управляется
отдельно. Полный набор targets описан в [`Makefile`](Makefile).

## Подключения и доступные базы

Внутри Compose-сети Adminer использует серверы `mysql` и `postgres`. Клиенты на
хосте используют `127.0.0.1` и настроенные `MYSQL_PORT` или `POSTGRES_PORT`.
Для обычной работы укажите `DB_USER` и `DB_PASSWORD`.

| СУБД | Доступна всегда | После optional sample initialization |
|---|---|---|
| MySQL | `demo` | `sakila`, `chinook` |
| PostgreSQL | `demo` | `pagila`, `chinook` |

Имена optional баз действительны только после их фактической инициализации.
Подробности: [запуск и подключения](docs/langs/ru/getting-started.md) ·
[базы и samples](docs/langs/ru/databases.md).

## Кратко об учётных данных

| Назначение | Пользователь | Пароль |
|---|---|---|
| Общий учебный пользователь | `DB_USER` | `DB_PASSWORD` |
| Администратор MySQL | `root` | `MYSQL_ROOT_PASSWORD` |
| Superuser PostgreSQL | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` и `DB_USER` должны быть разными ролями. Для упражнений
используйте учебного пользователя и замените примерные пароли до публикации
сервисов.

## Базы и ключевые проверки

Обе `demo` содержат эквивалентную таблицу `demo_users` с пятью строками.
Статические проверки не требуют запущенных СУБД:

```bash
make check-env
make config
make test-storage-paths
```

После запуска `make check` проверяет `demo` и доступ `DB_USER`, а
`make test-sql-imports` — public trusted import targets. Порядок и ограничения:
[Проверки и операции](docs/langs/ru/operations.md).

## Безопасность и жизненный цикл

- `BIND_ADDRESS=127.0.0.1` публикует сервисы только на loopback.
- `BIND_ADDRESS=0.0.0.0` открывает их на всех интерфейсах: заранее настройте
  firewall, надёжные credentials и доверенную сеть.
- Official entrypoints выполняют init только для пустого data-каталога.
- `make mysql-import` и `make postgres-import` принимают только доверенный SQL.
  Это не sandbox: возможна частичная запись без полного automatic rollback.
  Перед важным импортом проверьте SQL-файл и сделайте подходящий backup.
- Встроенные `make dump` и `make restore` покрывают только MySQL `demo`;
  встроенного backup target для PostgreSQL нет.
- Все `clean-*` и `reinit-*` destructive и требуют точного `CONFIRM=1`.

Безопасные последовательности: [Проверки и операции](docs/langs/ru/operations.md).
При ошибках сначала соберите диагностику:
[Диагностика](docs/langs/ru/troubleshooting.md).

## Лицензии учебных данных

Optional sample datasets сохраняют лицензии и notices upstream projects.
Provenance, закреплённые revisions, integrity information и тексты лицензий
приведены в [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

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
  <a href="https://yaleksandr89.github.io/">yaleksandr89.github.io</a>
</p>
