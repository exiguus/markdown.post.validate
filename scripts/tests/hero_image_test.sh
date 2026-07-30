#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Hero Image Tests
# Follows Google Shell Style Guide.

# Guard: only source framework and print summary when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  source "$(dirname "${0:-}")/test_framework.sh"
fi

echo "======================================="
echo "Hero Image Tests"
echo "======================================="
echo ""

run_test "hero_img missing hero_alt" \
  "hero_missing_alt.md" \
  1 \
  "hero_img present but hero_alt is missing"

run_test "hero_img missing hero_copy" \
  "hero_missing_copy.md" \
  1 \
  "hero_img present but hero_copy is missing"

run_test "hero_img missing images" \
  "hero_missing_images.md" \
  1 \
  "hero_img present but images array is missing"

run_grep_test "Hero alt too short triggers warning" \
  "hero_alt_too_short.md" \
  "hero_alt should be 30-45 words" \
  "hero_alt should be 30-45 words"

# Print category summary only when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_summary "Hero Image "
  if [[ ${failed:-0} -gt 0 ]]; then
    exit 1
  else
    exit 0
  fi
fi
