#!/bin/bash

# Valid Post Tests
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Guard: only source framework and print summary when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  source "$(dirname "${0:-}")/test_framework.sh"
fi

echo "======================================="
echo "Valid Post Tests"
echo "======================================="
echo ""

run_test "Valid complete post" \
  "valid_post.md" \
  0 \
  "A post with all required fields, proper structure, and valid content"

run_test "Valid post with hero_img and all extra fields" \
  "valid_with_hero.md" \
  0 \
  "A post with hero_img that has all required extra fields"

# Print category summary only when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_summary "Valid Post "
  if [[ ${failed:-0} -gt 0 ]]; then
    exit 1
  else
    exit 0
  fi
fi
