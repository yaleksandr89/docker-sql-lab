#!/usr/bin/env bash
set -Eeuo pipefail

required_variables=(MYSQL_ROOT_PASSWORD DB_USER DB_PASSWORD)
for variable_name in "${required_variables[@]}"; do
    if [[ -z "${!variable_name:-}" ]]; then
        echo "ERROR: environment variable ${variable_name} is required" >&2
        exit 1
    fi
done

mysql_root() {
    MYSQL_PWD="${MYSQL_ROOT_PASSWORD}" mysql \
        --protocol=socket \
        --user=root \
        --batch \
        --skip-column-names \
        "$@"
}

mysql_training() {
    MYSQL_PWD="${DB_PASSWORD}" mysql \
        --protocol=socket \
        --user="${DB_USER}" \
        --batch \
        --skip-column-names \
        "$@"
}

escape_sql_identifier() {
    local value=${1}
    value=${value//\`/\`\`}
    printf '%s' "${value}"
}

mapfile -t expected_databases < <(
    mysql_root --execute="
        SELECT SCHEMA_NAME
        FROM INFORMATION_SCHEMA.SCHEMATA
        WHERE SCHEMA_NAME NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
        ORDER BY SCHEMA_NAME;
    "
)

if (( ${#expected_databases[@]} == 0 )); then
    echo "ERROR: no user databases found" >&2
    exit 1
fi

if [[ ! " ${expected_databases[*]} " =~ [[:space:]]demo[[:space:]] ]]; then
    echo "ERROR: required MySQL database demo does not exist" >&2
    exit 1
fi

for database_name in "${expected_databases[@]}"; do
    database_sql=$(escape_sql_identifier "${database_name}")
    mysql_training <<SQL
USE \`${database_sql}\`;
CREATE TEMPORARY TABLE __sql_lab_access_check
(
    id INT PRIMARY KEY,
    value VARCHAR(32) NOT NULL
);
INSERT INTO __sql_lab_access_check (id, value) VALUES (1, 'ok');
SELECT CONCAT(DATABASE(), ':', value) FROM __sql_lab_access_check WHERE id = 1;
SQL
    echo "Verified read/write access to ${database_name}.*"
done

table_exists=$(mysql_training --execute="
    SELECT COUNT(*)
    FROM information_schema.tables
    WHERE table_schema = 'demo'
      AND table_name = 'demo_users'
      AND table_type = 'BASE TABLE';
")
if [[ "${table_exists}" != "1" ]]; then
    echo "ERROR: required MySQL table demo.demo_users does not exist" >&2
    exit 1
fi

required_seed_count=$(mysql_training --execute="
    SELECT COUNT(DISTINCT email)
    FROM demo.demo_users
    WHERE email IN (
        'alice@example.com',
        'bob@example.com',
        'carol@example.com',
        'dave@example.com',
        'eve@example.com'
    );
")
if [[ "${required_seed_count}" != "5" ]]; then
    echo "ERROR: demo.demo_users does not contain all five required seed emails" >&2
    exit 1
fi

mysql_training <<'SQL'
START TRANSACTION;
SET @sql_lab_probe_email = CONCAT('sql-lab-check-', UUID(), '@example.invalid');
INSERT INTO demo.demo_users (name, email) VALUES ('SQL Lab access check', @sql_lab_probe_email);
SELECT email FROM demo.demo_users WHERE email = @sql_lab_probe_email;
ROLLBACK;
SQL

echo "Verified required MySQL table, all five seed emails and user-row INSERT access."

if [[ " ${expected_databases[*]} " =~ [[:space:]]world[[:space:]] ]]; then
    mysql_training --execute="SELECT COUNT(*) FROM world.city;" >/dev/null
    echo "Found and verified optional MySQL sample world.city."
else
    echo "Optional MySQL sample World is not installed; skipped."
fi

if [[ " ${expected_databases[*]} " =~ [[:space:]]sakila[[:space:]] ]]; then
    mysql_training --execute="SELECT COUNT(*) FROM sakila.actor;" >/dev/null
    echo "Found and verified optional MySQL sample sakila.actor."
else
    echo "Optional MySQL sample Sakila is not installed; skipped."
fi

echo "All MySQL training-user access checks passed."
