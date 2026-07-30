#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Structure Tests
# Follows Google Shell Style Guide.

# Guard: only source framework and print summary when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  source "$(dirname "${0:-}")/test_framework.sh"
fi

echo "======================================="
echo "Structure Tests"
echo "======================================="
echo ""

run_test "Missing introduction section" \
  "missing_intro.md" \
  0 \
  "Post without introduction section (warning only, not failure)"

run_grep_test "Missing conclusion is a warning" \
  "missing_conclusion.md" \
  "Structure: Missing Conclusion section" \
  "Missing conclusion should trigger a warning, not a failure"

run_test "H1 heading in body" \
  "has_h1.md" \
  1 \
  "Post with H1 heading in body text"

run_test "H4 heading in body" \
  "has_h4.md" \
  0 \
  "Post with H4 heading in body text (warning only)"

# Print category summary only when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_summary "Structure "
  if [[ ${failed:-0} -gt 0 ]]; then
    exit 1
  else
    exit 0
  fi
fi
