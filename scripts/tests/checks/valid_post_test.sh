#!/bin/bash

# Valid Post Tests
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/bootstrap.sh"

begin_category "Valid Post Tests"

run_test_cases \
  "Valid complete post|valid_post.md|0|A post with all required fields, proper structure, and valid content" \
  "Valid post with hero_img and all extra fields|valid_with_hero.md|0|A post with hero_img that has all required extra fields"

end_category_if_direct "Valid Post " "${BASH_SOURCE[0]}" "${0}"
