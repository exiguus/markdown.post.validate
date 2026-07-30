#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Relative Links Tests
# Follows Google Shell Style Guide.

# Guard: only source framework and print summary when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  source "$(dirname "${0:-}")/test_framework.sh"
fi

echo "======================================="
echo "Relative Links Tests (A3)"
echo "======================================="
echo ""

run_test "Relative links should not cause A3 failures" \
  "relative_links.md" \
  0 \
  "Post with @/, ./, ../, / links should pass A3 (relative links excluded)"

# Print category summary only when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_summary "Relative Links "
  if [[ ${failed:-0} -gt 0 ]]; then
    exit 1
  else
    exit 0
  fi
fi
