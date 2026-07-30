#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Edge Case Tests
# Follows Google Shell Style Guide.

# Guard: only source framework and print summary when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  source "$(dirname "${0:-}")/test_framework.sh"
fi

echo "======================================="
echo "Edge Case Tests"
echo "======================================="
echo ""

run_test "No frontmatter at all" \
  "no_frontmatter.md" \
  1 \
  "Post without any frontmatter"

run_test "Empty file" \
  "empty.md" \
  1 \
  "Completely empty file"

# Print category summary only when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_summary "Edge Case "
  if [[ ${failed:-0} -gt 0 ]]; then
    exit 1
  else
    exit 0
  fi
fi
