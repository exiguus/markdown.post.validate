#!/bin/bash

# Main test runner that sources all category test files
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Source the test framework
source "$(dirname "${BASH_SOURCE[0]}")/test_framework.sh"

#######################
# Main Function       #
#######################

main() {
  local start_time
  start_time=$(date +%s)

  echo ""
  echo "======================================="
  echo "Blog Post Quality Gate Validator Test Suite"
  echo "======================================="
  echo ""

  # Check if validator exists
  local quality_gates=(
    "check.sh"
    "checks.sh"
    "assisted_checks.sh"
  )

  for quality_gate in "${quality_gates[@]}"; do
    local quality_gate_path
    quality_gate_path="$(dirname "${0:-}")/../${quality_gate}"
    if [[ ! -f "$quality_gate_path" ]]; then
      echo -e "${RED}Error: ${quality_gate} not found at ${quality_gate_path}${NC}" >&2
      exit 1
    fi

    # Check if validator is executable
    if [[ ! -x "$quality_gate_path" ]]; then
      echo -e "${YELLOW}Warning: ${quality_gate} is not executable${NC}" >&2
    fi
  done

  # Source all category test files
  local test_files=(
    "bpqgv/checks_test.sh"
    "bpqgv/assisted_checks_test.sh"
    "bpqgv/status_parser_test.sh"
    "bpqgv/cache_lib_test.sh"
    "bpqgv/e2e_cli_test.sh"
    "checks/valid_post_test.sh"
    "checks/frontmatter_test.sh"
    "checks/hero_image_test.sh"
    "checks/format_test.sh"
    "checks/tags_test.sh"
    "checks/structure_test.sh"
    "checks/content_test.sh"
    "checks/footnote_test.sh"
    "checks/edge_case_test.sh"
    "checks/relative_links_test.sh"
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
