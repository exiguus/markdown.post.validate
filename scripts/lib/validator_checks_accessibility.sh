#!/bin/bash

# Accessibility and style validation checks.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# C1: Validate hero image alt text.
# Args:
#   $1: File content
#   $2: Verbose flag
validate_hero_alt() {
  local content="$1"
  local verbose="$2"

  # Extract hero_alt value.
  local hero_alt
  hero_alt=$(echo "$content" | grep 'hero_alt =' | sed 's/.*hero_alt = \("\|\)\(.*\)\1.*/\2/' | tr -d '"')

  if [[ -n "$hero_alt" ]]; then
    local word_count
    word_count=$(echo "$hero_alt" | wc -w)

    if [[ $word_count -lt 30 || $word_count -gt 45 ]]; then
      warn "C1" "Format: hero_alt should be 30-45 words (currently $word_count words)."
    else
      if [[ "$verbose" == "true" ]]; then
        pass "C1" "Format: hero_alt has appropriate length ($word_count words)."
      fi
    fi
  else
    # No hero_alt is okay if there's no hero image.
    if echo "$content" | grep -q 'hero_img ='; then
      warn "C1" "Format: hero_alt is missing but hero_img is present."
    fi
  fi
}

# C2: Check description length.
# Args:
#   $1: File content
#   $2: Verbose flag
validate_description_length() {
  local content="$1"
  local verbose="$2"

  local description
  description=$(echo "$content" | grep 'description =' | sed -E "s/.*description = \"?([^\"]*)\"?.*/\1/")
  if [[ -n "$description" && ${#description} -gt 200 ]]; then
    warn "C2" "Format: Description is too long (${#description} chars). Keep it to 1-2 concise sentences."
  else
    if [[ "$verbose" == "true" ]]; then
      pass "C2" "Format: Description length is appropriate."
    fi
  fi
}

# C4: Validate table headers.
# Args:
#   $1: File content
#   $2: Verbose flag
validate_table_headers() {
  local content="$1"
  local verbose="$2"

  local in_frontmatter=false
  local line_num=0
  local table_found=false

  while IFS= read -r line; do
    ((line_num++))

    # Skip frontmatter.
    if echo "$line" | grep -q '^+++$'; then
      in_frontmatter=$(echo "$in_frontmatter" | awk '{print !($1+0)}')
      continue
    fi

    if [[ "$in_frontmatter" == "true" ]]; then
      continue
    fi

    # Check for table lines (start with |).
    if echo "$line" | grep -qE '^\|'; then
      table_found=true
      # Skip the table line itself, we'll check it below.
    fi
  done <<<"$content"

  # If we found tables, check they have headers.
  if [[ "$table_found" == "true" ]]; then
    local first_table_line
    first_table_line=$(echo "$content" | grep -E '^\|' | head -1)

    # A table has headers if the first row contains non-whitespace between pipes.
    if echo "$first_table_line" | grep -qE '\|[^|\s]+\|'; then
      if [[ "$verbose" == "true" ]]; then
        pass "C4" "Tables: Tables have headers."
      fi
    else
      warn "C4" "Tables: Tables may be missing headers."
    fi
  else
    if [[ "$verbose" == "true" ]]; then
      pass "C4" "Tables: No tables found (valid if none are needed)."
    fi
  fi
}
