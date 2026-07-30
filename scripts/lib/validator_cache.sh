#!/bin/bash

# Validator cache helpers.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Compute validation cache key.
# Args:
#   $1: File path
#   $2: Verbose flag (optional, default: false)
# Returns: Cache key with va_ prefix
compute_validation_cache_key() {
  local file_path="$1"
  local verbose_flag="${2:-false}"

  local source_files=(
    "$0"
    "${SCRIPT_DIR}/config/checks.cfg"
    "${SCRIPT_DIR}/lib/cache.sh"
    "${SCRIPT_DIR}/lib/validator_cache.sh"
    "${SCRIPT_DIR}/lib/validator_checks_accessibility.sh"
    "${SCRIPT_DIR}/lib/validator_checks_frontmatter.sh"
    "${SCRIPT_DIR}/lib/validator_checks_links.sh"
    "${SCRIPT_DIR}/lib/validator_checks_structure.sh"
    "${SCRIPT_DIR}/lib/validator_execution.sh"
    "${SCRIPT_DIR}/lib/validator_output.sh"
    "${SCRIPT_DIR}/lib/validator_runner.sh"
    "${SCRIPT_DIR}/lib/validator_summary.sh"
  )

  # Hash each validator source file so refactors invalidate stale cache entries.
  local validator_sources_hash_input=""
  local src_file
  for src_file in "${source_files[@]}"; do
    local src_hash
    if [[ -f "$src_file" ]]; then
      src_hash=$(sha256sum "$src_file" 2>/dev/null | awk '{print $1}') || true
      validator_sources_hash_input+="${src_file}:${src_hash}_"
    else
      validator_sources_hash_input+="${src_file}:missing_"
    fi
  done

  local schema_version="${CACHE_SCHEMA_VERSION:-v1}"

  local validator_sources_hash
  validator_sources_hash=$(echo -n "${schema_version}_${validator_sources_hash_input}" | sha256sum 2>/dev/null | awk '{print $1}') || true

  local file_hash
  file_hash=$(sha256sum "$file_path" 2>/dev/null | awk '{print $1}') || true

  # Hash the verbose flag.
  local flags_hash
  flags_hash=$(echo -n "${verbose_flag}" | sha256sum 2>/dev/null | awk '{print $1}') || true

  # Combine the hashes and hash again to get a single hash.
  local combined_hash
  combined_hash=$(echo -n "${validator_sources_hash}_${file_hash}_${flags_hash}" | sha256sum 2>/dev/null | awk '{print $1}') || true

  # Add va_ prefix to avoid collisions and identify validation cache files.
  echo "${VALIDATION_CACHE_PREFIX}${combined_hash}"
}

# Wrapper function for cache get operation.
# Keys from compute_validation_cache_key already include the prefix.
# Args:
#   $1: Cache key
get_cached_result() {
  local result
  result=$(cache_get_validation_by_key "$1")
  if [[ -n "$result" ]]; then
    echo "$result"
    return 0
  else
    return 1
  fi
}

# Wrapper function for cache set operation.
# Keys from compute_validation_cache_key already include the prefix.
# Args:
#   $1: Cache key
store_cached_result() {
  cache_set_validation_by_key "$1" ""
}
