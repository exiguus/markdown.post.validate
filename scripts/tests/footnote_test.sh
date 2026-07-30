#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Footnote Tests
# Follows Google Shell Style Guide.

# Guard: only source framework and print summary when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  source "$(dirname "${0:-}")/test_framework.sh"
fi

echo "======================================="
echo "Footnote Tests"
echo "======================================="
echo ""

run_test "Footnote reference without definition" \
  "orphan_footnote_ref.md" \
  1 \
  "Footnote reference [^1] exists but definition is missing"

run_test "Footnote definition without reference" \
  "orphan_footnote_def.md" \
  1 \
  "Footnote definition [^1]: exists but no reference in text"

run_test "Valid footnotes" \
  "valid_footnotes.md" \
  0 \
  "Post with matching footnote references and definitions"

# Print category summary only when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_summary "Footnote "
  if [[ ${failed:-0} -gt 0 ]]; then
    exit 1
  else
    exit 0
  fi
fi
