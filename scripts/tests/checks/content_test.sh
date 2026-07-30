#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Content Tests
# Follows Google Shell Style Guide.

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/bootstrap.sh"

begin_category "Content Tests"

run_test_cases \
  "Bare URL in body text|bare_url.md|0|Post with bare URL not wrapped in markdown link (warning only)" \
  "URL in code block should be ignored|url_in_code_block.md|0|URLs in code blocks should not be flagged as bare URLs" \
  "URL in inline code should be ignored|url_in_inline_code.md|0|URLs in inline code (backticks) should not be flagged as bare URLs" \
  "Code block without language fence|code_no_fence.md|1|Post with code block missing language specifier" \
  "Click here link text|click_here.md|1|Post with 'click here' link text"

end_category_if_direct "Content " "${BASH_SOURCE[0]}" "${0}"
