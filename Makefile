###############################################################################
# Makefile — MySQL Trainer
# Управление локальным MySQL-стендом и учебными базами
###############################################################################

SHELL := bash
.DEFAULT_GOAL := help

.PHONY: help init check-env samples pull config up wait-mysql down restart \
        reset status logs log in mysql mysql-user sh dump restore \
        mysql-grants mysql-import check check-mysql-access clean-mysql \
        reinit-mysql

# -----------------------------------------------------------------------------
# Основные переменные
# -----------------------------------------------------------------------------
PROJECT_DIR := $(CURDIR)
ENV_FILE_EXAMPLE := .docker.env.example
ENV_FILE := .docker.env
HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)

REQUIRED_ENV_VARS := COMPOSE_PROJECT_NAME MYSQL_VERSION ADMINER_VERSION \
                     MYSQL_CONTAINER ADMINER_CONTAINER MYSQL_PORT ADMINER_PORT \
                     MYSQL_DATA_DIR MYSQL_CONF_FILE INITDB_DIR MYSQL_DATABASE \
                     MYSQL_ROOT_PASSWORD DB_USER DB_PASSWORD

LOAD_ENV = set -a; source "$(ENV_FILE)"; set +a;
COMPOSE = docker compose --env-file "$(ENV_FILE)" -p "$$(awk -F= '$$1 == "COMPOSE_PROJECT_NAME" { print substr($$0, index($$0, "=") + 1); exit }' "$(ENV_FILE)")"

# -----------------------------------------------------------------------------
# Справка и инициализация окружения
# -----------------------------------------------------------------------------
help:
	@echo "Основные команды:"
	@echo "  make init                         создать .docker.env и рабочие каталоги"
	@echo "  make pull                         скачать образы MySQL и Adminer"
	@echo "  make up                           запустить MySQL и Adminer"
	@echo "  make down                         остановить сервисы без удаления данных"
	@echo "  make status                       показать состояние контейнеров"
	@echo "  make check                        проверить Compose и доступ DB_USER"
	@echo "  make mysql-grants                 выдать DB_USER права на все учебные базы"
	@echo "  make mysql-import FILE=path.sql   импортировать базу, выдать права и проверить"
	@echo "  make clean-mysql CONFIRM=1        удалить только данные MySQL"
	@echo "  make reinit-mysql CONFIRM=1       полностью переинициализировать MySQL"

$(ENV_FILE): $(ENV_FILE_EXAMPLE)
	@cp "$(ENV_FILE_EXAMPLE)" "$(ENV_FILE)"
	@echo "Создан $(ENV_FILE) из $(ENV_FILE_EXAMPLE)."

check-env: $(ENV_FILE)
	@if grep -qE '^(MYSQL_USER|MYSQL_PASSWORD)=' "$(ENV_FILE)"; then \
		echo "ERROR: замените MYSQL_USER/MYSQL_PASSWORD на DB_USER/DB_PASSWORD в $(ENV_FILE)" >&2; \
		exit 1; \
	fi
	@for variable_name in $(REQUIRED_ENV_VARS); do \
		if ! awk -v name="$$variable_name" '\
			index($$0, name "=") == 1 && length(substr($$0, length(name) + 2)) > 0 { found = 1 } \
			END { exit(found ? 0 : 1) }' "$(ENV_FILE)"; then \
			echo "ERROR: переменная $$variable_name не задана или пуста в $(ENV_FILE)" >&2; \
			exit 1; \
		fi; \
	done

init: check-env
	@echo "Проверяем каталоги и конфигурацию..."
	@$(LOAD_ENV) \
	for directory in "$${MYSQL_DATA_DIR}" "$$(dirname "$${MYSQL_CONF_FILE}")" "$${INITDB_DIR}"; do \
		if [[ -n "$$directory" && ! -d "$$directory" ]]; then \
			mkdir -p "$$directory"; \
			echo "Создан каталог: $$directory"; \
		fi; \
	done; \
	test -f "$${MYSQL_CONF_FILE}" || { echo "ERROR: не найден $${MYSQL_CONF_FILE}" >&2; exit 1; }; \
	test -x "$${INITDB_DIR}/090_grant_training_access.sh" || { echo "ERROR: grant-скрипт отсутствует или не исполняемый" >&2; exit 1; }; \
	test -x "$${INITDB_DIR}/099_check_training_access.sh" || { echo "ERROR: check-скрипт отсутствует или не исполняемый" >&2; exit 1; }

