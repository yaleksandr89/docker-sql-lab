# 🧠 MySQL тренажёр (Docker)

Локальный тренажёр для SQL-заданий.

---

## 🚀 Быстрый старт

```bash
make init        # создаст .docker.env и каталоги
make pull        # загрузит нужные образы
make up          # запустит mysql + adminer
```

Открой браузер → [http://localhost:8081](http://localhost:8081)  
**Adminer**

| Параметр | Значение |
|-----------|-----------|
| Сервер | mysql |
| Пользователь | student |
| Пароль | student |
| БД | demo |

---

## ⚙️ Настройки

- **MySQL:** 8.0.21
- **Adminer:** latest
- **Timezone:** Europe/Moscow
- **Encoding:** utf8mb4 / utf8mb4_0900_ai_ci
- **Strict SQL mode:** включён (строгие проверки)
- **initdb/**: SQL-файлы выполняются один раз при создании тома

---

## 📁 Структура проекта

```
.
├── docker-compose.yml
├── Makefile
├── .docker.env.example
├── conf/
│   └── my.cnf
├── initdb/
│   └── 001_init.sql
├── data/           # создаётся автоматически
└── backup/         # бэкапы по make dump
```

---

## 🛠 Команды Makefile

| Команда | Описание |
|----------|-----------|
| `make init` | Создать .docker.env и каталоги |
| `make pull` | Скачать образы |
| `make up` | Запустить контейнеры |
| `make down` | Остановить контейнеры |
| `make in mysql` | Зайти в bash MySQL контейнера |
| `make log mysql` | Посмотреть логи |
| `make dump` | Сделать SQL-бэкап |
| `make restore` | Восстановить из бэкапа |

---

## 💡 Полезно знать

- Если нужно «сбросить» БД — удали `./data/mysql/` и перезапусти `make up`.
- Можно добавлять `.sql`-файлы в `initdb/` для автозапуска при инициализации.
- PhpStorm легко подключается через `127.0.0.1:3306` (student/student).

---

Автор: **Александр Юрченко**  
Лицензия: MIT
