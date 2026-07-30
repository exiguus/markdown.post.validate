#!/bin/bash

# Validator cache-aware execution helpers.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Validate a single file with cache support and CLI-style exit behavior.
# Args:
#   $1: File path
#   $2: Verbose flag (true/false)
#   $3: Cache enabled (true/false)
run_validation_with_cache() {
  local file_path="$1"
  local verbose="$2"
  local cache_enabled="$3"

  # Check cache if enabled.
  local cache_key=""
  if [[ "$cache_enabled" == "true" ]]; then
    cache_key=$(compute_validation_cache_key "$file_path" "$verbose")
    local cached_output
    if cached_output=$(get_cached_result "$cache_key" 2>/dev/null); then
      echo "$cached_output"
      return "$SUCCESS"
    fi
  fi

  # Set up temp file for capturing validation output.
  local temp_output_file
  temp_output_file=$(mktemp) || {
    echo "Error: Cannot create temp file" >&2
    return "$FAILURE"
  }

  # Run validation and capture output while preserving its exit status.
  local exit_code
  if run_validation "$file_path" "$verbose" >"$temp_output_file" 2>&1; then
    exit_code="$SUCCESS"
  else
    exit_code="$FAILURE"
  fi

  # Replay captured output to stdout.
  cat "$temp_output_file"

  # Store full output in cache if enabled and result is PASSED.
  if [[ "$cache_enabled" == "true" && "$exit_code" == "$SUCCESS" ]]; then
    cat "$temp_output_file" | store_cached_result "$cache_key"
  fi

  # Clean up temp file.
  rm -f "$temp_output_file"

  return "$exit_code"
}