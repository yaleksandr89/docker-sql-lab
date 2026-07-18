# SQL Lab (Docker)

Локальный учебный SQL-стенд на Docker Compose с независимыми сервисами:

- MySQL 9.7.1 LTS;
- PostgreSQL 18.4 — последняя стабильная major-ветка с пятилетним сроком
  поддержки;
- один опциональный Adminer Docker Official Image 5.4.2 для обеих СУБД.

Upstream Adminer уже выпускает 5.4.4, но официальный Docker image пока
закреплён на 5.4.2. Поэтому стенд использует точный официальный тег 5.4.2 и не
собирает собственный образ только ради расхождения версий.

В MySQL и PostgreSQL всегда создаётся небольшая база `demo`. Для MySQL
опционально доступны Sakila и Chinook, для PostgreSQL — Pagila и та же
Chinook. Это позволяет сравнивать запросы к одинаковой учебной модели в двух
СУБД.

## Быстрый старт

Полный стенд с Adminer:

```bash
make init
make up
```

Полный стенд без UI:

```bash
make up-no-ui
```

Одиночные режимы:

```bash
make up-mysql
make up-mysql-ui
make up-postgres
make up-postgres-ui
```

Adminer можно добавить к уже работающим СУБД или остановить отдельно:

```bash
make up-ui
make down-ui
```

Команды одиночного запуска не останавливают уже работающие сервисы. Они лишь
не запускают другие сервисы автоматически.

## Режимы запуска

| Команда | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | запускает | запускает | запускает |
| `make up-no-ui` | запускает или оставляет активным | запускает или оставляет активным | останавливает, если запущен |
| `make up-mysql` | запускает | не запускает автоматически | не запускает автоматически |
| `make up-mysql-ui` | запускает | не запускает автоматически | запускает |
| `make up-postgres` | не запускает автоматически | запускает | не запускает автоматически |
| `make up-postgres-ui` | не запускает автоматически | запускает | запускает |
| `make up-ui` | не меняет состояние | не меняет состояние | запускает |
| `make down-ui` | не меняет состояние | не меняет состояние | останавливает |

`make up-no-ui` не выполняет общий `docker compose down`: сначала он
останавливает только Adminer, затем запускает или оставляет запущенными обе
СУБД и ждёт их готовности.

## Порты

Порты задаются в `.docker.env`:

| Сервис | Переменная | Значение по умолчанию |
|---|---|---|
| MySQL | `MYSQL_PORT` | `3306` |
| PostgreSQL | `POSTGRES_PORT` | `5432` |
| Adminer | `ADMINER_PORT` | `8081` |

При значениях по умолчанию Adminer открыт на
`http://127.0.0.1:8081`.

## Credentials

`.docker.env.example` содержит только локальные учебные значения:

| Назначение | Пользователь | Пароль |
|---|---|---|
| Администратор MySQL | `MYSQL_ROOT_PASSWORD` задаёт пароль пользователя `root` | `MYSQL_ROOT_PASSWORD` |
| Администратор PostgreSQL | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |
| Общий учебный пользователь | `DB_USER` | `DB_PASSWORD` |

Административная PostgreSQL-роль и `DB_USER` обязаны различаться. Реальный
`.docker.env` исключён из Git.

Значения из примера нельзя использовать в production, публичном окружении или
на доступном извне сервере.

## Один Adminer для двух СУБД

Adminer находится в общей Compose-сети с MySQL и PostgreSQL, не зависит от их
состояния и включается профилем `ui`. Это лёгкий optional UI с дизайном
`nette`; без профиля он не запускается и не расходует ресурсы.

Plugin `adminer/plugins-enabled/001-login-servers.php` заменяет свободный ввод
движка и сервера выпадающим списком из двух допустимых подключений:

```text
MySQL (mysql)
PostgreSQL (postgres)
```

Невалидный default server `db` в форме отсутствует. Пользователь выбирает
одно подключение, затем вводит общий `DB_USER`/`DB_PASSWORD` и базу.

Страница входа содержит локальную подсказку: выбрать MySQL или PostgreSQL,
использовать значения `DB_USER`/`DB_PASSWORD` из `.docker.env` и базу `demo`.
После отдельной подготовки samples доступны также Sakila и Chinook для MySQL,
Pagila и Chinook для PostgreSQL.

Вход в MySQL:

```text
Server: MySQL (mysql)
Username: значение DB_USER
Password: значение DB_PASSWORD
Database: demo, sakila, chinook или пустое поле
```

Вход в PostgreSQL:

