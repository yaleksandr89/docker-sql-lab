###############################################################################
# Makefile — SQL Lab
# Управление локальным учебным стендом MySQL, PostgreSQL и Adminer
###############################################################################

SHELL := bash
.DEFAULT_GOAL := help

.PHONY: help init check-env pull config up up-no-ui up-mysql up-mysql-ui \
        up-postgres up-postgres-ui up-ui down-ui wait-mysql wait-postgres \
        down status logs log in mysql mysql-user postgres postgres-user sh \
        samples-mysql samples-postgres mysql-grants mysql-import postgres-import check check-mysql-access \
        check-postgres-access dump restore clean-mysql clean-postgres clean-all \
        reinit-mysql reinit-postgres reinit-all test-storage-paths

PROJECT_DIR := $(CURDIR)
ENV_FILE_EXAMPLE := .docker.env.example
ENV_FILE := .docker.env
HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)

REQUIRED_ENV_VARS := COMPOSE_PROJECT_NAME MYSQL_VERSION POSTGRES_VERSION ADMINER_VERSION \
                     MYSQL_PORT POSTGRES_PORT ADMINER_PORT \
                     MYSQL_DATA_DIR POSTGRES_DATA_DIR MYSQL_CONF_FILE \
                     MYSQL_INITDB_DIR POSTGRES_INITDB_DIR MYSQL_SAMPLES_DIR POSTGRES_SAMPLES_DIR \
                     MYSQL_DATABASE POSTGRES_DATABASE MYSQL_ROOT_PASSWORD \
                     POSTGRES_SUPERUSER POSTGRES_SUPERUSER_PASSWORD DB_USER DB_PASSWORD

LOAD_ENV = set -a; source "$(ENV_FILE)"; set +a;
COMPOSE = docker compose --env-file "$(ENV_FILE)" -p "$$(awk -F= '$$1 == "COMPOSE_PROJECT_NAME" { print substr($$0, index($$0, "=") + 1); exit }' "$(ENV_FILE)")"
COMPOSE_UI = $(COMPOSE) --profile ui

MYSQL_SAMPLES_TMP_DIR := .tmp/mysql-samples
SAKILA_URL := https://downloads.mysql.com/docs/sakila-db.zip
SAKILA_SHA256 := c2ecb3dec28d752241ccfca02974ba970de3c3fc5d98887fd3f9d5843f946672
POSTGRES_SAMPLES_TMP_DIR := .tmp/postgres-samples
PAGILA_REF := 5ba5a57aeb159f75f02aca2432d3c262186d13d3
PAGILA_BASE_URL := https://raw.githubusercontent.com/devrimgunduz/pagila/$(PAGILA_REF)
PAGILA_LICENSE_URL := $(PAGILA_BASE_URL)/LICENSE.txt
PAGILA_LICENSE_BLOB := c6078c708c6f55b56e24f3687c591ca12df567ca
PAGILA_SCHEMA_BLOB := 23718a3adef90ced002e19ad4e1ac98d22aa5870
PAGILA_DATA_BLOB := b7c016861fd0f84008645153c6a1d9e5a99b9cc6
CHINOOK_REF := 4a944a942426e1f3263fe539155fb7ef92b04b4a
CHINOOK_BASE_URL := https://raw.githubusercontent.com/lerocha/chinook-database/$(CHINOOK_REF)
CHINOOK_LICENSE_URL := $(CHINOOK_BASE_URL)/LICENSE.md
CHINOOK_MYSQL_URL := $(CHINOOK_BASE_URL)/ChinookDatabase/DataSources/Chinook_MySql.sql
CHINOOK_POSTGRES_URL := $(CHINOOK_BASE_URL)/ChinookDatabase/DataSources/Chinook_PostgreSql.sql
CHINOOK_LICENSE_BLOB := 7487a9edc2d42e50d7a38ab1fbdba33ac63230f7
CHINOOK_MYSQL_BLOB := cdbd482f1be7fde54644480ec7c794ff2764b109
CHINOOK_POSTGRES_BLOB := d93a20d08239ac6bdd8a56601e148f5d4d048593

# Поддерживаются оба варианта: `make log mysql` (исторический интерфейс) и
# `make log SERVICE=mysql`. Второй positional goal становится no-op, чтобы он
# не запускал одноимённую интерактивную цель после выхода из log/in.
COMMAND_GOAL := $(firstword $(MAKECMDGOALS))
POSITIONAL_SERVICE := $(if $(filter in log,$(COMMAND_GOAL)),$(word 2,$(MAKECMDGOALS)))
SERVICE ?= $(POSITIONAL_SERVICE)

ifneq ($(strip $(POSITIONAL_SERVICE)),)
  ifneq ($(filter $(POSITIONAL_SERVICE),mysql postgres adminer),$(POSITIONAL_SERVICE))
    $(error неизвестный Compose-сервис: $(POSITIONAL_SERVICE))
  endif
  .PHONY: $(POSITIONAL_SERVICE)
  $(POSITIONAL_SERVICE):
	@:
endif

help:
	@echo "Основные команды:"
	@echo "  make init                         создать .docker.env и рабочие каталоги"
	@echo "  make pull                         скачать образы MySQL, PostgreSQL и Adminer"
	@echo "  make up                           запустить обе СУБД и Adminer"
	@echo "  make up-no-ui                     запустить обе СУБД и остановить Adminer"
	@echo "  make up-mysql[-ui]                запустить только MySQL, опционально с UI"
	@echo "  make up-postgres[-ui]             запустить только PostgreSQL, опционально с UI"
	@echo "  make up-ui / make down-ui         включить / остановить только Adminer"
	@echo "  make check                        проверить Compose и доступ DB_USER к обеим СУБД"
	@echo "  make samples-mysql                скачать optional samples Chinook и Sakila"
	@echo "  make samples-postgres             скачать optional samples Pagila и Chinook"
	@echo "  make test-storage-paths           проверить защиту managed storage paths"
	@echo "  make mysql-import FILE=... DATABASE=...   импортировать доверенный text SQL в MySQL"
	@echo "  make postgres-import FILE=... DATABASE=... импортировать доверенный text SQL в PostgreSQL"
	@echo "  make clean-{mysql,postgres,all} CONFIRM=1"
	@echo "  make reinit-{mysql,postgres,all} CONFIRM=1"

