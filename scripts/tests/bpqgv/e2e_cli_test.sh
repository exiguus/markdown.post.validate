#!/bin/bash

# End-to-end CLI tests for check.sh, checks.sh, and assisted_checks.sh.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Guard: only source framework and print summary when executed directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # shellcheck disable=SC1091
  source "$(dirname "${BASH_SOURCE[0]}")/../test_framework.sh"
fi

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../ && pwd)"
PROJECT_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"

echo -e "${BLUE}=== End-to-End CLI Tests ===${NC}"
echo ""

# check.sh: valid post passes end to end.
run_command_test \
  "check.sh e2e passes valid post" \
  "bash --norc --noprofile '${PROJECT_DIR}/check.sh' '${PROJECT_DIR}/mocks/valid_post.md' 2>&1" \
  0 \
  "Validating:" \
  "Result: PASSED"

# check.sh: invalid post fails end to end.
run_command_test \
  "check.sh e2e fails invalid post" \
  "bash --norc --noprofile '${PROJECT_DIR}/check.sh' '${PROJECT_DIR}/mocks/missing_title.md' 2>&1" \
  1 \
  "Validation Summary:" \
  "Result: FAILED"

# check.sh: unknown option returns error.
run_command_test \
  "check.sh e2e fails on unknown option" \
  "bash --norc --noprofile '${PROJECT_DIR}/check.sh' -x '${PROJECT_DIR}/mocks/valid_post.md' 2>&1" \
  1 \
  "Unknown option"

# check.sh: missing file argument returns parser error.
run_command_test \
  "check.sh e2e fails on missing file argument" \
  "bash --norc --noprofile '${PROJECT_DIR}/check.sh' 2>&1" \
  1 \
  "Error: Missing file argument."

# check.sh: unreadable file returns file validation error.
run_command_test \
  "check.sh e2e fails on unreadable file" \
  "tmp=\$(mktemp -d) && cp '${PROJECT_DIR}/mocks/valid_post.md' \"\$tmp/unreadable.md\" && chmod 000 \"\$tmp/unreadable.md\" && bash --norc --noprofile '${PROJECT_DIR}/check.sh' \"\$tmp/unreadable.md\" 2>&1; rc=\$?; chmod 644 \"\$tmp/unreadable.md\"; rm -rf \"\$tmp\"; exit \$rc" \
  1 \
  "Error: Cannot read file"

# checks.sh: directory run succeeds for valid files.
run_command_test \
  "checks.sh e2e succeeds for valid directory" \
  "tmp=\$(mktemp -d) && cp '${PROJECT_DIR}/mocks/valid_post.md' \"\$tmp/2026-01-01-valid.md\" && bash --norc --noprofile '${PROJECT_DIR}/checks.sh' -d \"\$tmp\" 2>&1 && rc=\$?; rm -rf \"\$tmp\"; exit \$rc" \
  0 \
  "Validating all posts in:" \
  "All 1 posts validated successfully!"

# checks.sh: fail-fast behavior triggers non-zero on first invalid file.
run_command_test \
  "checks.sh e2e fail-fast on invalid file" \
  "tmp=\$(mktemp -d) && cp '${PROJECT_DIR}/mocks/valid_post.md' \"\$tmp/2026-01-01-valid.md\" && cp '${PROJECT_DIR}/mocks/missing_title.md' \"\$tmp/2026-01-02-invalid.md\" && bash --norc --noprofile '${PROJECT_DIR}/checks.sh' -d \"\$tmp\" 2>&1; rc=\$?; rm -rf \"\$tmp\"; exit \$rc" \
  1 \
  "Validating all posts in:" \
  "Validation failed for:"

# assisted_checks.sh: mock mode single-check path runs end to end.
run_command_test \
  "assisted_checks.sh e2e mock single check" \
  "MISTRAL_MOCK=1 bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' -n -r -c C5 '${PROJECT_DIR}/mocks/valid_post.md' 2>&1" \
  0 \
  "Running AI-assisted manual quality checks" \
  "Mode: MOCK" \
  "Checks: C5" \
  "Summary: 0 PASS, 0 FAIL, 1 total" \
  "Status Breakdown: 1 PARTIAL, 0 NOT_APPLICABLE, 0 NEEDS_REVIEW, 0 UNKNOWN"