# -----------------------------------------------------------------------------
# Docker Compose
# -----------------------------------------------------------------------------
pull: check-env
	@$(LOAD_ENV) \
	echo "Скачиваем образы..."; \
	docker pull "mysql:$${MYSQL_VERSION}"; \
	docker pull "adminer:$${ADMINER_VERSION}"

config: check-env
	$(COMPOSE) config

up: init
	@echo "▶️  Запуск MySQL и Adminer..."
	$(COMPOSE) up -d
	@$(MAKE) --no-print-directory wait-mysql

wait-mysql: check-env
	@for ((attempt = 1; attempt <= 60; attempt++)); do \
		if $(COMPOSE) exec -T mysql sh -c 'MYSQL_PWD="$$MYSQL_ROOT_PASSWORD" mysqladmin ping -h 127.0.0.1 -uroot --silent' >/dev/null 2>&1; then \
			echo "✅ MySQL готов принимать подключения."; \
			exit 0; \
		fi; \
		sleep 2; \
	done; \
	echo "ERROR: MySQL не перешёл в готовое состояние" >&2; \
	$(COMPOSE) ps; \
	exit 1

down: check-env
	@echo "⏹️  Остановка сервисов..."
	$(COMPOSE) down

restart: check-env
	@echo "🔄 Перезапуск сервисов..."
	$(COMPOSE) restart
	@$(MAKE) --no-print-directory wait-mysql

reset:
	@echo "ERROR: неоднозначная цель reset отключена." >&2
	@echo "Используйте make restart или make reinit-mysql CONFIRM=1." >&2
	@exit 1

status: check-env
	@echo "📊 Состояние контейнеров:"
	$(COMPOSE) ps

logs: check-env
	$(COMPOSE) logs -f

# -----------------------------------------------------------------------------
# Доступ внутрь контейнеров
# -----------------------------------------------------------------------------
ifeq (in,$(firstword $(MAKECMDGOALS)))
  CONTAINER := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CONTAINER):;@: )
endif

in: check-env
	@test -n "$(CONTAINER)" || { echo "ERROR: пример использования: make in mysql" >&2; exit 1; }
	$(COMPOSE) exec $(CONTAINER) bash

mysql: wait-mysql
	$(COMPOSE) exec mysql sh -c 'MYSQL_PWD="$$MYSQL_ROOT_PASSWORD" mysql -uroot'

mysql-user: wait-mysql
	$(COMPOSE) exec mysql sh -c 'MYSQL_PWD="$$DB_PASSWORD" mysql -u"$$DB_USER"'

sh: check-env
	$(COMPOSE) exec mysql bash

ifeq (log,$(firstword $(MAKECMDGOALS)))
  CONTAINER := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CONTAINER):;@: )
endif

log: check-env
	@test -n "$(CONTAINER)" || { echo "ERROR: пример использования: make log mysql" >&2; exit 1; }
	$(COMPOSE) logs -f $(CONTAINER)

# -----------------------------------------------------------------------------
# Учебные базы и права
# -----------------------------------------------------------------------------
SAMPLES_TMP_DIR := .tmp/mysql-samples
WORLD_URL := https://downloads.mysql.com/docs/world-db.zip
SAKILA_URL := https://downloads.mysql.com/docs/sakila-db.zip

samples: check-env
	@command -v curl >/dev/null || { echo "ERROR: требуется curl" >&2; exit 1; }
	@command -v unzip >/dev/null || { echo "ERROR: требуется unzip" >&2; exit 1; }
	@$(LOAD_ENV) \
	echo "Скачиваем учебные базы World и Sakila..."; \
	rm -rf "$(SAMPLES_TMP_DIR)"; \
	mkdir -p "$(SAMPLES_TMP_DIR)/world" "$(SAMPLES_TMP_DIR)/sakila" "$${INITDB_DIR}"; \
	curl -fL "$(WORLD_URL)" -o "$(SAMPLES_TMP_DIR)/world-db.zip"; \
	curl -fL "$(SAKILA_URL)" -o "$(SAMPLES_TMP_DIR)/sakila-db.zip"; \
	unzip -q "$(SAMPLES_TMP_DIR)/world-db.zip" -d "$(SAMPLES_TMP_DIR)/world"; \
	unzip -q "$(SAMPLES_TMP_DIR)/sakila-db.zip" -d "$(SAMPLES_TMP_DIR)/sakila"; \
	cp "$(SAMPLES_TMP_DIR)/world/world-db/world.sql" "$${INITDB_DIR}/010_world.sql"; \
	cp "$(SAMPLES_TMP_DIR)/sakila/sakila-db/sakila-schema.sql" "$${INITDB_DIR}/020_sakila_schema.sql"; \
	cp "$(SAMPLES_TMP_DIR)/sakila/sakila-db/sakila-data.sql" "$${INITDB_DIR}/021_sakila_data.sql"; \
	rm -rf "$(SAMPLES_TMP_DIR)"; \
	echo "Подготовлены базы: demo, world, sakila."; \
	echo "SQL из initdb выполняется автоматически только на пустом MYSQL_DATA_DIR."