$(ENV_FILE):
	@cp "$(ENV_FILE_EXAMPLE)" "$(ENV_FILE)"
	@echo "Создан $(ENV_FILE) из $(ENV_FILE_EXAMPLE)."

check-env: $(ENV_FILE)
	@for variable_name in $(REQUIRED_ENV_VARS); do \
		if ! awk -v name="$$variable_name" '\
			index($$0, name "=") == 1 && length(substr($$0, length(name) + 2)) > 0 { found = 1 } \
			END { exit(found ? 0 : 1) }' "$(ENV_FILE)"; then \
			echo "ERROR: переменная $$variable_name не задана или пуста в $(ENV_FILE)" >&2; \
			exit 1; \
		fi; \
	done
	@$(LOAD_ENV) \
	if [[ "$${POSTGRES_SUPERUSER}" == "$${DB_USER}" ]]; then \
		echo "ERROR: POSTGRES_SUPERUSER и DB_USER должны быть разными ролями" >&2; \
		exit 1; \
	fi; \
	if [[ "$${MYSQL_DATABASE}" != "demo" || "$${POSTGRES_DATABASE}" != "demo" ]]; then \
		echo "ERROR: обязательные MYSQL_DATABASE и POSTGRES_DATABASE должны называться demo" >&2; \
		exit 1; \
	fi; \
	"$(PROJECT_DIR)/scripts/validate-storage-paths.sh" \
		--project-dir "$(PROJECT_DIR)" \
		--mysql-data "$${MYSQL_DATA_DIR}" \
		--postgres-data "$${POSTGRES_DATA_DIR}" \
		--mysql-samples "$${MYSQL_SAMPLES_DIR}" \
		--postgres-samples "$${POSTGRES_SAMPLES_DIR}"

test-storage-paths:
	@./scripts/test-storage-paths.sh

init: check-env
	@echo "Проверяем каталоги, конфигурацию и init-скрипты..."
	@$(LOAD_ENV) \
	for directory in \
		"$${MYSQL_DATA_DIR}" \
		"$${POSTGRES_DATA_DIR}" \
		"$$(dirname "$${MYSQL_CONF_FILE}")" \
		"$${MYSQL_INITDB_DIR}" \
		"$${POSTGRES_INITDB_DIR}" \
		"$${MYSQL_SAMPLES_DIR}" \
		"$${POSTGRES_SAMPLES_DIR}"; do \
		if [[ -n "$$directory" && ! -d "$$directory" ]]; then \
			mkdir -p "$$directory"; \
			echo "Создан каталог: $$directory"; \
		fi; \
	done; \
	test -f "$${MYSQL_CONF_FILE}" || { echo "ERROR: не найден $${MYSQL_CONF_FILE}" >&2; exit 1; }; \
	test -f "conf/postgres/postgresql.conf.example" || { echo "ERROR: не найден PostgreSQL config example" >&2; exit 1; }; \
	test -f "adminer/plugins-enabled/001-login-servers.php" || { echo "ERROR: не найден adminer/plugins-enabled/001-login-servers.php" >&2; exit 1; }; \
	test -f "adminer/plugins-enabled/002-login-help.php" || { echo "ERROR: не найден adminer/plugins-enabled/002-login-help.php" >&2; exit 1; }; \
	test -f "$${MYSQL_INITDB_DIR}/001_demo.sql" || { echo "ERROR: не найден обязательный MySQL init" >&2; exit 1; }; \
	for script in \
		"$${MYSQL_INITDB_DIR}/050_load_optional_samples.sh" \
		"$${MYSQL_INITDB_DIR}/090_grant_training_access.sh" \
		"$${MYSQL_INITDB_DIR}/099_check_training_access.sh" \
		"$${POSTGRES_INITDB_DIR}/001_create_training_role.sh" \
		"$${POSTGRES_INITDB_DIR}/010_initialize_demo.sh" \
		"$${POSTGRES_INITDB_DIR}/050_load_optional_samples.sh" \
		"$${POSTGRES_INITDB_DIR}/099_check_training_access.sh"; do \
		test -x "$$script" || { echo "ERROR: обязательный скрипт отсутствует или не исполняемый: $$script" >&2; exit 1; }; \
	done

pull: check-env
	@echo "Скачиваем образы MySQL, PostgreSQL и Adminer..."
	$(COMPOSE_UI) pull mysql postgres adminer

config: check-env
	@$(COMPOSE_UI) config --quiet
	@echo "✅ Docker Compose configuration is valid."

up: init
	@echo "▶️  Запуск MySQL, PostgreSQL и Adminer..."
	$(COMPOSE_UI) up -d mysql postgres adminer
	@$(MAKE) --no-print-directory wait-mysql
	@$(MAKE) --no-print-directory wait-postgres

up-no-ui: init
	@$(MAKE) --no-print-directory down-ui
	@echo "▶️  Запуск MySQL и PostgreSQL без Adminer..."
	$(COMPOSE) up -d mysql postgres
	@$(MAKE) --no-print-directory wait-mysql
	@$(MAKE) --no-print-directory wait-postgres

up-mysql: init
	@echo "▶️  Запуск MySQL без автоматического запуска других сервисов..."
	$(COMPOSE) up -d mysql
	@$(MAKE) --no-print-directory wait-mysql

up-mysql-ui: init
	@echo "▶️  Запуск MySQL и Adminer..."
	$(COMPOSE_UI) up -d mysql adminer
	@$(MAKE) --no-print-directory wait-mysql

up-postgres: init
	@echo "▶️  Запуск PostgreSQL без автоматического запуска других сервисов..."
	$(COMPOSE) up -d postgres
	@$(MAKE) --no-print-directory wait-postgres

up-postgres-ui: init
	@echo "▶️  Запуск PostgreSQL и Adminer..."
	$(COMPOSE_UI) up -d postgres adminer
	@$(MAKE) --no-print-directory wait-postgres

up-ui: init
	@echo "▶️  Запуск только Adminer..."
	$(COMPOSE_UI) up -d adminer

down-ui: check-env
	@container_id="$$( $(COMPOSE_UI) ps --all --quiet adminer )"; \
	if [[ -n "$$container_id" ]]; then \
		echo "⏹️  Остановка только Adminer..."; \
		$(COMPOSE_UI) stop adminer; \
	else \
		echo "Adminer отсутствует; останавливать нечего."; \
	fi

