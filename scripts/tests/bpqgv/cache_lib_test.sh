#!/bin/bash

# Tests for shared cache library (scripts/lib/cache.sh).
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

echo -e "${BLUE}=== Cache Library Tests ===${NC}"
echo ""

# Test: compute_cache_key preserves prefix and produces SHA256-sized suffix.
run_command_test \
  "compute_cache_key produces prefixed key" \
  "bash --norc --noprofile -c 'source \"${PROJECT_DIR}/lib/cache.sh\" && key=\$(compute_cache_key va_ alpha beta) && [[ \"\$key\" =~ ^va_[0-9a-f]{64}\$ ]] && echo ok'" \
  0 \
  "ok"

# Test: validation by-key set/get round-trip.
run_command_test \
  "validation cache set/get by key" \
  "bash --norc --noprofile -c 'tmp=\$(mktemp -d) && source \"${PROJECT_DIR}/lib/cache.sh\" && cache_init \"\$tmp\" true && cache_set_validation_by_key va_test_key \"hello world\" && out=\$(cache_get_validation_by_key va_test_key) && rm -rf \"\$tmp\" && [[ \"\$out\" == \"hello world\" ]] && echo ok'" \
  0 \
  "ok"

# Test: remove by key deletes a single entry.
run_command_test \
  "cache_remove_by_key removes entry" \
  "bash --norc --noprofile -c 'tmp=\$(mktemp -d) && source \"${PROJECT_DIR}/lib/cache.sh\" && cache_init \"\$tmp\" true && cache_set_validation_by_key va_remove_me \"x\" && cache_remove_by_key va_remove_me && ! cache_exists_validation_by_key va_remove_me && rm -rf \"\$tmp\" && echo ok'" \
  0 \
  "ok"

# Test: AI key includes check id suffix and ai_ prefix.
run_command_test \
  "compute_ai_check_cache_key format" \
  "bash --norc --noprofile -c 'source \"${PROJECT_DIR}/lib/cache.sh\" && key=\$(compute_ai_check_cache_key article model C6 1 posthash prompthash) && [[ \"\$key\" =~ ^ai_[0-9a-f]{64}_C6\$ ]] && echo ok'" \
  0 \
  "ok"

# Test: if flock command fails, cache still writes/reads by falling back to unlocked path.
run_command_test \
  "cache operations fallback when flock fails" \
  "bash --norc --noprofile -c 'tmp=\$(mktemp -d) && mkdir -p \"\$tmp/bin\" \"\$tmp/cache\" && for cmd in sha256sum awk mktemp mv rm mkdir find cat chmod; do ln -s \"\$(command -v \"\$cmd\")\" \"\$tmp/bin/\$cmd\"; done && printf \"#!/bin/bash\\nexit 1\\n\" >\"\$tmp/bin/flock\" && chmod +x \"\$tmp/bin/flock\" && PATH=\"\$tmp/bin\" && source \"${PROJECT_DIR}/lib/cache.sh\" && cache_init \"\$tmp/cache\" true && cache_set_validation_by_key va_fallback value && out=\$(cache_get_validation_by_key va_fallback) && rm -rf \"\$tmp\" && [[ \"\$out\" == \"value\" ]] && echo ok'" \
  0 \
  "ok"

# Test: concurrent writes to the same key remain readable and leave no temp files.
run_command_test \
  "concurrent writes are atomic" \
  "bash --norc --noprofile -c 'tmp=\$(mktemp -d) && source \"${PROJECT_DIR}/lib/cache.sh\" && cache_init \"\$tmp\" true && for i in \$(seq 1 40); do cache_set_validation_by_key va_race \"value_\$i\" & done && wait && out=\$(cache_get_validation_by_key va_race) && tmp_count=\$(find \"\$tmp\" -name \".va_race.tmp.*\" -type f | wc -l | tr -d \"[:space:]\") && rm -rf \"\$tmp\" && [[ \"\$out\" =~ ^value_[0-9]+\$ ]] && [[ \"\$tmp_count\" == \"0\" ]] && echo ok'" \
  0 \
  "ok"

# Print summary and exit only when executed directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo ""
  echo -e "${BLUE}Cache Library Test Summary:${NC}"
  echo "  Passed: ${passed:-0}"
  echo "  Failed: ${failed:-0}"
  echo "  Total:  ${total:-0}"

  if [[ ${failed:-0} -gt 0 ]]; then
    exit 1
  fi

  exit 0
fi
