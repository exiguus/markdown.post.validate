#!/bin/bash

# Structure-related validation checks.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# A3: Validate footnote integrity.
# Args:
#   $1: File content
#   $2: Verbose flag
validate_footnotes() {
  local content="$1"
  local verbose="$2"

  # Extract all footnote references in text (e.g., [^1], [^2]).
  local text_without_defs
  text_without_defs=$(echo "$content" | grep -v '^\[\^[0-9]\+\]:' || true)
  local text_refs
  text_refs=$(echo "$text_without_defs" | grep -oE '\[\^[0-9]+\]' | sed 's/\[\^//;s/\]//' | sort -u | tr -d ' ' || true)

  # Extract all footnote definitions (e.g., [^1]:, [^2]:).
  local definitions
  definitions=$(echo "$content" | grep -oE '\[\^[0-9]+\]:' | sed 's/\[\^//;s/\]://;s/://' | sort -u | tr -d ' ' || true)

  # Check if both are empty (no footnotes).
  if [[ -z "$text_refs" && -z "$definitions" ]]; then
    if [[ "$verbose" == "true" ]]; then
      pass "A5" "Structure: No footnotes found (valid if none are needed)."
    fi
    return 0
  fi

  # Convert to space-separated lists for easy comparison.
  local text_refs_list="$text_refs"
  local definitions_list="$definitions"

  # Check for references without definitions.
  local missing_defs=()
  local ref
  for ref in $text_refs_list; do
    if ! echo " $definitions_list " | grep -qw "$ref"; then
      missing_defs+=("$ref")
    fi
  done

  if [[ ${#missing_defs[@]} -gt 0 ]]; then
    fail "A5" "Structure: Footnote reference(s) without definitions: ${missing_defs[*]}"
    return 1
  fi

  # Check for definitions without references.
  local orphaned_defs=()
  local def
  for def in $definitions_list; do
    if ! echo " $text_refs_list " | grep -qw "$def"; then
      orphaned_defs+=("$def")
    fi
  done

  if [[ ${#orphaned_defs[@]} -gt 0 ]]; then
    fail "A5" "Structure: Orphaned footnote definition(s) (no reference in text): ${orphaned_defs[*]}"
    return 1
  fi

  if [[ "$verbose" == "true" ]]; then
    pass "A5" "Structure: All footnotes have matching references and definitions."
  fi

  # Check footnote numbering is sequential.
  if [[ -n "$text_refs" ]]; then
    local found_nums=()
    for ref in $text_refs; do
      found_nums+=("$ref")
    done

    # Sort numerically.
    IFS=$'\n' read -d '' -ra sorted < <(sort -n <<<"${found_nums[*]}") || true
    unset IFS

    # Check for gaps in sequence.
    local prev=0
    local has_gaps=false
    local num
    for num in "${sorted[@]}"; do
      if [[ $num -gt $((prev + 1)) ]]; then
        has_gaps=true
        break
      fi
      prev=$num
    done

    if [[ "$has_gaps" == "true" ]]; then
      warn "A5" "Structure: Footnote numbering has gaps. Footnotes should be numbered sequentially starting from 1."
    fi

    # Check that the first appearance of each footnote is in sequential order.
    local out_of_order=false

    # Get all unique footnote references in order of first appearance.
    local all_refs
    all_refs=$(echo "$content" | grep -vE '\[\^[0-9]+\]:$' | grep -oE '\[\^[0-9]+\]' | sed 's/\[\^//;s/\]//' | tr -d ' ')

    if [[ -n "$all_refs" ]]; then
      # Get unique references in order of first appearance.
      local first_appearances
      first_appearances=$(echo "$all_refs" | awk '!seen[$0]++')

      prev=0
      for num in $first_appearances; do
        if [[ $num -ne $((prev + 1)) && $prev -ne 0 ]]; then
          out_of_order=true
          break
        fi
        prev=$num
      done

      # Also check if the first reference is not 1.
      local first_ref
      first_ref=$(echo "$first_appearances" | head -1)
      if [[ -n "$first_ref" && $first_ref -ne 1 ]]; then
        out_of_order=true
      fi

      if [[ "$out_of_order" == "true" ]]; then
        warn "A5" "Structure: Footnote references are not in sequential order. Footnotes should appear as [^1], [^2], [^3], etc."
      fi
    fi
  fi
}

# B1: Validate introduction and conclusion sections.
# Args:
#   $1: File content
#   $2: Verbose flag
validate_intro_conclusion() {
  local content="$1"
  local verbose="$2"

  local has_intro=false
  local has_conclusion=false

  # Check for ## Introduction or equivalent.
  if echo "$content" | grep -qi '^##.*introduction'; then
    has_intro=true
  elif echo "$content" | grep -qi '^##.*intro'; then
    has_intro=true
  fi

  # Check for ## Conclusion or equivalent.
  if echo "$content" | grep -qi '^##.*conclusion'; then
    has_conclusion=true
  elif echo "$content" | grep -qi '^##.*wrapping up'; then
    has_conclusion=true
  elif echo "$content" | grep -qi '^##.*final thoughts'; then
    has_conclusion=true
  fi

  if [[ "$has_intro" == "false" ]]; then
    warn "B1" "Structure: Missing Introduction section (should be H2: ## Introduction)."
  fi

  if [[ "$has_conclusion" == "false" ]]; then
    warn "B1" "Structure: Missing Conclusion section (should be H2: ## Conclusion or similar)."
  else
    if [[ "$verbose" == "true" && "$has_intro" == "true" ]]; then
      pass "B1" "Structure: Introduction and Conclusion sections found."
    fi
  fi
}

# B2: Validate heading hierarchy.
# Args:
#   $1: File content
#   $2: Verbose flag
validate_heading_hierarchy() {
  local content="$1"
  local verbose="$2"

  local has_h1_in_body=false

  # Skip frontmatter lines and code blocks.
  local in_frontmatter=false
  local in_code_block=false
  local line_num=0

  while IFS= read -r line; do
    ((line_num++))

    # Check for frontmatter delimiters.
    if echo "$line" | grep -q '^+++$'; then
      if [[ "$in_frontmatter" == "false" ]]; then
        in_frontmatter=true
      else
        in_frontmatter=false
      fi
      continue
    fi

    # Skip if in frontmatter.
    if [[ "$in_frontmatter" == "true" ]]; then
      continue
    fi

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

    # Check for H1 in body.
    if echo "$line" | grep -qE '^# '; then
      has_h1_in_body=true
      fail "B2" "Structure: Found H1 heading in body text (line $line_num). Only H2 and H3 allowed."
    fi

    # Track heading levels.
    if echo "$line" | grep -q '^## '; then
      : # H2 heading
    elif echo "$line" | grep -q '^### '; then
      : # H3 heading
    elif echo "$line" | grep -q '^#### '; then
      warn "B2" "Structure: Found H4+ heading (line $line_num). Maximum allowed is H3."
    fi
  done <<<"$content"

  if [[ "$has_h1_in_body" == "false" ]]; then
    if [[ "$verbose" == "true" ]]; then
      pass "B2" "Structure: No H1 headings in body; hierarchy looks correct."
    fi
  fi
}

# B4/C4: Validate code blocks have language fences.
# Args:
#   $1: File content
#   $2: Verbose flag
validate_code_blocks() {
  local content="$1"
  local verbose="$2"

  local code_blocks_without_language=()
  local in_code_block=false
  local code_block_start=0
  local line_num=0

  while IFS= read -r line; do
    ((line_num++))

    # Check for code block start.
    if echo "$line" | grep -q '^```'; then
      if [[ "$in_code_block" == "false" ]]; then
        # This is the start of a code block.
        in_code_block=true
        code_block_start=$line_num

        # Check if it has a language specifier.
        local fence_line="$line"
        local language_spec
        language_spec=$(echo "$fence_line" | sed 's/^```//' | sed 's/^//' | xargs)

        # If language_spec is empty or just whitespace, it's a plain code block.
        if [[ -z "$language_spec" || "$language_spec" == " " ]]; then
          code_blocks_without_language+=("$code_block_start")
        fi
      else
        # This is the end of a code block.
        in_code_block=false
      fi
    fi
  done <<<"$content"

  if [[ ${#code_blocks_without_language[@]} -gt 0 ]]; then
    fail "B4" "Format: Code block(s) without language fences at line(s): ${code_blocks_without_language[*]}"
  else
    if [[ "$verbose" == "true" ]]; then
      pass "B4" "Format: All code blocks have language fences."
    fi
  fi
}

# B5: Validate section count (3-6 core sections).
# Args:
#   $1: File content
#   $2: Verbose flag
validate_section_count() {
  local content="$1"
  local verbose="$2"

  local in_frontmatter=false
  local in_intro=false
  local in_conclusion=false
  local core_section_count=0
  local line_num=0

  while IFS= read -r line; do
    ((line_num++))

    # Check for frontmatter.
    if echo "$line" | grep -q '^+++$'; then
      in_frontmatter=$(echo "$in_frontmatter" | awk '{print !($1+0)}')
      continue
    fi

    if [[ "$in_frontmatter" == "true" ]]; then
      continue
    fi

    # Check for introduction.
    if echo "$line" | grep -qi '^##.*introduction'; then
      in_intro=true
      continue
    fi

    # Check for conclusion.
    if echo "$line" | grep -qi '^##.*conclusion\|^##.*wrapping up\|^##.*final thoughts'; then
      in_conclusion=true
      continue
    fi

    # Count H2 sections between intro and conclusion.
    if [[ "$in_intro" == "true" && "$in_conclusion" == "false" ]]; then
      if echo "$line" | grep -q '^## '; then
        ((core_section_count++))
      fi
    fi
  done <<<"$content"

  if [[ $core_section_count -lt 3 || $core_section_count -gt 6 ]]; then
    warn "B5" "Structure: Core sections count is $core_section_count (expected 3-6)."
  else
    if [[ "$verbose" == "true" ]]; then
      pass "B5" "Structure: Core sections count is valid ($core_section_count)."
    fi
  fi
}

# B6: Validate no duplicate section headings.
# Args:
#   $1: File content
#   $2: Verbose flag
validate_section_redundancy() {
  local content="$1"
  local verbose="$2"

  local in_frontmatter=false
  local line_num=0
  local seen_headings=()
  local duplicate_found=false

  while IFS= read -r line; do
    ((line_num++))

    # Check for frontmatter.
    if echo "$line" | grep -q '^+++$'; then
      in_frontmatter=$(echo "$in_frontmatter" | awk '{print !($1+0)}')
      continue
    fi

    if [[ "$in_frontmatter" == "true" ]]; then
      continue
    fi

    # Check for H2 headings.
    if echo "$line" | grep -q '^## '; then
      local heading
      heading=$(echo "$line" | sed 's/^## //' | tr '[:upper:]' '[:lower:]')

      # Check if we've seen this heading before.
      local seen
      for seen in "${seen_headings[@]}"; do
        if [[ "$seen" == "$heading" ]]; then
          duplicate_found=true
          break
        fi
      done

      seen_headings+=("$heading")
    fi
  done <<<"$content"

  if [[ "$duplicate_found" == "true" ]]; then
    fail "B6" "Structure: Duplicate section headings found."
    return 1
  else
    if [[ "$verbose" == "true" ]]; then
      pass "B6" "Structure: No duplicate section headings found."
    fi
  fi
}
