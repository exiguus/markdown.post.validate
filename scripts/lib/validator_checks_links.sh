#!/bin/bash

# Link-related validation checks.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# A5: Basic link validation (syntax only, not network).
# Args:
#   $1: File content
#   $2: Verbose flag
validate_links() {
  local content="$1"
  local verbose="$2"

  # Check for bare URLs in body text (not in frontmatter, code blocks, or inline code).
  local in_code_block=false
  local line_num=0
  local bare_urls=()

  while IFS= read -r line; do
    ((line_num++))

    # Toggle code block state.
    if echo "$line" | grep -qE '^```'; then
      if [[ "$in_code_block" == "false" ]]; then
        in_code_block=true
      else
        in_code_block=false
      fi
      continue
    fi

    # Skip if in code block.
    if [[ "$in_code_block" == "true" ]]; then
      continue
    fi

    # Skip frontmatter (lines between +++).
    if [[ $line_num -le 10 ]]; then
      if echo "$line" | grep -q '+++'; then
        continue
      fi
    fi

    # Skip inline code with URLs.
    if echo "$line" | grep -qE '`[^`]*https?://[^`]*`'; then
      # Remove all inline code sections from the line for URL checking.
      line=$(echo "$line" | sed -E 's|`[^`]*https?://[^`]*`|INLINE_CODE_PLACEHOLDER|g')
    fi

    # Look for bare URLs (not in markdown link format).
    if echo "$line" | grep -qE 'https?://'; then
      if ! echo "$line" | grep -qE '\[.*\]\(https?://[^)]*\)' && ! echo "$line" | grep -qE '<https?://[^>]+>'; then
        # Not a markdown link, so it's a bare URL.
        local url
        url=$(echo "$line" | grep -oE 'https?://[^ >)]+' | head -1)
        url="${url%[>)\][]*}"
        if [[ -n "$url" ]]; then
          bare_urls+=("$url at line $line_num")
        fi
      fi
    fi
  done <<<"$content"

  if [[ ${#bare_urls[@]} -gt 0 ]]; then
    warn "A7" "Links: Found bare URL(s) in body text: ${bare_urls[0]}"
    # Only report first one to avoid spam.
    if [[ ${#bare_urls[@]} -gt 1 ]]; then
      warn "A7" "Links: ... and ${#bare_urls[@]} more bare URLs found."
    fi
  else
    if [[ "$verbose" == "true" ]]; then
      pass "A7" "Links: No bare URLs found in body text."
    fi
  fi
}

# A3: Validate links are not dead using lychee.
# Args:
#   $1: File path
#   $2: Verbose flag
validate_dead_links() {
  local file_path="$1"
  local verbose="$2"

  # Check if lychee is installed.
  if ! command -v lychee &>/dev/null; then
    warn "A3" "Links: lychee is not installed. Install with: cargo install lychee. See: https://lychee.cli.rs/guides/getting-started/"
    return 0
  fi

  # Run lychee to check for dead links.
  local lychee_output
  lychee_output=$(lychee --quiet --no-progress --exclude-all-private --include-fragments \
    --exclude '@/*' --exclude '../*' --exclude './*' --exclude-path '/.*' \
    "$file_path" 2>/dev/null || true)

  # Check if there are any errors in the output.
  if echo "$lychee_output" | grep -qE '🚫 [1-9][0-9]* Error(s)?'; then
    # Found dead links - fail.
    local error_count
    error_count=$(echo "$lychee_output" | grep -oE '🚫 [0-9]+ Error(s)?' | head -1 | grep -oE '[0-9]+')
    fail "A3" "Links: Dead links found ($error_count errors). Run: lychee --quiet --no-progress --exclude-all-private --include-fragments --exclude '@/*' --exclude '../*' --exclude './*' --exclude-path '/.*' ${file_path}"
    if [[ "$verbose" == "true" ]]; then
      echo "${lychee_output//^/  }"
    fi
    return 1
  else
    # All links are valid.
    if [[ "$verbose" == "true" ]]; then
      pass "A3" "Links: No dead links found."
    fi
  fi
}

# C3: Check for descriptive link text.
# Args:
#   $1: File content
#   $2: Verbose flag
validate_link_text() {
  local content="$1"
  local verbose="$2"

  local click_here_count
  click_here_count=$(echo "$content" | grep -ci 'click here')

  if [[ $click_here_count -gt 0 ]]; then
    warn "C3" "Links: Found '$click_here_count' instances of 'click here' link text. Use descriptive text instead."
  else
    if [[ "$verbose" == "true" ]]; then
      pass "C3" "Links: No 'click here' link text found."
    fi
  fi
}
