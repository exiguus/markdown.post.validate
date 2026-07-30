#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Structure Tests
# Follows Google Shell Style Guide.

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/bootstrap.sh"

begin_category "Structure Tests"

run_test_cases \
  "Missing introduction section|missing_intro.md|0|Post without introduction section (warning only, not failure)" \
  "H1 heading in body|has_h1.md|1|Post with H1 heading in body text" \
  "H4 heading in body|has_h4.md|0|Post with H4 heading in body text (warning only)"

run_grep_test_cases \
  "Missing conclusion is a warning|missing_conclusion.md|Structure: Missing Conclusion section|Missing conclusion should trigger a warning, not a failure"

end_category_if_direct "Structure " "${BASH_SOURCE[0]}" "${0}"
