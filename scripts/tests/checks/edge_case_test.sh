#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Edge Case Tests
# Follows Google Shell Style Guide.

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/bootstrap.sh"

begin_category "Edge Case Tests"

run_test_cases \
  "No frontmatter at all|no_frontmatter.md|1|Post without any frontmatter" \
  "Empty file|empty.md|1|Completely empty file"

end_category_if_direct "Edge Case " "${BASH_SOURCE[0]}" "${0}"
