#!/bin/bash

# Validator runner/orchestration helpers.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Run all configured checks and print summary.
# Args:
#   $1: File path
#   $2: Verbose flag (true/false)
run_validation() {
  local file_path="$1"
  local verbose="$2"

  echo "Validating: $file_path"
  echo "----------------------------------------"

  # Read file content.
  local content
  content=$(cat "$file_path") || {
    echo "Error: Cannot read file '$file_path'" >&2
    return "$FAILURE"
  }


  run_configured_checks "$file_path" "$verbose" "$content"
  print_validation_summary
  print_validation_result
}