wait-mysql: check-env
	@for ((attempt = 1; attempt <= 60; attempt++)); do \
		if $(COMPOSE) exec -T mysql sh -c 'MYSQL_PWD="$$MYSQL_ROOT_PASSWORD" mysqladmin ping -h 127.0.0.1 -uroot --silent' >/dev/null 2>&1; then \
			echo "✅ MySQL готов принимать подключения."; \
			exit 0; \
		fi; \
		sleep 2; \
	done; \
	echo "ERROR: MySQL не перешёл в готовое состояние" >&2; \
	$(COMPOSE_UI) ps; \
	exit 1

wait-postgres: check-env
	@for ((attempt = 1; attempt <= 60; attempt++)); do \
		if $(COMPOSE) exec -T postgres sh -c 'pg_isready --host=127.0.0.1 -U "$$POSTGRES_USER" -d "$$POSTGRES_DB"' >/dev/null 2>&1; then \
			echo "✅ PostgreSQL готов принимать подключения."; \
			exit 0; \
		fi; \
		sleep 2; \
	done; \
	echo "ERROR: PostgreSQL не перешёл в готовое состояние" >&2; \
	$(COMPOSE_UI) ps; \
	exit 1

down: check-env
	@echo "⏹️  Остановка сервисов без удаления bind-mounted данных..."
	$(COMPOSE_UI) down --remove-orphans

status: check-env
	@echo "📊 Состояние контейнеров:"
	$(COMPOSE_UI) ps

logs: check-env
	$(COMPOSE_UI) logs -f

log: check-env
	@test -n "$(SERVICE)" || { echo "ERROR: пример использования: make log SERVICE=postgres" >&2; exit 1; }
	$(COMPOSE_UI) logs -f $(SERVICE)

in: check-env
	@test -n "$(SERVICE)" || { echo "ERROR: пример использования: make in SERVICE=postgres" >&2; exit 1; }
	$(COMPOSE_UI) exec $(SERVICE) sh

ifneq ($(POSITIONAL_SERVICE),mysql)
mysql: wait-mysql
	$(COMPOSE) exec mysql sh -c 'MYSQL_PWD="$$MYSQL_ROOT_PASSWORD" exec mysql -uroot "$$MYSQL_DATABASE"'
endif

mysql-user: wait-mysql
	$(COMPOSE) exec mysql sh -c 'MYSQL_PWD="$$DB_PASSWORD" exec mysql -u"$$DB_USER" "$$MYSQL_DATABASE"'

ifneq ($(POSITIONAL_SERVICE),postgres)
postgres: wait-postgres
	$(COMPOSE) exec postgres sh -c 'exec psql --username="$$POSTGRES_USER" --dbname="$$POSTGRES_DB"'
endif

postgres-user: wait-postgres
	$(COMPOSE) exec postgres sh -c 'PGPASSWORD="$$DB_PASSWORD" exec psql --host=127.0.0.1 --username="$$DB_USER" --dbname="$$POSTGRES_DB"'

sh: check-env
	$(COMPOSE) exec mysql bash

