#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Tags Tests
# Follows Google Shell Style Guide.

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/bootstrap.sh"

begin_category "Tags Tests"

run_test_cases \
  "Only 2 tags (needs at least 3)|only_two_tags.md|1|Post with only 2 tags" \
  "Only 1 tag (needs at least 3)|only_one_tag.md|1|Post with only 1 tag" \
  "3 tags (minimum valid)|three_tags.md|0|Post with exactly 3 tags"

end_category_if_direct "Tags " "${BASH_SOURCE[0]}" "${0}"
