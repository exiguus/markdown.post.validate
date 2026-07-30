#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Format Tests
# Follows Google Shell Style Guide.

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/bootstrap.sh"

begin_category "Frontmatter Format Tests"

run_grep_test_cases \
  "Date with quotes triggers warning|date_with_quotes.md|Format: Date should be unquoted|Date should be unquoted (YYYY-MM-DD without quotes)" \
  "Long description triggers warning|long_description.md|Format: Description is too long|Description should be concise (1-2 sentences)"

end_category_if_direct "Format " "${BASH_SOURCE[0]}" "${0}"
