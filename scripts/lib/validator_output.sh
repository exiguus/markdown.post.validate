#!/bin/bash

# Validator output and usage helpers.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Print error message to stderr and increment failure counter.
# Args:
#   $1: Gate identifier (A1, A2, etc.)
#   $2: Error message
fail() {
  local gate="$1"
  local message="$2"
  echo -e "${RED}✗ [${gate}] ${message}${NC}" >&2
  case "$gate" in
    A*) ((gate_a_failures++)) || true ;;
    B*) ((gate_b_failures++)) || true ;;
    C*) ((gate_c_failures++)) || true ;;
    *) ((warnings++)) || true ;;
  esac
}

# Print success message.
# Args:
#   $1: Gate identifier
#   $2: Success message
pass() {
  local gate="$1"
  local message="$2"
  echo -e "${GREEN}✓ [${gate}] ${message}${NC}"
}

# Print warning message.
# Args:
#   $1: Warning identifier
#   $2: Warning message
warn() {
  local identifier="$1"
  local message="$2"
  echo -e "${YELLOW}⚠ [${identifier}] ${message}${NC}" >&2
  ((warnings++)) || true
}

# Return the best label for validation output.
# Uses the frontmatter title when present, otherwise falls back to the file path.
# Args:
#   $1: File path
#   $2: File content
format_validation_target() {
  local file_path="$1"
  local content="$2"

  local title
  title=$(awk '
    BEGIN {
      fence_count = 0
    }
    /^\+\+\+$/ {
      fence_count++
      next
    }
    fence_count == 1 && /^title = / {
      sub(/^title = "/, "")
      sub(/"$/, "")
      print
      exit
    }
    fence_count == 2 {
      exit
    }
  ' <<<"$content" || true)

  if [[ -n "$title" ]]; then
    echo "$title"
  else
    echo "$file_path"
  fi
}

# Print usage information.
usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [-h|--help] [-v|--verbose] [-c|--no-cache] FILE.md

Validates a blog post markdown file against blog post quality standards.

Arguments:
  FILE.md    Path to the markdown file to validate.

Options:
  -h, --help          Show this help message and exit.
  -v, --verbose       Verbose output (show all checks, not just failures).
  -c, --no-cache      Disable caching of validation results.

Exit Codes:
  ${SUCCESS}    All checks passed.
  ${FAILURE}    One or more checks failed.

Checks Performed:
EOF

  # Group checks by gate.
  declare -A gate_checks
  local check_id
  for check_id in "${CHECK_IDS[@]}"; do
    local gate
    gate=$(get_config "$check_id" "gate")
    if [[ -n "$gate" ]]; then
      if [[ -z "${gate_checks[$gate]:-}" ]]; then
        gate_checks["$gate"]=""
      fi
      gate_checks["$gate"]+="  $(printf "%-4s" "$check_id")$(get_config "$check_id" "category"): $(get_config "$check_id" "label")\n"
    fi
  done

  # Print checks by gate.
  local gate_letter
  for gate_letter in A B C; do
    local gate_name=""
    case "$gate_letter" in
      A) gate_name="Blocking" ;;
      B) gate_name="Quality" ;;
      C) gate_name="Accessibility & Style" ;;
    esac
    echo "  Gate ${gate_letter} (${gate_name}):"
    echo -ne "${gate_checks[$gate_letter]:-}"
  done
  echo ""
}
