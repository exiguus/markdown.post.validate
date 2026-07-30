#!/bin/bash

# Shared test framework for blog post validator tests
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Framework guard - load once, use everywhere
if [[ -z "${TEST_FRAMEWORK_LOADED:-}" ]]; then
  export TEST_FRAMEWORK_LOADED=1

  # Colors for output (ALL in one place)
  if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly BLUE='\033[0;34m'
    readonly YELLOW='\033[0;33m'
    readonly NC='\033[0m'
  else
    readonly RED=''
    readonly GREEN=''
    readonly BLUE=''
    readonly YELLOW=''
    readonly NC=''
  fi
  export RED GREEN BLUE YELLOW NC

  # Exit codes
  readonly SUCCESS=0
  readonly FAILURE=1
  export SUCCESS FAILURE

  # MOCKS_DIR relative to test files
  # Use BASH_SOURCE[0] to get the framework file path
  FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PROJECT_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
  MOCKS_DIR="$PROJECT_DIR/mocks"

  # Validator paths
  VALIDATOR="$PROJECT_DIR/check.sh"
  VALIDATOR_ALL="$PROJECT_DIR/checks.sh"
  export VALIDATOR VALIDATOR_ALL MOCKS_DIR

  # Counters (declared globally so they persist across source calls)
  passed=0
  failed=0
  total=0
  export passed failed total
fi

#######################
# Test Framework      #
#######################

# Run a test and check the exit code
# Args:
#   $1: Test name
#   $2: Test file path (relative to MOCKS_DIR)
#   $3: Expected exit code (0 for pass, 1 for fail)
#   $4: Optional description
run_test() {
  local test_name
  test_name="$1"
  local test_file
  test_file="${MOCKS_DIR}/$2"
  local expected_exit
  expected_exit="$3"
  local description
  description="${4:-}"
  local actual_exit=0

  echo -e "${BLUE}Test: ${test_name}${NC}"
  if [[ -n "$description" ]]; then
    echo "  Description: $description"
  fi
  echo "  File: $test_file"

  # Run the validator
  if [[ -f "$test_file" ]]; then
    # Capture both stdout and stderr, but only show on failure
    # Use --noprofile and --no-cache to avoid issues with user's bash profile and caching
    # Use || true to prevent errexit from triggering on validator failure
    local output
    local actual_exit=0
    # Add cargo bin to PATH for lychee
    local test_path="${PATH:-}"
    local test_home="${HOME:-}"
    if [[ -n "$test_home" && -d "$test_home/.cargo/bin" ]]; then
      test_path="$test_home/.cargo/bin:$test_path"
    fi
    output=$(env -i HOME="$test_home" PATH="$test_path" bash --norc --noprofile "$VALIDATOR" "$test_file" 2>&1) || actual_exit=$?

    if [[ $actual_exit -eq $expected_exit ]]; then
      echo -e "  ${GREEN}✓ PASSED${NC} (exit code: $actual_exit)"
      ((passed++)) || true
    else
      echo -e "  ${RED}✗ FAILED${NC} (expected exit: $expected_exit, got: $actual_exit)"
      echo "  Output:"
      echo "${output//^/    }"
      ((failed++)) || true
    fi
  else
    echo -e "  ${RED}✗ FAILED${NC} - Test file not found: $test_file"
    ((failed++)) || true
  fi
  ((total++)) || true
  echo ""
}

# Assert that a string exists in the validator output
# Args:
#   $1: Test name
#   $2: Test file path (relative to MOCKS_DIR)
#   $3: String to search for in output
#   $4: Optional description
run_grep_test() {
  local test_name
  test_name="$1"
  local test_file
  test_file="${MOCKS_DIR}/$2"
  local search_string
  search_string="$3"
  local description
  description="${4:-}"

  ((total++)) || true

  echo -e "${BLUE}Test: ${test_name}${NC}"
  if [[ -n "$description" ]]; then
    echo "  Description: $description"
  fi
  echo "  File: $test_file"
  echo "  Searching for: '$search_string'"

  if [[ -f "$test_file" ]]; then
    local output
    output=$(env -i HOME="" PATH="$PATH" bash --norc --noprofile "$VALIDATOR" "$test_file" 2>&1) || true

    if grep -q -- "$search_string" <<<"$output"; then
      echo -e "  ${GREEN}✓ PASSED${NC} - String found in output"
      ((passed++)) || true
    else
      echo -e "  ${RED}✗ FAILED${NC} - String not found in output"
      echo "  Output:"
      echo "${output//^/    }"
      ((failed++)) || true
    fi
  else
    echo -e "  ${RED}✗ FAILED${NC} - Test file not found: $test_file"
    ((failed++)) || true
  fi
  echo ""
}

