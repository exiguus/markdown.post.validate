#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Content Tests
# Follows Google Shell Style Guide.

# Guard: only source framework and print summary when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  source "$(dirname "${0:-}")/test_framework.sh"
fi

echo "======================================="
echo "Content Tests"
echo "======================================="
echo ""

run_test "Bare URL in body text" \
  "bare_url.md" \
  0 \
  "Post with bare URL not wrapped in markdown link (warning only)"

run_test "URL in code block should be ignored" \
  "url_in_code_block.md" \
  0 \
  "URLs in code blocks should not be flagged as bare URLs"

run_test "URL in inline code should be ignored" \
  "url_in_inline_code.md" \
  0 \
  "URLs in inline code (backticks) should not be flagged as bare URLs"

run_test "Code block without language fence" \
  "code_no_fence.md" \
  1 \
  "Post with code block missing language specifier"

run_test "Click here link text" \
  "click_here.md" \
  1 \
  "Post with 'click here' link text"

# Print category summary only when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_summary "Content "
  if [[ ${failed:-0} -gt 0 ]]; then
    exit 1
  else
    exit 0
  fi
fi