samples-mysql: check-env
	@command -v curl >/dev/null || { echo "ERROR: требуется curl" >&2; exit 1; }
	@command -v unzip >/dev/null || { echo "ERROR: требуется unzip" >&2; exit 1; }
	@command -v git >/dev/null || { echo "ERROR: требуется git для проверки Git blob SHA" >&2; exit 1; }
	@command -v sha256sum >/dev/null || { echo "ERROR: требуется sha256sum" >&2; exit 1; }
	@set -Eeuo pipefail; $(LOAD_ENV) \
	tmp_root="$(MYSQL_SAMPLES_TMP_DIR)"; \
	download_dir="$${tmp_root}/download"; \
	ready_dir="$${tmp_root}/ready"; \
	previous_dir="$${tmp_root}/previous"; \
	target_dir="$${MYSQL_SAMPLES_DIR}"; \
	cleanup() { \
		if [[ -d "$${previous_dir}" && ! -e "$${target_dir}" ]]; then \
			mv "$${previous_dir}" "$${target_dir}"; \
		fi; \
		rm -rf "$${tmp_root}"; \
	}; \
	trap cleanup EXIT; \
	rm -rf "$${tmp_root}"; \
	mkdir -p "$${download_dir}/sakila" "$${ready_dir}"; \
	if [[ -L "$${target_dir}" ]]; then \
		echo "ERROR: MYSQL_SAMPLES_DIR не должен быть символической ссылкой: $${target_dir}" >&2; \
		exit 1; \
	fi; \
	if [[ -e "$${target_dir}" && ! -d "$${target_dir}" ]]; then \
		echo "ERROR: MYSQL_SAMPLES_DIR должен быть каталогом: $${target_dir}" >&2; \
		exit 1; \
	fi; \
	if [[ -d "$${target_dir}" ]] && find "$${target_dir}" -mindepth 1 -maxdepth 1 \
		! -name .gitkeep ! -name 010_world.sql ! -name 010_chinook.sql \
		! -name 020_sakila_schema.sql ! -name 021_sakila_data.sql -print -quit | grep -q .; then \
		echo "ERROR: $${target_dir} содержит посторонние файлы; безопасная замена отменена" >&2; \
		exit 1; \
	fi; \
	echo "Скачиваем Chinook из lerocha/chinook-database@$(CHINOOK_REF) и официальный Sakila..."; \
	curl --fail --location --retry 3 --retry-all-errors --connect-timeout 15 --max-time 180 \
		"$(CHINOOK_LICENSE_URL)" -o "$${download_dir}/LICENSE.md"; \
	curl --fail --location --retry 3 --retry-all-errors --connect-timeout 15 --max-time 180 \
		"$(CHINOOK_MYSQL_URL)" -o "$${download_dir}/Chinook_MySql.sql"; \
	curl --fail --location --retry 3 --retry-all-errors --connect-timeout 15 --max-time 180 \
		"$(SAKILA_URL)" -o "$${download_dir}/sakila-db.zip"; \
	echo "$(SAKILA_SHA256)  $${download_dir}/sakila-db.zip" | sha256sum --check --status || { echo "ERROR: неожиданный SHA-256 sakila-db.zip" >&2; exit 1; }; \
	test "$$(git hash-object --no-filters "$${download_dir}/LICENSE.md")" = "$(CHINOOK_LICENSE_BLOB)" || { echo "ERROR: неожиданный Git blob SHA LICENSE.md" >&2; exit 1; }; \
	test "$$(git hash-object --no-filters "$${download_dir}/Chinook_MySql.sql")" = "$(CHINOOK_MYSQL_BLOB)" || { echo "ERROR: неожиданный Git blob SHA Chinook_MySql.sql" >&2; exit 1; }; \
	test -s "$${download_dir}/LICENSE.md" || { echo "ERROR: LICENSE.md пуст" >&2; exit 1; }; \
	test -s "$${download_dir}/Chinook_MySql.sql" || { echo "ERROR: Chinook_MySql.sql пуст" >&2; exit 1; }; \
	sed 's/\r$$//' "$${download_dir}/LICENSE.md" > "$${download_dir}/LICENSE.normalized.md"; \
	sed 's/\r$$//' "$${download_dir}/Chinook_MySql.sql" > "$${download_dir}/Chinook_MySql.normalized.sql"; \
	chinook_source="$${download_dir}/Chinook_MySql.normalized.sql"; \
	grep -Fq 'Chinook Database - Version 1.4.5' "$${chinook_source}" || { echo "ERROR: неожиданная версия Chinook MySQL" >&2; exit 1; }; \
	grep -Fq 'DB Server: MySql' "$${chinook_source}" || { echo "ERROR: неожиданный DB Server Chinook MySQL" >&2; exit 1; }; \
	for table_name in Album Artist Customer Invoice Track; do \
		grep -Fq "CREATE TABLE \`$${table_name}\`" "$${chinook_source}" || { echo "ERROR: Chinook MySQL не содержит таблицу $${table_name}" >&2; exit 1; }; \
		grep -Fq "INSERT INTO \`$${table_name}\`" "$${chinook_source}" || { echo "ERROR: Chinook MySQL не содержит данные $${table_name}" >&2; exit 1; }; \
	done; \
	for expected_line in 'DROP DATABASE IF EXISTS `Chinook`;' 'CREATE DATABASE `Chinook`;' 'USE `Chinook`;'; do \
		test "$$(grep -Fxc "$${expected_line}" "$${chinook_source}" || true)" = 1 || { echo "ERROR: неожиданный формат database-level строки: $${expected_line}" >&2; exit 1; }; \
	done; \
	test "$$(awk 'BEGIN { in_comment = 0; count = 0 } { upper = toupper($$0) } /^[[:space:]]*\/\*/ { in_comment = 1 } !in_comment && upper ~ /^[[:space:]]*((DROP|CREATE)[[:space:]]+DATABASE|USE[[:space:]])/ { count++ } /\*\// { in_comment = 0 } END { print count }' "$${chinook_source}")" = 3 || { echo "ERROR: Chinook MySQL содержит неожиданные database-level statements" >&2; exit 1; }; \
	{ \
		echo '-- Chinook Database MIT license notice (upstream LICENSE.md):'; \
		sed 's/^/-- /' "$${download_dir}/LICENSE.normalized.md"; \
		echo; \
		awk '$$0 != "DROP DATABASE IF EXISTS `Chinook`;" && $$0 != "CREATE DATABASE `Chinook`;" && $$0 != "USE `Chinook`;"' "$${chinook_source}"; \
	} > "$${ready_dir}/010_chinook.sql"; \
	if awk 'BEGIN { in_comment = 0; found = 0 } { upper = toupper($$0) } /^[[:space:]]*\/\*/ { in_comment = 1 } !in_comment && upper ~ /^[[:space:]]*((DROP|CREATE)[[:space:]]+DATABASE|USE[[:space:]])/ { found = 1 } /\*\// { in_comment = 0 } END { exit(found ? 0 : 1) }' "$${ready_dir}/010_chinook.sql"; then \
		echo "ERROR: готовый Chinook MySQL содержит database-level setup" >&2; \
		exit 1; \
	fi; \
	while IFS= read -r license_line || [[ -n "$${license_line}" ]]; do \
		grep -Fxq -- "-- $${license_line}" "$${ready_dir}/010_chinook.sql" || { echo "ERROR: MIT notice перенесён не полностью" >&2; exit 1; }; \
	done < "$${download_dir}/LICENSE.normalized.md"; \
	unzip -q "$${download_dir}/sakila-db.zip" -d "$${download_dir}/sakila"; \
	sakila_schema_source="$$(find "$${download_dir}/sakila" -type f -name sakila-schema.sql -print -quit)"; \
	sakila_data_source="$$(find "$${download_dir}/sakila" -type f -name sakila-data.sql -print -quit)"; \
	test -n "$$sakila_schema_source" || { echo "ERROR: архив Sakila не содержит sakila-schema.sql" >&2; exit 1; }; \
	test -n "$$sakila_data_source" || { echo "ERROR: архив Sakila не содержит sakila-data.sql" >&2; exit 1; }; \
	for sakila_source in "$$sakila_schema_source" "$$sakila_data_source"; do \
		grep -Fq 'Redistribution and use in source and binary forms' "$$sakila_source" || { echo "ERROR: в $${sakila_source} отсутствует ожидаемый New BSD notice" >&2; exit 1; }; \
		grep -Fq 'THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS' "$$sakila_source" || { echo "ERROR: в $${sakila_source} отсутствует ожидаемый New BSD disclaimer" >&2; exit 1; }; \
	done; \
	cp "$$sakila_schema_source" "$${ready_dir}/020_sakila_schema.sql"; \
	cp "$$sakila_data_source" "$${ready_dir}/021_sakila_data.sql"; \
	if [[ -f "$${target_dir}/.gitkeep" ]]; then cp "$${target_dir}/.gitkeep" "$${ready_dir}/.gitkeep"; else touch "$${ready_dir}/.gitkeep"; fi; \
	mkdir -p "$$(dirname "$${target_dir}")"; \
	if [[ "$$(stat -c %d "$${ready_dir}")" != "$$(stat -c %d "$$(dirname "$${target_dir}")")" ]]; then \
		echo "ERROR: .tmp и MYSQL_SAMPLES_DIR должны находиться на одной файловой системе для атомарной публикации" >&2; \
		exit 1; \
	fi; \
	if [[ -d "$${target_dir}" ]]; then mv "$${target_dir}" "$${previous_dir}"; fi; \
	mv "$${ready_dir}" "$${target_dir}"; \
	rm -rf "$${previous_dir}"; \
	echo "✅ Optional samples Chinook и Sakila подготовлены в $${target_dir}."; \
	echo "Они загрузятся только при следующей чистой инициализации MySQL."; \
	echo "Для существующего MYSQL_DATA_DIR выполните явно: make reinit-mysql CONFIRM=1"