# Run a table of run_test cases
# Args:
#   $@: Entries in format "test_name|fixture_file|expected_exit|description"
run_test_cases() {
  local cases=("$@")

  local case_entry
  for case_entry in "${cases[@]}"; do
    local test_name
    local fixture_file
    local expected_exit
    local description
    IFS='|' read -r test_name fixture_file expected_exit description <<<"$case_entry"
    run_test "$test_name" "$fixture_file" "$expected_exit" "$description"
  done
}

# Run a table of run_grep_test cases
# Args:
#   $@: Entries in format "test_name|fixture_file|search_string|description"
run_grep_test_cases() {
  local cases=("$@")

  local case_entry
  for case_entry in "${cases[@]}"; do
    local test_name
    local fixture_file
    local search_string
    local description
    IFS='|' read -r test_name fixture_file search_string description <<<"$case_entry"
    run_grep_test "$test_name" "$fixture_file" "$search_string" "$description"
  done
}

# Run a command test and check output and exit code
# Args:
#   $1: Test name
#   $2: Command to run
#   $3: Expected exit code (0 for pass, 1 for fail)
#   $4...: Strings to search for in output (all must be found)
run_command_test() {
  local test_name
  test_name="$1"
  local command_to_run
  command_to_run="$2"
  local expected_exit
  expected_exit="$3"
  local actual_exit=0

  # Collect search strings from remaining args
  local search_strings=()
  shift 3
  while [[ $# -gt 0 ]]; do
    search_strings+=("$1")
    shift
  done

  ((total++)) || true

  echo -e "${BLUE}Test: ${test_name}${NC}"
  echo "  Command: ${command_to_run}"
  if [[ ${#search_strings[@]} -gt 0 ]]; then
    echo "  Searching for: ${search_strings[*]}"
  fi

  # Run the command
  local output
  local test_path="${PATH:-}"
  local test_home="${HOME:-}"
  if [[ -n "$test_home" && -d "$test_home/.cargo/bin" ]]; then
    test_path="$test_home/.cargo/bin:$test_path"
  fi
  output=$(env -i HOME="$test_home" PATH="$test_path" bash --norc --noprofile -c "$command_to_run" 2>&1) || actual_exit=$?

  # Check exit code
  local exit_ok=true
  if [[ $actual_exit -ne $expected_exit ]]; then
    echo -e "  ${RED}✗ FAILED${NC} - Expected exit code $expected_exit, got $actual_exit"
    exit_ok=false
  fi

  # Check search strings
  local all_found=true
  for search_str in "${search_strings[@]}"; do
    if ! grep -q -- "$search_str" <<<"$output"; then
      echo -e "  ${RED}✗ FAILED${NC} - String not found: '$search_str'"
      all_found=false
    fi
  done

  if [[ "$exit_ok" == "true" && "$all_found" == "true" ]]; then
    echo -e "  ${GREEN}✓ PASSED${NC} (exit code: $actual_exit)"
    ((passed++)) || true
  else
    echo "  Output:"
    echo "${output//^/    }"
    ((failed++)) || true
  fi
  echo ""
}

#######################
# Test Summary Function  #
#######################

# Print summary and exit with appropriate code
# Call this at the end of each test file
print_summary() {
  local category_name="${1:-}"

  echo "======================================="
  echo "${category_name}Summary"
  echo "======================================="
  echo "Total:  $total"
  echo -e "${GREEN}Passed: $passed${NC}"
  echo -e "${RED}Failed: $failed${NC}"
  echo ""
}

# Get current counter values for final aggregation
# Returns: echo "passed failed total"
get_counters() {
  echo "$passed $failed $total"
}

# Reset counters for a new test run
reset_counters() {
  passed=0
  failed=0
  total=0
}
