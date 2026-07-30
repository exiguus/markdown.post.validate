# Blog Post Quality Validator

A comprehensive Bash-based validation system for markdown blog posts that enforces blog post quality standards before publication.

## Quick Start

```bash
# Validate a single post
./scripts/validate_blog_post.sh path/to/post.md

# Validate all posts in the posts/ directory
./scripts/validate_all_blog_posts.sh

# Run the full test suite
make test

# Run all checks (format, lint, styleguide, test)
make check
```

## Features

- **22 Quality Gates** across 3 categories (Blocking, Quality, Accessibility)
- **14 Automated Checks** (64% automation coverage)
- **8 Manual Checks** with clear guidance
- **TOML Frontmatter** validation
- **Markdown Structure** verification
- **Link Validation** with lychee integration
- **Image Verification** for referenced assets
- **Footnote Integrity** checking
- **Comprehensive Test Suite** with 31+ test cases

## Installation

### Prerequisites

- Bash 4+ (for associative arrays)
- GNU core utilities (find, grep, sed, awk)
- Optional: [lychee](https://lychee.cli.rs/) for link validation (`cargo install lychee`)
- Optional: [shfmt](https://github.com/mvdan/sh) for formatting
- Optional: [shellcheck](https://www.shellcheck.net/) for linting

### Setup

```bash
# Clone the repository
git clone <repository-url>
cd markdown.post.validate

# Make scripts executable
chmod +x scripts/*.sh scripts/tests/*.sh

# Install development dependencies (optional)
make install
```

## Usage

### Single Post Validation

```bash
./scripts/validate_blog_post.sh --help
Usage: validate_blog_post.sh [-h|--help] [-v|--verbose] [-c|--no-cache] FILE.md

Validates a blog post markdown file against blog post quality standards.

Arguments:
  FILE.md    Path to the markdown file to validate.

Options:
  -h, --help          Show this help message and exit.
  -v, --verbose       Verbose output (show all checks, not just failures).
  -c, --no-cache      Disable caching of validation results.

Exit Codes:
  0    All checks passed.
  1    One or more checks failed.

Checks Performed:
  Gate A (Blocking):
  A1  Format: Required frontmatter fields and format validation
  A2  Fact-Checking: Source verification
  A3  Links: No dead links
  A4  Images: Image files exist
  A5  Structure: Footnote integrity
  A6  Link Relevance: Ensure all links are relevant and add value
  A7  Links: No bare URLs in content
  Gate B (Quality):
  B1  Structure: Introduction and conclusion sections
  B2  Structure: Heading hierarchy
  B3  Evidence Quality: Verify claims are supported by evidence
  B4  Format: Code block language fences
  B5  Structure: 3-6 core sections between intro and conclusion
  B6  Structure: No duplicate section headings
  B7  Quote Accuracy: Verify quotes are accurate and properly attributed
  B8  Conclusion Quality: Assess conclusion effectiveness and synthesis
  Gate C (Accessibility & Style):
  C1  Format: Hero image alt text length
  C2  Format: Description length
  C3  Links: Descriptive link text
  C4  Tables: Table headers
  C5  Originality Check: Verify content is original, not plagiarized
  C6  Argument Balance: Ensure fair and balanced presentation
  C7  Writing Quality: Assess tone, readability, and style
```

### Bulk Validation

The bulk validator checks all markdown posts in a directory, excluding files starting with underscore (`_`). By default, it fails fast on the first validation error. Use `-k` or `--continue` to validate all posts and get a summary of failures.

```bash
./scripts/validate_all_blog_posts.sh --help
Usage: validate_all_blog_posts.sh [-h|--help] [-v|--verbose] [-c|--no-cache] [-k|--continue] [-d|--directory DIRECTORY]

Validates all blog post markdown files against blog post quality standards.

Options:
  -h, --help             Show this help message and exit.
  -v, --verbose          Verbose output (show all checks, not just failures).
  -c, --no-cache         Disable caching of validation results.
  -k, --continue         Continue validation on failure (don't fail-fast).
  -d, --directory DIRECTORY  Directory to search for posts (default: posts/).

Exit Codes:
  0    All checks passed.
  1    One or more checks failed.

Examples:
  validate_all_blog_posts.sh                          # Validate all posts in posts/
  validate_all_blog_posts.sh --help                   # Show this help message
  validate_all_blog_posts.sh -v                      # Verbose output
  validate_all_blog_posts.sh --verbose               # Verbose output (long form)
  validate_all_blog_posts.sh -c                      # Disable cache
  validate_all_blog_posts.sh --no-cache             # Disable cache (long form)
  validate_all_blog_posts.sh -k                      # Continue on failure
  validate_all_blog_posts.sh --continue              # Continue on failure (long form)
  validate_all_blog_posts.sh -d custom/posts/        # Validate posts in custom directory
  validate_all_blog_posts.sh --directory custom/posts/ # Validate posts in custom directory (long form)
  validate_all_blog_posts.sh -v -c -k                # Verbose, no cache, continue on failure
```

### Make Targets

```bash
# Format all shell scripts
make fmt

# Check formatting without modifying files
make fmt-check

# Run shellcheck linter
make lint

# Run styleguide checks
make styleguide

# Run all tests
make test

# Run all checks (format + lint + styleguide + test)
make check
```

## Example Output

Here's an example of verbose output from validating a post:

```log
$ ./scripts/validate_blog_post.sh -v posts/2026-07-30-getting-started-with-rust.md
Validating: posts/2026-07-30-getting-started-with-rust.md
----------------------------------------

=== Gate A: Blocking Failures ===
✓ [A1] Format: All required frontmatter fields present.
✓ [A1] Format: Date format is valid (YYYY-MM-DD).
✓ [A1] Format: TOML delimiters are valid.
o [A2] Fact-Checking: Source verification (manual validation required)
✓ [A3] Links: No dead links found.
✓ [A4] Images: No images to validate (none in frontmatter).
✓ [A5] Structure: No footnotes found (valid if none are needed).
o [A6] Link Relevance: Ensure all links are relevant and add value (manual validation required)
✓ [A7] Links: No bare URLs found in body text.

=== Gate B: Major Quality Checks ===
✓ [B1] Structure: Introduction and Conclusion sections found.
✓ [B2] Structure: No H1 headings in body; hierarchy looks correct.
o [B3] Evidence Quality: Verify claims are supported by evidence (manual validation required)
✓ [B4] Format: All code blocks have language fences.
⚠ [B5] Structure: Core sections count is 7 (expected 3-6).
✓ [B6] Structure: No duplicate section headings found.
o [B7] Quote Accuracy: Verify quotes are accurate and properly attributed (manual validation required)
o [B8] Conclusion Quality: Assess conclusion effectiveness and synthesis (manual validation required)

=== Gate C: Accessibility & Style ===
✓ [C2] Format: Description length is appropriate.
✓ [C3] Links: No 'click here' link text found.
✓ [C4] Tables: No tables found (valid if none are needed).
o [C5] Originality Check: Verify content is original, not plagiarized (manual validation required)
o [C6] Argument Balance: Ensure fair and balanced presentation (manual validation required)
o [C7] Writing Quality: Assess tone, readability, and style (manual validation required)

----------------------------------------
Validation Summary:
  Gate A (Blocking):    0 failure(s)
  Gate B (Quality):      0 failure(s)
  Gate C (Accessibility): 0 failure(s)
  Warnings:              1 warning(s)
  Automated:            14/22 gates (63%)
  Manual:               8/22 gates (A2 A6 B3 B7 B8 C5 C6 C7)
----------------------------------------
Result: PASSED
```

### Bulk Validation Example

Here's an example of validating all posts in a directory:

```log
$ ./scripts/validate_all_blog_posts.sh -v
Validating all posts in: posts/
----------------------------------------
[1] Validating: posts/2026-07-29-the-art-of-debugging.md
Validating: posts/2026-07-29-the-art-of-debugging.md
----------------------------------------

=== Gate A: Blocking Failures ===
✓ [A1] Format: All required frontmatter fields present.
✓ [A1] Format: Date format is valid (YYYY-MM-DD).
✓ [A1] Format: TOML delimiters are valid.
o [A2] Fact-Checking: Source verification (manual validation required)
✓ [A3] Links: No dead links found.
✓ [A4] Images: No images to validate (none in frontmatter).
✓ [A5] Structure: No footnotes found (valid if none are needed).
o [A6] Link Relevance: Ensure all links are relevant and add value (manual validation required)
✓ [A7] Links: No bare URLs found in body text.

=== Gate B: Major Quality Checks ===
✓ [B1] Structure: Introduction and Conclusion sections found.
✓ [B2] Structure: No H1 headings in body; hierarchy looks correct.
o [B3] Evidence Quality: Verify claims are supported by evidence (manual validation required)
✓ [B4] Format: All code blocks have language fences.
✓ [B5] Structure: Core sections count is valid (4).
✓ [B6] Structure: No duplicate section headings found.
o [B7] Quote Accuracy: Verify quotes are accurate and properly attributed (manual validation required)
o [B8] Conclusion Quality: Assess conclusion effectiveness and synthesis (manual validation required)

=== Gate C: Accessibility & Style ===
✓ [C2] Format: Description length is appropriate.
✓ [C3] Links: No 'click here' link text found.
✓ [C4] Tables: No tables found (valid if none are needed).
o [C5] Originality Check: Verify content is original, not plagiarized (manual validation required)
o [C6] Argument Balance: Ensure fair and balanced presentation (manual validation required)
o [C7] Writing Quality: Assess tone, readability, and style (manual validation required)

----------------------------------------
Validation Summary:
  Gate A (Blocking):    0 failure(s)
  Gate B (Quality):      0 failure(s)
  Gate C (Accessibility): 0 failure(s)
  Warnings:              0 warning(s)
  Automated:            14/22 gates (63%)
  Manual:               8/22 gates (A2 A6 B3 B7 B8 C5 C6 C7)
----------------------------------------
  Status: PASSED

[2] Validating: posts/2026-07-30-getting-started-with-rust.md
Validating: posts/2026-07-30-getting-started-with-rust.md
----------------------------------------

=== Gate A: Blocking Failures ===
✓ [A1] Format: All required frontmatter fields present.
✓ [A1] Format: Date format is valid (YYYY-MM-DD).
✓ [A1] Format: TOML delimiters are valid.
o [A2] Fact-Checking: Source verification (manual validation required)
✓ [A3] Links: No dead links found.
✓ [A4] Images: No images to validate (none in frontmatter).
✓ [A5] Structure: No footnotes found (valid if none are needed).
o [A6] Link Relevance: Ensure all links are relevant and add value (manual validation required)
✓ [A7] Links: No bare URLs found in body text.

=== Gate B: Major Quality Checks ===
✓ [B1] Structure: Introduction and Conclusion sections found.
✓ [B2] Structure: No H1 headings in body; hierarchy looks correct.
o [B3] Evidence Quality: Verify claims are supported by evidence (manual validation required)
✓ [B4] Format: All code blocks have language fences.
⚠ [B5] Structure: Core sections count is 7 (expected 3-6).
✓ [B6] Structure: No duplicate section headings found.
o [B7] Quote Accuracy: Verify quotes are accurate and properly attributed (manual validation required)
o [B8] Conclusion Quality: Assess conclusion effectiveness and synthesis (manual validation required)

=== Gate C: Accessibility & Style ===
✓ [C2] Format: Description length is appropriate.
✓ [C3] Links: No 'click here' link text found.
✓ [C4] Tables: No tables found (valid if none are needed).
o [C5] Originality Check: Verify content is original, not plagiarized (manual validation required)
o [C6] Argument Balance: Ensure fair and balanced presentation (manual validation required)
o [C7] Writing Quality: Assess tone, readability, and style (manual validation required)

----------------------------------------
Validation Summary:
  Gate A (Blocking):    0 failure(s)
  Gate B (Quality):      0 failure(s)
  Gate C (Accessibility): 0 failure(s)
  Warnings:              1 warning(s)
  Automated:            14/22 gates (63%)
  Manual:               8/22 gates (A2 A6 B3 B7 B8 C5 C6 C7)
----------------------------------------
  Status: PASSED

========================================
Validation Summary
========================================
Total posts:  2
Passed:        2
Failed:        0

All 2 posts validated successfully!
```

### Legend

| Symbol | Meaning |
| ------ | ------- |
| ✓ | Check passed |
| ✗ | Check failed (blocks merge for Gate A) |
| ⚠ | Warning (doesn't block merge) |
| o | Manual check (requires human review) |

## Quality Gate System

The validator organizes checks into three gates with increasing specificity:

### Gate A: Blocking Failures

**Purpose:** Catch critical issues that prevent publication. Failures here **block merging**.

| Check | Type | Category | Description |
| ----- | ---- | -------- | ----------- |
| A1 | Automated | Format | Required frontmatter fields and format validation |
| A2 | Manual | Fact-Checking | Source verification |
| A3 | Automated | Links | No dead links (via lychee) |
| A4 | Automated | Images | Image files exist |
| A5 | Automated | Structure | Footnote integrity |
| A6 | Manual | Link Relevance | Ensure all links are relevant and add value |
| A7 | Automated | Links | No bare URLs in content |

### Gate B: Major Quality Checks

**Purpose:** Ensure structural and content quality standards. Warnings are acceptable but indicate areas for improvement.

| Check | Type | Category | Description |
| ----- | ---- | -------- | ----------- |
| B1 | Automated | Structure | Introduction and Conclusion sections |
| B2 | Automated | Structure | Heading hierarchy (max H3) |
| B3 | Manual | Evidence Quality | Verify claims are supported by evidence |
| B4 | Automated | Format | Code block language fences |
| B5 | Automated | Structure | 3-6 core sections between intro and conclusion |
| B6 | Automated | Structure | No duplicate section headings |
| B7 | Manual | Quote Accuracy | Verify quotes are accurate and properly attributed |
| B8 | Manual | Conclusion Quality | Assess conclusion effectiveness and synthesis |

### Gate C: Accessibility & Style

**Purpose:** Ensure content is accessible, original, and well-written. Warnings indicate style or accessibility improvements.

| Check | Type | Category | Description |
| ----- | ---- | -------- | ----------- |
| C1 | Automated | Format | Hero image alt text length (30-45 words) |
| C2 | Automated | Format | Description length (< 200 chars recommended) |
| C3 | Automated | Links | Descriptive link text (no "click here") |
| C4 | Automated | Tables | Table headers present |
| C5 | Manual | Originality | Verify content is original, not plagiarized |
| C6 | Manual | Argument Balance | Ensure fair and balanced presentation |
| C7 | Manual | Writing Quality | Assess tone, readability, and style |

## Exit Codes

| Code | Meaning |
| ---- | ------- |
| 0 | All checks passed |
| 1 | One or more checks failed |

## Example Posts

Two example posts demonstrating proper structure are included in the `posts/` directory:

1. **posts/2026-07-30-getting-started-with-rust.md** - A beginner's guide to Rust programming
2. **posts/2026-07-29-the-art-of-debugging.md** - Debugging techniques and best practices

Both posts:

- Have valid TOML frontmatter with all required fields
- Include Introduction and Conclusion sections
- Use proper heading hierarchy (H2 and H3 only)
- Have code blocks with language specifiers
- Contain 3-6 core sections
- Pass all automated checks

## Post Requirements

### Required Frontmatter Fields

All posts **must** include these TOML frontmatter fields:

```toml
+++
title = "Your Post Title"
description = "A concise description under 200 characters"
date = 2026-07-30  # YYYY-MM-DD format, unquoted
authors = ["author-name"]
[taxonomies]
tags = ["tag1", "tag2", "tag3"]  # Minimum 3 tags
+++
```

### Optional Hero Image Fields

If your post includes a hero image, add these `[extra]` fields:

```toml
[extra]
hero_img = "path/to/image.png"
images = ["path/to/image.png"]
hero_alt = "Alt text between 30-45 words describing the image"
hero_copy = "Optional caption text"
```

### Structural Requirements

1. **Introduction Section**: Must have `## Introduction` or `## Intro`
2. **Conclusion Section**: Must have `## Conclusion`, `## Wrapping Up`, or `## Final Thoughts`
3. **Core Sections**: 3-6 H2 sections between Introduction and Conclusion
4. **Heading Hierarchy**: Use H2 (`##`) and H3 (`###`) only. No H1 in body text.
5. **Unique Headings**: All H2 section headings must be unique

### Content Requirements

1. **Code Blocks**: Must have language specifiers (e.g., bash, python, text)
2. **Links**: Use descriptive text, not "click here" or bare URLs
3. **Footnotes**: All references `[^n]` must have definitions `[^n]:` and vice versa
4. **No Dead Links**: All external URLs must be accessible (validated via lychee if installed)

## Configuration System

The validator uses a centralized configuration system defined in `scripts/validate_blog_post.sh`. Each check is configured with:

```bash
# Check ID configuration example
[A1_gate]="A"
[A1_category]="Format"
[A1_label]="Required frontmatter fields and format validation"
[A1_type]="automated"
[A1_severity]="error"
[A1_function]="validate_frontmatter validate_frontmatter_format validate_toml_delimiter"
[A1_args]="content verbose"
```

### Configuration Fields

| Field | Description | Values |
| ----- | ----------- | ------ |
| `gate` | Gate group identifier | A, B, or C |
| `category` | Display category | Format, Structure, Links, Images, Code, etc. |
| `label` | Human-readable description | Any string |
| `type` | Check automation type | `automated` or `manual` |
| `severity` | Failure behavior | `error` (blocks merge) or `warning` (allows merge) |
| `function` | Validation function(s) | Space-separated function names |
| `args` | Function arguments | Space-separated variable names |

### Multi-Function Checks

Some checks require multiple validation functions. For example, A1 (frontmatter validation) uses three functions:

- `validate_frontmatter` - Checks required fields exist
- `validate_frontmatter_format` - Validates field formats (dates, etc.)
- `validate_toml_delimiter` - Ensures proper TOML delimiter usage

All functions receive the same arguments specified in the `args` field.

## Testing

A comprehensive test suite validates all validator functions:

```bash
# Run all tests
make test

# Or directly
./scripts/tests/run_tests.sh

# Run specific test categories
./scripts/tests/valid_post_test.sh
./scripts/tests/frontmatter_test.sh
./scripts/tests/structure_test.sh
./scripts/tests/validate_all_blog_posts_test.sh
# ... etc
```

### Test Results

- **Total Tests**: 46 automated tests
- **Coverage**: All validation functions tested
- **Test Files**: 11 category-specific test suites
- **Mock Posts**: 12+ test fixtures in `scripts/mocks/`

### Adding Tests

To add a new test:

1. Create a new test file in `scripts/tests/` (e.g., `new_feature_test.sh`)
2. Source the test framework: `source "$FRAMEWORK_DIR/test_framework.sh"`
3. Use `run_test` function for individual tests or `run_category_tests` for grouped tests
4. Add your test file to the `test_files` array in `run_tests.sh`

## Development

### Project Structure

```
.
├── posts/                          # Example blog posts
│   ├── 2026-07-29-the-art-of-debugging.md
│   └── 2026-07-30-getting-started-with-rust.md
├── scripts/                        # Validator scripts
│   ├── validate_blog_post.sh       # Main validation script
│   ├── validate_all_blog_posts.sh  # Bulk validation
│   └── tests/                      # Test suite
│       ├── run_tests.sh            # Test runner
│       ├── test_framework.sh       # Test framework
│       ├── valid_post_test.sh      # Valid post tests
│       ├── frontmatter_test.sh      # Frontmatter tests
│       ├── hero_image_test.sh      # Hero image tests
│       ├── format_test.sh          # Format tests
│       ├── tags_test.sh            # Tags tests
│       ├── structure_test.sh       # Structure tests
│       ├── content_test.sh         # Content tests
│       ├── footnote_test.sh        # Footnote tests
│       ├── edge_case_test.sh       # Edge case tests
│       ├── relative_links_test.sh  # Relative links tests
│       └── validate_all_blog_posts_test.sh  # Bulk validation tests
├── Makefile                        # Build and check targets
└── README.md                       # This file
```

### Adding a New Automated Check

1. **Create the validation function** in `scripts/validate_blog_post.sh`:

   ```bash
   validate_my_new_check() {
     local content="$1"
     local verbose="$2"
     # Your validation logic here
     # Return 0 for pass, 1 for fail
   }
   ```

2. **Add configuration** to the `CHECK_CONFIG` associative array:

   ```bash
   [NEW1_gate]="A"
   [NEW1_category]="New Category"
   [NEW1_label]="Description of new check"
   [NEW1_type]="automated"
   [NEW1_severity]="error"
   [NEW1_function]="validate_my_new_check"
   [NEW1_args]="content verbose"
   ```

3. **Add check ID** to the `CHECK_IDS` array:

   ```bash
   CHECK_IDS+=("NEW1")
   ```

4. **Add test cases** in `scripts/tests/` directory

The usage message and summary statistics are automatically generated from the configuration.

### Code Style

This project follows the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html):

- **Shebang**: All scripts must start with `#!/bin/bash`
- **Strict Mode**: Include `set -o errexit`, `set -o nounset`, `set -o pipefail`
- **Indentation**: 2 spaces (configured in `.editorconfig`)
- **Naming**: Use `lower_snake_case` for functions and variables
- **Line Length**: Keep lines under 80 characters where possible
- **No Backticks**: Use `$(...)` for command substitution, not backticks

Run `make fmt` to auto-format all scripts.

## Automation Coverage

| Status | Count | Percentage |
| ------ | ----- | ---------- |
| Total Gates | 22 | 100% |
| Automated | 14 | 64% |
| Manual | 8 | 36% |

### Automated Checks (14)

- A1: Required frontmatter fields
- A3: Dead link detection
- A4: Image file existence
- A5: Footnote integrity
- A7: Bare URL detection
- B1: Introduction/Conclusion sections
- B2: Heading hierarchy
- B4: Code block language fences
- B5: Core section count
- B6: Duplicate heading detection
- C1: Hero image alt text length
- C2: Description length
- C3: Descriptive link text
- C4: Table headers

### Manual Checks (8)

- A2: Fact-checking / Source verification
- A6: Link relevance
- B3: Evidence quality
- B7: Quote accuracy
- B8: Conclusion quality
- C5: Originality check
- C6: Argument balance
- C7: Writing quality

## Future Enhancements

Potential integrations to increase automation coverage:

| Check | API/Tool | Purpose | Current Status |
| ----- | -------- | ------- | -------------- |
| A2 | Google Fact Check Tools | Automate fact-checking | Manual |
| A2 | Zyla API | Automated fact verification | Manual |
| A6 | Reboot Relevancy Rating | Automated link relevance | Manual |
| A6 | IBM Watson | NLP-based link analysis | Manual |
| C5 | Copyleaks API | Automated plagiarism detection | Manual |
| C5 | Grammarly API | Automated originality check | Manual |
| C5 | Winston AI | AI-powered plagiarism detection | Manual |
| B7 | Lexis Create+ | Automated quote validation | Manual |
| B7 | QuoteRight | Quote accuracy verification | Manual |
| C7 | ApyHub | Readability scoring | Manual |
| C7 | ReadablePro | Enhanced readability analysis | Manual |
| C7 | IBM Watson Tone Analyzer | Tone and style analysis | Manual |
| C7 | Sapling.ai | Writing quality suggestions | Manual |

## Troubleshooting

### Common Issues

**"Command not found: lychee"**

Install lychee for link validation:

```bash
cargo install lychee
```

Or the check will be skipped with a warning.

**"set: -o pipefail: invalid option"**

Ensure you're using Bash 4+. Check your bash version:

```bash
bash --version
```

**Test failures with exit code issues**

Make sure all scripts have the required header:

```bash
#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `make check` to verify all checks pass
5. Submit a pull request

All pull requests must pass `make check` before merging.

## License

Licensed under the [MIT License](LICENSE).
