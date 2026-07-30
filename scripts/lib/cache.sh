#!/bin/bash

# Shared Cache Library for Blog Post Validator
# Provides common caching functionality for check.sh and assisted_checks.sh
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Framework guard - load once
if [[ -z "${CACHE_LIB_LOADED:-}" ]]; then
  export CACHE_LIB_LOADED=1

  #######################
  # Cache Configuration  #
  #######################

  # Default cache directory - can be overridden before calling cache_init
  CACHE_DIR_DEFAULT="${HOME:-}/.cache/blog-validator"
  CACHE_ENABLED_DEFAULT=true

  # Cache prefix for different types of cache
  VALIDATION_CACHE_PREFIX="va_"    # Validation results cache
  AI_CACHE_PREFIX="ai_"             # AI check results cache
  CACHE_SCHEMA_VERSION="v2"

  #######################
  # Cache Initialization  #
  #######################

  # Initialize cache with optional custom directory
  # Args:
  #   $1: Custom cache directory (optional, defaults to CACHE_DIR_DEFAULT)
  #   $2: Custom enabled flag (optional, defaults to CACHE_ENABLED_DEFAULT)
  cache_init() {
    local custom_dir="${1:-}"
    local custom_enabled="${2:-}"

    if [[ -n "$custom_dir" ]]; then
      CACHE_DIR="$custom_dir"
    else
      CACHE_DIR="$CACHE_DIR_DEFAULT"
    fi

    if [[ -n "$custom_enabled" ]]; then
      CACHE_ENABLED="$custom_enabled"
    else
      CACHE_ENABLED="$CACHE_ENABLED_DEFAULT"
    fi

    # Create cache directory if it doesn't exist
    if [[ -n "${HOME:-}" && "$CACHE_ENABLED" == "true" ]]; then
      mkdir -p "$CACHE_DIR" || true
    fi

    export CACHE_DIR CACHE_ENABLED
  }

  #######################
  # Cache Key Generation  #
  #######################

  # Compute SHA256 hash of a string
  # Args:
  #   $1: String to hash
  # Returns: SHA256 hash via stdout
  _cache_sha256() {
    local input="$1"
    echo -n "$input" | sha256sum 2>/dev/null | awk '{print $1}' || echo ""
  }

  # Compute cache key by hashing multiple parts together
  # Args:
  #   $1: Prefix for the cache key (e.g., "va_" for validation, "ai_" for AI)
  #   $@: Additional parts to include in the hash
  # Returns: Cache key via stdout
  compute_cache_key() {
    local prefix="$1"
    shift

    local parts=("$@")
    local hash_parts=()

    # Hash each part separately
    for part in "${parts[@]}"; do
      hash_parts+=("$(_cache_sha256 "$part")")
    done

    # Combine all hashes and hash again
    local combined
    combined=$(IFS="_"; echo -n "${hash_parts[*]}")
    local final_hash
    final_hash=$(_cache_sha256 "$combined")

    echo "${prefix}${final_hash}"
  }

  #######################
  # Cache Operations     #
  #######################

  # Run a cache operation under an optional lock.
  # Args:
  #   $1: Lock token
  #   $2..: Command and arguments to execute
  _cache_run_locked() {
    local lock_token="$1"
    shift

    local lock_hash
    lock_hash=$(_cache_sha256 "$lock_token")
    local lock_file="${CACHE_DIR}/.lock.${lock_hash}"

    if command -v flock >/dev/null 2>&1; then
      local lock_fd
      exec {lock_fd}>>"$lock_file" || {
        "$@"
        return $?
      }

      if flock -w 2 "$lock_fd"; then
        "$@"
        local status=$?
        flock -u "$lock_fd" || true
        exec {lock_fd}>&-
        return "$status"
      fi

      exec {lock_fd}>&-
    fi

    "$@"
  }

  # Write cache content atomically for a full key.
  # Args:
  #   $1: Full cache key filename (includes prefix)
  #   $2: Content to cache (read from stdin if empty)
  _cache_set_by_key_unlocked() {
    local cache_key="$1"
    local content="$2"
    local cache_file="${CACHE_DIR}/${cache_key}"

    mkdir -p "$CACHE_DIR" || true

    local temp_file
    temp_file=$(mktemp "${CACHE_DIR}/.${cache_key}.tmp.XXXXXX") || return 1

    if [[ -z "$content" ]]; then
      if ! cat >"$temp_file"; then
        rm -f "$temp_file" || true
        return 1
      fi
    else
      if ! printf '%s\n' "$content" >"$temp_file"; then
        rm -f "$temp_file" || true
        return 1
      fi
    fi

    if ! mv -f "$temp_file" "$cache_file"; then
      rm -f "$temp_file" || true
      return 1
    fi

    return 0
  }

  # Remove cache entry by full key.
  # Args:
  #   $1: Full cache key filename (includes prefix)
  _cache_remove_by_key_unlocked() {
    local cache_key="$1"
    local cache_file="${CACHE_DIR}/${cache_key}"
    rm -f "$cache_file" || true
  }

  # Get cached content by full key filename.
  # Args:
  #   $1: Full cache key filename (includes prefix)
  # Returns: Cached content via stdout, or empty if not found
  cache_get_by_key() {
    local cache_key="$1"
    local cache_file="${CACHE_DIR}/${cache_key}"

    if [[ -f "$cache_file" ]]; then
      cat "$cache_file" || echo ""
      return 0
    fi

    echo ""
    return 1
  }

  # Store cached content by full key filename.
  # Args:
  #   $1: Full cache key filename (includes prefix)
  #   $2: Content to cache (read from stdin if empty)
  cache_set_by_key() {
    local cache_key="$1"
    local content="$2"
    _cache_run_locked "$cache_key" _cache_set_by_key_unlocked "$cache_key" "$content" || true
  }

  # Check whether a full-key cache entry exists.
  # Args:
  #   $1: Full cache key filename (includes prefix)
  # Returns: 0 if exists, 1 otherwise
  cache_exists_by_key() {
    local cache_key="$1"
    local cache_file="${CACHE_DIR}/${cache_key}"
    [[ -f "$cache_file" ]]
  }

  # Remove cache entry by full key filename.
  # Args:
  #   $1: Full cache key filename (includes prefix)
  cache_remove_by_key() {
    local cache_key="$1"
    _cache_run_locked "$cache_key" _cache_remove_by_key_unlocked "$cache_key" || true
  }

  # Validation cache operations (full keys).
  cache_get_validation_by_key() {
    cache_get_by_key "$1"
  }

  cache_set_validation_by_key() {
    cache_set_by_key "$1" "$2"
  }

  cache_exists_validation_by_key() {
    cache_exists_by_key "$1"
  }

  # AI cache operations (full keys).
  cache_get_ai_by_key() {
    cache_get_by_key "$1"
  }

  cache_set_ai_by_key() {
    cache_set_by_key "$1" "$2"
  }

  #######################
  # AI Check Cache Helpers #
  #######################

  # Compute AI check cache key.
  # Args:
  #   $1: Article identity token
  #   $2: Model name
  #   $3: Check ID (e.g., A2, C6)
  #   $4: Mock mode flag (0 or 1)
  #   $5: Post content hash
  #   $6: Prompt hash
  # Returns: Cache key via stdout
  compute_ai_check_cache_key() {
    local article_identity="$1"
    local model="$2"
    local check_id="$3"
    local mock_mode="$4"
    local post_content_hash="$5"
    local prompt_hash="$6"

    local schema_hash
    schema_hash=$(_cache_sha256 "$CACHE_SCHEMA_VERSION")

    local article_hash
    article_hash=$(_cache_sha256 "$article_identity")
    local model_hash
    model_hash=$(_cache_sha256 "$model")
    local mock_hash
    mock_hash=$(_cache_sha256 "$mock_mode")
    local post_hash
    post_hash=$(_cache_sha256 "$post_content_hash")
    local prompt_hash_hash
    prompt_hash_hash=$(_cache_sha256 "$prompt_hash")

    local combined
    combined=$(echo -n "${schema_hash}_${article_hash}_${model_hash}_${mock_hash}_${post_hash}_${prompt_hash_hash}")
    local suffix
    suffix=$(_cache_sha256 "$combined")

    echo "${AI_CACHE_PREFIX}${suffix}_${check_id}"
  }

fi
