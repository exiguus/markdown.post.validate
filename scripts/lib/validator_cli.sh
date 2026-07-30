#!/bin/bash

# Validator CLI parsing and input validation helpers.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Parsed CLI values (set by parse_validator_cli_args).
# shellcheck disable=SC2034
CLI_VERBOSE="false"
# shellcheck disable=SC2034
CLI_CACHE_ENABLED="true"
# shellcheck disable=SC2034
CLI_FILE_PATH=""

# Parse validator CLI arguments.
# Supports short and long options used by scripts/check.sh.
# Args:
#   $@: Raw CLI arguments
# Returns:
#   0 on success, 1 on invalid arguments
parse_validator_cli_args() {
  CLI_VERBOSE="false"
  CLI_CACHE_ENABLED="$CACHE_ENABLED"
  CLI_FILE_PATH=""

  # Handle long options first to keep getopts focused on short flags.
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help)
        usage
        return "$SUCCESS"
        ;;
      --verbose)
        CLI_VERBOSE="true"
        shift
        ;;
      --no-cache)
        CLI_CACHE_ENABLED="false"
        shift
        ;;
      -*)
        break
        ;;
      *)
        break
        ;;
    esac
  done

  # Parse short options.
  OPTIND=1
  while getopts "hvc" opt; do
    case "$opt" in
      h)
        usage
        return "$SUCCESS"
        ;;
      v)
        CLI_VERBOSE="true"
        ;;
      c)
        CLI_CACHE_ENABLED="false"
        ;;
      *)
        echo "Unknown option: -$opt" >&2
        usage
        return "$FAILURE"
        ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ $# -ne 1 ]]; then
    echo "Error: Missing file argument." >&2
    usage
    return "$FAILURE"
  fi

  CLI_FILE_PATH="$1"
  return "$SUCCESS"
}

# Validate that the target file exists and is readable.
# Args:
#   $1: File path
# Returns:
#   0 if valid, 1 if missing or unreadable
validate_target_file() {
  local file_path="$1"

  if [[ ! -f "$file_path" ]]; then
    echo "Error: File '$file_path' not found." >&2
    return "$FAILURE"
  fi

  if [[ ! -r "$file_path" ]]; then
    echo "Error: Cannot read file '$file_path'." >&2
    return "$FAILURE"
  fi

  return "$SUCCESS"
}