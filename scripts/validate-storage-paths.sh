#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: validate-storage-paths.sh \
  --project-dir PATH \
  --mysql-data PATH \
  --postgres-data PATH \
  --mysql-samples PATH \
  --postgres-samples PATH
USAGE
}

reject() {
  local variable_name="$1"
  local rejected_path="$2"
  local reason="$3"

  printf 'ERROR: %s: rejected path %q (%s)\n' \
    "$variable_name" "$rejected_path" "$reason" >&2
  exit 1
}

require_value() {
  local variable_name="$1"
  local value="$2"

  [[ -n "$value" ]] || reject "$variable_name" "$value" 'path must not be empty'
}

is_strict_descendant() {
  local parent="$1"
  local child="$2"

  [[ "$child" == "$parent/"* ]]
}

contains_reserved_component() {
  local managed_path="$1"
  local component
  local -a components
  local -a reserved_components=(.git .github initdb conf adminer backup .tmp docs scripts)

  IFS='/' read -r -a components <<< "$managed_path"
  for component in "${components[@]}"; do
    case "$component" in
      ''|.|..|data|samples) ;;
      *)
        local reserved
        for reserved in "${reserved_components[@]}"; do
          [[ "$component" == "$reserved" ]] && return 0
        done
        ;;
    esac
  done

  return 1
}

has_symlink_component() {
  local path="$1"
  local component
  local current=/
  local -a components

  IFS='/' read -r -a components <<< "$path"
  for component in "${components[@]}"; do
    case "$component" in
      ''|.) continue ;;
      ..) current="$current/.." ;;
      *) current="$current/$component" ;;
    esac

    [[ -L "$current" ]] && return 0
  done

  return 1
}

project_dir=''
mysql_data=''
postgres_data=''
mysql_samples=''
postgres_samples=''

while (($#)); do
  case "$1" in
    --project-dir|--mysql-data|--postgres-data|--mysql-samples|--postgres-samples)
      (($# >= 2)) || { usage; exit 2; }
      case "$1" in
        --project-dir) project_dir="$2" ;;
        --mysql-data) mysql_data="$2" ;;
        --postgres-data) postgres_data="$2" ;;
        --mysql-samples) mysql_samples="$2" ;;
        --postgres-samples) postgres_samples="$2" ;;
      esac
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'ERROR: unknown argument: %s\n' "$1" >&2
      usage
      exit 2
      ;;
  esac
done

require_value PROJECT_DIR "$project_dir"
require_value MYSQL_DATA_DIR "$mysql_data"
require_value POSTGRES_DATA_DIR "$postgres_data"
require_value MYSQL_SAMPLES_DIR "$mysql_samples"
require_value POSTGRES_SAMPLES_DIR "$postgres_samples"

project_dir_abs="$(realpath -m -- "$project_dir")"
[[ -d "$project_dir_abs" ]] || reject PROJECT_DIR "$project_dir" 'project directory does not exist'

data_root="$project_dir_abs/data"
samples_root="$project_dir_abs/samples"

variable_names=(MYSQL_DATA_DIR POSTGRES_DATA_DIR MYSQL_SAMPLES_DIR POSTGRES_SAMPLES_DIR)
raw_paths=("$mysql_data" "$postgres_data" "$mysql_samples" "$postgres_samples")
allowed_roots=("$data_root" "$data_root" "$samples_root" "$samples_root")
resolved_paths=()

for index in "${!variable_names[@]}"; do
  variable_name="${variable_names[$index]}"
  raw_path="${raw_paths[$index]}"
  allowed_root="${allowed_roots[$index]}"

  if [[ "$raw_path" == /* ]]; then
    path_to_inspect="$raw_path"
  else
    path_to_inspect="$project_dir_abs/$raw_path"
  fi

  if has_symlink_component "$path_to_inspect"; then
    reject "$variable_name" "$raw_path" 'managed path contains a symbolic-link component'
  fi

  resolved_path="$(realpath -m -- "$path_to_inspect")"
  if ! is_strict_descendant "$allowed_root" "$resolved_path"; then
    reject "$variable_name" "$raw_path" "must be strictly inside $allowed_root"
  fi

  managed_path="${resolved_path#"$project_dir_abs"/}"
  if contains_reserved_component "$managed_path"; then
    reject "$variable_name" "$raw_path" 'managed path contains a reserved component'
  fi

  resolved_paths[$index]="$resolved_path"
done

for ((left = 0; left < ${#resolved_paths[@]}; left++)); do
  for ((right = left + 1; right < ${#resolved_paths[@]}; right++)); do
    left_path="${resolved_paths[$left]}"
    right_path="${resolved_paths[$right]}"

    if [[ "$left_path" == "$right_path" ]]; then
      reject "${variable_names[$left]}" "${raw_paths[$left]}" \
        "must not match ${variable_names[$right]}"
    fi

    if is_strict_descendant "$left_path" "$right_path" || \
       is_strict_descendant "$right_path" "$left_path"; then
      reject "${variable_names[$left]}" "${raw_paths[$left]}" \
        "must not be nested with ${variable_names[$right]}"
    fi
  done
done
