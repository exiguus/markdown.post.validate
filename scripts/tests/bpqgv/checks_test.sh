#!/bin/bash

# Tests for checks.sh
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Guard: only source framework and print summary when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  source "$(dirname "${BASH_SOURCE[0]}")/../test_framework.sh"
fi

#######################
# Helper Functions    #
#######################

# Create a valid post
create_valid_post() {
  local file_path="$1"
  local title="$2"
  local date="$3"

  cat >"$file_path" <<EOF
+++
title = "$title"
description = "A valid test post"
date = $date
authors = ["test-author"]
[taxonomies]
tags = ["test", "valid", "post"]
+++

## Introduction

This is a valid post.

## Content

Some content here.

## Conclusion

This is the conclusion.
EOF
}

# Create an invalid post (missing required frontmatter)
create_invalid_post() {
  local file_path="$1"
  local title="$2"

  cat >"$file_path" <<EOF
+++
title = "$title"
+++

## Introduction

This post is missing required fields.

## Conclusion

This is the conclusion.
EOF
}

# Create a post with H1 in body
create_h1_post() {
  local file_path="$1"
  local title="$2"
  local date="$3"

  cat >"$file_path" <<EOF
+++
title = "$title"
description = "A post with H1 in body"
date = $date
authors = ["test-author"]
[taxonomies]
tags = ["test", "h1", "post"]
+++

# This is an H1 heading in body

## Introduction

This is a post.

## Conclusion

This is the conclusion.
EOF
}

#######################
# Test Suite           #
#######################

# Main test function for checks.sh
# Tests all functionality of the bulk validation script
checks_test() {
  local test_dir
  test_dir=$(mktemp -d) || {
    echo "Error: Could not create temp directory" >&2
    return 1
  }

  echo "[test] ${FUNCNAME[0]}"
  echo "========================================="

  # Test 1: Validate all valid posts
  create_valid_post "${test_dir}/2026-01-01-valid-post-1.md" "Valid Post 1" "2026-01-01"
  create_valid_post "${test_dir}/2026-01-02-valid-post-2.md" "Valid Post 2" "2026-01-02"

  run_command_test "All valid posts pass" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} -d ${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "All 2 posts validated successfully!"

  # Test 2: Verbose mode
  run_command_test "Verbose mode shows check details" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} -v -d ${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "Status: PASSED"

  # Test 3: Help flag
  run_command_test "Help flag shows usage" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} -h 2>&1" \
    "${SUCCESS}" \
    "Usage:"

  # Test 4: No cache flag
  run_command_test "No cache flag disables caching" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} -c -d ${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "All 2 posts validated successfully!"

  # Test 5: Custom directory flag
  run_command_test "Custom directory flag works" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} -d ${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "Validating all posts in: ${test_dir}/"

  # Test 6: Long options work
  run_command_test "Long option --help works" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} --help 2>&1" \
    "${SUCCESS}" \
    "Usage:"

  run_command_test "Long option --verbose works" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} --verbose -d ${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "Status: PASSED"

  run_command_test "Long option --no-cache works" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} --no-cache -d ${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "All 2 posts validated successfully!"

  run_command_test "Long option --continue works" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} --continue -d ${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "All 2 posts validated successfully!"

  run_command_test "Long option --directory works" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} --directory ${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "Validating all posts in: ${test_dir}/"

  run_command_test "Long option --directory=<value> works" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} --directory=${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "Validating all posts in: ${test_dir}/"

  run_command_test "Invalid short option fails" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} -z 2>&1" \
    "${FAILURE}" \
    "Unknown option:"

  # Clean up valid posts for next tests
  rm "${test_dir}"/2026-01-01-valid-post-1.md "${test_dir}"/2026-01-02-valid-post-2.md

  # Test 7: Fail-fast on invalid post (default behavior)
  create_valid_post "${test_dir}/2026-01-01-valid.md" "Valid Post" "2026-01-01"
  create_invalid_post "${test_dir}/2026-01-02-invalid.md" "Invalid Post"

  run_command_test "Fail-fast on invalid post" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} -d ${test_dir}/ 2>&1" \
    "${FAILURE}" \
    "Validation failed for"

  # Test 8: Continue on failure lists all failed posts
  create_h1_post "${test_dir}/2026-01-03-h1.md" "H1 Post" "2026-01-03"

  run_command_test "Continue on failure lists all failed posts" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} -k -d ${test_dir}/ 2>&1" \
    "${FAILURE}" \
    "Failed posts:"

  # Clean up for next test
  rm "${test_dir}"/2026-01-01-valid.md "${test_dir}"/2026-01-02-invalid.md "${test_dir}"/2026-01-03-h1.md

  # Test 9: Exclude files starting with underscore
  create_valid_post "${test_dir}/2026-01-01-valid.md" "Valid Post" "2026-01-01"
  create_valid_post "${test_dir}/_2026-01-02-underscore.md" "Underscore Post" "2026-01-02"

  run_command_test "Exclude underscore-prefixed posts" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} -d ${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "Total posts:"

  # Clean up
  rm "${test_dir}"/2026-01-01-valid.md "${test_dir}"/_2026-01-02-underscore.md

  # Test 10: Non-existent directory
  run_command_test "Non-existent directory shows error" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} -d /nonexistent/path/ 2>&1" \
    "${FAILURE}" \
    "Error: Directory '/nonexistent/path/' not found."

  # Test 11: Empty directory
  local empty_dir="${test_dir}/empty"
  mkdir -p "$empty_dir"
  run_command_test "Empty directory shows zero posts" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} -d ${empty_dir}/ 2>&1" \
    "${SUCCESS}" \
    "Total posts:"

  # Cleanup
  rm -rf "$test_dir"

  # Test 12: Ignore flag with single pattern
  test_dir=$(mktemp -d) || return 1
  mkdir -p "${test_dir}/subdir/report"
  create_valid_post "${test_dir}/2026-01-01-valid.md" "Valid Post" "2026-01-01"
  create_valid_post "${test_dir}/subdir/report/B3.md" "Report Post" "2026-01-02"

  run_command_test "Ignore flag excludes matching paths" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} -i report/ -d ${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "Total posts:       1"

  # Test 13: Ignore flag with multiple patterns
  mkdir -p "${test_dir}/temp"
  create_valid_post "${test_dir}/temp/2026-01-03-temp.md" "Temp Post" "2026-01-03"
  create_valid_post "${test_dir}/2026-01-04-draft.md" "Draft Post" "2026-01-04"

  run_command_test "Multiple ignore patterns work" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} -i report/ -i temp/ -d ${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "Total posts:       2"

  # Test 14: Long option --ignore
  run_command_test "Long option --ignore works" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} --ignore report/ -d ${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "Total posts:       3"

  # Test 15: Long option --ignore with equals
  run_command_test "Long option --ignore= works" \
    "cd \"${PROJECT_DIR}\" && ${VALIDATOR_ALL} --ignore=report/ -d ${test_dir}/ 2>&1" \
    "${SUCCESS}" \
    "Total posts:       3"

  # Cleanup
  rm -rf "$test_dir"

  # Print category summary only when executed directly
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_summary "Validate All Blog Posts "
    if [[ ${failed:-0} -gt 0 ]]; then
      exit 1
    else
      exit 0
    fi
  fi
}

# Run the tests
checks_test
