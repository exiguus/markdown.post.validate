#!/bin/bash

# Blog Post Validator
# Validates a markdown blog post against blog post quality standards.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Add cargo bin to PATH for lychee
# Use ${HOME:-} to avoid nounset error when HOME is unset
if [[ -n "${HOME:-}" && -d "${HOME}/.cargo/bin" ]]; then
  export PATH="${HOME}/.cargo/bin:${PATH}"
fi

readonly SUCCESS=0
readonly FAILURE=1

# Script name for usage messages
SCRIPT_NAME="$(basename "$0")"

# Cache configuration
# Use ${HOME:-} to avoid nounset error when HOME is unset
CACHE_DIR="${HOME:-}/.cache/blog-validator"
CACHE_ENABLED=true

# Create cache directory if it doesn't exist
if [[ -n "${HOME:-}" ]]; then
  mkdir -p "$CACHE_DIR" || true
fi

# Function to compute hash for cache key
# Args:
#   $1: File path
#   $2: Verbose flag (optional, default: false)
compute_cache_key() {
  local file_path="$1"
  local verbose_flag="${2:-false}"
  local script_hash
  script_hash=$(sha256sum "$0" 2>/dev/null | awk '{print $1}') || true
  local file_hash
  file_hash=$(sha256sum "$file_path" 2>/dev/null | awk '{print $1}') || true
  # Include verbose flag in cache key to differentiate between verbose/non-verbose output
  local flags_hash
  flags_hash=$(echo -n "${verbose_flag}" | sha256sum 2>/dev/null | awk '{print $1}') || true
  echo "${script_hash}_${file_hash}_${flags_hash}"
}

# Function to get cached result
get_cached_result() {
  local cache_key="$1"
  local cache_file="${CACHE_DIR}/${cache_key}"
  if [[ -f "$cache_file" ]]; then
    cat "$cache_file" || return 1
    return 0
  else
    return 1
  fi
}

# Function to store result in cache
store_cached_result() {
  local cache_key="$1"
  local cache_file="${CACHE_DIR}/${cache_key}"
  # Read from stdin
  cat >"$cache_file" || true
}

# Colors for output (only if stdout is a terminal)
if [[ -t 1 ]]; then
  readonly RED='\033[0;31m'
  readonly GREEN='\033[0;32m'
  readonly YELLOW='\033[0;33m'
  readonly BLUE='\033[0;34m'
  readonly NC='\033[0m' # No Color
else
  readonly RED=''
  readonly GREEN=''
  readonly YELLOW=''
  readonly BLUE=''
  readonly NC=''
fi

# Counters for issues found
declare -i gate_a_failures=0
declare -i gate_b_failures=0
declare -i gate_c_failures=0
declare -i warnings=0

#######################
# Configuration       #
#######################

