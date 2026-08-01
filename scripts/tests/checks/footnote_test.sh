#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Footnote Tests
# Follows Google Shell Style Guide.

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/bootstrap.sh"

begin_category "Footnote Tests"

run_test_cases \
  "Footnote reference without definition|orphan_footnote_ref.md|1|Footnote reference [^1] exists but definition is missing" \
  "Footnote definition without reference|orphan_footnote_def.md|1|Footnote definition [^1]: exists but no reference in text" \
  "Sequential footnotes with double digits|sequential_footnotes.md|0|Post with footnotes 1 through 10 in order" \
  "Valid footnotes|valid_footnotes.md|0|Post with matching footnote references and definitions"

end_category_if_direct "Footnote " "${BASH_SOURCE[0]}" "${0}"
