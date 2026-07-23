#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "${script_dir}/.." && pwd)"
cd -- "${project_dir}"

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[[ -f .docker.env ]] || fail '.docker.env is required; run make init first'

set -a
source .docker.env
set +a

for variable_name in COMPOSE_PROJECT_NAME DB_USER DB_PASSWORD; do
  [[ -n "${!variable_name:-}" ]] || fail "${variable_name} is required in .docker.env"
done

compose=(docker compose --env-file .docker.env -p "${COMPOSE_PROJECT_NAME}")
temp_dir="$(mktemp -d)"
mysql_table=''
postgres_table=''
mysql_cleanup_needed=false
postgres_cleanup_needed=false

assert_safe_identifier() {
  local identifier="$1"

  [[ "${identifier}" =~ ^[a-z][a-z0-9_]{0,62}$ ]] || \
    fail "generated unsafe SQL identifier: ${identifier}"
}

mysql_query() {
  local query="$1"

  "${compose[@]}" exec -T \
    -e IMPORT_DATABASE=demo \
    -e IMPORT_QUERY="${query}" \
    mysql sh -c 'MYSQL_PWD="$DB_PASSWORD" exec mysql --host=127.0.0.1 --user="$DB_USER" --batch --skip-column-names "$IMPORT_DATABASE" --execute "$IMPORT_QUERY"'
}

postgres_query() {
  local query="$1"

  "${compose[@]}" exec -T \
    -e IMPORT_DATABASE=demo \
    -e IMPORT_QUERY="${query}" \
    postgres sh -c 'PGPASSWORD="$DB_PASSWORD" exec psql --host=127.0.0.1 --username="$DB_USER" --dbname="$IMPORT_DATABASE" --no-psqlrc --set=ON_ERROR_STOP=1 --tuples-only --no-align --command="$IMPORT_QUERY"'
}

drop_smoke_tables() {
  local cleanup_failed=0

  if [[ "${mysql_cleanup_needed}" == true ]]; then
    if mysql_query "DROP TABLE IF EXISTS \`${mysql_table}\`;" >/dev/null; then
      mysql_cleanup_needed=false
    else
      printf 'ERROR: failed to remove MySQL smoke table\n' >&2
      cleanup_failed=1
    fi
  fi
  if [[ "${postgres_cleanup_needed}" == true ]]; then
    if postgres_query "DROP TABLE IF EXISTS public.${postgres_table};" >/dev/null; then
      postgres_cleanup_needed=false
    else
      printf 'ERROR: failed to remove PostgreSQL smoke table\n' >&2
      cleanup_failed=1
    fi
  fi

  return "${cleanup_failed}"
}

cleanup() {
  local exit_status=$?
  local cleanup_failed=0
  local final_status

  trap - EXIT
  set +e

  if ! drop_smoke_tables; then
    cleanup_failed=1
  fi
  if ! rm -rf -- "${temp_dir}"; then
    printf 'ERROR: failed to remove smoke-test temporary directory\n' >&2
    cleanup_failed=1
  fi
  if ((cleanup_failed)); then
    printf 'ERROR: trusted SQL import smoke-test cleanup failed\n' >&2
  fi

  final_status="${exit_status}"
  if ((exit_status == 0 && cleanup_failed)); then
    final_status=1
  fi

  exit "${final_status}"
}
trap cleanup EXIT

make --no-print-directory wait-mysql
make --no-print-directory wait-postgres

suffix="$(date +%s)_$$_${RANDOM}"
mysql_table="sql_import_smoke_mysql_${suffix}"
postgres_table="sql_import_smoke_postgres_${suffix}"
mysql_marker="mysql_import_marker_${suffix}"
postgres_marker="postgres_import_marker_${suffix}"

assert_safe_identifier "${mysql_table}"
assert_safe_identifier "${postgres_table}"

[[ "$(mysql_query "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = '${mysql_table}';")" == 0 ]] || \
  fail "MySQL smoke table already exists: ${mysql_table}"
[[ "$(postgres_query "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '${postgres_table}';")" == 0 ]] || \
  fail "PostgreSQL smoke table already exists: ${postgres_table}"

mysql_sql="${temp_dir}/mysql-import.sql"
postgres_sql="${temp_dir}/postgres-import.sql"

printf 'CREATE TABLE `%s` (marker VARCHAR(255) NOT NULL);\nINSERT INTO `%s` (marker) VALUES (\047%s\047);\n' \
  "${mysql_table}" "${mysql_table}" "${mysql_marker}" > "${mysql_sql}"
printf 'CREATE TABLE public.%s (marker TEXT NOT NULL);\nINSERT INTO public.%s (marker) VALUES (\047%s\047);\n' \
  "${postgres_table}" "${postgres_table}" "${postgres_marker}" > "${postgres_sql}"

mysql_cleanup_needed=true
make mysql-import FILE="${mysql_sql}" DATABASE=demo
[[ "$(mysql_query "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = '${mysql_table}';")" == 1 ]] || \
  fail "MySQL smoke table was not created: ${mysql_table}"
[[ "$(mysql_query "SELECT marker FROM \`${mysql_table}\`;")" == "${mysql_marker}" ]] || \
  fail 'MySQL smoke marker did not match'

postgres_cleanup_needed=true
make postgres-import FILE="${postgres_sql}" DATABASE=demo
[[ "$(postgres_query "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '${postgres_table}';")" == 1 ]] || \
  fail "PostgreSQL smoke table was not created: ${postgres_table}"
[[ "$(postgres_query "SELECT marker FROM public.${postgres_table};")" == "${postgres_marker}" ]] || \
  fail 'PostgreSQL smoke marker did not match'

drop_smoke_tables
[[ "$(mysql_query "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = '${mysql_table}';")" == 0 ]] || \
  fail "MySQL smoke table still exists: ${mysql_table}"
[[ "$(postgres_query "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '${postgres_table}';")" == 0 ]] || \
  fail "PostgreSQL smoke table still exists: ${postgres_table}"

printf 'PASS: trusted SQL import smoke tests completed\n'