# assisted_checks.sh: non-mock mode fails if key file is missing.
run_command_test \
  "assisted_checks.sh e2e fails without key file" \
  "bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' -c C5 -k /tmp/does-not-exist.key '${PROJECT_DIR}/mocks/valid_post.md' 2>&1" \
  1 \
  "Error: API key file '/tmp/does-not-exist.key' not found"

# assisted_checks.sh: invalid option is rejected by parser.
run_command_test \
  "assisted_checks.sh e2e fails on invalid option" \
  "bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' --definitely-invalid '${PROJECT_DIR}/mocks/valid_post.md' 2>&1" \
  1 \
  "Invalid option: --definitely-invalid"

# assisted_checks.sh: non-mock mode fails if key file lacks MISTRAL_API_KEY.
run_command_test \
  "assisted_checks.sh e2e fails on missing key variable" \
  "tmp=\$(mktemp -d) && key_file=\"\$tmp/no_key.env\" && printf '# missing key\n' >\"\$key_file\" && bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' -c C5 -k \"\$key_file\" '${PROJECT_DIR}/mocks/valid_post.md' 2>&1; rc=\$?; rm -rf \"\$tmp\"; exit \$rc" \
  1 \
  "Error: MISTRAL_API_KEY not found"

# assisted_checks.sh: reports are written when -r is not used.
run_command_test \
  "assisted_checks.sh e2e writes reports by default" \
  "article='e2e-assisted-report' && post='${PROJECT_DIR}/mocks/'\"\${article}\"'.md' && cp '${PROJECT_DIR}/mocks/valid_post.md' \"\$post\" && report_dir='${PROJECT_DIR}/../reports/'\"\${article}\" && MISTRAL_MOCK=1 bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' -n -c C5 \"\$post\" >/tmp/e2e_assisted_report.out 2>&1; rc=\$?; cat /tmp/e2e_assisted_report.out; [[ -f \"\$report_dir/C5.md\" ]]; file_rc=\$?; rm -f \"\$post\" /tmp/e2e_assisted_report.out; rm -rf \"\$report_dir\"; [[ \$rc -eq 0 && \$file_rc -eq 0 ]]" \
  0 \
  "Reports saved to:"

# assisted_checks.sh: unreadable post file triggers read error.
run_command_test \
  "assisted_checks.sh e2e fails on unreadable post" \
  "tmp=\$(mktemp -d) && post=\"\$tmp/unreadable.md\" && cp '${PROJECT_DIR}/mocks/valid_post.md' \"\$post\" && chmod 000 \"\$post\" && MISTRAL_MOCK=1 bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' -n -r -c C5 \"\$post\" 2>&1; rc=\$?; chmod 644 \"\$post\"; rm -rf \"\$tmp\"; exit \$rc" \
  1 \
  "Error: Could not read post file"

# assisted_checks.sh: missing prompt file warns and exits successfully.
run_command_test \
  "assisted_checks.sh e2e warns on missing prompt file" \
  "tmp=\$(mktemp -d) && prompts=\"\$tmp/prompts\" && cp -r '${PROJECT_DIR}/../prompts' \"\$prompts\" && mv \"\$prompts/C5-Originality-Check.md\" \"\$prompts/C5-Originality-Check.md.bak\" && post='${PROJECT_DIR}/mocks/valid_post.md' && (cd \"\$tmp\" && MISTRAL_MOCK=1 bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' -n -r -c C5 \"\$post\" 2>&1); rc=\$?; rm -rf \"\$tmp\"; exit \$rc" \
  0 \
  "Warning: Prompt file not found: prompts/C5-Originality-Check.md"

