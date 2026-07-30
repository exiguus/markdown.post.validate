#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Frontmatter Tests
# Follows Google Shell Style Guide.

# Guard: only source framework and print summary when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  source "$(dirname "${0:-}")/test_framework.sh"
fi

echo "======================================="
echo "Frontmatter Tests"
echo "======================================="
echo ""

run_test "Missing title" \
  "missing_title.md" \
  1 \
  "Post without title field"

run_test "Missing date" \
  "missing_date.md" \
  1 \
  "Post without date field"

run_test "Missing authors" \
  "missing_authors.md" \
  1 \
  "Post without authors field"

run_test "Missing tags" \
  "missing_tags.md" \
  1 \
  "Post without tags field"

run_test "Missing taxonomies section" \
  "missing_taxonomies.md" \
  1 \
  "Post without [taxonomies] section"

# Print category summary only when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_summary "Frontmatter "
  if [[ ${failed:-0} -gt 0 ]]; then
    exit 1
  else
    exit 0
  fi
fi