samples-postgres: check-env
	@command -v curl >/dev/null || { echo "ERROR: требуется curl" >&2; exit 1; }
	@command -v git >/dev/null || { echo "ERROR: требуется git для проверки Git blob SHA" >&2; exit 1; }
	@set -Eeuo pipefail; $(LOAD_ENV) \
	tmp_root="$(POSTGRES_SAMPLES_TMP_DIR)"; \
	download_dir="$${tmp_root}/download"; \
	ready_dir="$${tmp_root}/ready"; \
	previous_dir="$${tmp_root}/previous"; \
	target_dir="$${POSTGRES_SAMPLES_DIR}"; \
	cleanup() { \
		if [[ -d "$${previous_dir}" && ! -e "$${target_dir}" ]]; then \
			mv "$${previous_dir}" "$${target_dir}"; \
		fi; \
		rm -rf "$${tmp_root}"; \
	}; \
	trap cleanup EXIT; \
	rm -rf "$${tmp_root}"; \
	mkdir -p "$${download_dir}" "$${ready_dir}"; \
	if [[ -L "$${target_dir}" ]]; then \
		echo "ERROR: POSTGRES_SAMPLES_DIR не должен быть символической ссылкой: $${target_dir}" >&2; \
		exit 1; \
	fi; \
	if [[ -e "$${target_dir}" && ! -d "$${target_dir}" ]]; then \
		echo "ERROR: POSTGRES_SAMPLES_DIR должен быть каталогом: $${target_dir}" >&2; \
		exit 1; \
	fi; \
	if [[ -d "$${target_dir}" ]] && find "$${target_dir}" -mindepth 1 -maxdepth 1 \
		! -name 010_pagila_schema.sql ! -name 020_pagila_data.sql ! -name 030_chinook.sql -print -quit | grep -q .; then \
		echo "ERROR: $${target_dir} содержит посторонние файлы; безопасная замена отменена" >&2; \
		exit 1; \
	fi; \
	echo "Скачиваем Pagila из devrimgunduz/pagila@$(PAGILA_REF) и Chinook из lerocha/chinook-database@$(CHINOOK_REF)..."; \
	curl --fail --location --retry 3 --retry-all-errors --connect-timeout 15 --max-time 180 \
		"$(PAGILA_BASE_URL)/pagila-schema.sql" -o "$${download_dir}/pagila-schema.sql"; \
	curl --fail --location --retry 3 --retry-all-errors --connect-timeout 15 --max-time 180 \
		"$(PAGILA_BASE_URL)/pagila-data.sql" -o "$${download_dir}/pagila-data.sql"; \
	curl --fail --location --retry 3 --retry-all-errors --connect-timeout 15 --max-time 180 \
		"$(PAGILA_LICENSE_URL)" -o "$${download_dir}/LICENSE.pagila.txt"; \
	curl --fail --location --retry 3 --retry-all-errors --connect-timeout 15 --max-time 180 \
		"$(CHINOOK_LICENSE_URL)" -o "$${download_dir}/LICENSE.md"; \
	curl --fail --location --retry 3 --retry-all-errors --connect-timeout 15 --max-time 180 \
		"$(CHINOOK_POSTGRES_URL)" -o "$${download_dir}/Chinook_PostgreSql.sql"; \
	test "$$(git hash-object --no-filters "$${download_dir}/LICENSE.pagila.txt")" = "$(PAGILA_LICENSE_BLOB)" || { echo "ERROR: неожиданный Git blob SHA Pagila LICENSE.txt" >&2; exit 1; }; \
	test "$$(git hash-object --no-filters "$${download_dir}/pagila-schema.sql")" = "$(PAGILA_SCHEMA_BLOB)" || { echo "ERROR: неожиданный Git blob SHA pagila-schema.sql" >&2; exit 1; }; \
	test "$$(git hash-object --no-filters "$${download_dir}/pagila-data.sql")" = "$(PAGILA_DATA_BLOB)" || { echo "ERROR: неожиданный Git blob SHA pagila-data.sql" >&2; exit 1; }; \
	test -s "$${download_dir}/LICENSE.pagila.txt" || { echo "ERROR: Pagila LICENSE.txt пуст" >&2; exit 1; }; \
	test -s "$${download_dir}/pagila-schema.sql" || { echo "ERROR: pagila-schema.sql пуст" >&2; exit 1; }; \
	test -s "$${download_dir}/pagila-data.sql" || { echo "ERROR: pagila-data.sql пуст" >&2; exit 1; }; \
	grep -Fq 'CREATE TABLE public.actor' "$${download_dir}/pagila-schema.sql" || { echo "ERROR: в schema нет таблицы actor" >&2; exit 1; }; \
	grep -Fq 'CREATE TABLE public.film' "$${download_dir}/pagila-schema.sql" || { echo "ERROR: в schema нет таблицы film" >&2; exit 1; }; \
	grep -Fq 'ALTER TABLE public.actor OWNER TO postgres;' "$${download_dir}/pagila-schema.sql" || { echo "ERROR: неожиданный формат владельцев Pagila" >&2; exit 1; }; \
	grep -Fq 'COPY public.actor' "$${download_dir}/pagila-data.sql" || { echo "ERROR: в data нет COPY для actor" >&2; exit 1; }; \
	grep -Fq 'COPY public.rental' "$${download_dir}/pagila-data.sql" || { echo "ERROR: в data нет COPY для rental" >&2; exit 1; }; \
	grep -Fxq '\.' "$${download_dir}/pagila-data.sql" || { echo "ERROR: в data нет завершителей COPY" >&2; exit 1; }; \
	test "$$(git hash-object --no-filters "$${download_dir}/LICENSE.md")" = "$(CHINOOK_LICENSE_BLOB)" || { echo "ERROR: неожиданный Git blob SHA LICENSE.md" >&2; exit 1; }; \
	test "$$(git hash-object --no-filters "$${download_dir}/Chinook_PostgreSql.sql")" = "$(CHINOOK_POSTGRES_BLOB)" || { echo "ERROR: неожиданный Git blob SHA Chinook_PostgreSql.sql" >&2; exit 1; }; \
	test -s "$${download_dir}/LICENSE.md" || { echo "ERROR: LICENSE.md пуст" >&2; exit 1; }; \
	test -s "$${download_dir}/Chinook_PostgreSql.sql" || { echo "ERROR: Chinook_PostgreSql.sql пуст" >&2; exit 1; }; \
	sed 's/\r$$//' "$${download_dir}/LICENSE.md" > "$${download_dir}/LICENSE.normalized.md"; \
	sed 's/\r$$//' "$${download_dir}/Chinook_PostgreSql.sql" > "$${download_dir}/Chinook_PostgreSql.normalized.sql"; \
	chinook_source="$${download_dir}/Chinook_PostgreSql.normalized.sql"; \
	grep -Fq 'Chinook Database - Version 1.4.5' "$${chinook_source}" || { echo "ERROR: неожиданная версия Chinook PostgreSQL" >&2; exit 1; }; \
	grep -Fq 'DB Server: PostgreSql' "$${chinook_source}" || { echo "ERROR: неожиданный DB Server Chinook PostgreSQL" >&2; exit 1; }; \
	for table_name in album artist customer invoice track; do \
		grep -Fq "CREATE TABLE $${table_name}" "$${chinook_source}" || { echo "ERROR: Chinook PostgreSQL не содержит таблицу $${table_name}" >&2; exit 1; }; \
		grep -Fq "INSERT INTO $${table_name}" "$${chinook_source}" || { echo "ERROR: Chinook PostgreSQL не содержит данные $${table_name}" >&2; exit 1; }; \
	done; \
	for expected_line in 'DROP DATABASE IF EXISTS chinook;' 'CREATE DATABASE chinook;' '\c chinook;'; do \
		test "$$(grep -Fxc "$${expected_line}" "$${chinook_source}" || true)" = 1 || { echo "ERROR: неожиданный формат database-level строки: $${expected_line}" >&2; exit 1; }; \
	done; \
	test "$$(awk 'BEGIN { in_comment = 0; count = 0 } { upper = toupper($$0) } /^[[:space:]]*\/\*/ { in_comment = 1 } !in_comment && (upper ~ /^[[:space:]]*(DROP|CREATE)[[:space:]]+DATABASE/ || upper ~ /^[[:space:]]*\\(C|CONNECT)([[:space:]]|$$)/) { count++ } /\*\// { in_comment = 0 } END { print count }' "$${chinook_source}")" = 3 || { echo "ERROR: Chinook PostgreSQL содержит неожиданные database-level statements" >&2; exit 1; }; \
	sed 's/\r$$//' "$${download_dir}/LICENSE.pagila.txt" > "$${download_dir}/LICENSE.pagila.normalized.txt"; \
	{ \
		echo '-- Pagila license notice (upstream LICENSE.txt):'; \
		sed 's/^/-- /' "$${download_dir}/LICENSE.pagila.normalized.txt"; \
		echo; \
		cat "$${download_dir}/pagila-schema.sql"; \
	} > "$${ready_dir}/010_pagila_schema.sql"; \
	{ \
		echo '-- Pagila license notice (upstream LICENSE.txt):'; \
		sed 's/^/-- /' "$${download_dir}/LICENSE.pagila.normalized.txt"; \
		echo; \
		cat "$${download_dir}/pagila-data.sql"; \
	} > "$${ready_dir}/020_pagila_data.sql"; \
	while IFS= read -r license_line || [[ -n "$${license_line}" ]]; do \
		for pagila_ready_file in "$${ready_dir}/010_pagila_schema.sql" "$${ready_dir}/020_pagila_data.sql"; do \
			grep -Fxq -- "-- $${license_line}" "$${pagila_ready_file}" || { echo "ERROR: Pagila notice перенесён не полностью в $${pagila_ready_file}" >&2; exit 1; }; \
		done; \
	done < "$${download_dir}/LICENSE.pagila.normalized.txt"; \
	{ \
		echo '-- Chinook Database MIT license notice (upstream LICENSE.md):'; \
		sed 's/^/-- /' "$${download_dir}/LICENSE.normalized.md"; \
		echo; \
		awk '$$0 != "DROP DATABASE IF EXISTS chinook;" && $$0 != "CREATE DATABASE chinook;" && $$0 != "\\c chinook;"' "$${chinook_source}"; \
	} > "$${ready_dir}/030_chinook.sql"; \
	if awk 'BEGIN { in_comment = 0; found = 0 } { upper = toupper($$0) } /^[[:space:]]*\/\*/ { in_comment = 1 } !in_comment && (upper ~ /^[[:space:]]*(DROP|CREATE)[[:space:]]+DATABASE/ || upper ~ /^[[:space:]]*\\(C|CONNECT)([[:space:]]|$$)/) { found = 1 } /\*\// { in_comment = 0 } END { exit(found ? 0 : 1) }' "$${ready_dir}/030_chinook.sql"; then \
		echo "ERROR: готовый Chinook PostgreSQL содержит database-level setup" >&2; \
		exit 1; \
	fi; \
	while IFS= read -r license_line || [[ -n "$${license_line}" ]]; do \
		grep -Fxq -- "-- $${license_line}" "$${ready_dir}/030_chinook.sql" || { echo "ERROR: MIT notice перенесён не полностью" >&2; exit 1; }; \
	done < "$${download_dir}/LICENSE.normalized.md"; \
	mkdir -p "$$(dirname "$${target_dir}")"; \
	if [[ "$$(stat -c %d "$${ready_dir}")" != "$$(stat -c %d "$$(dirname "$${target_dir}")")" ]]; then \
		echo "ERROR: .tmp и POSTGRES_SAMPLES_DIR должны находиться на одной файловой системе для атомарной публикации" >&2; \
		exit 1; \
	fi; \
	if [[ -d "$${target_dir}" ]]; then \
		mv "$${target_dir}" "$${previous_dir}"; \
	fi; \
	mv "$${ready_dir}" "$${target_dir}"; \
	rm -rf "$${previous_dir}"; \
	echo "✅ Pagila и Chinook подготовлены в $${target_dir} из закреплённых ревизий."; \
	echo "Пустой POSTGRES_DATA_DIR: make up-postgres"; \
	echo "Уже инициализированный POSTGRES_DATA_DIR: make reinit-postgres CONFIRM=1"

