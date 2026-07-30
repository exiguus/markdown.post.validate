#!/bin/bash

# Shared bootstrap for checks test suites.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/../test_framework.sh"

# Print common category header.
# Args:
#   $1: Category title
begin_category() {
  local title="$1"
  echo "======================================="
  echo "$title"
  echo "======================================="
  echo ""
}

# Print summary and exit when test is executed directly.
# Args:
#   $1: Summary prefix (e.g. "Content ")
#   $2: BASH_SOURCE[0] from caller
#   $3: 0 from caller
end_category_if_direct() {
  local summary_prefix="$1"
  local source_file="$2"
  local script_name="$3"

  if [[ "$source_file" == "$script_name" ]]; then
    print_summary "$summary_prefix"
    if [[ ${failed:-0} -gt 0 ]]; then
      exit 1
    else
      exit 0
    fi
  fi
}
