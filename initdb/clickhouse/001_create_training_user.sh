#!/usr/bin/env bash
set -Eeuo pipefail

require_identifier() {
  local variable_name="$1"
  local value="${!variable_name:-}"

  if [[ ! "$value" =~ ^[A-Za-z_][A-Za-z0-9_]{0,62}$ ]]; then
    printf 'ERROR: %s must be a conservative ASCII identifier\n' "$variable_name" >&2
    exit 1
  fi
}

for variable_name in CLICKHOUSE_DB CLICKHOUSE_USER CLICKHOUSE_PASSWORD DB_USER DB_PASSWORD; do
  if [[ -z "${!variable_name:-}" ]]; then
    printf 'ERROR: required environment variable is empty: %s\n' "$variable_name" >&2
    exit 1
  fi
done

require_identifier CLICKHOUSE_DB
require_identifier CLICKHOUSE_USER
require_identifier DB_USER

if [[ "$CLICKHOUSE_DB" != 'demo' ]]; then
  printf 'ERROR: CLICKHOUSE_DB must be demo\n' >&2
  exit 1
fi

admin_client=(
  clickhouse-client
  --host 127.0.0.1
  --user "$CLICKHOUSE_USER"
  --password "$CLICKHOUSE_PASSWORD"
)

"${admin_client[@]}" \
  --param_training_user="$DB_USER" \
  --param_training_password="$DB_PASSWORD" \
  --multiquery \
  --query "
    CREATE ROLE IF NOT EXISTS sql_lab_training;
    CREATE USER IF NOT EXISTS {training_user:Identifier}
      IDENTIFIED WITH sha256_password BY {training_password:String};
    GRANT SELECT, INSERT, CREATE TABLE, CREATE VIEW, ALTER, TRUNCATE,
      OPTIMIZE, DROP TABLE, DROP VIEW ON demo.* TO sql_lab_training;
    GRANT CREATE TEMPORARY TABLE ON *.* TO sql_lab_training;
  "

# ClickHouse 26.3 accepts query parameters in CREATE/ALTER USER, including the
# password value, but not in the grantee position of GRANT. DB_USER has already
# been restricted to a plain ASCII identifier before this statement is built.
"${admin_client[@]}" \
  --query "GRANT sql_lab_training TO \`${DB_USER}\`"

"${admin_client[@]}" \
  --param_training_user="$DB_USER" \
  --query "ALTER USER {training_user:Identifier} DEFAULT ROLE sql_lab_training"

printf 'ClickHouse training role and user initialized.\n'