# assisted_checks.sh: cached output path is used on second run.
run_command_test \
  "assisted_checks.sh e2e cache hit on second run" \
  "tmp=\$(mktemp -d) && out1=\"\$tmp/first.out\" && out2=\"\$tmp/second.out\" && HOME=\"\$tmp/home\" MISTRAL_MOCK=1 bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' -r -c C5 '${PROJECT_DIR}/mocks/valid_post.md' >\"\$out1\" 2>&1 && HOME=\"\$tmp/home\" MISTRAL_MOCK=1 bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' -r -c C5 '${PROJECT_DIR}/mocks/valid_post.md' >\"\$out2\" 2>&1 && cat \"\$out2\" && grep -q '\\[CACHE\\] Using cached result for C5' \"\$out2\"; rc=\$?; rm -rf \"\$tmp\"; exit \$rc" \
  0 \
  "Using cached result for C5"

# assisted_checks.sh: report writer strips accidental leading separator lines.
run_command_test \
  "assisted_checks.sh e2e strips leading separator in report" \
  "tmp=\$(mktemp -d) && article='e2e-leading-separator' && post='${PROJECT_DIR}/mocks/'\"\${article}\"'.md' && report_dir='${PROJECT_DIR}/../reports/'\"\${article}\" && report_file=\"\$report_dir/C5.md\" && cp '${PROJECT_DIR}/mocks/valid_post.md' \"\$post\" && HOME=\"\$tmp/home\" MISTRAL_MOCK=1 bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' -c C5 \"\$post\" >/dev/null 2>&1 && cache_file=\$(find \"\$tmp/home/.cache/blog-validator\" -maxdepth 1 -type f -name 'ai_*_C5' | head -n 1) && [[ -n \"\$cache_file\" ]] && printf '%s\n' '---' >\"\$tmp/prefixed.txt\" && cat \"\$cache_file\" >>\"\$tmp/prefixed.txt\" && mv \"\$tmp/prefixed.txt\" \"\$cache_file\" && out=\"\$tmp/out.txt\" && HOME=\"\$tmp/home\" MISTRAL_MOCK=1 bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' -c C5 \"\$post\" >\"\$out\" 2>&1 && cat \"\$out\" && [[ -f \"\$report_file\" ]] && first_line=\$(head -n 1 \"\$report_file\") && [[ \"\$first_line\" != '---' ]]; rc=\$?; rm -f \"\$post\"; rm -rf \"\$report_dir\" \"\$tmp\"; exit \$rc" \
  0 \
  "Using cached result for C5"

# assisted_checks.sh: invalid cached output is rejected by schema validator.
run_command_test \
  "assisted_checks.sh e2e rejects invalid cached report" \
  "tmp=\$(mktemp -d) && post='${PROJECT_DIR}/mocks/valid_post.md' && out=\"\$tmp/out.txt\" && HOME=\"\$tmp/home\" MISTRAL_MOCK=1 bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' -r -c C5 \"\$post\" >\"\$tmp/seed.out\" 2>&1 && cache_file=\$(find \"\$tmp/home/.cache/blog-validator\" -maxdepth 1 -type f -name 'ai_*_C5' | head -n 1) && [[ -n \"\$cache_file\" ]] && printf '%s\n' '## Originality Check Report' '' '### Status: PASS' '' '### Summary' '' '- Verdict: FAIL' >\"\$cache_file\" && HOME=\"\$tmp/home\" MISTRAL_MOCK=1 bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' -r -c C5 \"\$post\" >\"\$out\" 2>&1 && cat \"\$out\" && grep -q '\[SCHEMA\] Cached result invalid for C5; regenerating' \"\$out\" && ! grep -q '\[CACHE\] Using cached result for C5' \"\$out\"; rc=\$?; rm -rf \"\$tmp\"; exit \$rc" \
  0 \
  "Cached result invalid for C5; regenerating"

# assisted_checks.sh: no arguments shows usage and fails.
run_command_test \
  "assisted_checks.sh e2e usage on missing args" \
  "bash --norc --noprofile '${PROJECT_DIR}/assisted_checks.sh' 2>&1" \
  1 \
  "Usage:"

# Print summary and exit only when executed directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo ""
  echo -e "${BLUE}End-to-End CLI Test Summary:${NC}"
  echo "  Passed: ${passed:-0}"
  echo "  Failed: ${failed:-0}"
  echo "  Total:  ${total:-0}"

  if [[ ${failed:-0} -gt 0 ]]; then
    exit 1
  fi

  exit 0
fi