mysql-grants: wait-mysql
	$(COMPOSE) exec -T mysql /docker-entrypoint-initdb.d/090_grant_training_access.sh

mysql-import:
	@set -Eeuo pipefail; \
	if [[ -z "$${FILE:-}" ]]; then echo "ERROR: укажите FILE=path/to/file.sql" >&2; exit 1; fi; \
	if [[ -z "$${DATABASE:-}" ]]; then echo "ERROR: укажите DATABASE=database_name" >&2; exit 1; fi; \
	if [[ ! -f "$${FILE}" || ! -r "$${FILE}" || ! -s "$${FILE}" ]]; then echo "ERROR: FILE должен быть существующим читаемым непустым обычным файлом" >&2; exit 1; fi; \
	if [[ ! "$${DATABASE}" =~ ^[a-z][a-z0-9_]{0,62}$$ ]]; then echo "ERROR: недопустимое имя MySQL database: $${DATABASE}" >&2; exit 1; fi; \
	case "$${DATABASE}" in mysql|information_schema|performance_schema|sys) echo "ERROR: импорт в системную MySQL database запрещён: $${DATABASE}" >&2; exit 1 ;; esac
	@$(MAKE) --no-print-directory wait-mysql
	@set -Eeuo pipefail; \
	$(LOAD_ENV) \
	if ! $(COMPOSE) exec -T -e IMPORT_DATABASE="$${DATABASE}" mysql sh -c 'MYSQL_PWD="$$DB_PASSWORD" exec mysql --host=127.0.0.1 --user="$$DB_USER" --batch --skip-column-names "$$IMPORT_DATABASE" --execute "SELECT 1;"' >/dev/null; then \
		echo "ERROR: DB_USER cannot connect to MySQL database $${DATABASE}; import was not started" >&2; exit 1; \
	fi; \
	echo "Импортируем $${FILE} в MySQL database $${DATABASE} от имени DB_USER..."; \
	$(COMPOSE) exec -T -e IMPORT_DATABASE="$${DATABASE}" mysql sh -c 'MYSQL_PWD="$$DB_PASSWORD" exec mysql --host=127.0.0.1 --user="$$DB_USER" --binary-mode=1 "$$IMPORT_DATABASE"' < "$${FILE}"; \
	if ! $(COMPOSE) exec -T -e IMPORT_DATABASE="$${DATABASE}" mysql sh -c 'MYSQL_PWD="$$DB_PASSWORD" exec mysql --host=127.0.0.1 --user="$$DB_USER" --batch --skip-column-names "$$IMPORT_DATABASE" --execute "SELECT 1;"' >/dev/null; then \
		echo "ERROR: DB_USER cannot reconnect to MySQL database $${DATABASE} after import" >&2; exit 1; \
	fi
	@$(MAKE) --no-print-directory check-mysql-access