# Check configuration format:
#   key: Check ID (A1, A2, etc.)
#   gate: Gate group (A, B, or C)
#   category: Display category (Format, Structure, Links, etc.)
#   label: Full description for display
#   type: automated or manual
#   severity: error (fail on failure) or warning (warn on failure)
#   function: Name of validation function to call
#   args: Arguments to pass to the validation function (space-separated)
#
declare -A CHECK_CONFIG=(
  # Gate A: Blocking Failures
  [A1_gate]="A"
  [A1_category]="Format"
  [A1_label]="Required frontmatter fields and format validation"
  [A1_type]="automated"
  [A1_severity]="error"
  [A1_function]="validate_frontmatter validate_frontmatter_format validate_toml_delimiter"
  [A1_args]="content verbose"

  [A2_gate]="A"
  [A2_category]="Fact-Checking"
  [A2_label]="Source verification"
  [A2_type]="manual"
  [A2_severity]="error"
  [A2_function]=""
  [A2_args]=""

  [A3_gate]="A"
  [A3_category]="Links"
  [A3_label]="No dead links"
  [A3_type]="automated"
  [A3_severity]="error"
  [A3_function]="validate_dead_links"
  [A3_args]="file_path verbose"

  [A4_gate]="A"
  [A4_category]="Images"
  [A4_label]="Image files exist"
  [A4_type]="automated"
  [A4_severity]="error"
  [A4_function]="validate_image_files"
  [A4_args]="content verbose file_path"

  [A5_gate]="A"
  [A5_category]="Structure"
  [A5_label]="Footnote integrity"
  [A5_type]="automated"
  [A5_severity]="error"
  [A5_function]="validate_footnotes"
  [A5_args]="content verbose"

  [A6_gate]="A"
  [A6_category]="Link Relevance"
  [A6_label]="Ensure all links are relevant and add value"
  [A6_type]="manual"
  [A6_severity]="error"
  [A6_function]=""
  [A6_args]=""

  [A7_gate]="A"
  [A7_category]="Links"
  [A7_label]="No bare URLs in content"
  [A7_type]="automated"
  [A7_severity]="warning"
  [A7_function]="validate_links"
  [A7_args]="content verbose"

  # Gate B: Quality Checks
  [B1_gate]="B"
  [B1_category]="Structure"
  [B1_label]="Introduction and conclusion sections"
  [B1_type]="automated"
  [B1_severity]="warning"
  [B1_function]="validate_intro_conclusion"
  [B1_args]="content verbose"

  [B2_gate]="B"
  [B2_category]="Structure"
  [B2_label]="Heading hierarchy"
  [B2_type]="automated"
  [B2_severity]="error"
  [B2_function]="validate_heading_hierarchy"
  [B2_args]="content verbose"

  [B3_gate]="B"
  [B3_category]="Evidence Quality"
  [B3_label]="Verify claims are supported by evidence"
  [B3_type]="manual"
  [B3_severity]="warning"
  [B3_function]=""
  [B3_args]=""

  [B4_gate]="B"
  [B4_category]="Format"
  [B4_label]="Code block language fences"
  [B4_type]="automated"
  [B4_severity]="error"
  [B4_function]="validate_code_blocks"
  [B4_args]="content verbose"

  [B5_gate]="B"
  [B5_category]="Structure"
  [B5_label]="3-6 core sections between intro and conclusion"
  [B5_type]="automated"
  [B5_severity]="warning"
  [B5_function]="validate_section_count"
  [B5_args]="content verbose"

  [B6_gate]="B"
  [B6_category]="Structure"
  [B6_label]="No duplicate section headings"
  [B6_type]="automated"
  [B6_severity]="error"
  [B6_function]="validate_section_redundancy"
  [B6_args]="content verbose"

  [B7_gate]="B"
  [B7_category]="Quote Accuracy"
  [B7_label]="Verify quotes are accurate and properly attributed"
  [B7_type]="manual"
  [B7_severity]="warning"
  [B7_function]=""
  [B7_args]=""

  [B8_gate]="B"
  [B8_category]="Conclusion Quality"
  [B8_label]="Assess conclusion effectiveness and synthesis"
  [B8_type]="manual"
  [B8_severity]="warning"
  [B8_function]=""
  [B8_args]=""

  # Gate C: Accessibility & Style
  [C1_gate]="C"
  [C1_category]="Format"
  [C1_label]="Hero image alt text length"
  [C1_type]="automated"
  [C1_severity]="warning"
  [C1_function]="validate_hero_alt"
  [C1_args]="content verbose"

  [C2_gate]="C"
  [C2_category]="Format"
  [C2_label]="Description length"
  [C2_type]="automated"
  [C2_severity]="warning"
  [C2_function]="validate_description_length"
  [C2_args]="content verbose"

  [C3_gate]="C"
  [C3_category]="Links"
  [C3_label]="Descriptive link text"
  [C3_type]="automated"
  [C3_severity]="error"
  [C3_function]="validate_link_text"
  [C3_args]="content verbose"

  [C4_gate]="C"
  [C4_category]="Tables"
  [C4_label]="Table headers"
  [C4_type]="automated"
  [C4_severity]="warning"
  [C4_function]="validate_table_headers"
  [C4_args]="content verbose"

  [C5_gate]="C"
  [C5_category]="Originality Check"
  [C5_label]="Verify content is original, not plagiarized"
  [C5_type]="manual"
  [C5_severity]="warning"
  [C5_function]=""
  [C5_args]=""

  [C6_gate]="C"
  [C6_category]="Argument Balance"
  [C6_label]="Ensure fair and balanced presentation"
  [C6_type]="manual"
  [C6_severity]="warning"
  [C6_function]=""
  [C6_args]=""

  [C7_gate]="C"
  [C7_category]="Writing Quality"
  [C7_label]="Assess tone, readability, and style"
  [C7_type]="manual"
  [C7_severity]="warning"
  [C7_function]=""
  [C7_args]=""
)

# Get all check IDs
CHECK_IDS=("A1" "A2" "A3" "A4" "A5" "A6" "A7" "B1" "B2" "B3" "B4" "B5" "B6" "B7" "B8" "C1" "C2" "C3" "C4" "C5" "C6" "C7")

# Helper function to get config value
# Args:
#   $1: Check ID (e.g., A1)
#   $2: Field name (gate, category, label, type, severity, function, args)
get_config() {
  local check_id="$1"
  local field="$2"
  echo "${CHECK_CONFIG[${check_id}_${field}]}"
}

#######################
# Helper Functions    #
#######################

