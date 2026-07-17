#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
validator="$script_dir/validate-storage-paths.sh"
temp_dir="$(mktemp -d)"
project_dir="$temp_dir/project"
outside_dir="$temp_dir/outside"
failures=0

cleanup() {
  rm -rf -- "$temp_dir"
}
trap cleanup EXIT

mkdir -p \
  "$project_dir/data/mysql" \
  "$project_dir/data/postgres" \
  "$project_dir/samples/mysql" \
  "$project_dir/samples/postgres" \
  "$outside_dir"

run_validator() {
  local mysql_data="${1-$project_dir/data/mysql}"
  local postgres_data="${2-$project_dir/data/postgres}"
  local mysql_samples="${3-$project_dir/samples/mysql}"
  local postgres_samples="${4-$project_dir/samples/postgres}"

  "$validator" \
    --project-dir "$project_dir" \
    --mysql-data "$mysql_data" \
    --postgres-data "$postgres_data" \
    --mysql-samples "$mysql_samples" \
    --postgres-samples "$postgres_samples"
}

expect_accept() {
  local case_name="$1"
  shift

  if ! run_validator "$@" >/dev/null 2>&1; then
    printf 'FAIL: positive case %q was rejected\n' "$case_name" >&2
    failures=$((failures + 1))
  fi
}

expect_reject() {
  local case_name="$1"
  shift

  if run_validator "$@" >/dev/null 2>&1; then
    printf 'FAIL: negative case %q was accepted\n' "$case_name" >&2
    failures=$((failures + 1))
  fi
}

expect_accept 'default managed paths'
expect_accept 'relative data and sample paths' \
  'data/mysql' \
  'data/postgres' \
  'samples/mysql' \
  'samples/postgres'
expect_accept 'other names strictly inside their roots' \
  "$project_dir/data/mysql-v2" \
  "$project_dir/data/postgres-v2" \
  "$project_dir/samples/mysql-extra" \
  "$project_dir/samples/postgres-extra"

fresh_clone_project_dir="$temp_dir/fresh-clone"
mkdir -p "$fresh_clone_project_dir"
if ! "$validator" \
  --project-dir "$fresh_clone_project_dir" \
  --mysql-data 'data/mysql' \
  --postgres-data 'data/postgres' \
  --mysql-samples 'samples/mysql' \
  --postgres-samples 'samples/postgres' \
  >/dev/null 2>&1; then
  printf 'FAIL: positive case %q was rejected\n' 'fresh clone without managed directories' >&2
  failures=$((failures + 1))
fi
if [[ -e "$fresh_clone_project_dir/data" || -e "$fresh_clone_project_dir/samples" ]]; then
  printf 'FAIL: validator created managed directories in %q\n' "$fresh_clone_project_dir" >&2
  failures=$((failures + 1))
fi

docs_project_dir="$temp_dir/docs/projects/sql-lab"
mkdir -p \
  "$docs_project_dir/data/mysql" \
  "$docs_project_dir/data/postgres" \
  "$docs_project_dir/samples/mysql" \
  "$docs_project_dir/samples/postgres"
if ! "$validator" \
  --project-dir "$docs_project_dir" \
  --mysql-data "$docs_project_dir/data/mysql" \
  --postgres-data "$docs_project_dir/data/postgres" \
  --mysql-samples "$docs_project_dir/samples/mysql" \
  --postgres-samples "$docs_project_dir/samples/postgres" \
  >/dev/null 2>&1; then
  printf 'FAIL: positive case %q was rejected\n' 'project under docs/projects/sql-lab' >&2
  failures=$((failures + 1))
fi

expect_reject '.git' "$project_dir/.git"
expect_reject '.github' "$project_dir/data/mysql" "$project_dir/data/postgres" "$project_dir/.github"
expect_reject 'project root' "$project_dir"
expect_reject 'data root' "$project_dir/data"
expect_reject 'samples root' "$project_dir/data/mysql" "$project_dir/data/postgres" "$project_dir/samples"
expect_reject 'outside directory' "$outside_dir"
expect_reject 'relative outside directory' '../outside'
expect_reject 'empty path' ''
expect_reject 'filesystem root' '/'

for reserved_component in .git .github initdb conf adminer backup .tmp docs scripts; do
  expect_reject "reserved component $reserved_component" \
    "$project_dir/data/$reserved_component/mysql"
done

ln -s "$project_dir/data/mysql" "$project_dir/data/mysql-link"
expect_reject 'symlink managed path' "$project_dir/data/mysql-link"

ln -s "$outside_dir" "$project_dir/data/escape"
expect_reject 'symlink component outside project' "$project_dir/data/escape/nested"

expect_reject 'same data paths' "$project_dir/data/mysql" "$project_dir/data/mysql"
expect_reject 'nested data paths' "$project_dir/data/mysql" "$project_dir/data/mysql/nested"
expect_reject 'same sample paths' \
  "$project_dir/data/mysql" \
  "$project_dir/data/postgres" \
  "$project_dir/samples/mysql" \
  "$project_dir/samples/mysql"
expect_reject 'nested sample paths' \
  "$project_dir/data/mysql" \
  "$project_dir/data/postgres" \
  "$project_dir/samples/mysql" \
  "$project_dir/samples/mysql/nested"
expect_reject 'sample inside data' \
  "$project_dir/data/mysql" \
  "$project_dir/data/postgres" \
  "$project_dir/data/mysql/sample"
expect_reject 'data inside sample' \
  "$project_dir/samples/mysql/data" \
  "$project_dir/data/postgres"

if ((failures > 0)); then
  printf 'FAIL: %d storage-path test case(s) failed\n' "$failures" >&2
  exit 1
fi

printf 'PASS: storage-path validator tests completed\n'
