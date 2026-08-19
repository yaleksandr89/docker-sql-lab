#!/usr/bin/env bash
set -Eeuo pipefail

# This is a non-interactive acceptance check and must never consume caller stdin.
exec </dev/null

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

training_client=(
  clickhouse-client
  --host 127.0.0.1
  --user "$DB_USER"
  --password "$DB_PASSWORD"
  --database "$CLICKHOUSE_DB"
  --async_insert=0
)
admin_client=(
  clickhouse-client
  --host 127.0.0.1
  --user "$CLICKHOUSE_USER"
  --password "$CLICKHOUSE_PASSWORD"
)

"${training_client[@]}" --multiquery --query "
  DROP VIEW IF EXISTS demo.training_access_view;
  DROP TABLE IF EXISTS demo.training_access_check;
  CREATE TABLE demo.training_access_check (value UInt32) ENGINE = MergeTree ORDER BY value;
  INSERT INTO demo.training_access_check VALUES (1), (2);
  ALTER TABLE demo.training_access_check ADD COLUMN note String DEFAULT 'ok';
  CREATE VIEW demo.training_access_view AS
    SELECT value, note FROM demo.training_access_check;
  SELECT throwIf(count() != 2) FROM demo.training_access_view FORMAT Null;
  OPTIMIZE TABLE demo.training_access_check FINAL;
  TRUNCATE TABLE demo.training_access_check;
  INSERT INTO demo.training_access_check VALUES (3, 'after-truncate');
  SELECT throwIf(sum(value) != 3) FROM demo.training_access_check FORMAT Null;
  DROP VIEW demo.training_access_view;
  DROP TABLE demo.training_access_check;
  CREATE TEMPORARY TABLE training_temp (value UInt8);
  INSERT INTO training_temp VALUES (7);
  SELECT throwIf(sum(value) != 7) FROM training_temp FORMAT Null;
"

expect_denied() {
  local boundary_name="$1"
  local query="$2"

  if "${training_client[@]}" --query "$query" >/dev/null 2>&1; then
    printf 'ERROR: DB_USER unexpectedly crossed boundary: %s\n' "$boundary_name" >&2
    return 1
  fi
}

if "${training_client[@]}" --query 'CREATE DATABASE sql_lab_forbidden' >/dev/null 2>&1; then
  "${admin_client[@]}" --query 'DROP DATABASE IF EXISTS sql_lab_forbidden'
  printf 'ERROR: DB_USER unexpectedly has CREATE DATABASE\n' >&2
  exit 1
fi
"${admin_client[@]}" --query 'CREATE DATABASE sql_lab_drop_boundary'
if "${training_client[@]}" --query 'DROP DATABASE sql_lab_drop_boundary' >/dev/null 2>&1; then
  printf 'ERROR: DB_USER unexpectedly has DROP DATABASE\n' >&2
  exit 1
fi
"${admin_client[@]}" --query 'DROP DATABASE sql_lab_drop_boundary'

if "${training_client[@]}" --query 'CREATE USER sql_lab_forbidden_user' >/dev/null 2>&1; then
  "${admin_client[@]}" --query 'DROP USER IF EXISTS sql_lab_forbidden_user'
  printf 'ERROR: DB_USER unexpectedly has CREATE USER\n' >&2
  exit 1
fi
if "${training_client[@]}" --query 'CREATE ROLE sql_lab_forbidden_role' >/dev/null 2>&1; then
  "${admin_client[@]}" --query 'DROP ROLE IF EXISTS sql_lab_forbidden_role'
  printf 'ERROR: DB_USER unexpectedly has CREATE ROLE\n' >&2
  exit 1
fi
expect_denied 'SYSTEM privilege' 'SYSTEM FLUSH LOGS'
expect_denied 'GRANT OPTION' 'GRANT SELECT ON demo.* TO sql_lab_training'

role_grants="$("${admin_client[@]}" --query 'SHOW GRANTS FOR sql_lab_training')"
if grep -Eq '(^| )ALL ON \*\.\*|ACCESS MANAGEMENT|CREATE DATABASE|DROP DATABASE|SYSTEM|GRANT OPTION|ADMIN OPTION' \
    <<< "$role_grants"; then
  printf 'ERROR: sql_lab_training contains a forbidden broad privilege\n%s\n' "$role_grants" >&2
  exit 1
fi

role_membership="$("${admin_client[@]}" \
  --param_training_user="$DB_USER" \
  --query "
    SELECT granted_role_name, granted_role_is_default, with_admin_option
    FROM system.role_grants
    WHERE user_name = {training_user:String}
    FORMAT TSVRaw
  ")"
if [[ "$role_membership" != $'sql_lab_training\t1\t0' ]]; then
  printf 'ERROR: unexpected DB_USER role membership: %q\n' "$role_membership" >&2
  exit 1
fi

shape="$("${training_client[@]}" --query "
  SELECT
    sum(category_count),
    min(min_dimension),
    max(max_dimension),
    count(),
    min(category_count),
    max(category_count)
  FROM
  (
    SELECT
      category,
      count() AS category_count,
      min(length(embedding)) AS min_dimension,
      max(length(embedding)) AS max_dimension
    FROM demo.vector_items
    GROUP BY category
  )
  FORMAT TSVRaw
")"
if [[ "$shape" != $'131072\t32\t32\t8\t16384\t16384' ]]; then
  printf 'ERROR: unexpected vector demo shape: %q\n' "$shape" >&2
  exit 1
fi

anchor="CAST([10.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.], 'Array(Float32)')"

exact_result="$("${training_client[@]}" --query "
  SELECT id, category, L2Distance(embedding, $anchor)
  FROM demo.vector_items
  ORDER BY L2Distance(embedding, $anchor), id
  LIMIT 1
  SETTINGS use_skip_indexes = 0
  FORMAT TSVRaw
")"
if [[ "$exact_result" != $'0\tanalytics\t0' ]]; then
  printf 'ERROR: unexpected exact vector result: %q\n' "$exact_result" >&2
  exit 1
fi

ann_result="$("${training_client[@]}" --query "
  SELECT id, category
  FROM demo.vector_items
  ORDER BY L2Distance(embedding, $anchor)
  LIMIT 1
  SETTINGS force_data_skipping_indices = 'embedding_hnsw'
  FORMAT TSVRaw
")"
if [[ "$ann_result" != $'0\tanalytics' ]]; then
  printf 'ERROR: unexpected ANN vector result: %q\n' "$ann_result" >&2
  exit 1
fi

index_plan="$("${training_client[@]}" --query "
  EXPLAIN indexes = 1
  SELECT id, category
  FROM demo.vector_items
  ORDER BY L2Distance(embedding, $anchor)
  LIMIT 10
")"
if ! grep -Fq 'Name: embedding_hnsw' <<< "$index_plan"; then
  printf 'ERROR: EXPLAIN did not select embedding_hnsw\n%s\n' "$index_plan" >&2
  exit 1
fi
if ! awk '
  /Name: embedding_hnsw/ { in_vector_index = 1; next }
  in_vector_index && /Granules:/ {
    split($2, granules, "/")
    exit !((granules[1] + 0) < (granules[2] + 0))
  }
  END { if (!in_vector_index) exit 1 }
' <<< "$index_plan"; then
  printf 'ERROR: embedding_hnsw did not reduce selected granules\n%s\n' "$index_plan" >&2
  exit 1
fi

printf 'ClickHouse DB_USER access and vector index checks passed.\n'