```text
Server: PostgreSQL (postgres)
Username: значение DB_USER
Password: значение DB_PASSWORD
Database: demo, pagila или chinook, если optional sample установлен
```

Имена `mysql` и `postgres` применяются только внутри Docker-сети.

## Внешние клиенты

Полноценные IDE-клиенты — PhpStorm, DataGrip, DBeaver — и CLI на хосте
подключаются к `127.0.0.1` и опубликованному порту, а не к имени
Compose-сервиса.

MySQL:

```text
Host: 127.0.0.1
Port: значение MYSQL_PORT
User: значение DB_USER
Password: значение DB_PASSWORD
Database: demo, sakila или chinook, если optional sample установлен
```

PostgreSQL:

```text
Host: 127.0.0.1
Port: значение POSTGRES_PORT
User: значение DB_USER
Password: значение DB_PASSWORD
Database: demo, pagila или chinook, если optional sample установлен
```

CLI внутри контейнеров не требует размещать пароль в shell history:

```bash
make mysql
make mysql-user
make postgres
make postgres-user
```

## Учебные базы

MySQL:

- `demo` — обязательная база с таблицей `demo.demo_users`;
- `sakila` — опциональная официальная учебная база;
- `chinook` — опциональная база с музыкальным каталогом и продажами.

PostgreSQL:

- `demo` — обязательная база с таблицей `public.demo_users`;
- `pagila` — опциональный PostgreSQL-порт Sakila с фильмами, актёрами,
  клиентами и прокатом;
- `chinook` — та же модель музыкального каталога и продаж, что в MySQL.

Обе таблицы `demo_users` имеют одинаковую смысловую структуру:

| Поле | Назначение |
|---|---|
| `id` | автоматически создаваемый integer primary key |
| `name` | `varchar(100) NOT NULL` |
| `email` | `varchar(150) NOT NULL UNIQUE` |
| `created_at` | обязательный timestamp с `CURRENT_TIMESTAMP` по умолчанию |

MySQL использует `TIMESTAMP`, PostgreSQL — `timestamptz`. В обе базы
идемпотентно добавляются одинаковые обязательные строки:

| Name | Email | Created at |
|---|---|---|
| Alice | `alice@example.com` | `2025-01-10 09:00:00+03` |
| Bob | `bob@example.com` | `2025-01-11 10:15:00+03` |
| Carol | `carol@example.com` | `2025-01-12 11:30:00+03` |
| Dave | `dave@example.com` | `2025-01-13 12:45:00+03` |
| Eve | `eve@example.com` | `2025-01-14 14:00:00+03` |

Дополнительные пользовательские строки разрешены и не считаются ошибкой при
проверках.

Обычные `make init`, `make up`, `make up-no-ui`, `make up-mysql` и
`make up-postgres` не скачивают и не подготавливают optional samples. Обе СУБД
полностью работоспособны только с обязательной `demo`.

## Optional samples MySQL

Скачать Chinook и официальный архив Sakila и подготовить локальные SQL-файлы:

```bash
make samples-mysql
```

Для нового пустого каталога данных:

```bash
make samples-mysql
make up-mysql
```

Для уже инициализированного MySQL:

```bash
make samples-mysql
make reinit-mysql CONFIRM=1
```

MySQL выполняет init-файлы только при первом запуске с пустым
`MYSQL_DATA_DIR`. Загрузка samples не изменяет данные и не перезапускает
контейнеры автоматически.

`make samples-mysql` больше не скачивает World. Файлы сохраняются
детерминированно:

```text
samples/mysql/
├── .gitkeep
├── 010_chinook.sql
├── 020_sakila_schema.sql
└── 021_sakila_data.sql
```

Эти загруженные SQL-файлы считаются локально сгенерированными и исключены из
Git. `initdb/mysql/050_load_optional_samples.sh` пропускает отсутствующие
samples, безопасно пропускает уже полную `chinook` и прекращает init с ошибкой
при неполной/неожиданной `chinook` или неполной паре schema/data Sakila.

## Optional samples PostgreSQL: Pagila и Chinook

Подготовить Pagila и Chinook отдельной явной командой:

```bash
make samples-postgres
```

Для существующей локальной установки `.docker.env` не перезаписывается
автоматически: добавьте в него вручную
`POSTGRES_SAMPLES_DIR=./samples/postgres`.

Для нового пустого каталога данных:

```bash
make samples-postgres
make up-postgres
```

Для уже инициализированного PostgreSQL требуется явное пересоздание только его
data-каталога:

