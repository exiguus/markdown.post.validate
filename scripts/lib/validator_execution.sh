#!/bin/bash

# Validator check execution helpers.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Run configured checks against file content.
# Args:
#   $1: File path
#   $2: Verbose flag (true/false)
#   $3: File content
run_configured_checks() {
  local file_path="$1"
  local verbose="$2"
  local content="$3"

  # Track gate sections for display.
  declare -A gate_sections

  # Group checks by gate and run them.
  declare -A gate_display_names
  gate_display_names=(
    ["A"]="Blocking Failures"
    ["B"]="Major Quality Checks"
    ["C"]="Accessibility & Style"
  )

  # Track which checks have been run (for multi-function checks like A1).
  declare -A checks_run

  # Process each check in order.
  local check_id
  for check_id in "${CHECK_IDS[@]}"; do
    local gate
    gate=$(get_config "$check_id" "gate")
    local category
    category=$(get_config "$check_id" "category")
    local label
    label=$(get_config "$check_id" "label")
    local check_type
    check_type=$(get_config "$check_id" "type")
    local function_name
    function_name=$(get_config "$check_id" "function")
    local args_str
    args_str=$(get_config "$check_id" "args")

    # Start a new gate section if needed.
    if [[ -z "${gate_sections[$gate]:-}" ]]; then
      echo -e "\n${BLUE}=== Gate ${gate}: ${gate_display_names[$gate]} ===${NC}"
      gate_sections["$gate"]=1
    fi

    # Handle manual checks (just print the message).
    if [[ "$check_type" == "manual" ]]; then
      echo "o [$check_id] ${category}: ${label} (manual validation required)"
      continue
    fi

    # Skip if already run (for multi-function checks like A1).
    if [[ -n "${checks_run[$check_id]:-}" ]]; then
      continue
    fi

    # Run the validation function(s).
    if [[ -n "$function_name" ]]; then
      local functions=()
      IFS=' ' read -ra functions <<<"$function_name"
      local func
      for func in "${functions[@]}"; do
        if [[ -n "$func" ]]; then
          # Build arguments.
          local call_args=("$func")
          if [[ -n "$args_str" ]]; then
            local arg_array=()
            IFS=' ' read -ra arg_array <<<"$args_str"
            local arg
            for arg in "${arg_array[@]}"; do
              # Resolve variable names.
              case "$arg" in
                content) call_args+=("$content") ;;
                verbose) call_args+=("$verbose") ;;
                file_path) call_args+=("$file_path") ;;
                *) call_args+=("$arg") ;;
              esac
            done
          fi
          # Call the function.
          "${call_args[@]}" || true
        fi
      done
      checks_run["$check_id"]=1
    fi
  done
}