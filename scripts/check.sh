#!/bin/bash

# Blog Post Validator
# Validates a markdown blog post against blog post quality standards.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Source shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/cache.sh"
source "${SCRIPT_DIR}/config/checks.cfg"
source "${SCRIPT_DIR}/lib/validator_cache.sh"
source "${SCRIPT_DIR}/lib/validator_cli.sh"
source "${SCRIPT_DIR}/lib/validator_command.sh"
source "${SCRIPT_DIR}/lib/validator_runtime.sh"
source "${SCRIPT_DIR}/lib/validator_checks_frontmatter.sh"
source "${SCRIPT_DIR}/lib/validator_checks_links.sh"
source "${SCRIPT_DIR}/lib/validator_checks_structure.sh"
source "${SCRIPT_DIR}/lib/validator_checks_accessibility.sh"
source "${SCRIPT_DIR}/lib/validator_execution.sh"
source "${SCRIPT_DIR}/lib/validator_output.sh"
source "${SCRIPT_DIR}/lib/validator_runner.sh"
source "${SCRIPT_DIR}/lib/validator_run_cached.sh"
source "${SCRIPT_DIR}/lib/validator_summary.sh"

# Initialize validator runtime and global state.
bootstrap_validator

#######################
# Helper Functions    #
#######################

#######################
# Validation Functions #
#######################

# Validation check implementations are sourced from domain libraries under
# scripts/lib/validator_checks_*.sh.

#######################
# Main Function       #
#######################

main() {
  if ! run_validator_command "$@"; then
    exit "$FAILURE"
  fi

  exit "$SUCCESS"
}

main "$@"