# Print error message to stderr and increment failure counter
# Args:
#   $1: Gate identifier (A1, A2, etc.)
#   $2: Error message
fail() {
  local gate="$1"
  local message="$2"
  echo -e "${RED}✗ [${gate}] ${message}${NC}" >&2
  case "$gate" in
    A*) ((gate_a_failures++)) || true ;;
    B*) ((gate_b_failures++)) || true ;;
    C*) ((gate_c_failures++)) || true ;;
    *) ((warnings++)) || true ;;
  esac
}

# Print success message
# Args:
#   $1: Gate identifier
#   $2: Success message
pass() {
  local gate="$1"
  local message="$2"
  echo -e "${GREEN}✓ [${gate}] ${message}${NC}"
}

# Print warning message
# Args:
#   $1: Warning identifier
#   $2: Warning message
warn() {
  local identifier="$1"
  local message="$2"
  echo -e "${YELLOW}⚠ [${identifier}] ${message}${NC}" >&2
  ((warnings++)) || true
}

# Print usage information
usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [-h|--help] [-v|--verbose] [-c|--no-cache] FILE.md

Validates a blog post markdown file against blog post quality standards.

Arguments:
  FILE.md    Path to the markdown file to validate.

Options:
  -h, --help          Show this help message and exit.
  -v, --verbose       Verbose output (show all checks, not just failures).
  -c, --no-cache      Disable caching of validation results.

Exit Codes:
  ${SUCCESS}    All checks passed.
  ${FAILURE}    One or more checks failed.

Checks Performed:
EOF

  # Group checks by gate
  declare -A gate_checks
  for check_id in "${CHECK_IDS[@]}"; do
    gate=$(get_config "$check_id" "gate")
    if [[ -n "$gate" ]]; then
      if [[ -z "${gate_checks[$gate]:-}" ]]; then
        gate_checks["$gate"]=""
      fi
      gate_checks["$gate"]+="  $(printf "%-4s" "$check_id")$(get_config "$check_id" "category"): $(get_config "$check_id" "label")\n"
    fi
  done

  # Print checks by gate
  for gate_letter in A B C; do
    gate_name=""
    case "$gate_letter" in
      A) gate_name="Blocking" ;;
      B) gate_name="Quality" ;;
      C) gate_name="Accessibility & Style" ;;
    esac
    echo "  Gate ${gate_letter} (${gate_name}):"
    echo -ne "${gate_checks[$gate_letter]:-}"
  done
  echo ""
}

#######################
# Validation Functions #
#######################