postgres-import:
	@set -Eeuo pipefail; \
	if [[ -z "$${FILE:-}" ]]; then echo "ERROR: укажите FILE=path/to/file.sql" >&2; exit 1; fi; \
	if [[ -z "$${DATABASE:-}" ]]; then echo "ERROR: укажите DATABASE=database_name" >&2; exit 1; fi; \
	if [[ ! -f "$${FILE}" || ! -r "$${FILE}" || ! -s "$${FILE}" ]]; then echo "ERROR: FILE должен быть существующим читаемым непустым обычным файлом" >&2; exit 1; fi; \
	if [[ ! "$${DATABASE}" =~ ^[a-z][a-z0-9_]{0,62}$$ ]]; then echo "ERROR: недопустимое имя PostgreSQL database: $${DATABASE}" >&2; exit 1; fi; \
	case "$${DATABASE}" in postgres|template0|template1) echo "ERROR: импорт в системную PostgreSQL database запрещён: $${DATABASE}" >&2; exit 1 ;; esac
	@$(MAKE) --no-print-directory wait-postgres
	@set -Eeuo pipefail; \
	$(LOAD_ENV) \
	if ! $(COMPOSE) exec -T -e IMPORT_DATABASE="$${DATABASE}" postgres sh -c 'PGPASSWORD="$$DB_PASSWORD" exec psql --host=127.0.0.1 --username="$$DB_USER" --dbname="$$IMPORT_DATABASE" --no-psqlrc --set=ON_ERROR_STOP=1 --command="SELECT 1;"' >/dev/null; then \
		echo "ERROR: DB_USER cannot connect to PostgreSQL database $${DATABASE}; import was not started" >&2; exit 1; \
	fi; \
	echo "Импортируем $${FILE} в PostgreSQL database $${DATABASE} от имени DB_USER..."; \
	$(COMPOSE) exec -T -e IMPORT_DATABASE="$${DATABASE}" postgres sh -c 'PGPASSWORD="$$DB_PASSWORD" exec psql --host=127.0.0.1 --username="$$DB_USER" --dbname="$$IMPORT_DATABASE" --no-psqlrc --set=ON_ERROR_STOP=1 --file=-' < "$${FILE}"; \
	if ! $(COMPOSE) exec -T -e IMPORT_DATABASE="$${DATABASE}" postgres sh -c 'PGPASSWORD="$$DB_PASSWORD" exec psql --host=127.0.0.1 --username="$$DB_USER" --dbname="$$IMPORT_DATABASE" --no-psqlrc --set=ON_ERROR_STOP=1 --command="SELECT 1;"' >/dev/null; then \
		echo "ERROR: DB_USER cannot reconnect to PostgreSQL database $${DATABASE} after import" >&2; exit 1; \
	fi
	@$(MAKE) --no-print-directory check-postgres-access

check-mysql-access: wait-mysql
	$(COMPOSE) exec -T mysql /docker-entrypoint-initdb.d/099_check_training_access.sh

check-postgres-access: wait-postgres
	$(COMPOSE) exec -T postgres env POSTGRES_CHECK_HOST=127.0.0.1 /docker-entrypoint-initdb.d/099_check_training_access.sh

check: config
	@$(MAKE) --no-print-directory check-mysql-access
	@$(MAKE) --no-print-directory check-postgres-access

