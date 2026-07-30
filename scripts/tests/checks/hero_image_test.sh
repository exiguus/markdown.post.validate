#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Hero Image Tests
# Follows Google Shell Style Guide.

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/bootstrap.sh"

begin_category "Hero Image Tests"

run_test_cases \
  "hero_img missing hero_alt|hero_missing_alt.md|1|hero_img present but hero_alt is missing" \
  "hero_img missing hero_copy|hero_missing_copy.md|1|hero_img present but hero_copy is missing" \
  "hero_img missing images|hero_missing_images.md|1|hero_img present but images array is missing"

run_grep_test_cases \
  "Hero alt too short triggers warning|hero_alt_too_short.md|hero_alt should be 30-45 words|hero_alt should be 30-45 words"

end_category_if_direct "Hero Image " "${BASH_SOURCE[0]}" "${0}"
