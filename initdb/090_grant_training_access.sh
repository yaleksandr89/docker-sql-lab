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

escape_sql_literal() {
    local value=${1}
    value=${value//\\/\\\\}
    value=${value//\'/\'\'}
    printf '%s' "${value}"
}

escape_sql_identifier() {
    local value=${1}
    value=${value//\`/\`\`}
    printf '%s' "${value}"
}

user_sql=$(escape_sql_literal "${DB_USER}")
password_sql=$(escape_sql_literal "${DB_PASSWORD}")

mysql_root <<SQL
CREATE USER IF NOT EXISTS '${user_sql}'@'%' IDENTIFIED BY '${password_sql}';
ALTER USER '${user_sql}'@'%' IDENTIFIED BY '${password_sql}';
SQL

mapfile -t training_databases < <(
    mysql_root --execute="
        SELECT SCHEMA_NAME
        FROM INFORMATION_SCHEMA.SCHEMATA
        WHERE SCHEMA_NAME NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
        ORDER BY SCHEMA_NAME;
    "
)

if (( ${#training_databases[@]} == 0 )); then
    echo "ERROR: no user databases found; grants were not applied" >&2
    exit 1
fi

for database_name in "${training_databases[@]}"; do
    database_sql=$(escape_sql_identifier "${database_name}")
    mysql_root --execute="GRANT ALL PRIVILEGES ON \`${database_sql}\`.* TO '${user_sql}'@'%';"
    echo "Granted ${DB_USER}@% access to ${database_name}.*"
done

echo "Training user grants configured for ${#training_databases[@]} database(s)."
