#!/bin/bash

# Frontmatter and metadata validation checks.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# A1: Validate required frontmatter fields.
# Args:
#   $1: File content
#   $2: Verbose flag
validate_frontmatter() {
  local content="$1"
  local verbose="$2"

  local required_fields=("title" "description" "date" "authors" "tags")
  local missing_fields=()

  local field
  for field in "${required_fields[@]}"; do
    if [[ "$field" == "tags" ]]; then
      # tags is under [taxonomies] section
      if ! grep -q '\[taxonomies\]' <<<"$content"; then
        missing_fields+=("taxonomies.tags")
        continue
      fi
      # Use a temp variable to avoid pipeline exit issues.
      local tax_content
      tax_content=$(grep -A5 '\[taxonomies\]' <<<"$content" || true)
      if ! grep -q 'tags = \[' <<<"$tax_content"; then
        missing_fields+=("taxonomies.tags")
      fi
    else
      if ! grep -q "${field} =" <<<"$content"; then
        missing_fields+=("$field")
      fi
    fi
  done

  # Check if hero_img exists, then all extra fields must exist.
  local has_hero_img
  has_hero_img=$(grep -q 'hero_img =' <<<"$content" && echo "yes" || echo "no")

  if [[ "$has_hero_img" == "yes" ]]; then
    local extra_required=("images" "hero_alt" "hero_copy")
    local missing_extra=()

    for field in "${extra_required[@]}"; do
      if ! grep -q "${field} =" <<<"$content"; then
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

# A1: Validate frontmatter format details.
# Args:
#   $1: File content
#   $2: Verbose flag
validate_frontmatter_format() {
  local content="$1"
  local verbose="$2"

  # Check date format (YYYY-MM-DD).
  if grep -q 'date = "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]"' <<<"$content"; then
    warn "A1" "Format: Date should be unquoted (YYYY-MM-DD without quotes)."
  fi

  # Check if date is in correct format.
  if grep -E 'date = [0-9]{4}-[0-9]{2}-[0-9]{2}' <<<"$content" >/dev/null; then
    if [[ "$verbose" == "true" ]]; then
      pass "A1" "Format: Date format is valid (YYYY-MM-DD)."
    fi
  else
    # Try with quotes.
    if ! grep -E 'date = "[0-9]{4}-[0-9]{2}-[0-9]{2}"' <<<"$content" >/dev/null; then
      fail "A1" "Format: Date format should be YYYY-MM-DD."
    fi
  fi

  # Check at least 3 tags exist.
  local tags_line
  tags_line=$(grep -m1 'tags = \[' <<<"$content" || true)
  if [[ -n "$tags_line" ]]; then
    # Count the number of tags by counting commas in the tags array and adding 1.
    local comma_count
    comma_count=$(echo "$tags_line" | grep -o ',' | wc -l)
    local tag_count=$((comma_count + 1))
    if [[ $tag_count -lt 3 ]]; then
      fail "A1" "Format: At least 3 tags are required (found $tag_count)."
    fi
  else
    # tags field is required, so this should already be caught by validate_frontmatter.
    fail "A1" "Format: Missing tags field."
  fi
}

# A1: Validate TOML delimiter.
# Args:
#   $1: File content
#   $2: Verbose flag
validate_toml_delimiter() {
  local content="$1"
  local verbose="$2"

  local first_line
  first_line=$(sed -n '1p' <<<"$content")
  local has_opening
  has_opening=$(grep -q '^+++$' <<<"$first_line" && echo "yes" || echo "no")

  if [[ "$has_opening" == "no" ]]; then
    fail "A1" "Format: Frontmatter does not start with '+++'."
    return 1
  fi

  # Find the closing +++ (could be on any line).
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

# A4: Validate image files exist.
# Args:
#   $1: File content
#   $2: Verbose flag
#   $3: File path (to check relative image paths)
validate_image_files() {
  local content="$1"
  local verbose="$2"
  local file_path="$3"

  # Extract the directory of the markdown file.
  local file_dir
  file_dir=$(dirname "$file_path")

  # Extract images from frontmatter.
  local images_line
  images_line=$(grep -m1 'images = \[' <<<"$content" || true)

  # If no images in frontmatter, just return (nothing to validate).
  if [[ -z "$images_line" ]]; then
    if [[ "$verbose" == "true" ]]; then
      pass "A4" "Images: No images to validate (none in frontmatter)."
    fi
    return 0
  fi

  if [[ -n "$images_line" ]]; then
    # Extract image filenames from the array.
    local images
    images=$(echo "$images_line" | sed -E 's/.*images = \[//' | sed -E 's/\]//' | tr -d ' "' || true)

    local missing_images=()
    local img_array=()
    if [[ -n "$images" ]]; then
      IFS=', ' read -ra img_array <<<"$images"
    fi

    local img
    for img in "${img_array[@]}"; do
      # Skip empty entries.
      if [[ -z "$img" ]]; then
        continue
      fi

      # Check if image exists relative to the markdown file directory.
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
