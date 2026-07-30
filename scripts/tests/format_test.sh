#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Format Tests
# Follows Google Shell Style Guide.

# Guard: only source framework and print summary when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  source "$(dirname "${0:-}")/test_framework.sh"
fi

echo "======================================="
echo "Frontmatter Format Tests"
echo "======================================="
echo ""

run_grep_test "Date with quotes triggers warning" \
  "date_with_quotes.md" \
  "Format: Date should be unquoted" \
  "Date should be unquoted (YYYY-MM-DD without quotes)"

run_grep_test "Long description triggers warning" \
  "long_description.md" \
  "Format: Description is too long" \
  "Description should be concise (1-2 sentences)"

# Print category summary only when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_summary "Format "
  if [[ ${failed:-0} -gt 0 ]]; then
    exit 1
  else
    exit 0
  fi
fi
