#!/bin/bash

# Validate All Blog Posts
# Validates all markdown blog posts in posts/ directory
# against blog post quality standards.
# Fails immediately if any validation fails (unless -k flag is used).

set -o errexit
set -o nounset
set -o pipefail

readonly SUCCESS=0
readonly FAILURE=1

# Script name for usage messages
SCRIPT_NAME="$(basename "$0")"

# Default cache behavior (matches check.sh default)
CACHE_ENABLED=true

# Print usage information
usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [-h|--help] [-v|--verbose] [-c|--no-cache] [-k|--continue] [-d|--directory DIRECTORY]

Validates all blog post markdown files against blog post quality standards.

Options:
  -h, --help             Show this help message and exit.
  -v, --verbose          Verbose output (show all checks, not just failures).
  -c, --no-cache         Disable caching of validation results.
  -k, --continue         Continue validation on failure (don't fail-fast).
  -d, --directory DIRECTORY  Directory to search for posts (default: posts/).

Exit Codes:
  ${SUCCESS}    All checks passed.
  ${FAILURE}    One or more checks failed.

Examples:
  ${SCRIPT_NAME}                          # Validate all posts in posts/
  ${SCRIPT_NAME} --help                   # Show this help message
  ${SCRIPT_NAME} -v                      # Verbose output
  ${SCRIPT_NAME} --verbose               # Verbose output (long form)
  ${SCRIPT_NAME} -c                      # Disable cache
  ${SCRIPT_NAME} --no-cache             # Disable cache (long form)
  ${SCRIPT_NAME} -k                      # Continue on failure
  ${SCRIPT_NAME} --continue              # Continue on failure (long form)
  ${SCRIPT_NAME} -d custom/posts/        # Validate posts in custom directory
  ${SCRIPT_NAME} --directory custom/posts/ # Validate posts in custom directory (long form)
  ${SCRIPT_NAME} -v -c -k                # Verbose, no cache, continue on failure
EOF
}

# Parse command line options
main() {
  local opt
  local continue_on_failure="false"
  local posts_dir="posts/"
  local VERBOSE="false"

  # Handle long options first
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help)
        usage
        exit "$SUCCESS"
        ;;
      --verbose)
        VERBOSE="true"
        shift
        ;;
      --no-cache)
        CACHE_ENABLED="false"
        shift
        ;;
      --continue)
        continue_on_failure="true"
        shift
        ;;
      --directory)
        posts_dir="${2%/}/"
        shift 2
        ;;
      --directory=*)
        posts_dir="${1#*=}"
        posts_dir="${posts_dir%/}/"
        shift
        ;;
      -*)
        # Short options
        break
        ;;
      *)
        break
        ;;
    esac
  done

  # Parse short options
  while getopts "hcvkd:" opt; do
    case "$opt" in
      h)
        usage
        exit "$SUCCESS"
        ;;
      v)
        VERBOSE="true"
        ;;
      c)
        CACHE_ENABLED="false"
        ;;
      k)
        continue_on_failure="true"
        ;;
      d)
        posts_dir="${OPTARG%/}/"
        ;;
      *)
        echo "Unknown option: -$opt" >&2
        usage
        exit "$FAILURE"
        ;;
    esac
  done
  shift $((OPTIND - 1))

  # Validate posts directory exists
  if [[ ! -d "$posts_dir" ]]; then
    echo "Error: Directory '$posts_dir' not found." >&2
    exit "$FAILURE"
  fi

  # Find all markdown files in the specified directory, excluding those starting with underscore
  local failed=0
  local total=0
  local passed=0
  local failed_files=()

  echo "Validating all posts in: $posts_dir"
  echo "----------------------------------------"

  while IFS= read -r file; do
    ((total++)) || true
    echo "[$total] Validating: $file"

    # Build the validate command with flags
    local validate_cmd
    validate_cmd="$(dirname "$0")/check.sh"

    if [[ "$VERBOSE" == "true" ]]; then
      validate_cmd+=" -v"
    fi

    if [[ "$CACHE_ENABLED" == "false" ]]; then
      validate_cmd+=" -c"
    fi

    # Run validation
    if $validate_cmd "$file"; then
      ((passed++)) || true
      echo "Status: PASSED"
    else
      ((failed++)) || true
      echo "Status: FAILED" >&2
      failed_files+=("$file")

      if [[ "$continue_on_failure" == "false" ]]; then
        echo ""
        echo "Validation failed for: $file" >&2
        echo "Use -k flag to continue validation of all posts." >&2
        exit "$FAILURE"
      fi
    fi
    echo ""
  done < <(find "$posts_dir" -name '*.md' -type f ! -name '_*' | sort)

  # Print summary
  echo "========================================"
  echo "Validation Summary"
  echo "========================================"
  echo "Total posts:       $total"
  echo "Passed:            $passed"
  echo "Failed:            $failed"

  if [[ $failed -gt 0 ]]; then
    echo ""
    echo "Failed posts:"
    for file in "${failed_files[@]}"; do
      echo "  - $file"
    done
    exit "$FAILURE"
  else
    echo ""
    echo "All $total posts validated successfully!"
    exit "$SUCCESS"
  fi
}

main "$@"
