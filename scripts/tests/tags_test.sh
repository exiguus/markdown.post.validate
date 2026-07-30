#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Tags Tests
# Follows Google Shell Style Guide.

# Guard: only source framework and print summary when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  source "$(dirname "${0:-}")/test_framework.sh"
fi

echo "======================================="
echo "Tags Tests"
echo "======================================="
echo ""

run_test "Only 2 tags (needs at least 3)" \
  "only_two_tags.md" \
  1 \
  "Post with only 2 tags"

run_test "Only 1 tag (needs at least 3)" \
  "only_one_tag.md" \
  1 \
  "Post with only 1 tag"

run_test "3 tags (minimum valid)" \
  "three_tags.md" \
  0 \
  "Post with exactly 3 tags"

# Print category summary only when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_summary "Tags "
  if [[ ${failed:-0} -gt 0 ]]; then
    exit 1
  else
    exit 0
  fi
fi
