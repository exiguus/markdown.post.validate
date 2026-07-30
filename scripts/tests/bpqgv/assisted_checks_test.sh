#!/bin/bash

# Tests for assisted_checks.sh
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Guard: only source framework and print summary when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Source the test framework
  # shellcheck disable=SC1091
  source "$(dirname "${BASH_SOURCE[0]}")/../test_framework.sh"
fi

# Test files directory
# MOCKS_DIR relative to test files
# Use BASH_SOURCE[0] to get the framework file path
FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../ && pwd)"
PROJECT_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
MOCKS_DIR="$PROJECT_DIR/mocks"
mkdir -p "$MOCKS_DIR"

# Create mock post file for testing
MOCK_POST="$MOCKS_DIR/test_post.md"
cat >"$MOCK_POST" <<'EOF'
# Test Post

This is a test post with some content.

According to recent studies, AI is transforming industries.

> "AI is the future" - Expert Person

## Conclusion

This concludes the test post.
EOF

# Create mock .mistral file for testing (without real API key)
MOCK_MISTRAL="$MOCKS_DIR/test_mistral"
echo "MISTRAL_API_KEY=test_key_for_testing" >"$MOCK_MISTRAL"

# Path to the script under test
SCRIPT_UNDER_TEST="$PROJECT_DIR/assisted_checks.sh"

echo -e "${BLUE}=== AI Manual Checks Script Tests ===${NC}"
echo ""

# ============================================================================
# Basic functionality tests (no API calls needed)
# ============================================================================

# Script exists and is executable
run_command_test \
  "Script is executable" \
  "test -x '$SCRIPT_UNDER_TEST' && echo 'executable'" \
  0 \
  "executable"

# Script shows usage when no arguments
run_command_test \
  "Shows usage with no arguments" \
  "bash '$SCRIPT_UNDER_TEST' 2>&1" \
  1 \
  "Usage:"

# Script shows usage with -h flag
run_command_test \
  "Shows usage with -h flag" \
  "bash '$SCRIPT_UNDER_TEST' -h 2>&1" \
  0 \
  "Usage:"

# Script shows usage with --help flag
run_command_test \
  "Shows usage with --help flag" \
  "bash '$SCRIPT_UNDER_TEST' --help 2>&1" \
  0 \
  "Usage:"

# Script fails when post file doesn't exist
run_command_test \
  "Fails with non-existent post file" \
  "bash '$SCRIPT_UNDER_TEST' /nonexistent/file.md 2>&1" \
  1 \
  "Error: Post file"

# Script accepts -m flag for model
run_command_test \
  "Accepts -m flag" \
  "bash '$SCRIPT_UNDER_TEST' -m mistral-medium -h 2>&1" \
  0 \
  "mistral-medium"

# Script accepts --model flag
run_command_test \
  "Accepts --model flag" \
  "bash '$SCRIPT_UNDER_TEST' --model mistral-medium --help 2>&1" \
  0 \
  "mistral-medium"

# Script accepts -k flag for key file
run_command_test \
  "Accepts -k flag" \
  "bash '$SCRIPT_UNDER_TEST' -k /tmp/nonexistent -h 2>&1" \
  0 \
  "File containing API key"

# Script uses mistral-medium as default model
run_command_test \
  "Uses mistral-medium as default model" \
  "bash '$SCRIPT_UNDER_TEST' -h 2>&1" \
  0 \
  "default: mistral-medium"

# sanitize_report_content: trims leading separator only on first non-empty line
run_command_test \
  "Sanitizer trims first-content-line separator" \
  "output=\$(printf '%s\n' '---' 'foo bar' '---' | (source '$SCRIPT_UNDER_TEST' && sanitize_report_content \"\$(cat)\")) && expected=\$(printf '%s\n' 'foo bar' '---') && [[ \"\$output\" == \"\$expected\" ]]" \
  0

# sanitize_report_content: preserves separator when not first non-empty line
run_command_test \
  "Sanitizer preserves non-leading separator" \
  "output=\$(printf '%s\n' 'foo bar' '---' | (source '$SCRIPT_UNDER_TEST' && sanitize_report_content \"\$(cat)\")) && expected=\$(printf '%s\n' 'foo bar' '---') && [[ \"\$output\" == \"\$expected\" ]]" \
  0

# Script accepts --key-file flag
run_command_test \
  "Accepts --key-file flag" \
  "bash '$SCRIPT_UNDER_TEST' --key-file /tmp/nonexistent --help 2>&1" \
  0 \
  "File containing API key"

# Script accepts -c flag with single check
run_command_test \
  "Accepts -c flag with single check" \
  "bash '$SCRIPT_UNDER_TEST' -c C6 -h 2>&1" \
  0 \
  "Comma-separated list of checks"

# Script accepts -c flag with multiple checks
run_command_test \
  "Accepts -c flag with multiple checks" \
  "bash '$SCRIPT_UNDER_TEST' -c C5,C6 -h 2>&1" \
  0 \
  "Comma-separated list of checks"

