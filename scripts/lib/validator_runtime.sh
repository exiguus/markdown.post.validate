#!/bin/bash

# Validator runtime/bootstrap helpers.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Add cargo bin to PATH for lychee.
configure_validator_path() {
  # Use ${HOME:-} to avoid nounset error when HOME is unset.
  if [[ -n "${HOME:-}" && -d "${HOME}/.cargo/bin" ]]; then
    export PATH="${HOME}/.cargo/bin:${PATH}"
  fi
}

# Initialize output color constants.
init_validator_colors() {
  if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[0;33m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m' # No Color
  else
    # shellcheck disable=SC2034
    readonly RED=''
    # shellcheck disable=SC2034
    readonly GREEN=''
    # shellcheck disable=SC2034
    readonly YELLOW=''
    # shellcheck disable=SC2034
    readonly BLUE=''
    # shellcheck disable=SC2034
    readonly NC=''
  fi
}

# Initialize gate and warning counters.
init_validator_counters() {
  # shellcheck disable=SC2034
  declare -gi gate_a_failures=0
  # shellcheck disable=SC2034
  declare -gi gate_b_failures=0
  # shellcheck disable=SC2034
  declare -gi gate_c_failures=0
  # shellcheck disable=SC2034
  declare -gi warnings=0
}

# Initialize shared runtime state in one call.
init_validator_runtime() {
  configure_validator_path
  init_validator_colors
  init_validator_counters
}