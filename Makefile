TEST_SHELLS := $(wildcard scripts/tests/*.sh) $(wildcard scripts/tests/**/*.sh)
ROOT_SHELLS := $(filter-out $(TEST_SHELLS),$(wildcard scripts/*.sh))
SHELLS := $(ROOT_SHELLS) $(TEST_SHELLS)

.PHONY: fmt check lint styleguide test install hooks

## Format all shell scripts (2-space indent, Google style) and Markdown files (via rumdl)
fmt:
	@# Rewrite scripts in-place with project formatting rules.
	@echo "[fmt] Formatting shell scripts"
	@shfmt -w -i 2 -ci -bn $(SHELLS)
	@echo "[fmt] Formatting Markdown files"
	@rumdl fmt -s

## Show formatting diff without writing
fmt-check:
	@# Show formatting differences without modifying files.
	@echo "[fmt-check] Checking formatting of shell scripts"
	@shfmt -d -i 2 -ci -bn $(SHELLS)
	@echo "[fmt-check] Checking formatting of Markdown files"
	@rumdl check

## Lint all shell scripts and Markdown files
lint:
	@# Run ShellCheck with sourced-file resolution enabled.
	@echo "[lint] Running shellcheck"
	@shellcheck -x -S warning $(SHELLS)
	@# Run Markdown check (rumdl) for bare URLs and other issues.
	@echo "[lint] Running rumdl"
	@rumdl check

## Google Bash styleguide baseline checks
styleguide:
	@# Validate shebang, strict-mode header lines, and additional script hygiene rules.
	@echo "[styleguide] Running Bash style checks"
	@STATUS=0; \
	for f in $(SHELLS); do \
	  if ! bash -n "$$f"; then \
	    echo "STYLE: $$f has bash syntax errors"; \
	    STATUS=1; \
	  fi; \
	  if grep -nE '\`[^\`]+\`' "$$f" >/dev/null; then \
	    echo "STYLE: $$f uses backticks; use \$$() command substitution instead"; \
	    grep -nE '\`[^\`]+\`' "$$f" | sed 's/^/  /'; \
	    STATUS=1; \
	  fi; \
	  if grep -nE '^[[:space:]]*function[[:space:]]+[A-Za-z_][A-Za-z0-9_]*([[:space:]]*\(\))?[[:space:]]*\{' "$$f" >/dev/null; then \
	    echo "STYLE: $$f uses 'function name' style; prefer 'name() {'"; \
	    grep -nE '^[[:space:]]*function[[:space:]]+[A-Za-z_][A-Za-z0-9_]*([[:space:]]*\(\))?[[:space:]]*\{' "$$f" | sed 's/^/  /'; \
	    STATUS=1; \
	  fi; \
	  if grep -nE '^[[:space:]]*[A-Z][A-Za-z0-9_]*[[:space:]]*\(\)[[:space:]]*\{' "$$f" >/tmp/styleguide-func-names.$$; then \
	    echo "STYLE: $$f has function names outside lower_snake_case"; \
	    sed 's/^/  /' /tmp/styleguide-func-names.$$; \
	    STATUS=1; \
	  fi; \
	  if grep -nE '^[[:space:]]*[a-z][A-Za-z0-9]*[A-Z][A-Za-z0-9]*[[:space:]]*\(\)[[:space:]]*\{' "$$f" >>/tmp/styleguide-func-names.$$; then \
	    echo "STYLE: $$f has function names outside lower_snake_case"; \
	    sed 's/^/  /' /tmp/styleguide-func-names.$$; \
	    STATUS=1; \
	  fi; \
	  rm -f /tmp/styleguide-func-names.$$; \
	  if ! awk 'NR==1 && $$0=="#!/bin/bash" {ok=1} END{exit !ok}' "$$f"; then \
	    echo "STYLE: $$f missing '#!/bin/bash' on line 1"; \
	    STATUS=1; \
	  fi; \
	  if ! awk 'NR<=15 && $$0=="set -o errexit" {ok=1} END{exit !ok}' "$$f"; then \
	    echo "STYLE: $$f missing 'set -o errexit' in header"; \
	    STATUS=1; \
	  fi; \
	  if ! awk 'NR<=15 && $$0=="set -o nounset" {ok=1} END{exit !ok}' "$$f"; then \
	    echo "STYLE: $$f missing 'set -o nounset' in header"; \
	    STATUS=1; \
	  fi; \
	  if ! awk 'NR<=15 && $$0=="set -o pipefail" {ok=1} END{exit !ok}' "$$f"; then \
	    echo "STYLE: $$f missing 'set -o pipefail' in header"; \
	    STATUS=1; \
	  fi; \
	  if awk '/\r$$/ {exit 1} END {exit 0}' "$$f"; then :; else \
	    echo "STYLE: $$f contains CRLF line endings"; \
	    STATUS=1; \
	  fi; \
	  if awk '/[[:space:]]$$/ {exit 1} END {exit 0}' "$$f"; then :; else \
	    echo "STYLE: $$f contains trailing whitespace"; \
	    STATUS=1; \
	  fi; \
	  if [ -n "$$(tail -c 1 "$$f")" ]; then \
	    echo "STYLE: $$f missing trailing newline at EOF"; \
	    STATUS=1; \
	  fi; \
	done; \
	if [ "$$STATUS" -eq 0 ]; then echo "Google Bash styleguide checks passed."; fi; \
	exit $$STATUS

## Run executable shell tests via the main test runner
test:
	@# Execute integration-style shell tests via run_tests.sh.
	@echo "[test] Running shell tests"
	@if [ -f "scripts/tests/run_tests.sh" ]; then \
	  bash scripts/tests/run_tests.sh; \
	else \
	  echo "[test] run_tests.sh not found"; \
	  exit 1; \
	fi

## Format + lint + styleguide + test + secrets + contract checks
check:
	@echo "[check] Starting full validation"
	@$(MAKE) --no-print-directory fmt-check
	@$(MAKE) --no-print-directory lint
	@$(MAKE) --no-print-directory styleguide
	@$(MAKE) --no-print-directory test
	@echo "[check] All checks passed"

## Install shfmt, shellcheck, jq, curl, and lychee link checker if missing
install:
	@# Install shfmt if missing.
	@command -v shfmt >/dev/null 2>&1 || { echo "Installing shfmt..."; sudo apt-get update -qq && sudo apt-get install -y shfmt; }
	@# Install shellcheck if missing.
	@command -v shellcheck >/dev/null 2>&1 || { echo "Installing shellcheck..."; sudo apt-get update -qq && sudo apt-get install -y shellcheck; }
	@# Install jq if missing.
	@command -v jq >/dev/null 2>&1 || { echo "Installing jq..."; sudo apt-get update -qq && sudo apt-get install -y jq; }
	@# Install curl if missing.
	@command -v curl >/dev/null 2>&1 || { echo "Installing curl..."; sudo apt-get update -qq && sudo apt-get install -y curl; }
	@# Install lychee link checker if missing.
	@if ! command -v lychee >/dev/null 2>&1; then \
		if command -v cargo >/dev/null 2>&1; then \
			echo "Installing lychee..."; \
			cargo install lychee; \
		else \
			echo "Install cargo to be able to install lychee"; \
			exit 1; \
		fi; \
	fi
	@# Install rumdl if missing.
	@if ! command -v rumdl >/dev/null 2>&1; then \
    if command -v cargo >/dev/null 2>&1; then \
      echo "Installing rumdl..."; \
      cargo install rumdl; \
    else \
      echo "Install cargo to be able to install rumdl"; \
      exit 1; \
    fi; \
  fi
	@echo "[install] Tooling is ready"


## Install git pre-commit hook for secrets scanning
hooks:
	@# Ensure the hook script is executable.
	@chmod +x .githooks/pre-commit
	@# Point git to the repo-local hooks directory.
	@git config core.hooksPath .githooks
	@echo "[hooks] Git hooks installed (.githooks/pre-commit)"