dump: wait-mysql
	@mkdir -p backup
	@$(LOAD_ENV) \
	$(COMPOSE) exec -T mysql sh -c 'MYSQL_PWD="$$MYSQL_ROOT_PASSWORD" mysqldump -uroot --single-transaction --set-gtid-purged=OFF --databases "$$MYSQL_DATABASE"' > "backup/$${MYSQL_DATABASE}.sql"; \
	echo "Бэкап сохранён: backup/$${MYSQL_DATABASE}.sql"

restore: wait-mysql
	@$(LOAD_ENV) \
	test -f "backup/$${MYSQL_DATABASE}.sql" || { echo "ERROR: нет backup/$${MYSQL_DATABASE}.sql" >&2; exit 1; }; \
	$(COMPOSE) exec -T mysql sh -c 'MYSQL_PWD="$$MYSQL_ROOT_PASSWORD" mysql -uroot' < "backup/$${MYSQL_DATABASE}.sql"
	@$(MAKE) --no-print-directory mysql-grants
	@echo "Восстановление завершено."

clean-mysql: check-env
	@test "$(CONFIRM)" = "1" || { echo "ERROR: команда удаляет MYSQL_DATA_DIR. Повторите с CONFIRM=1" >&2; exit 1; }
	@$(LOAD_ENV) \
	project_dir_abs="$$(realpath -m "$(PROJECT_DIR)")"; \
	data_dir_abs="$$(realpath -m "$${MYSQL_DATA_DIR}")"; \
	data_dir_rel="$${data_dir_abs#"$${project_dir_abs}"/}"; \
	echo "🗑️  Удаление только данных MySQL: $${MYSQL_DATA_DIR}"; \
	container_id="$$( $(COMPOSE) ps --all --quiet mysql )"; \
	if [[ -n "$${container_id}" ]]; then \
		echo "⏹️  Остановка и удаление только MySQL..."; \
		$(COMPOSE) rm --stop --force mysql; \
	else \
		echo "Контейнер MySQL отсутствует; останавливать нечего."; \
	fi; \
	docker run --rm --user 0:0 --entrypoint sh \
		-e DATA_DIR_REL="$${data_dir_rel}" -e HOST_UID="$(HOST_UID)" -e HOST_GID="$(HOST_GID)" \
		-v "$${project_dir_abs}:/workspace" "mysql:$${MYSQL_VERSION}" \
		-c 'rm -rf -- "/workspace/$${DATA_DIR_REL}" && mkdir -p "/workspace/$${DATA_DIR_REL}" && chown "$${HOST_UID}:$${HOST_GID}" "/workspace/$${DATA_DIR_REL}"'; \
	echo "✅ Данные MySQL удалены, пустой каталог возвращён пользователю $(HOST_UID):$(HOST_GID)."

clean-postgres: check-env
	@test "$(CONFIRM)" = "1" || { echo "ERROR: команда удаляет POSTGRES_DATA_DIR. Повторите с CONFIRM=1" >&2; exit 1; }
	@$(LOAD_ENV) \
	project_dir_abs="$$(realpath -m "$(PROJECT_DIR)")"; \
	data_dir_abs="$$(realpath -m "$${POSTGRES_DATA_DIR}")"; \
	data_dir_rel="$${data_dir_abs#"$${project_dir_abs}"/}"; \
	echo "🗑️  Удаление только данных PostgreSQL: $${POSTGRES_DATA_DIR}"; \
	container_id="$$( $(COMPOSE) ps --all --quiet postgres )"; \
	if [[ -n "$${container_id}" ]]; then \
		echo "⏹️  Остановка и удаление только PostgreSQL..."; \
		$(COMPOSE) rm --stop --force postgres; \
	else \
		echo "Контейнер PostgreSQL отсутствует; останавливать нечего."; \
	fi; \
	docker run --rm --user 0:0 --entrypoint sh \
		-e DATA_DIR_REL="$${data_dir_rel}" -e HOST_UID="$(HOST_UID)" -e HOST_GID="$(HOST_GID)" \
		-v "$${project_dir_abs}:/workspace" "postgres:$${POSTGRES_VERSION}" \
		-c 'rm -rf -- "/workspace/$${DATA_DIR_REL}" && mkdir -p "/workspace/$${DATA_DIR_REL}" && chown "$${HOST_UID}:$${HOST_GID}" "/workspace/$${DATA_DIR_REL}"'; \
	echo "✅ Данные PostgreSQL удалены, пустой каталог возвращён пользователю $(HOST_UID):$(HOST_GID)."

clean-all: check-env
	@test "$(CONFIRM)" = "1" || { echo "ERROR: команда удаляет данные MySQL и PostgreSQL. Повторите с CONFIRM=1" >&2; exit 1; }
	@$(LOAD_ENV) \
	project_dir_abs="$$(realpath -m "$(PROJECT_DIR)")"; \
	mysql_abs="$$(realpath -m "$${MYSQL_DATA_DIR}")"; \
	postgres_abs="$$(realpath -m "$${POSTGRES_DATA_DIR}")"; \
	mysql_rel="$${mysql_abs#"$${project_dir_abs}"/}"; \
	postgres_rel="$${postgres_abs#"$${project_dir_abs}"/}"; \
	echo "🗑️  Удаление данных MySQL и PostgreSQL..."; \
	$(COMPOSE_UI) down --remove-orphans; \
	docker run --rm --user 0:0 --entrypoint sh \
		-e MYSQL_REL="$$mysql_rel" -e POSTGRES_REL="$$postgres_rel" \
		-e HOST_UID="$(HOST_UID)" -e HOST_GID="$(HOST_GID)" \
		-v "$${project_dir_abs}:/workspace" "mysql:$${MYSQL_VERSION}" \
		-c 'for path in "$${MYSQL_REL}" "$${POSTGRES_REL}"; do rm -rf -- "/workspace/$${path}" && mkdir -p "/workspace/$${path}" && chown "$${HOST_UID}:$${HOST_GID}" "/workspace/$${path}"; done'; \
	echo "✅ Оба data-каталога очищены; env, init, samples и backup сохранены."

reinit-mysql: clean-mysql
	@$(MAKE) --no-print-directory up-mysql
	@$(MAKE) --no-print-directory check-mysql-access

reinit-postgres: clean-postgres
	@$(MAKE) --no-print-directory up-postgres
	@$(MAKE) --no-print-directory check-postgres-access

reinit-all: clean-all
	@$(MAKE) --no-print-directory up-no-ui
	@$(MAKE) --no-print-directory check
