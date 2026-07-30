#!/bin/bash

# Validator command orchestration helpers.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

readonly SUCCESS=0
readonly FAILURE=1

# Script name used by usage output.
# shellcheck disable=SC2034
SCRIPT_NAME=""

# Initialize validator shared state.
bootstrap_validator() {
  SCRIPT_NAME="$(basename "$0")"
  cache_init
  init_validator_runtime
}

# Execute validator command flow.
# Args:
#   $@: Raw CLI arguments
# Returns:
#   0 if validation passes (or help requested), 1 on failure
run_validator_command() {
  if ! parse_validator_cli_args "$@"; then
    return "$FAILURE"
  fi

  # Help mode returns success after printing usage.
  if [[ -z "$CLI_FILE_PATH" ]]; then
    return "$SUCCESS"
  fi

  if ! validate_target_file "$CLI_FILE_PATH"; then
    return "$FAILURE"
  fi

  if run_validation_with_cache "$CLI_FILE_PATH" "$CLI_VERBOSE" "$CLI_CACHE_ENABLED"; then
    return "$SUCCESS"
  fi

  return "$FAILURE"
}