#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Relative Links Tests
# Follows Google Shell Style Guide.

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/bootstrap.sh"

begin_category "Relative Links Tests (A3)"

run_test_cases \
  "Relative links should not cause A3 failures|relative_links.md|0|Post with @/, ./, ../, / links should pass A3 (relative links excluded)"

end_category_if_direct "Relative Links " "${BASH_SOURCE[0]}" "${0}"
