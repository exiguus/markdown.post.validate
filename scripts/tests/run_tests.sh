#!/bin/bash

# Main test runner that sources all category test files
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Source the test framework
source "$(dirname "${0:-}")/test_framework.sh"

# Colors for output (YELLOW is used here but not in framework)
if [[ -t 1 ]]; then
  readonly YELLOW='\033[0;33m'
else
  readonly YELLOW=''
fi

#######################
# Main Function       #
#######################

main() {
  local start_time
  start_time=$(date +%s)

  echo ""
  echo "======================================="
  echo "Blog Post Validator Test Suite"
  echo "======================================="
  echo ""

  # Check if validator exists
  local validator
  validator="$(dirname "${0:-}")/../validate_blog_post.sh"
  if [[ ! -f "$validator" ]]; then
    echo -e "${RED}Error: Validator script not found${NC}" >&2
    exit 1
  fi

  # Check if validator is executable
  if [[ ! -x "$validator" ]]; then
    echo -e "${YELLOW}Warning: Validator script is not executable${NC}" >&2
  fi

  # Source all category test files
  local test_files=(
    "valid_post_test.sh"
    "frontmatter_test.sh"
    "hero_image_test.sh"
    "format_test.sh"
    "tags_test.sh"
    "structure_test.sh"
    "content_test.sh"
    "footnote_test.sh"
    "edge_case_test.sh"
    "relative_links_test.sh"
    "validate_all_blog_posts_test.sh"
  )

  local test_dir
  test_dir="$(dirname "${0:-}")"
  local found=0

  for test_file in "${test_files[@]}"; do
    local file_path="${test_dir}/${test_file}"
    if [[ -f "$file_path" ]]; then
      found=1
      echo "[test] $file_path"
      # shellcheck disable=SC1090
      source "$file_path"
    fi
  done

  if [[ $found -eq 0 ]]; then
    echo "[test] No category test files found"
  fi

  # Summary
  local end_time
  end_time=$(date +%s)
  local duration=$((end_time - start_time))

  echo ""
  echo "======================================="
  echo "Final Test Summary"
  echo "======================================="
  echo "Total:  ${total:-0}"
  echo -e "${GREEN}Passed: ${passed:-0}${NC}"
  echo -e "${RED}Failed: ${failed:-0}${NC}"
  echo "Time:   ${duration}s"
  echo ""

  if [[ ${failed:-0} -gt 0 ]]; then
    echo -e "${RED}Some tests failed!${NC}" >&2
    exit 1
  else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
  fi
}

main "$@"
