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

mysql_training --execute="SELECT COUNT(*) FROM demo.demo_users;" >/dev/null
mysql_training --execute="SELECT COUNT(*) FROM world.city;" >/dev/null
mysql_training --execute="SELECT COUNT(*) FROM sakila.actor;" >/dev/null

echo "Verified sample data access in demo, world and sakila."
echo "All MySQL training-user access checks passed."
