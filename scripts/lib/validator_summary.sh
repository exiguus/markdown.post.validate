#!/bin/bash

# Validator summary and result helpers.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Print validation summary including gate failure counts and automation ratio.
print_validation_summary() {
  echo ""
  echo "----------------------------------------"
  echo "Validation Summary:"
  echo "  Gate A (Blocking):      ${gate_a_failures} failure(s)"
  echo "  Gate B (Quality):       ${gate_b_failures} failure(s)"
  echo "  Gate C (Accessibility): ${gate_c_failures} failure(s)"
  echo "  Warnings:               ${warnings} warning(s)"

  # Calculate automation percentage from configuration.
  local total_gates=${#CHECK_IDS[@]}
  local manual_gates=0
  local automated_gates=0
  local manual_gate_list=()
  local check_id

  for check_id in "${CHECK_IDS[@]}"; do
    local type_value
    type_value=$(get_config "$check_id" "type")
    if [[ "$type_value" == "manual" ]]; then
      ((manual_gates++)) || true
      manual_gate_list+=("$check_id")
    else
      ((automated_gates++)) || true
    fi
  done

  local automation_percentage=$((automated_gates * 100 / total_gates))

  echo "  Automated:              ${automated_gates}/${total_gates} gates (${automation_percentage}%)"
  echo "  Manual:                 ${manual_gates}/${total_gates} gates (${manual_gate_list[*]})"
  echo "----------------------------------------"
  echo "Note: To get help with manual validation, run: ./scripts/assisted_checks.sh --help"
  echo ""
}

# Print final pass/fail result and return corresponding status code.
print_validation_result() {
  local total_failures=$((gate_a_failures + gate_b_failures + gate_c_failures))
  if [[ $total_failures -gt 0 ]]; then
    echo -e "${RED}Result: FAILED (${total_failures} failure(s))${NC}" >&2
    return "$FAILURE"
  fi

  echo -e "${GREEN}Result: PASSED${NC}"
  return "$SUCCESS"
}