```bash
make samples-postgres
make reinit-postgres CONFIRM=1
```

`make samples-postgres` только скачивает и проверяет SQL обеих баз: команда не
запускает контейнеры, не удаляет данные и не выполняет reinit. Официальный
PostgreSQL entrypoint читает `/docker-entrypoint-initdb.d` лишь при
инициализации пустого `POSTGRES_DATA_DIR`, поэтому добавление файлов не меняет
существующую базу.

Используется upstream
[`devrimgunduz/pagila`](https://github.com/devrimgunduz/pagila), закреплённый
на immutable commit
[`5ba5a57aeb159f75f02aca2432d3c262186d13d3`](https://github.com/devrimgunduz/pagila/commit/5ba5a57aeb159f75f02aca2432d3c262186d13d3).
Загружаются только `pagila-schema.sql` и COPY-вариант `pagila-data.sql`;
альтернативный insert-файл не используется. Точный текст `LICENSE.txt`
закреплённой ревизии проверяется по Git blob SHA и переносится в оба
подготовленных SQL-файла. Upstream README называет лицензию PostgreSQL License;
полный notice и provenance приведены в
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

Проверенная ревизия Pagila использует схему `public`, стандартные
PL/pgSQL-функции и `COPY FROM stdin`; дополнительных extensions, пакетов или
собственного Docker image не требуется. Подготовленные файлы сохраняются
детерминированно:

```text
samples/postgres/
├── 010_pagila_schema.sql
├── 020_pagila_data.sql
└── 030_chinook.sql
```

Все файлы локальные и исключены из Git. Отсутствие пары Pagila безопасно
пропускается, а наличие только одного файла останавливает чистую инициализацию
с ошибкой. Chinook обрабатывается независимо: она также optional. Повторный
загрузчик отдельно пропускает уже полные Pagila и Chinook с ожидаемым
владельцем, но не удаляет и не исправляет автоматически неполную базу или
неверное владение. Для этого требуется явный
`make reinit-postgres CONFIRM=1`. Штатные команды очистки data-каталогов не
удаляют `samples/postgres`.

## Источник и безопасная подготовка Chinook

Оба варианта Chinook берутся только из официального upstream
[`lerocha/chinook-database`](https://github.com/lerocha/chinook-database) на
immutable commit
[`4a944a942426e1f3263fe539155fb7ef92b04b4a`](https://github.com/lerocha/chinook-database/commit/4a944a942426e1f3263fe539155fb7ef92b04b4a),
соответствующем release `v1.4.5`. Chinook распространяется по MIT license;
полный copyright и permission notice из закреплённого `LICENSE.md` добавляется
SQL-комментариями в каждую подготовленную локальную копию.

Upstream SQL нельзя выполнять напрямую: он содержит `DROP DATABASE`,
`CREATE DATABASE` и выбор базы. Команды подготовки проверяют Git blob SHA,
версию, целевую СУБД, ключевые таблицы и точный формат трёх setup-строк, затем
удаляют только эти известные строки. Готовый SQL повторно проверяется на
отсутствие database-level setup и публикуется атомарно вместе с остальными
sample-файлами. Он загружается только в заранее выбранную базу `chinook`.

Chinook выбрана вместо MySQL World, потому что upstream явно указывает MIT
license и предоставляет одинаковые MySQL/PostgreSQL datasets. Существующая
база `world` автоматически не удаляется. Чтобы убрать старую `world` и
получить `chinook` в уже инициализированном MySQL, сначала подготовьте samples,
затем осознанно выполните `make reinit-mysql CONFIRM=1`; эта команда удалит
данные только MySQL.

## Инициализация и порядок файлов

```text
initdb/
├── mysql/
│   ├── 001_demo.sql
│   ├── 030_training_database.sql.example
│   ├── 050_load_optional_samples.sh
│   ├── 090_grant_training_access.sh
│   └── 099_check_training_access.sh
└── postgres/
    ├── 001_create_training_role.sh
    ├── 010_initialize_demo.sh
    ├── 030_training_database.sh.example
    ├── 050_load_optional_samples.sh
    └── 099_check_training_access.sh
```

Файлы `.example` служат шаблонами и не выполняются entrypoint автоматически.
MySQL-шаблон показывает добавление новой базы перед grants. PostgreSQL-шаблон
безопасно передаёт значения через psql variables, назначает `DB_USER`
владельцем новой базы и создаёт начальную таблицу от его имени.

Оба официальных entrypoint обрабатывают init-каталог только для пустого
data-каталога. Изменение init-файлов не обновляет существующую базу.

## Конфигурация СУБД

```text
conf/
├── mysql/
│   └── my.cnf
└── postgres/
    └── postgresql.conf.example
```

`conf/mysql/my.cnf` подключается к MySQL и фиксирует `utf8mb4`, collation
`utf8mb4_0900_ai_ci`, строгий SQL mode с `ONLY_FULL_GROUP_BY`, часовой пояс
`+03:00` и отключение DNS lookup клиентов. Performance-настройки оставлены
только понятными закомментированными примерами: универсальных значений для
лимитов памяти, соединений и slow query log нет.

`conf/postgres/postgresql.conf.example` полностью закомментирован и
автоматически к Compose не подключается. Он показывает, как ресурсы и тип
нагрузки влияют на `shared_buffers`, `work_mem`, `maintenance_work_mem` и
временную диагностику медленных запросов. Активного PostgreSQL performance
tuning и отдельного logging collector нет: сервер продолжает писать в штатные
Docker logs.

## Права учебного пользователя

В MySQL `090_grant_training_access.sh` создаёт или обновляет `DB_USER` и
выдаёт ему `ALL PRIVILEGES` отдельно на каждую фактически существующую
несистемную базу. Глобальные административные права на `*.*` не выдаются.

В PostgreSQL роль `DB_USER` получает `LOGIN`, владеет обязательной базой
`demo` и схемой `public`, но остаётся без `SUPERUSER`, `CREATEDB`,
`CREATEROLE`, `REPLICATION` и `BYPASSRLS`. Таблица `demo_users` создаётся от
имени этой роли. Если подготовлена Pagila, база создаётся с владельцем
`DB_USER`, а schema и data загружаются от его имени. Закреплённый upstream dump
содержит `OWNER TO postgres`; загрузчик безопасно заменяет эти фиксированные
owner-выражения на quoted psql-переменную `DB_USER`, не меняя локальные
SQL-файлы и не повышая права роли. PostgreSQL Chinook также создаётся с
владельцем `DB_USER`; этой роли принадлежат схема `public`, таблицы и все
созданные в ней последовательности, представления, функции и пользовательские
типы. Пароли не хардкодятся и берутся только из environment контейнеров.

## Проверки

Проверка каждой СУБД отдельно:

```bash
make check-mysql-access
make check-postgres-access
```

MySQL-проверка требует `demo.demo_users`, все пять обязательных email,
проверяет temporary read/write и пробный откатываемый `INSERT` в `demo_users`.
Она также проверяет доступ ко всем существующим пользовательским базам и
`sakila.actor` только при наличии sample. Для optional Chinook отдельно
проверяются таблицы с точным регистром `Artist`, `Album`, `Track`, `Customer`,
`Invoice`, данные, join и откатываемая запись.

PostgreSQL-проверка подключается как `DB_USER` по TCP к работающему серверу,
проверяет владение базой и `demo_users`, все пять обязательных email, создаёт
временную таблицу, записывает и читает строку, выполняет откатываемый `INSERT`
в `demo_users` и подтверждает отсутствие всех административных атрибутов роли.
Наличие Pagila и Chinook определяется независимо по фактическим базам, а не по
sample-файлам. Для каждой установленной базы дополнительно проверяются
владелец, ожидаемые таблицы и владельцы объектов, данные, читающий join,
временный объект и откатываемый `INSERT` без остаточных данных. Поэтому
поддерживаются все варианты: только `demo`, `demo + pagila`,
`demo + chinook`, `demo + pagila + chinook`.

Для полного стенда:

```bash
make check
```

Команда проверяет Compose-конфигурацию и фактический доступ `DB_USER` к обеим
СУБД.

## Troubleshooting optional Chinook

Если загрузчик сообщает, что `chinook` уже существует, но неполна или имеет
неожиданного владельца, он намеренно ничего не удаляет и не пытается исправить
базу поверх существующих объектов. Проверьте, что sample подготовлен текущей
командой `make samples-mysql` или `make samples-postgres`, сохраните нужные
данные, затем при необходимости явно выполните reinit соответствующей СУБД с
`CONFIRM=1`. Reinit удаляет data-каталог выбранной СУБД; обычные `make up*`
этого не делают.

Если подготовленный `010_chinook.sql` или `030_chinook.sql` отклонён до
загрузки, не запускайте raw upstream SQL вручную. Повторите подготовку и
проверьте сеть; несовпадение Git blob SHA или формата setup-строк считается
ошибкой безопасности.

## Остановка и очистка данных

Остановить все сервисы без удаления bind-mounted данных:

```bash
make down
```

Удаление данных всегда требует явного `CONFIRM=1`:

```bash
make clean-mysql CONFIRM=1
make clean-postgres CONFIRM=1
make clean-all CONFIRM=1
```

Первые две команды удаляют только каталог соответствующей СУБД. `clean-all`
удаляет только `data/mysql` и `data/postgres`. `.docker.env`, конфигурация,
init-файлы, optional samples и backup сохраняются. Перед удалением проверяется,
что data-каталог находится внутри проекта; пустой каталог возвращается
текущему UID/GID.

Чистая инициализация с последующей проверкой:

```bash
make reinit-mysql CONFIRM=1
make reinit-postgres CONFIRM=1
make reinit-all CONFIRM=1
```

Одиночные команды запускают только выбранную СУБД без Adminer. `reinit-all`
запускает обе СУБД без Adminer и выполняет общую проверку.

## Основные команды

| Команда | Назначение |
|---|---|
| `make init` | Создать `.docker.env`, data/init/samples-каталоги и проверить скрипты |
| `make pull` | Скачать три образа |
| `make config` | Проверить итоговую Compose-конфигурацию |
| `make samples-mysql` | Подготовить optional Chinook и Sakila без запуска контейнеров |
| `make samples-postgres` | Подготовить optional Pagila и Chinook без запуска контейнеров |
| `make status` | Показать MySQL, PostgreSQL и профильный Adminer |
| `make logs` | Смотреть общие логи |
| `make log postgres` | Смотреть лог выбранного сервиса (`SERVICE=postgres` также поддерживается) |
| `make in postgres` | Открыть shell выбранного контейнера (`SERVICE=postgres` также поддерживается) |
| `make wait-mysql` | Дождаться MySQL |
| `make wait-postgres` | Дождаться PostgreSQL |
| `make mysql-grants` | Повторно применить MySQL grants |
| `make mysql-import FILE=... DATABASE=...` | Импортировать доверенный text SQL в существующую MySQL-базу от `DB_USER` |
| `make postgres-import FILE=... DATABASE=...` | Импортировать доверенный text SQL в существующую PostgreSQL-базу от `DB_USER` |
| `make dump` / `make restore` | Создать / восстановить backup MySQL `demo` |

## Импорт доверенных SQL-файлов

Поддерживаются обычные локальные текстовые SQL-файлы. Архивы, gzip и
PostgreSQL custom-format backups этими командами не обрабатываются.

Для обеих СУБД обязательны `FILE` и `DATABASE`:

```bash
make mysql-import FILE=path/to/file.sql DATABASE=demo
make postgres-import FILE=path/to/file.sql DATABASE=demo
```

Файл должен существовать, быть читаемым и непустым. Имя базы должно начинаться
со строчной латинской буквы и содержать только строчные латинские буквы, цифры
и `_`. Системные базы запрещены.

Указанная база должна уже существовать, а `DB_USER` должен иметь возможность
подключиться к ней. Импорт выполняется от `DB_USER`, а не от MySQL root или
PostgreSQL superuser. Команды не создают и не пересоздают базу, не удаляют её
автоматически и не применяют административные grants.

Используйте эти цели только для доверенных SQL-файлов. `DATABASE` задаёт базу
подключения по умолчанию, но не создаёт изолированный sandbox. SQL может
обращаться к другим доступным объектам и базам через qualified names, смену
подключения или клиентские команды, если это разрешено фактическими правами
`DB_USER`.

Импорт может изменить или удалить доступные пользователю объекты и данные.
Полный rollback при ошибке не гарантируется: часть команд может успеть
выполниться. Перед важным импортом создайте backup и предварительно проверьте
содержимое файла.

## Структура данных и Git

Данные СУБД разделены:

```text
data/
├── mysql/
└── postgres/
```

Контейнеры могут присвоить файлам числовые UID/GID своих системных
пользователей. Не редактируйте содержимое data-каталогов вручную.

Для официального образа PostgreSQL 18 host-каталог `data/postgres` подключён к
`/var/lib/postgresql`; фактический versioned data directory образ создаёт
внутри этого bind mount.

В Git не должны попадать:

```text
.docker.env
.env
data/
backup/
.tmp/
samples/mysql/*.sql
samples/postgres/*.sql
```

Обязательные init-скрипты и оба шаблона `.example` остаются отслеживаемыми.

---

Автор: **Александр Юрченко**

Лицензия проекта: [MIT](LICENSE.md). Условия сторонних optional samples:
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