mysql-grants: wait-mysql
	$(COMPOSE) exec -T mysql /docker-entrypoint-initdb.d/090_grant_training_access.sh

mysql-import: wait-mysql
	@test -n "$(FILE)" || { echo "ERROR: укажите FILE=path/to/database.sql" >&2; exit 1; }
	@test -f "$(FILE)" || { echo "ERROR: файл $(FILE) не найден" >&2; exit 1; }
	@echo "Импортируем $(FILE) от имени root..."
	$(COMPOSE) exec -T mysql sh -c 'MYSQL_PWD="$$MYSQL_ROOT_PASSWORD" mysql -uroot' < "$(FILE)"
	@$(MAKE) --no-print-directory mysql-grants
	@$(MAKE) --no-print-directory check-mysql-access

check-mysql-access: wait-mysql
	$(COMPOSE) exec -T mysql /docker-entrypoint-initdb.d/099_check_training_access.sh

check: config check-mysql-access

# -----------------------------------------------------------------------------
# Бэкап и восстановление demo
# -----------------------------------------------------------------------------
dump: wait-mysql
	@mkdir -p backup
	@$(LOAD_ENV) \
	$(COMPOSE) exec -T mysql sh -c 'MYSQL_PWD="$$MYSQL_ROOT_PASSWORD" mysqldump -uroot --databases "$$MYSQL_DATABASE"' > "backup/$${MYSQL_DATABASE}.sql"; \
	echo "Бэкап сохранён: backup/$${MYSQL_DATABASE}.sql"

restore: wait-mysql
	@$(LOAD_ENV) \
	test -f "backup/$${MYSQL_DATABASE}.sql" || { echo "ERROR: нет backup/$${MYSQL_DATABASE}.sql" >&2; exit 1; }; \
	$(COMPOSE) exec -T mysql sh -c 'MYSQL_PWD="$$MYSQL_ROOT_PASSWORD" mysql -uroot' < "backup/$${MYSQL_DATABASE}.sql"
	@$(MAKE) --no-print-directory mysql-grants
	@echo "Восстановление завершено."

# -----------------------------------------------------------------------------
# Явный сброс данных MySQL
# -----------------------------------------------------------------------------
clean-mysql: check-env
	@test "$(CONFIRM)" = "1" || { echo "ERROR: команда удаляет MYSQL_DATA_DIR. Повторите с CONFIRM=1" >&2; exit 1; }
	@$(LOAD_ENV) \
	project_dir_abs="$$(realpath -m "$(PROJECT_DIR)")"; \
	data_dir_abs="$$(realpath -m "$${MYSQL_DATA_DIR}")"; \
	case "$${data_dir_abs}" in \
		"$${project_dir_abs}"/*) ;; \
		*) echo "ERROR: MYSQL_DATA_DIR должен находиться внутри проекта: $${data_dir_abs}" >&2; exit 1 ;; \
	esac; \
	data_dir_rel="$$(realpath --relative-to="$${project_dir_abs}" "$${data_dir_abs}")"; \
	echo "🗑️  Удаление данных MySQL: $${MYSQL_DATA_DIR}"; \
	$(COMPOSE) down --remove-orphans; \
	docker run --rm \
		--user 0:0 \
		--entrypoint sh \
		-e DATA_DIR_REL="$${data_dir_rel}" \
		-e HOST_UID="$(HOST_UID)" \
		-e HOST_GID="$(HOST_GID)" \
		-v "$${project_dir_abs}:/workspace" \
		"mysql:$${MYSQL_VERSION}" \
		-c 'rm -rf -- "/workspace/$${DATA_DIR_REL}" && mkdir -p "/workspace/$${DATA_DIR_REL}" && chown "$${HOST_UID}:$${HOST_GID}" "/workspace/$${DATA_DIR_REL}"'; \
	echo "✅ Данные MySQL удалены, пустой каталог возвращён пользователю $(HOST_UID):$(HOST_GID)."

reinit-mysql: clean-mysql
	@$(MAKE) --no-print-directory up
	$(COMPOSE) exec -T mysql /docker-entrypoint-initdb.d/099_check_training_access.sh
