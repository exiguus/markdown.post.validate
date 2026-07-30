#!/bin/bash

# Unit-style tests for extract_report_status in assisted_checks.sh.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Guard: only source framework and print summary when executed directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # shellcheck disable=SC1091
  source "$(dirname "${BASH_SOURCE[0]}")/../test_framework.sh"
fi

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../ && pwd)"
PROJECT_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
SCRIPT_UNDER_TEST="$PROJECT_DIR/assisted_checks.sh"

echo -e "${BLUE}=== Status Parser Tests ===${NC}"
echo ""

run_command_test \
  "Parses canonical status line" \
  "bash --norc --noprofile -c 'source \"$SCRIPT_UNDER_TEST\"; out=\$(extract_report_status \"### Status: PASS\"); [[ \"\$out\" == \"PASS\" ]] && echo ok'" \
  0 \
  "ok"

run_command_test \
  "Normalizes mixed case with spaces" \
  "bash --norc --noprofile -c 'source \"$SCRIPT_UNDER_TEST\"; out=\$(extract_report_status \"### Status: Needs Review\"); [[ \"\$out\" == \"NEEDS_REVIEW\" ]] && echo ok'" \
  0 \
  "ok"

run_command_test \
  "Parses bold status format" \
  "bash --norc --noprofile -c 'source \"$SCRIPT_UNDER_TEST\"; out=\$(extract_report_status \"**Status:** partial\"); [[ \"\$out\" == \"PARTIAL\" ]] && echo ok'" \
  0 \
  "ok"

run_command_test \
  "Handles NOT APPLICABLE spacing" \
  "bash --norc --noprofile -c 'source \"$SCRIPT_UNDER_TEST\"; out=\$(extract_report_status \"### Status: NOT APPLICABLE\"); [[ \"\$out\" == \"NOT_APPLICABLE\" ]] && echo ok'" \
  0 \
  "ok"

run_command_test \
  "Unknown label maps to UNKNOWN" \
  "bash --norc --noprofile -c 'source \"$SCRIPT_UNDER_TEST\"; out=\$(extract_report_status \"### Status: INCONCLUSIVE\"); [[ \"\$out\" == \"UNKNOWN\" ]] && echo ok'" \
  0 \
  "ok"

run_command_test \
  "Missing status line maps to UNKNOWN" \
  "bash --norc --noprofile -c 'source \"$SCRIPT_UNDER_TEST\"; out=\$(extract_report_status \"No status in this report\"); [[ \"\$out\" == \"UNKNOWN\" ]] && echo ok'" \
  0 \
  "ok"

run_command_test \
  "Parses bullet verdict status" \
  "bash --norc --noprofile -c 'source \"$SCRIPT_UNDER_TEST\"; out=\$(extract_report_verdict_status \"- **Verdict:** Needs Review\"); [[ \"\$out\" == \"NEEDS_REVIEW\" ]] && echo ok'" \
  0 \
  "ok"

run_command_test \
  "Parses table verdict status" \
  "bash --norc --noprofile -c 'source \"$SCRIPT_UNDER_TEST\"; out=\$(extract_report_verdict_status \"| **Verdict** | PARTIAL |\"); [[ \"\$out\" == \"PARTIAL\" ]] && echo ok'" \
  0 \
  "ok"

run_command_test \
  "Parses verdict with trailing details" \
  "bash --norc --noprofile -c 'source \"$SCRIPT_UNDER_TEST\"; out=\$(extract_report_verdict_status \"- **Verdict:** FAIL (8 HIGH RISK claims)\"); [[ \"\$out\" == \"FAIL\" ]] && echo ok'" \
  0 \
  "ok"

run_command_test \
  "Schema validator accepts valid report" \
  "bash --norc --noprofile -c 'source \"$SCRIPT_UNDER_TEST\"; report=\$(echo -e \"## Link Relevance Report\\n### Status: PASS\\n\\n- **Verdict:** PASS\"); validate_report_schema A6 \"\$report\" && echo ok'" \
  0 \
  "ok"

run_command_test \
  "Sanitizer removes duplicate separators" \
  "bash --norc --noprofile -c 'source \"$SCRIPT_UNDER_TEST\"; report=\$(echo -e \"### Status: FAIL\\n\\n---\\n---\\n\\n- **Verdict:** FAIL\"); clean=\$(sanitize_report_content \"\$report\"); validate_report_schema B3 \"\$clean\" && echo ok'" \
  0 \
  "ok"

run_command_test \
  "Schema validator rejects duplicate A6 headers" \
  "bash --norc --noprofile -c 'source \"$SCRIPT_UNDER_TEST\"; report=\$(echo -e \"## Link Relevance Report\\n### Status: PASS\\n\\n- **Verdict:** PASS\\n## Link Relevance Report\"); ! validate_report_schema A6 \"\$report\" && echo ok'" \
  0 \
  "ok"

run_command_test \
  "Schema validator rejects C5 placeholder rows" \
  "bash --norc --noprofile -c 'source \"$SCRIPT_UNDER_TEST\"; report=\$(echo -e \"### Status: PASS\\n\\n- **Verdict:** PASS\\n\\n| Phrase | Location |\\n|---|---|\\n| sample | Not present |\"); ! validate_report_schema C5 \"\$report\" && echo ok'" \
  0 \
  "ok"

# Print summary and exit only when executed directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo ""
  echo -e "${BLUE}Status Parser Test Summary:${NC}"
  echo "  Passed: ${passed:-0}"
  echo "  Failed: ${failed:-0}"
  echo "  Total:  ${total:-0}"

  if [[ ${failed:-0} -gt 0 ]]; then
    exit 1
  fi

  exit 0
fi