# Script accepts --check flag with single check
run_command_test \
  "Accepts --check flag with single check" \
  "bash '$SCRIPT_UNDER_TEST' --check C6 -h 2>&1" \
  0 \
  "Comma-separated list of checks"

# Script accepts --check flag with multiple checks
run_command_test \
  "Accepts --check flag with multiple checks" \
  "bash '$SCRIPT_UNDER_TEST' --check C5,C6 -h 2>&1" \
  0 \
  "Comma-separated list of checks"

# Reports directory path is shown in output (skipped - tests use -r to avoid writing reports)
# Reports saved to message appears (skipped - tests use -r to avoid writing reports)

# ============================================================================
# Mock mode tests (test actual check execution without API calls)
# ============================================================================

# Mock mode runs all checks successfully
export MISTRAL_MOCK=1
run_command_test \
  "Mock mode runs all checks" \
  "MISTRAL_MOCK=1 bash '$SCRIPT_UNDER_TEST' -n -r '$MOCK_POST' 2>&1" \
  0 \
  "Running AI-assisted manual quality checks" \
  "Mode: MOCK" \
  "Checks: ALL" \
  "=== A2" \
  "PASS"

# Mock mode runs single check
export MISTRAL_MOCK=1
run_command_test \
  "Mock mode runs single check (C6)" \
  "MISTRAL_MOCK=1 bash '$SCRIPT_UNDER_TEST' -n -r -c C6 '$MOCK_POST' 2>&1" \
  0 \
  "Checks: C6" \
  "=== C6" \
  "Argument Balance Report"

# Mock mode runs multiple checks
export MISTRAL_MOCK=1
run_command_test \
  "Mock mode runs multiple checks (C5,C6)" \
  "MISTRAL_MOCK=1 bash '$SCRIPT_UNDER_TEST' -n -r -c C5,C6 '$MOCK_POST' 2>&1" \
  0 \
  "Checks: C5 C6" \
  "=== C5" \
  "=== C6" \
  "Summary: 0 PASS, 0 FAIL, 2 total" \
  "Status Breakdown: 1 PARTIAL, 0 NOT_APPLICABLE, 1 NEEDS_REVIEW, 0 UNKNOWN"

# Mock mode with invalid check shows warning
export MISTRAL_MOCK=1
run_command_test \
  "Mock mode warns on invalid check" \
  "MISTRAL_MOCK=1 bash '$SCRIPT_UNDER_TEST' -n -r -c INVALID,C6 '$MOCK_POST' 2>&1" \
  0 \
  "Warning: Unknown check 'INVALID'" \
  "=== C6"

# Mock mode with no valid checks fails
export MISTRAL_MOCK=1
run_command_test \
  "Mock mode fails with no valid checks" \
  "MISTRAL_MOCK=1 bash '$SCRIPT_UNDER_TEST' -n -r -c INVALID1,INVALID2 '$MOCK_POST' 2>&1" \
  1 \
  "Error: No valid checks specified"

# Mock mode doesn't require API key file
export MISTRAL_MOCK=1
MOCK_MISTRAL_NOKY="$MOCKS_DIR/test_mistral_nokey"
echo "# No key here" >"$MOCK_MISTRAL_NOKY"
run_command_test \
  "Mock mode skips API key validation" \
  "MISTRAL_MOCK=1 bash '$SCRIPT_UNDER_TEST' -n -r -k '$MOCK_MISTRAL_NOKY' '$MOCK_POST' 2>&1" \
  0 \
  "Mode: MOCK"

# Mock mode shows summary
export MISTRAL_MOCK=1
run_command_test \
  "Mock mode shows correct summary" \
  "MISTRAL_MOCK=1 bash '$SCRIPT_UNDER_TEST' -n -r '$MOCK_POST' 2>&1" \
  0 \
  "Summary: 3 PASS, 1 FAIL, 8 total" \
  "Status Breakdown: 1 PARTIAL, 1 NOT_APPLICABLE, 1 NEEDS_REVIEW, 1 UNKNOWN"

# Reports directory is created (skipped - tests use -r to avoid writing reports)
# Individual report files are created (skipped - tests use -r to avoid writing reports)
# Report files contain check results (skipped - tests use -r to avoid writing reports)
# Multiple checks create multiple report files (skipped - tests use -r to avoid writing reports)

# Clean up
rm -f "$MOCK_POST" "$MOCK_MISTRAL" "$MOCK_MISTRAL_NOKY"
# Also clean up cache files (though tests use -n so they shouldn't create any)
# Cache files are now named ai_[suffix]_[check_id]
rm -f "${HOME:-}/.cache/blog-validator/ai_"* 2>/dev/null || true
unset MISTRAL_MOCK

# Print summary and exit only when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo ""
  echo -e "${BLUE}Test Summary:${NC}"
  echo "  Passed: ${passed:-0}"
  echo "  Failed: ${failed:-0}"
  echo "  Total:  ${total:-0}"

  if [[ $failed -gt 0 ]]; then
    exit 1
  fi

  exit 0
fi
