#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Frontmatter Tests
# Follows Google Shell Style Guide.

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/bootstrap.sh"

begin_category "Frontmatter Tests"

run_test_cases \
  "Missing title|missing_title.md|1|Post without title field" \
  "Missing date|missing_date.md|1|Post without date field" \
  "Missing authors|missing_authors.md|1|Post without authors field" \
  "Missing tags|missing_tags.md|1|Post without tags field" \
  "Missing taxonomies section|missing_taxonomies.md|1|Post without [taxonomies] section"

end_category_if_direct "Frontmatter " "${BASH_SOURCE[0]}" "${0}"