# A1: Validate required frontmatter fields
# Args:
#   $1: File content
#   $2: Verbose flag
validate_frontmatter() {
  local content="$1"
  local verbose="$2"

  local required_fields=("title" "description" "date" "authors" "tags")
  local missing_fields=()

  for field in "${required_fields[@]}"; do
    if [[ "$field" == "tags" ]]; then
      # tags is under [taxonomies] section
      if ! echo "$content" | grep -q '\[taxonomies\]'; then
        missing_fields+=("taxonomies.tags")
        continue
      fi
      # Use a temp variable to avoid pipeline exit issues
      local tax_content
      tax_content=$(echo "$content" | grep -A5 '\[taxonomies\]' || true)
      if ! echo "$tax_content" | grep -q 'tags = \['; then
        missing_fields+=("taxonomies.tags")
      fi
    else
      if ! echo "$content" | grep -q "${field} ="; then
        missing_fields+=("$field")
      fi
    fi
  done

  # Check if hero_img exists, then all extra fields must exist
  local has_hero_img
  has_hero_img=$(echo "$content" | grep -q 'hero_img =' && echo "yes" || echo "no")

  if [[ "$has_hero_img" == "yes" ]]; then
    local extra_required=("images" "hero_alt" "hero_copy")
    local missing_extra=()

    for field in "${extra_required[@]}"; do
      if ! echo "$content" | grep -q "${field} ="; then
        missing_extra+=("$field")
      fi
    done

    if [[ ${#missing_extra[@]} -gt 0 ]]; then
      fail "A1" "Format: hero_img is present but missing required [extra] field(s): ${missing_extra[*]}"
      return 1
    fi
  fi

  if [[ ${#missing_fields[@]} -eq 0 ]]; then
    if [[ "$verbose" == "true" ]]; then
      pass "A1" "Format: All required frontmatter fields present."
    fi
    return 0
  else
    fail "A1" "Format: Missing required frontmatter field(s): ${missing_fields[*]}"
    return 1
  fi
}

# A1: Validate frontmatter format details
# Args:
#   $1: File content
#   $2: Verbose flag
validate_frontmatter_format() {
  local content="$1"
  local verbose="$2"

  # Check date format (YYYY-MM-DD)
  if echo "$content" | grep -q 'date = "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]"'; then
    warn "A1" "Format: Date should be unquoted (YYYY-MM-DD without quotes)."
  fi

  # Check if date is in correct format
  if echo "$content" | grep -E 'date = [0-9]{4}-[0-9]{2}-[0-9]{2}' >/dev/null; then
    if [[ "$verbose" == "true" ]]; then
      pass "A1" "Format: Date format is valid (YYYY-MM-DD)."
    fi
  else
    # Try with quotes
    if ! echo "$content" | grep -E 'date = "[0-9]{4}-[0-9]{2}-[0-9]{2}"' >/dev/null; then
      fail "A1" "Format: Date format should be YYYY-MM-DD."
    fi
  fi

  # Check at least 3 tags exist
  local tags_line
  tags_line=$(echo "$content" | grep 'tags = \[' | head -1)
  if [[ -n "$tags_line" ]]; then
    # Count the number of tags by counting commas in the tags array and adding 1
    local comma_count
    comma_count=$(echo "$tags_line" | grep -o ',' | wc -l)
    local tag_count=$((comma_count + 1))
    if [[ $tag_count -lt 3 ]]; then
      fail "A1" "Format: At least 3 tags are required (found $tag_count)."
    fi
  else
    # tags field is required, so this should already be caught by validate_frontmatter
    fail "A1" "Format: Missing tags field."
  fi
}

# A3: Validate footnote integrity
# Args:
#   $1: File content
#   $2: Verbose flag
validate_footnotes() {
  local content="$1"
  local verbose="$2"

  # Extract all footnote references in text (e.g., [^1], [^2])
  # Remove definition lines first to avoid matching [^n]: when looking for [^n]
  local text_without_defs
  text_without_defs=$(echo "$content" | grep -v '^\[\^[0-9]\+\]:' || true)
  local text_refs
  text_refs=$(echo "$text_without_defs" | grep -oE '\[\^[0-9]+\]' | sed 's/\[\^//;s/\]//' | sort -u | tr -d ' ' || true)

  # Extract all footnote definitions (e.g., [^1]:, [^2]:)
  local definitions
  definitions=$(echo "$content" | grep -oE '\[\^[0-9]+\]:' | sed 's/\[\^//;s/\]://;s/://' | sort -u | tr -d ' ' || true)

  # Check if both are empty (no footnotes)
  if [[ -z "$text_refs" && -z "$definitions" ]]; then
    if [[ "$verbose" == "true" ]]; then
      pass "A5" "Structure: No footnotes found (valid if none are needed)."
    fi
    return 0
  fi

  # Convert to space-separated lists for easy comparison
  local text_refs_list="$text_refs"
  local definitions_list="$definitions"

  # Check for references without definitions
  local missing_defs=()
  for ref in $text_refs_list; do
    if ! echo " $definitions_list " | grep -qw "$ref"; then
      missing_defs+=("$ref")
    fi
  done

  if [[ ${#missing_defs[@]} -gt 0 ]]; then
    fail "A5" "Structure: Footnote reference(s) without definitions: ${missing_defs[*]}"
    return 1
  fi

  # Check for definitions without references
  local orphaned_defs=()
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

  # Check footnote numbering is sequential
  if [[ -n "$text_refs" ]]; then
    # Check for gaps in sequence
    local found_nums=()
    for ref in $text_refs; do
      found_nums+=("$ref")
    done

    # Sort numerically
    IFS=$'\n' read -d '' -ra sorted < <(sort -n <<<"${found_nums[*]}") || true
    unset IFS

    # Check for gaps in sequence
    local prev=0
    local has_gaps=false
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

    # Check that the first appearance of each footnote is in sequential order
    # (allows repeats, just checks that 1 appears before 2 before 3, etc.)
    local out_of_order=false

    # Get all unique footnote references in order of first appearance
    local all_refs
    all_refs=$(echo "$content" | grep -vE '\[\^[0-9]+\]:$' | grep -oE '\[\^[0-9]+\]' | sed 's/\[\^//;s/\]//' | tr -d ' ')

    if [[ -n "$all_refs" ]]; then
      # Get unique references in order of first appearance
      local first_appearances
      first_appearances=$(echo "$all_refs" | awk '!seen[$0]++')

      local prev=0
      for num in $first_appearances; do
        if [[ $num -ne $((prev + 1)) && $prev -ne 0 ]]; then
          out_of_order=true
          break
        fi
        prev=$num
      done

      # Also check if the first reference is not 1
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

# A5: Basic link validation (syntax only, not network)
# Args:
#   $1: File content
#   $2: Verbose flag
validate_links() {
  local content="$1"
  local verbose="$2"

  # Check for bare URLs in body text (not in frontmatter, code blocks, or inline code)
  # This is a simplified check - looks for http:// or https:// outside of code blocks
  local in_code_block=false
  local line_num=0
  local bare_urls=()

  while IFS= read -r line; do
    ((line_num++))

    # Toggle code block state
    if echo "$line" | grep -qE '^```'; then
      if [[ "$in_code_block" == "false" ]]; then
        in_code_block=true
      else
        in_code_block=false
      fi
      continue
    fi

    # Skip if in code block
    if [[ "$in_code_block" == "true" ]]; then
      continue
    fi

    # Skip frontmatter (lines between +++)
    if [[ $line_num -le 10 ]]; then # Simple heuristic: frontmatter is at start
      if echo "$line" | grep -q '+++'; then
        continue
      fi
    fi

    # Skip if line contains inline code with URLs
    # Check if the line has backtick-wrapped text containing URLs
    if echo "$line" | grep -qE '`[^`]*https?://[^`]*`'; then
      # Remove all inline code sections from the line for URL checking
      # Use | as delimiter to avoid issues with / in URLs
      line=$(echo "$line" | sed -E 's|`[^`]*https?://[^`]*`|INLINE_CODE_PLACEHOLDER|g')
    fi

    # Look for bare URLs (not in markdown link format)
    # Simple check: if line has http:// or https:// but NOT in [](url) format
    if echo "$line" | grep -qE 'https?://'; then
      # Check if it's wrapped in markdown link syntax
      if ! echo "$line" | grep -qE '\[.*\]\(https?://[^)]*\)' && ! echo "$line" | grep -qE '<https?://[^>]+>'; then
        # Not a markdown link, so it's a bare URL
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
    # Only report first one to avoid spam
    if [[ ${#bare_urls[@]} -gt 1 ]]; then
      warn "A7" "Links: ... and ${#bare_urls[@]} more bare URLs found."
    fi
  else
    if [[ "$verbose" == "true" ]]; then
      pass "A7" "Links: No bare URLs found in body text."
    fi
  fi
}

# A3: Validate links are not dead using lychee
# Args:
#   $1: File path
#   $2: Verbose flag
validate_dead_links() {
  local file_path="$1"
  local verbose="$2"

  # Check if lychee is installed
  if ! command -v lychee &>/dev/null; then
    warn "A3" "Links: lychee is not installed. Install with: cargo install lychee. See: https://lychee.cli.rs/guides/getting-started/"
    return 0
  fi

  # Run lychee to check for dead links
  # --quiet: Suppress non-error output
  # --no-progress: Don't show progress bar
  # --exclude-all-private: Skip private IPs
  # --include-fragments: Check URL fragments too
  # --exclude: Skip relative URL patterns (@/, ../, ./)
  # --exclude-path: Skip root-relative paths (/)
  local lychee_output
  lychee_output=$(lychee --quiet --no-progress --exclude-all-private --include-fragments \
    --exclude '@/*' --exclude '../*' --exclude './*' --exclude-path '/.*' \
    "$file_path" 2>/dev/null || true)

  # Check if there are any errors in the output
  # Lychee output format includes lines like:
  # 🚫 1 Error - meaning 1 dead link found
  # 🚫 5 Errors - meaning 5 dead links found
  # If all links are OK, we see "🚫 0 Error" or "🚫 0 Errors"
  if echo "$lychee_output" | grep -qE '🚫 [1-9][0-9]* Error(s)?'; then
    # Found dead links - fail
    local error_count
    error_count=$(echo "$lychee_output" | grep -oE '🚫 [0-9]+ Error(s)?' | head -1 | grep -oE '[0-9]+')
    fail "A3" "Links: Dead links found ($error_count errors). Run: lychee --quiet --no-progress --exclude-all-private --include-fragments --exclude '@/*' --exclude '../*' --exclude './*' --exclude-path '/.*' ${file_path}"
    if [[ "$verbose" == "true" ]]; then
      echo "${lychee_output//^/  }"
    fi
    return 1
  else
    # All links are valid
    if [[ "$verbose" == "true" ]]; then
      pass "A3" "Links: No dead links found."
    fi
  fi
}

# B1: Validate introduction and conclusion sections
# Args:
#   $1: File content
#   $2: Verbose flag
validate_intro_conclusion() {
  local content="$1"
  local verbose="$2"

  local has_intro=false
  local has_conclusion=false

  # Check for ## Introduction or equivalent
  if echo "$content" | grep -qi '^##.*introduction'; then
    has_intro=true
  elif echo "$content" | grep -qi '^##.*intro'; then
    has_intro=true
  fi

  # Check for ## Conclusion or equivalent
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

# B2: Validate heading hierarchy
# Args:
#   $1: File content
#   $2: Verbose flag
validate_heading_hierarchy() {
  local content="$1"
  local verbose="$2"

  local has_h1_in_body=false

  # Skip frontmatter lines and code blocks
  local in_frontmatter=false
  local in_code_block=false
  local line_num=0

  while IFS= read -r line; do
    ((line_num++))

    # Check for frontmatter delimiters
    if echo "$line" | grep -q '^+++$'; then
      if [[ "$in_frontmatter" == "false" ]]; then
        in_frontmatter=true
      else
        in_frontmatter=false
      fi
      continue
    fi

    # Skip if in frontmatter
    if [[ "$in_frontmatter" == "true" ]]; then
      continue
    fi

    # Toggle code block state
    if echo "$line" | grep -qE '^```'; then
      if [[ "$in_code_block" == "false" ]]; then
        in_code_block=true
      else
        in_code_block=false
      fi
      continue
    fi

    # Skip if in code block
    if [[ "$in_code_block" == "true" ]]; then
      continue
    fi

    # Check for H1 in body
    if echo "$line" | grep -qE '^# '; then
      has_h1_in_body=true
      fail "B2" "Structure: Found H1 heading in body text (line $line_num). Only H2 and H3 allowed."
    fi

    # Track heading levels
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

# B4/C4: Validate code blocks have language fences
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

    # Check for code block start
    if echo "$line" | grep -q '^```'; then
      if [[ "$in_code_block" == "false" ]]; then
        # This is the start of a code block
        in_code_block=true
        code_block_start=$line_num

        # Check if it has a language specifier
        local fence_line="$line"
        # Remove the backticks
        local language_spec
        language_spec=$(echo "$fence_line" | sed 's/^```//' | sed 's/^//' | xargs)

        # If language_spec is empty or just whitespace, it's a plain code block
        if [[ -z "$language_spec" || "$language_spec" == " " ]]; then
          code_blocks_without_language+=("$code_block_start")
        fi
      else
        # This is the end of a code block
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

# C1: Validate hero image alt text
# Args:
#   $1: File content
#   $2: Verbose flag
validate_hero_alt() {
  local content="$1"
  local verbose="$2"

  # Extract hero_alt value
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
    # No hero_alt is okay if there's no hero image
    if echo "$content" | grep -q 'hero_img ='; then
      warn "C1" "Format: hero_alt is missing but hero_img is present."
    fi
  fi
}

# A1: Validate TOML delimiter
# Args:
#   $1: File content
#   $2: Verbose flag
validate_toml_delimiter() {
  local content="$1"
  local verbose="$2"

  local first_line
  first_line=$(echo "$content" | head -1)
  local has_opening
  has_opening=$(echo "$first_line" | grep -q '^+++$' && echo "yes" || echo "no")

  if [[ "$has_opening" == "no" ]]; then
    fail "A1" "Format: Frontmatter does not start with '+++'."
    return 1
  fi

  # Find the closing +++ (could be on any line)
  local closing_line
  closing_line=$(echo "$content" | grep -n '^+++$' | tail -1 | cut -d: -f1)

  if [[ -z "$closing_line" ]]; then
    fail "A1" "Format: Frontmatter does not end with '+++'."
    return 1
  fi

  if [[ "$verbose" == "true" ]]; then
    pass "A1" "Format: TOML delimiters are valid."
  fi
}

# B5: Validate section count (3-6 core sections)
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

    # Check for frontmatter
    if echo "$line" | grep -q '^+++$'; then
      in_frontmatter=$(echo "$in_frontmatter" | awk '{print !($1+0)}')
      continue
    fi

    if [[ "$in_frontmatter" == "true" ]]; then
      continue
    fi

    # Check for introduction
    if echo "$line" | grep -qi '^##.*introduction'; then
      in_intro=true
      continue
    fi

    # Check for conclusion
    if echo "$line" | grep -qi '^##.*conclusion\|^##.*wrapping up\|^##.*final thoughts'; then
      in_conclusion=true
      continue
    fi

    # Count H2 sections between intro and conclusion
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

# B6: Validate no duplicate section headings
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

    # Check for frontmatter
    if echo "$line" | grep -q '^+++$'; then
      in_frontmatter=$(echo "$in_frontmatter" | awk '{print !($1+0)}')
      continue
    fi

    if [[ "$in_frontmatter" == "true" ]]; then
      continue
    fi

    # Check for H2 headings
    if echo "$line" | grep -q '^## '; then
      local heading
      heading=$(echo "$line" | sed 's/^## //' | tr '[:upper:]' '[:lower:]')

      # Check if we've seen this heading before
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

# A4: Validate image files exist
# Args:
#   $1: File content
#   $2: Verbose flag
#   $3: File path (to check relative image paths)
validate_image_files() {
  local content="$1"
  local verbose="$2"
  local file_path="$3"

  # Extract the directory of the markdown file
  local file_dir
  file_dir=$(dirname "$file_path")

  # Extract images from frontmatter
  local images_line
  images_line=$(echo "$content" | grep 'images = \[' | head -1 || true)

  # If no images in frontmatter, just return (nothing to validate)
  if [[ -z "$images_line" ]]; then
    if [[ "$verbose" == "true" ]]; then
      pass "A4" "Images: No images to validate (none in frontmatter)."
    fi
    return 0
  fi

  if [[ -n "$images_line" ]]; then
    # Extract image filenames from the array
    local images
    images=$(echo "$images_line" | sed -E 's/.*images = \[//' | sed -E 's/\]//' | tr -d ' "' || true)

    local missing_images=()
    local img_array=()
    if [[ -n "$images" ]]; then
      IFS=', ' read -ra img_array <<<"$images"
    fi

    for img in "${img_array[@]}"; do
      # Skip empty entries
      if [[ -z "$img" ]]; then
        continue
      fi

      # Check if image exists relative to the markdown file directory
      local full_path="${file_dir}/${img}"
      if [[ ! -f "$full_path" ]]; then
        missing_images+=("$img")
      fi
    done

    if [[ ${#missing_images[@]} -gt 0 ]]; then
      fail "A4" "Images: Image file(s) referenced in frontmatter but missing: ${missing_images[*]}"
      return 1
    else
      if [[ "$verbose" == "true" ]]; then
        pass "A4" "Images: All image files exist."
      fi
    fi
  fi
}

# C2: Check description length
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

# C3: Check for descriptive link text
# Args:
#   $1: File content
#   $2: Verbose flag
validate_link_text() {
  local content="$1"
  local verbose="$2"

  local click_here_count
  click_here_count=$(echo "$content" | grep -ci 'click here')

  if [[ $click_here_count -gt 0 ]]; then
    fail "C3" "Links: Found '$click_here_count' instances of 'click here' link text. Use descriptive text instead."
  else
    if [[ "$verbose" == "true" ]]; then
      pass "C3" "Links: No 'click here' link text found."
    fi
  fi
}

# C4: Validate table headers
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

    # Skip frontmatter
    if echo "$line" | grep -q '^+++$'; then
      in_frontmatter=$(echo "$in_frontmatter" | awk '{print !($1+0)}')
      continue
    fi

    if [[ "$in_frontmatter" == "true" ]]; then
      continue
    fi

    # Check for table lines (start with |)
    if echo "$line" | grep -qE '^\|'; then
      table_found=true
      # Skip the table line itself, we'll check it below
    fi
  done <<<"$content"

  # If we found tables, check they have headers
  if [[ "$table_found" == "true" ]]; then
    local first_table_line
    first_table_line=$(echo "$content" | grep -E '^\|' | head -1)

    # A table has headers if the first row contains non-whitespace between pipes
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

#######################
# Main Function       #
#######################

main() {
  local verbose="false"
  local file_path=""
  local cache_enabled="$CACHE_ENABLED"

  # Track gate sections for display
  declare -A gate_sections

  # Parse options (supports both short and long options)
  # Handle long options first
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help)
        usage
        exit "$SUCCESS"
        ;;
      --verbose)
        verbose="true"
        shift
        ;;
      --no-cache)
        cache_enabled="false"
        shift
        ;;
      -*)
        # Short options
        break
        ;;
      *)
        break
        ;;
    esac
  done

  # Parse short options
  while getopts "hvc" opt; do
    case "$opt" in
      h)
        usage
        exit "$SUCCESS"
        ;;
      v)
        verbose="true"
        ;;
      c)
        cache_enabled="false"
        ;;
      *)
        echo "Unknown option: -$opt" >&2
        usage
        exit "$FAILURE"
        ;;
    esac
  done
  shift $((OPTIND - 1))

  # Check for file argument
  if [[ $# -ne 1 ]]; then
    echo "Error: Missing file argument." >&2
    usage
    exit "$FAILURE"
  fi

  file_path="$1"

  # Check if file exists
  if [[ ! -f "$file_path" ]]; then
    echo "Error: File '$file_path' not found." >&2
    exit "$FAILURE"
  fi

  # Check if file is readable
  if [[ ! -r "$file_path" ]]; then
    echo "Error: Cannot read file '$file_path'." >&2
    exit "$FAILURE"
  fi

  # Check cache if enabled
  local cache_key=""
  if [[ "$cache_enabled" == "true" ]]; then
    cache_key=$(compute_cache_key "$file_path" "$verbose")
    local cached_output
    if cached_output=$(get_cached_result "$cache_key" 2>/dev/null); then
      echo "$cached_output"
      exit 0
    fi
  fi

  # Set up temp file for capturing validation output
  local temp_output_file
  temp_output_file=$(mktemp) || {
    echo "Error: Cannot create temp file" >&2
    exit "$FAILURE"
  }

  # Run validation and capture output
  {
    echo "Validating: $file_path"
    echo "----------------------------------------"

    # Read file content
    local content
    content=$(cat "$file_path") || {
      echo "Error: Cannot read file '$file_path'" >&2
      exit "$FAILURE"
    }

    # Group checks by gate and run them
    declare -A gate_display_names
    gate_display_names=(
      ["A"]="Blocking Failures"
      ["B"]="Major Quality Checks"
      ["C"]="Accessibility & Style"
    )

    # Track which checks have been run (to handle multi-function checks like A1)
    declare -A checks_run

    # Process each check in order
    for check_id in "${CHECK_IDS[@]}"; do
      gate=$(get_config "$check_id" "gate")
      category=$(get_config "$check_id" "category")
      label=$(get_config "$check_id" "label")
      check_type=$(get_config "$check_id" "type")
      function_name=$(get_config "$check_id" "function")
      args_str=$(get_config "$check_id" "args")

      # Start a new gate section if needed
      if [[ -z "${gate_sections[$gate]:-}" ]]; then
        echo -e "\n${BLUE}=== Gate ${gate}: ${gate_display_names[$gate]} ===${NC}"
        gate_sections["$gate"]=1
      fi

      # Handle manual checks (just print the message)
      if [[ "$check_type" == "manual" ]]; then
        echo "o [$check_id] ${category}: ${label} (manual validation required)"
        continue
      fi

      # Skip if already run (for multi-function checks like A1)
      if [[ -n "${checks_run[$check_id]:-}" ]]; then
        continue
      fi

      # Run the validation function(s)
      if [[ -n "$function_name" ]]; then
        # Handle multiple functions (space-separated)
        IFS=' ' read -ra functions <<<"$function_name"
        for func in "${functions[@]}"; do
          if [[ -n "$func" ]]; then
            # Build arguments
            local call_args=("$func")
            if [[ -n "$args_str" ]]; then
              IFS=' ' read -ra arg_array <<<"$args_str"
              for arg in "${arg_array[@]}"; do
                # Resolve variable names
                case "$arg" in
                  content) call_args+=("$content") ;;
                  verbose) call_args+=("$verbose") ;;
                  file_path) call_args+=("$file_path") ;;
                  *) call_args+=("$arg") ;;
                esac
              done
            fi
            # Call the function
            "${call_args[@]}" || true
          fi
        done
        checks_run["$check_id"]=1
      fi
    done

    # Summary
    echo ""
    echo "----------------------------------------"
    echo "Validation Summary:"
    echo "  Gate A (Blocking):    ${gate_a_failures} failure(s)"
    echo "  Gate B (Quality):      ${gate_b_failures} failure(s)"
    echo "  Gate C (Accessibility): ${gate_c_failures} failure(s)"
    echo "  Warnings:              ${warnings} warning(s)"

    # Calculate automation percentage from configuration
    local total_gates=${#CHECK_IDS[@]}
    local manual_gates=0
    local automated_gates=0
    local manual_gate_list=()

    for check_id in "${CHECK_IDS[@]}"; do
      check_type=$(get_config "$check_id" "type")
      if [[ "$check_type" == "manual" ]]; then
        ((manual_gates++)) || true
        manual_gate_list+=("$check_id")
      else
        ((automated_gates++)) || true
      fi
    done

    local automation_percentage=$((automated_gates * 100 / total_gates))

    echo "  Automated:            ${automated_gates}/${total_gates} gates (${automation_percentage}%)"
    echo "  Manual:               ${manual_gates}/${total_gates} gates (${manual_gate_list[*]})"
    echo "----------------------------------------"

    # Exit with appropriate code
    local total_failures=$((gate_a_failures + gate_b_failures + gate_c_failures))
    if [[ $total_failures -gt 0 ]]; then
      echo -e "${RED}Result: FAILED (${total_failures} failure(s))${NC}" >&2
      exit "$FAILURE"
    else
      echo -e "${GREEN}Result: PASSED${NC}"
      exit "$SUCCESS"
    fi
  } | tee "$temp_output_file"
  true

  # Capture exit code from the subshell
  local exit_code=${PIPESTATUS[0]}

  # Store full output in cache if enabled and result is PASSED
  if [[ "$cache_enabled" == "true" && -n "$file_path" && "$exit_code" == "$SUCCESS" ]]; then
    cat "$temp_output_file" | store_cached_result "$cache_key"
  fi

  # Clean up temp file
  rm -f "$temp_output_file"

  exit "$exit_code"
}

main "$@"
