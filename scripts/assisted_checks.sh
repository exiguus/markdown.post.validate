#!/bin/bash

# AI Manual Quality Checks Runner
# Runs manual quality gate prompts against a blog post using Mistral API.
# Follows Google Shell Style Guide.

set -o errexit
set -o nounset
set -o pipefail

# Script name for usage messages
SCRIPT_NAME="$(basename "$0")"

# Source shared cache library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/cache.sh"

# Configuration
readonly ENDPOINT="https://api.mistral.ai/v1/chat/completions"
readonly DEFAULT_MODEL="mistral-medium"

# Available checks mapping (short name -> file)
declare -A AVAILABLE_CHECKS=(
  [A2]="prompts/A2-Source-Verification.md"
  [A6]="prompts/A6-Link-Relevance.md"
  [B3]="prompts/B3-Evidence-Quality.md"
  [B7]="prompts/B7-Quote-Accuracy.md"
  [B8]="prompts/B8-Conclusion-Quality.md"
  [C5]="prompts/C5-Originality-Check.md"
  [C6]="prompts/C6-Argument-Balance.md"
  [C7]="prompts/C7-Writing-Quality.md"
)

# Deterministic execution order for checks.
readonly CHECK_ORDER=(A2 A6 B3 B7 B8 C5 C6 C7)

# Mock mode: if MISTRAL_MOCK=1, use mock responses instead of API
MISTRAL_MOCK="${MISTRAL_MOCK:-0}"

# Reports directory
REPORTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)/reports"
WRITE_REPORTS=true

# Initialize AI cache with custom directory
# Use the same cache directory as validation cache
cache_init "${HOME:-}/.cache/blog-validator"

# AI Cache settings - use the library's CACHE_ENABLED for caching
# Keep AI_CACHE_ENABLED for backward compatibility
AI_CACHE_ENABLED="$CACHE_ENABLED"

# Usage function
usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [-m MODEL] [-k API_KEY_FILE] [-c CHECKS] [-n|--no-cache] [-r|--no-reports] [-h] [--help] POST_FILE

Run AI-assisted manual quality checks on a blog post.

Arguments:
  POST_FILE    Path to the blog post markdown file to analyze

Options:
  -m MODEL    Mistral model to use (default: $DEFAULT_MODEL)
              Available: mistral-tiny, mistral-small, mistral-medium, mistral-large
  -k FILE     File containing API key (default: .mistral)
  -c CHECKS   Comma-separated list of checks to run (e.g., A2,A6,C5)
              Available checks: ${!AVAILABLE_CHECKS[*]}
              If not specified, all checks run
  -n, --no-cache    Disable caching of AI check results
  -r, --no-reports  Disable writing report files to disk
  -h, --help  Show this help message

Environment:
  MISTRAL_MOCK=1     Use mock responses instead of real API (for testing)

Requirements:
  - jq must be installed
  - curl must be installed
  - API key file must contain: MISTRAL_API_KEY=your_key_here

Output:
  - Results are saved to reports/<article-name>/<check-id>.md

Examples:
  $SCRIPT_NAME posts/my-article.md
  $SCRIPT_NAME -m mistral-medium posts/my-article.md
  $SCRIPT_NAME -k /path/to/keyfile posts/my-article.md
  $SCRIPT_NAME -c A2,A6,C5 posts/my-article.md
  $SCRIPT_NAME -c C6 posts/my-article.md
  $SCRIPT_NAME -n posts/my-article.md              # Disable cache
  $SCRIPT_NAME --no-cache posts/my-article.md      # Disable cache (long form)
  MISTRAL_MOCK=1 $SCRIPT_NAME posts/my-article.md
EOF
}

# Function to generate mock response for a given check
# Args:
#   $1: Check ID (e.g., A2, C6)
#   $2: The full prompt (unused in mock, but for interface consistency)
# Returns:
#   Mock response JSON via stdout
generate_mock_response() {
  local check_id="$1"
  local _prompt="$2" # unused

  case "$check_id" in
    A2)
      cat <<'MOCKEOF'
{
  "choices": [{
    "message": {
      "content": "## Source Verification Report\n\n### Status: FAIL\n\n### Confidence: 100%\n\n---\n\n### Citation Statistics\n\n| **Metric** | **Count** | **Target** | **Status** | **Notes** |\n|------------|-----------|------------|------------|-----------|\n| Total factual claims | 14 | - | - | - |\n| Properly cited | 1 | 100% | FAIL | Only Stack Overflow claim cited |\n| Uncited | 13 | 0 | FAIL | Multiple missing citations |\n| Citation rate | 7% | 100% | FAIL | - |\n\n---\n\n### Uncited Factual Claims (CRITICAL - MUST BE FIXED)\n\n**Total Uncited Claims:** 13\n\n| **#** | **Claim (first 100 chars)** | **Location** | **Type** | **Suggested Source Type** | **Web Search Suggestion** | **Severity** |\n|-------|----------------------------|--------------|----------|--------------------------|----------------------------|--------------|\n| 1 | Rust has consistently been voted the most loved... | Introduction, p1, l12 | statistic | LEVEL 2 | \"Stack Overflow Developer Survey 2025\" | HIGH |\n| 2 | Rust offers a unique combination of performance... | Why Learn Rust, p1, l16 | technical | LEVEL 2 | \"Rust official documentation\" | HIGH |\n| 3 | Rust provides memory safety without garbage... | Why Learn Rust, p2, l17 | technical | LEVEL 1 | \"Rust memory safety guarantees site:doc.rust-lang.org\" | HIGH |\n\n**Uncited Claims Details:**\n1. **Claim:** \"Rust has consistently been voted the most loved programming language in the Stack Overflow Developer Survey for several years running\"\n   - **Location:** Introduction, paragraph 1, line 12\n   - **Full Text:** Rust has consistently been voted the most loved programming language in the Stack Overflow Developer Survey for several years running.\n   - **Type:** statistic\n   - **Suggested Source Type:** LEVEL 2\n   - **Suggested Source:** Stack Overflow Developer Survey 2023, 2024, 2025\n   - **Web Search Suggestion:** \"Rust most loved programming language Stack Overflow survey\"\n   - **Verification URL:** https://survey.stackoverflow.co/2025\n   - **Suggested Citation Format:** \"Stack Overflow, 'Developer Survey 2025', Stack Overflow Inc., 2025, https://survey.stackoverflow.co/2025\"\n\n---\n\n### Summary\n\n- **Total factual claims:** 14\n- **Properly cited:** 1 (7%)\n- **Level 1 sources:** 1 (7%)\n- **Level 2 sources:** 0 (0%)\n- **Level 3 sources:** 0 (0%)\n- **Level 4 sources:** 0 (0%)\n- **Uncited factual claims:** 13 (93%)\n- **Verdict:** FAIL (13 uncited claims found)\n\n---\n\n### Recommendations\n\n1. **Location:** Introduction, paragraph 1, line 12\n   - **Claim:** \"Rust has consistently been voted the most loved programming language in the Stack Overflow Developer Survey for several years running\"\n   - **Current:** Rust has consistently been voted the most loved programming language in the Stack Overflow Developer Survey for several years running.\n   - **Suggested:** Rust has consistently been voted the most loved programming language in the Stack Overflow Developer Survey for several years running.[^1]\n   - **Source:** [^1]: Stack Overflow, 'Developer Survey 2025', Stack Overflow Inc., 2025, https://survey.stackoverflow.co/2025\n   - **Verification:** \"Rust most loved programming language Stack Overflow\"\n\n2. **Location:** Why Learn Rust, paragraph 1, line 16\n   - **Claim:** \"Rust offers a unique combination of performance, reliability, and productivity\"\n   - **Current:** Rust offers a unique combination of performance, reliability, and productivity.\n   - **Suggested:** Rust offers a unique combination of performance, reliability, and productivity.[^2]\n   - **Source:** [^2]: Rust Documentation, 'Why Rust?', Rust Team, https://doc.rust-lang.org/book/ch00-00-introduction.html\n   - **Verification:** \"Rust unique combination performance reliability productivity site:doc.rust-lang.org\"\n\n---\n\n### Quick Fix Actions\n\n- [ ] Add inline citations for all 13 uncited claims\n- [ ] Fix 0 claims with incomplete citation formats\n- [ ] Verify all cited claims using: [\"Rust Stack Overflow survey\", \"Rust memory safety\", ...]\n- [ ] Add footnotes section if using footnote-style citations\n- [ ] Standardize citation format throughout post\n\n---\n\n### Direct Verification Links\n\n- [Verify Stack Overflow Claim](https://www.google.com/search?q=Rust+most+loved+programming+language+Stack+Overflow+survey)\n- [Verify Rust Memory Safety](https://www.google.com/search?q=Rust+provides+memory+safety+without+garbage+collection+site%3Adoc.rust-lang.org)"
    }
  }]
}
MOCKEOF
      ;;
    A6)
      cat <<'MOCKEOF'
{
  "choices": [{
    "message": {
      "content": "## Link Relevance Report\n\n### Status: PASS\n\n### Confidence: 98%\n\n---\n\n### Document Link Statistics\n\n| **Metric** | **Value** | **In Code Blocks** | **In Prose** | **Notes** |\n|------------|-----------|-------------------|--------------|-----------|\n| Total links | 4 | 1 | 3 | - |\n| External links | 4 | 0 | 4 | All to Rust docs |\n| Internal links | 0 | 0 | 0 | - |\n| Affiliate links | 0 | - | 0 | DISCLOSURE: YES |\n\n---\n\n### Complete Link Assessment Table\n\n| **#** | **Link Text** | **URL** | **In Code Block** | **Descriptiveness** | **Relevance** | **Value** | **Quality Score** | **Status** | **Issues** |\n|-------|--------------|---------|------------------|---------------------|--------------|-----------|------------------|------------|------------|\n| 1 | The Rust Programming Language | https://doc.rust-lang.org/book/ | NO | 5 | 5 | 5 | 5.0 | EXCELLENT | PASS | - |\n| 2 | Rust by Example | https://doc.rust-lang.org/rust-by-example/ | NO | 5 | 5 | 5 | 5.0 | EXCELLENT | PASS | - |\n| 3 | Rustlings | https://github.com/rust-lang/rustlings | NO | 5 | 5 | 5 | 5.0 | EXCELLENT | PASS | - |\n| 4 | Rust Documentation | https://doc.rust-lang.org/ | NO | 5 | 5 | 5 | 5.0 | EXCELLENT | PASS | - |\n| 5 | https://sh.rustup.rs | https://sh.rustup.rs | YES | N/A | N/A | N/A | N/A | EXEMPT | - |\n\n---\n\n### Detailed Link Analysis\n\n**Prose Links:**\n1. **Link Text:** The Rust Programming Language\n   - **URL:** https://doc.rust-lang.org/book/\n   - **Location:** Resources for Learning More, paragraph 1, line 102\n   - **Context:** \"- [The Rust Programming Language](https://doc.rust-lang.org/book/) - The official Rust book\"\n   - **Descriptiveness Score:** 5\n     - **Rationale:** Text perfectly describes the official Rust book\n   - **Contextual Relevance Score:** 5\n     - **Rationale:** Directly relevant to learning Rust\n   - **Reader Value Score:** 5\n     - **Rationale:** Official documentation provides unique value\n   - **Quality Score:** 5.0\n   - **Quality Rating:** EXCELLENT\n   - **Status:** PASS\n\n---\n\n### Link Density Analysis\n\n| **Metric** | **Value** | **Assessment** | **Recommendation** |\n|------------|-----------|----------------|------------------|\n| **Total Links** | 4 | - | - |\n| **Links per 1000 words** | 3.6 | Normal (3-8) | - |\n| **External vs Internal Ratio** | 4:0 | Balanced | - |\n| **Density Assessment** | - | NORMAL | - |\n\n---
\n### Summary\n\n| **Category** | **Count** | **Percentage** | **Quality Distribution** |\n|--------------|-----------|--------------|---------------------------|\n| **Excellent links** | 4 | 100% | Quality score 4.5-5.0 |\n| **Good links** | 0 | 0% | Quality score 3.5-4.4 |\n| **Fair links** | 0 | 0% | Quality score 2.5-3.4 |\n| **Poor links** | 0 | 0% | Quality score 1.0-2.4 |\n| **Verdict** | - | - | PASS (no problematic links) |\n\n---\n\n### Quick Fix Checklist\n\n- [ ] Fix 0 problematic links\n- [ ] Add descriptive text to: None needed\n- [ ] Remove or replace irrelevant links: None\n- [ ] Fix broken links: None\n- [ ] Add affiliate disclosure: Not applicable\n- [ ] Convert HTTP to HTTPS: All use HTTPS\n- [ ] Verify all code block links: [\"curl -I https://sh.rustup.rs\"]"
    }
  }]
}
MOCKEOF
      ;;
    B3)
      cat <<'MOCKEOF'
{
  "choices": [{
    "message": {
      "content": "## Evidence Quality Report\n\n### Status: FAIL\n\n### Confidence: 95%\n\n---\n\n### Document Statistics\n\n| **Metric** | **Total Claims** | **With Evidence** | **Without Evidence** | **Evidence Rate** |\n|------------|------------------|-------------------|----------------------|-------------------|\n| All claims | 15 | 1 | 14 | 7% |\n| Factual claims | 15 | 1 | 14 | 7% |\n| Requiring evidence | 15 | 1 | 14 | 7% |\n\n---\n\n### All Claims Assessment\n\n**Total Claims Analyzed:** 15\n\n| **#** | **Claim (first 100 chars)** | **Location** | **Evidence Level** | **Appropriateness** | **Currency** | **Status** |\n|-------|----------------------------|--------------|-------------------|--------------------|-------------|------------|\n| 1 | Rust provides memory safety without... | Why Learn Rust, p2, l17 | LEVEL 1 | APPROPRIATE | CURRENT | PASS | - |\n| 2 | Rust has consistently been voted... | Introduction, p1, l12 | LEVEL 5 | MISSING | N/A | FAIL | missing |\n\n---\n\n### Flagged Claims (LEVEL 3-5 - Need Attention)\n\n**Total Flagged Claims:** 14\n\n| **#** | **Claim (first 100 chars)** | **Location** | **Current Level** | **Required Level** | **Issue** | **Severity** | **Web Search** |\n|-------|----------------------------|--------------|------------------|---------------------|-----------|--------------|---------------|\n| 1 | Rust has consistently been voted... | Introduction,p1,l12 | LEVEL 5 | LEVEL 2 | MISSING | HIGH | \"Stack Overflow Developer Survey Rust\" |\n| 2 | Rust offers a unique combination... | Why Learn Rust,p1,l16 | LEVEL 5 | LEVEL 2 | MISSING | HIGH | \"Rust performance reliability productivity\" |\n\n**Flagged Claim Details:**\n1. **Claim:** \"Rust has consistently been voted the most loved programming language in the Stack Overflow Developer Survey for several years running\"\n   - **Full Text:** Rust has consistently been voted the most loved programming language in the Stack Overflow Developer Survey for several years running.\n   - **Location:** Introduction, paragraph 1, line 12\n   - **Claim Type:** statistic\n   - **Current Evidence:** NONE\n   - **Current Evidence Level:** LEVEL 5\n   - **Issue:** MISSING EVIDENCE\n   - **Required Evidence Level:** LEVEL 2\n   - **Why This Level:** Statistical claims require reputable sources\n   - **Suggested Source Type:** industry report\n   - **Suggested Specific Source:** Stack Overflow Developer Survey 2023-2025\n   - **Web Search Suggestion:** \"Stack Overflow Developer Survey Rust most loved\"\n   - **Verification URL:** https://survey.stackoverflow.co/2025\n   - **Suggested Fix:** \"Rust has consistently been voted the most loved programming language in the Stack Overflow Developer Survey for several years running. [Source: Stack Overflow Developer Survey 2025]\"\n\n---\n\n### Patterns Detected\n\n| **Pattern** | **Status** | **Count** | **Examples** | **Severity** | **Suggested Action** |\n|-------------|------------|-----------|--------------|--------------|-----------------------|\n| Cherry-picking | NO | 0 | - | - | - |\n| Outdated references | NO | 0 | - | - | - |\n| Over-reliance on single source | NO | 0 | - | - | - |\n| Vendor claims without support | NO | 0 | - | - | - |\n\n---\n\n### Evidence Quality Summary\n\n| **Level** | **Count** | **Percentage** | **Claim Types** | **Action Required** |\n|----------|-----------|--------------|-----------------|-------------------|\n| LEVEL 1 (Strongest) | 1 | 7% | technical | None - excellent |\n| LEVEL 2 (Strong) | 0 | 0% | - | None - good |\n| LEVEL 3 (Acceptable) | 0 | 0% | - | Review for improvement |\n| LEVEL 4 (Weak) | 0 | 0% | - | Replace with stronger sources |\n| LEVEL 5 (None) | 14 | 93% | statistic, technical, historical | **ADD EVIDENCE - CRITICAL** |\n\n---\n\n### Summary\n\n- **Total evidence-based claims:** 15\n- **Level 1 (Strong):** 1 (7%)\n- **Level 2 (Strong):** 0 (0%)\n- **Level 3 (Acceptable):** 0 (0%)\n- **Level 4 (Weak):** 0 (0%)\n- **Level 5 (None):** 14 (93%)\n- **Verdict:** FAIL (claims with LEVEL 4-5 evidence found)\n\n---\n\n### Quick Fix Actions\n\n- [ ] Add evidence for 14 claims with LEVEL 5 (NO EVIDENCE)\n- [ ] Replace 0 claims with LEVEL 4 (WEAK SOURCES) with stronger evidence\n- [ ] Update 0 claims with LEVEL 3 (OUTDATED) sources\n- [ ] Verify all cited claims: [\"Rust memory safety\", ...]\n- [ ] Fix cherry-picking: None detected\n- [ ] Reduce reliance on single source: None detected\n- [ ] Add independent verification for vendor claims: None detected"
    }
  }]
}

---

### Direct Verification Links

- [Verify Claim 1](https://www.google.com/search?q=Rust+most+loved+programming+language+Stack+Overflow+survey)
- [Verify Claim 2](https://www.google.com/search?q=Rust+performance+reliability+productivity)

MOCKEOF
      ;;
    B7)
      cat <<'MOCKEOF'
{
  "choices": [{
    "message": {
      "content": "## Quote Accuracy Report\n\n### Status: PASS\n\n### Confidence: 98%\n\n---\n\n### Quote Inventory Table\n\n| # | **Quote Text (first 80 chars)** | **Location** | **Formatting** | **Attr Level** | **Context** | **Status** |\n|---|--------------------------------|--------------|---------------|----------------|-------------|------------|\n| 1 | \"AI is the future\" | (none in post) | CORRECT | LEVEL 5 | PRESERVED | FAIL |\n\n---\n\n### Detailed Quote Assessment\n\n**Total Quotes Found:** 0\n\nNo direct quotes found in the post.\n\n---\n\n### Issues Summary Table\n\n| **Issue Type** | **Count** | **Severity** | **Example Locations** |\n|---------------|-----------|--------------|----------------------|\n| Formatting problems | 0 | - | - |\n| Missing attributions (LEVEL 5) | 0 | - | - |\n| Incomplete attributions (LEVEL 2-4) | 0 | - | - |\n\n---\n\n### Summary\n\n- **Total quotes found:** 0\n- **Properly formatted and fully attributed (LEVEL 1):** 0\n- **Needs minor improvement (LEVEL 2):** 0\n- **Needs significant improvement (LEVEL 3-4):** 0\n- **Unacceptable/missing attribution (LEVEL 5):** 0\n- **Verdict:** PASS\n\n---\n\n### Quick Fix Checklist\n\n- [ ] Fix style shifts at: None\n- [ ] Replace generic phrases at: None\n- [ ] Remove redundant content at: None\n- [ ] Replace template language at: None\n- [ ] Verify suspicious content: None\n- [ ] Add more original insights and examples: Consider adding"
    }
  }]
}
MOCKEOF
      ;;
    B8)
      cat <<'MOCKEOF'
{
  "choices": [{
    "message": {
      "content": "## Conclusion Quality Report\n\n### Status: FAIL\n\n### Confidence: 95%\n\n---\n\n### Conclusion Identification\n\n| **Property** | **Value** | **Assessment** |\n|-------------|-----------|----------------|\n| **Location** | Final section (no explicit heading) | Needs heading |\n| **Starting at** | Line 108 / Paragraph 12 | - |\n| **Ending at** | Line 111 / Paragraph 12 | - |\n| **Word count** | 35 words | TOO SHORT (ideal: 100-250) |\n| **Percentage of post** | 3% | TOO SHORT (ideal: 10-20%) |\n| **Explicit heading** | NO | Suggested: \"Conclusion\" |\n\n---\n\n### Evaluation Against Criteria\n\n| **Criterion** | **Status** | **Location/Details** | **Issue Severity** |\n|--------------|------------|---------------------|---------------------|\n| Signals conclusion | NO | No explicit heading or transition | HIGH |\n| Synthesizes main points | PARTIAL | Mentions performance/safety but misses key concepts | MEDIUM |\n| No new information | YES | - | - |\n| Provides takeaways | PARTIAL | Ends with generic statement | LOW |\n| Memorable closing | NO | Weak closing without call to action | MEDIUM |\n| Matches introduction | PARTIAL | Intro promises learning, conclusion delivers vague praise | LOW |\n\n---\n\n### Problematic Elements\n\n1. **Issue:** NO EXPLICIT HEADING\n   - **Location:** Beginning of final section, line 108\n   - **Problem Text:** [No heading, jumps directly into conclusion text]\n   - **Specific Problem:** Reader cannot visually identify where the conclusion begins\n   - **Severity:** HIGH\n   - **Suggested Fix:** Add heading \"## Conclusion\" at line 108\n\n2. **Issue:** TOO SHORT\n   - **Location:** Lines 108-111\n   - **Problem Text:** \"Rust offers a compelling combination... in your development arsenal.\"\n   - **Specific Problem:** Only 35 words, fails to properly synthesize the post\n   - **Severity:** HIGH\n   - **Suggested Fix:** Expand to 150-200 words, add synthesis of key points\n\n---
\n### Introduction-Conclusion Alignment\n\n| **Introduction Promise** | **Conclusion Delivery** | **Status** | **Gap Analysis** |\n|-------------------------|------------------------|------------|-----------------|\n| Learn fundamentals of Rust | Rust is a powerful tool | PARTIAL MATCH | Missing: installation, ownership, borrow checker |\n| Why developers are flocking | Compelling combination | PARTIAL MATCH | Missing: specific reasons |\n\n---
\n### Summary\n\n- **Overall assessment:** Weak\n- **Passes all critical criteria:** NO\n- **Number of issues found:** 2 (HIGH: 2, MEDIUM: 0, LOW: 0)\n- **Verdict:** FAIL\n\n---\n\n### Recommendations\n\n1. **Issue:** NO EXPLICIT HEADING at line 108\n   - **Current:** [No heading]\n   - **Suggested:** \"## Conclusion\\n\\n\"\n   - **Rationale:** Provides clear visual separation and reader expectation\n\n2. **Issue:** TOO SHORT at lines 108-111\n   - **Current:** \"Rust offers a compelling combination...\"\n   - **Suggested:** Expand to include synthesis of installation, ownership, borrow checker, and learning curve\n   - **Rationale:** Properly summarizes all main points from the post\n\n---\n\n### Quick Fix Checklist\n\n- [ ] Add explicit \"Conclusion\" heading\n- [ ] Ensure conclusion is 100-250 words (currently 35 words)\n- [ ] Synthesize all main points from the post\n- [ ] Remove any new information or claims\n- [ ] Add clear takeaways or call to action\n- [ ] Strengthen the closing sentence\n- [ ] Ensure alignment with introduction promise"
    }
  }]
}
MOCKEOF
      ;;
    C5)
      cat <<'MOCKEOF'
{
  "choices": [{
    "message": {
      "content": "## Originality Check Report\n\n### Status: PASS\n\n### Confidence: 95%\n\n---\n\n### Style Consistency Analysis\n\n| **Aspect** | **Baseline** | **Consistency** | **Issues Found** | **Issue Locations** |\n|------------|--------------|-----------------|------------------|---------------------|\n| **Voice** | Second person (you, your) | CONSISTENT | - | - |\n| **Tone** | Professional yet approachable | CONSISTENT | - | - |\n| **Vocabulary** | Technical but accessible | CONSISTENT | - | - |\n| **Sentence Structure** | Mixed short and medium (15-25 words) | CONSISTENT | - | - |\n\n**Voice Usage by Section:**\n| **Section** | **First Person** | **Second Person** | **Third Person** | **Notes** |\n|-------------|------------------|-------------------|------------------|-----------|\n| Introduction | 0 | 2 | 0 | Consistent \"you\" perspective |\n| Why Learn Rust | 0 | 3 | 1 | Mostly \"you\", one \"developers\" |\n| Installation | 0 | 4 | 0 | Consistent |\n\n---\n\n### Style Shift Details\n\nNone detected - voice and tone remain consistent throughout\n\n---\n\n### Generic Language Findings\n\n**Total Generic Phrases Found:** 0\n\nNo generic or boilerplate language detected\n\n---\n\n### Redundancy Findings\n\n**Total Redundant Sections Found:** 0\n\nNo redundant content detected\n\n---\n\n### Template Language Findings\n\n**Template Language Detected:** NO\n\n---\n\n### Suspicious External Content\n\n**External Content Flags:** 0\n\nNo suspicious external content detected\n\n---\n\n### Unique Value Assessment\n\n| **Value Type** | **Rating** | **Examples from Post** | **Count** |\n|---------------|------------|------------------------|-----------|\n| **Original Insights** | HIGH | [\"Rust's ownership system enables...\", \"The borrow checker catches bugs...\"] | 5+ |\n| **Original Analysis** | HIGH | [\"Rust offers unique combination...\"] | 3+ |\n| **Added Perspective** | HIGH | [\"While steep, the learning curve...\", \"The Rust community is welcoming...\"] | 4+ |\n| **Personal Experience** | MEDIUM | [Implicit in guidance] | 2 |\n| **Unique Examples** | HIGH | [Hello World, Guessing Game, Installation steps] | 3+ |\n| **Actionable Advice** | HIGH | [\"Get started with rustup\", \"Try the examples\", \"Build the guessing game\"] | 3+ |\n\n**Unique Content Examples:**\n1. **Type:** UNIQUE EXAMPLE\n   - **Text:** \"cargo new guessing_game\"\n   - **Location:** Building a Guessing Game, paragraph 2, line 73\n   - **Why Unique:** Original step-by-step guide with specific commands\n\n---
\n### Originality Scoring\n\n| **Factor** | **Score** | **Weight** | **Weighted Score** |\n|------------|----------|------------|---------------------|\n| Style Consistency | 100 | 40% | 40.0 |\n| Unique Value | 95 | 40% | 38.0 |\n| External Content Flags | 100 | 20% | 20.0 |\n| **Total** | - | **100%** | **98/100** |\n\n---\n\n### Summary\n\n- **Style Consistency:** CONSISTENT\n- **Unique Value:** HIGH\n- **External Content Concerns:** NONE\n- **Estimated Originality:** 95%\n- **Verdict:** PASS\n\n---\n\n### Recommendations\n\n1. Consider adding more personal anecdotes or experiences to increase originality\n2. Add unique insights from your own Rust journey\n3. Include more original examples beyond the standard ones\n\n---\n\n### Quick Action Items\n\n- [ ] Add personal experience story\n- [ ] Include more original examples\n- [ ] Add unique perspective on learning Rust"
    }
  }]
}
MOCKEOF
      ;;
    C6)
      cat <<'MOCKEOF'
{
  "choices": [{
    "message": {
      "content": "## Argument Balance Report\n\n### Status: FAIL\n\n### Confidence: 90%\n\n---\n\n### Main Argument Analysis\n\n| **Property** | **Value** | **Assessment** |\n|-------------|-----------|----------------|\n| **Primary Thesis** | \"Rust is ideal for systems programming, web assembly, and many other domains\" | Unqualified claim |\n| **Thesis Location** | Conclusion, paragraph 1, line 109 | Stated explicitly |\n| **Explicit or Implied** | EXPLICIT | YES | \"Rust offers a compelling combination...\" |\n| **Topic** | Programming language recommendation | - |\n| **Controversy Level** | HIGH | Language preferences are subjective |\n\n---\n\n### Viewpoints Presentation Table\n\n| **#** | **Viewpoint** | **Position** | **Space Given** | **Presentation** | **Evidence** | **Counterargs Addressed** | **Status** |\n|-------|---------------|--------------|----------------|------------------|--------------|--------------------------------|------------|\n| 1 | PRIMARY | Rust is superior | 35 words (100%) | FAIR | UNCITED | NO | FLAGGED |\n| 2 | MISSING | C/C++ perspective | 0% | - | - | - | FLAGGED |\n| 3 | MISSING | Go language perspective | 0% | - | - | - | FLAGGED |\n\n**Viewpoint Details:**\n1. **Viewpoint:** PRIMARY\n   - **Position:** Rust provides unique combination of performance, reliability, and productivity\n   - **Representative Text:** \"Rust offers a compelling combination of performance and safety that makes it ideal for systems programming\"\n   - **Location:** Conclusion, paragraph 1, line 109\n   - **Space Allocated:** 35 words, 100% of conclusion\n   - **Presentation Style:** FAIR\n   - **Supporting Evidence:** UNCITED\n   - **Counterarguments Raised:** NO\n   - **Counterarguments Addressed:** NO\n\n---\n\n### Missing Perspectives Analysis\n\n**Missing Legitimate Viewpoints:** 3 found\n\n| **#** | **Missing Perspective** | **Description** | **Why It Matters** | **Web Search Suggestion** | **Severity** |\n|-------|------------------------|-----------------|-------------------|----------------------------|--------------|\n| 1 | C/C++ for systems programming | Fine-grained control, mature ecosystem | Readers need comparison | \"C++ vs Rust systems programming\" | HIGH |\n| 2 | Go language simplicity | Simpler concurrency, faster compiles | Alternative for simplicity seekers | \"Go vs Rust systems programming\" | HIGH |\n| 3 | Learning curve critique | Rust complexity as barrier | Honest discussion builds credibility | \"Rust learning curve criticism\" | MEDIUM |\n\n---
\n### Bias Indicators Found\n\n| **Category** | **Count** | **Severity** | **Example Locations** | **Examples from Post** |\n|--------------|-----------|--------------|----------------------|-------------------------|\n| Superlatives | 3 | HIGH | Conclusion:p1:l109, Intro:p1:l12, Why Rust:p1:l16 | \"ideal\", \"most loved\", \"unique combination\" |\n| Positive Bias | 5 | MEDIUM | Throughout post | \"special\", \"powerful\", \"compelling\" |\n\n**Bias Word Details:**\n1. **Word:** \"most loved\"\n   - **Category:** SUPERLATIVE\n   - **Location:** Introduction, paragraph 1, line 12\n   - **Context:** \"Rust has consistently been voted the most loved programming language\"\n   - **Suggested Replacement:** \"highly ranked\" or \"frequently voted among the most loved\"\n   - **Severity:** HIGH\n\n---\n\n### Logical Fallacies Detected\n\n**Total Fallacies Found:** 1\n\n| **#** | **Fallacy Type** | **Example Text** | **Location** | **Problem** | **Severity** | **Suggested Fix** |\n|-------|------------------|-----------------|--------------|-------------|--------------|-------------------|\n| 1 | FALSE DICHOTOMY | \"Rust offers a unique combination...\" | Conclusion, p1, l109 | Implies only Rust offers this | MEDIUM | Qualify with \"among the best\" |\n\n---
\n### Facts vs. Opinions Assessment\n\n**Facts Clearly Separated:** PARTIAL\n\n| **#** | **Type** | **Text** | **Location** | **Issue** | **Suggested Fix** |\n|-------|----------|---------|--------------|-----------|-------------------|\n| 1 | OPINION PRESENTED AS FACT | \"Rust offers a compelling combination...\" | Conclusion, p1, l109 | Subjective assessment | Add \"In my experience,\" |\n\n---\n\n### Bias and Conflict of Interest Disclosure\n\n**Bias Disclosure Present:** NO\n\n**Potential Biases to Disclose:**\n- Financial interests: None apparent\n- Personal connections: Author may be Rust enthusiast\n- **Suggested Disclosure Text:** \"Note: I am a Rust enthusiast and have been using Rust for [X] years. My perspective may be biased toward Rust's strengths.\"\n\n---
\n### Language Assessment\n\n| **Aspect** | **Rating** | **Details** |\n|------------|------------|-------------|\n| **Neutral tone** | PARTIAL | Positive bias toward Rust |\n| **Facts vs. opinions separation** | PARTIAL | Subjective claims not qualified |\n| **Bias disclosure** | MISSING | No author bias disclosed |\n\n---
\n### Fairness Test\n\n**Test Question:** Would someone with the opposite view (e.g., a C++ advocate) feel this post is fair?\n\n**Answer:** NO\n\n**Evidence:**\n- Supporting: Clear explanation of Rust's features\n- Detracting: No mention of alternatives, uses superlatives, presents opinions as facts\n\n---
\n### Summary\n\n| **Metric** | **Value** |\n|------------|-----------|\n| **Viewpoints Covered** | 1 of 4 legitimate viewpoints |\n| **Balance Score** | 30/100 |\n| **Bias Indicators** | 8 found (HIGH: 3, MEDIUM: 5) |\n| **Logical Fallacies** | 1 found (MEDIUM: 1) |\n| **Facts/Opinions Separation** | PARTIAL |\n| **Bias Disclosure** | FAIL |\n| **Verdict** | FAIL |\n\n---\n\n### Recommendations\n\n1. **Issue:** MISSING PERSPECTIVES at Conclusion\n   - **Problem:** Post presents Rust as ideal without acknowledging C++, Go, or other alternatives\n   - **Suggested Fix:** Add section comparing Rust to C++ (control, maturity) and Go (simplicity, fast compiles)\n   - **Verification:** Search \"Rust vs C++ vs Go comparison\"\n\n2. **Issue:** BIAS INDICATORS throughout post\n   - **Location:** Multiple locations\n   - **Problem:** Uses superlatives and positive bias without qualification\n   - **Suggested Fix:** Qualify claims: \"Rust is AMONG the most loved\" instead of \"THE most loved\"\n\n3. **Issue:** FACT/OPINION CONFUSION at Conclusion, paragraph 1, line 109\n   - **Problem:** Subjective claims presented as facts\n   - **Suggested Fix:** Add: \"In my experience, Rust offers...\"\n\n4. **Issue:** MISSING DISCLOSURE\n   - **Problem:** No author bias or perspective disclosed\n   - **Suggested Fix:** Add disclosure at beginning\n\n---\n\n### Quick Fix Checklist\n\n- [ ] Acknowledge missing viewpoints: C/C++, Go, learning curve\n- [ ] Replace biased language: \"most loved\" -> \"highly ranked\"\n- [ ] Fix logical fallacy: Qualify superlative claims\n- [ ] Separate facts from opinions: Add \"In my experience\"\n- [ ] Add bias disclosure statement at introduction\n- [ ] Research and include: \"Rust vs C++ comparison\", \"Rust vs Go comparison\""
    }
  }]
}
MOCKEOF
      ;;
    C7)
      cat <<'MOCKEOF'
{
  "choices": [{
    "message": {
      "content": "## Writing Quality Report\n\n### Status: PASS\n\n### Confidence: 95%\n\n### Overall Score: 92/100\n\n---\n\n### Document Statistics\n\n| **Metric** | **Value** | **Target** | **Status** | **Notes** |\n|------------|-----------|------------|------------|-----------|\n| Total words | 1111 | - | - | - |\n| Total sentences | 55 | - | - | - |\n| Total paragraphs | 14 | - | - | - |\n| Total sections | 8 | - | - | - |\n| Avg words per section | 139 | 300-600 | PASS | Slightly short but acceptable |\n\n---\n\n### Readability Analysis\n\n| **Metric** | **Value** | **Target** | **Status** | **Flagged Items** | **Flagged Locations** |\n|------------|-----------|------------|------------|------------------|-----------------------|\n| Avg sentence length | 20 words | 15-25 words | PASS | 0 sentences | - |\n| Long sentences (>35 words) | 0 | < 5% | PASS | 0 sentences | - |\n| Avg paragraph length | 80 words | 75-150 words | PASS | 0 paragraphs | - |\n| Long paragraphs (>200 words) | 0 | 0 | PASS | 0 paragraphs | - |\n| Estimated reading level | Grade 8 | 8-12 | PASS | - | - |\n\n---\n\n### Style Consistency Analysis\n\n| **Aspect** | **Value** | **Target** | **Status** | **Issues Found** | **Issue Locations** |\n|------------|-----------|------------|------------|------------------|--------------------|\n| **Voice: Active** | 98% | > 90% | PASS | 1 passive sentence | Common Challenges:p1:s1 |\n| **Voice: Passive** | 2% | < 10% | PASS | - | - |\n| **Terminology** | CONSISTENT | CONSISTENT | PASS | 0 instances | - |\n| **Headings** | CONSISTENT | Title Case | PASS | 0 issues | - |\n| **Numbers** | CONSISTENT | Spell 0-9 | PASS | 0 issues | - |\n| **Punctuation** | CORRECT | Correct | PASS | 0 issues | - |\n\n**Passive Voice Instances:**\n1. **Sentence:** \"Don't be discouraged if you struggle with these concepts at first\"\n   - **Location:** Common Challenges, paragraph 1, sentence 1\n   - **Suggested Active Rewrite:** \"These concepts may challenge you at first, but don't be discouraged\"\n\n---\n\n### Tone Assessment\n\n| **Aspect** | **Rating** | **Details** | **Example Locations** |\n|------------|------------|-------------|----------------------|\n| **Consistency** | CONSISTENT | Professional and approachable throughout | - |\n| **Appropriateness** | APPROPRIATE | Suitable for technical beginners | - |\n| **Professionalism** | HIGH | No casual or unprofessional language | - |\n| **Engagement** | HIGH | Active voice, clear examples | - |\n\n---\n\n### Flow Assessment\n\n| **Aspect** | **Rating** | **Details** | **Problem Locations** |\n|------------|------------|-------------|----------------------|\n| **Paragraph Structure** | GOOD | Most paragraphs have clear topic sentences | Common Challenges:p1 |\n| **Transitions** | SMOOTH | Logical flow between sections | - |\n| **Logical Progression** | CLEAR | Each section builds on previous | - |\n\n**Paragraph Structure Issues:**\n1. **Paragraph:** \"While Rust is powerful, it does have a steep learning curve...\"\n   - **Location:** Common Challenges, paragraph 1\n   - **Issue:** NO CLEAR TOPIC SENTENCE - starts with contrast\n   - **Suggested Fix:** Move \"While Rust is powerful...\" after topic sentence about challenges\n\n---\n\n### Error Analysis\n\n| **Error Type** | **Count** | **Target** | **Status** | **Severity** |\n|---------------|-----------|------------|------------|--------------|\n| **Spelling** | 0 | 0 | PASS | - |\n| **Grammar** | 0 | 0 | PASS | - |\n| **Punctuation** | 0 | 0 | PASS | - |\n\n---\n\n### Category Scores\n\n| **Category** | **Score** | **Weight** | **Weighted Score** | **Issues** |\n|--------------|----------|------------|---------------------|-----------|\n| **Readability** | 100 | 25% | 25.0 | None |\n| **Style Consistency** | 95 | 25% | 23.8 | 1 passive sentence |\n| **Tone** | 100 | 20% | 20.0 | None |\n| **Flow** | 95 | 20% | 19.0 | 1 paragraph structure issue |\n| **Technical Accuracy** | 100 | 10% | 10.0 | None |\n| **Overall** | **98** | **100%** | **97.8/100** | - |\n\n---\n\n### Suggestions\n\n1. **Location:** Common Challenges, paragraph 1, sentence 1\n   - **Issue:** Passive voice usage\n   - **Current:** \"Don't be discouraged if you struggle with these concepts at first\"\n   - **Suggested:** \"These concepts may challenge you at first, but don't be discouraged\"\n   - **Rationale:** Active voice improves clarity and engagement\n   - **Severity:** LOW\n\n2. **Location:** Common Challenges, paragraph 1\n   - **Issue:** No clear topic sentence\n   - **Current:** \"While Rust is powerful, it does have a steep learning curve...\"\n   - **Suggested:** \"Common challenges include understanding ownership. While Rust is powerful...\"\n   - **Rationale:** Clear topic sentence improves paragraph structure and readability\n   - **Severity:** LOW\n\n---\n\n### Quick Fix Summary\n\n- [ ] Fix 0 long sentences (>35 words): None found\n- [ ] Split 0 long paragraphs (>200 words): None found\n- [x] Convert 1 passive sentence to active at: Common Challenges:p1:s1\n- [ ] Fix 0 terminology inconsistencies: None found\n- [ ] Fix 0 capitalization issues: None found\n- [ ] Fix 0 number formatting issues: None found\n- [ ] Fix 0 punctuation errors: None found\n- [ ] Fix 0 spelling errors: None found\n- [ ] Fix 0 grammar errors: None found\n- [ ] Fix 0 tone issues: None found\n- [x] Fix 1 flow issue at: Common Challenges:p1"
    }
  }]
}
MOCKEOF
      ;;
    *)
      # Generic mock response for unknown checks
      cat <<MOCKEOF
{
  "choices": [{
    "message": {
      "content": "## ${check_id} Report\n\n**Status:** PASS\n\n**Confidence:** 90%\n\nVerdict: PASS"
    }
  }]
}
MOCKEOF
      ;;
  esac
}

# Parse arguments manually to handle both short and long options
MODEL="$DEFAULT_MODEL"
API_KEY_FILE=".mistral"
CHECK_FILTER=""

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Process arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -m | --model)
        MODEL="$2"
        shift 2
        ;;
      -k | --key-file)
        API_KEY_FILE="$2"
        shift 2
        ;;
      -c | --check)
        CHECK_FILTER="$2"
        shift 2
        ;;
      -n | --no-cache)
        AI_CACHE_ENABLED=false
        shift
        ;;
      -r | --no-reports)
        WRITE_REPORTS=false
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "Invalid option: $1" >&2
        usage
        exit 1
        ;;
      *)
        # First non-option argument is the post file
        break
        ;;
    esac
  done

  # Check post file argument
  if [[ $# -ne 1 ]]; then
    echo "Error: Missing post file argument" >&2
    usage
    exit 1
  fi

  POST_FILE="$1"

  # Validate post file exists
  if [[ ! -f "$POST_FILE" ]]; then
    echo "Error: Post file '$POST_FILE' not found" >&2
    exit 1
  fi

  # Load API key from file (not needed in mock mode)
  if [[ "$MISTRAL_MOCK" != "1" ]]; then
    if [[ ! -f "$API_KEY_FILE" ]]; then
      echo "Error: API key file '$API_KEY_FILE' not found" >&2
      echo "Create it from .mistral.sample" >&2
      exit 1
    fi

    # Export API key for use in functions
    # shellcheck disable=SC1090
    source "$API_KEY_FILE"

    if [[ -z "${MISTRAL_API_KEY:-}" ]]; then
      echo "Error: MISTRAL_API_KEY not found in $API_KEY_FILE" >&2
      exit 1
    fi
  fi
fi

# Counters for results
declare -i total_checks=0
declare -i pass_count=0
declare -i fail_count=0
declare -i partial_count=0
declare -i not_applicable_count=0
declare -i needs_review_count=0
declare -i unknown_count=0

# Function to extract prompt content from markdown file
# Args:
#   $1: Path to prompt markdown file
# Returns:
#   Prompt text via stdout
extract_prompt() {
  local prompt_file="$1"
  local in_prompt=false
  local line

  while IFS= read -r line; do
    # Detect start of code block (contains text marker)
    if echo "$line" | grep -q '^```text$'; then
      in_prompt=true
      continue
    fi
    # Detect end of code block
    if echo "$line" | grep -q '^```$' && [[ "$in_prompt" == true ]]; then
      break
    fi
    if [[ "$in_prompt" == true ]]; then
      echo "$line"
    fi
  done <"$prompt_file"
}

# Function to build a deterministic mock response payload.
# Args:
#   $1: Check ID
# Returns:
#   Valid JSON payload with markdown report content
build_mock_response() {
  local check_id="$1"
  local report_body=""

  case "$check_id" in
    A2)
      report_body="## Source Verification Report\n\n### Status: PASS\n\n### Confidence: 98%\n\n---\n\n### Summary\n\n- Verdict: PASS"
      ;;
    A6)
      report_body="## Link Relevance Report\n\n### Status: NOT_APPLICABLE\n\n### Confidence: 98%\n\n---\n\n### Summary\n\n- Verdict: NOT_APPLICABLE"
      ;;
    B3)
      report_body="## Evidence Quality Report\n\n### Status: PASS\n\n### Confidence: 96%\n\n---\n\n### Summary\n\n- Verdict: PASS"
      ;;
    B7)
      report_body="## Quote Accuracy Report\n\n### Status: INCONCLUSIVE\n\n### Confidence: 99%\n\n---\n\n### Summary\n\n- Verdict: INCONCLUSIVE"
      ;;
    B8)
      report_body="## Conclusion Quality Report\n\n### Status: FAIL\n\n### Confidence: 95%\n\n---\n\n### Summary\n\n- Verdict: FAIL"
      ;;
    C5)
      report_body="## Originality Check Report\n\n### Status: PARTIAL\n\n### Confidence: 97%\n\n---\n\n### Summary\n\n- Verdict: PARTIAL"
      ;;
    C6)
      report_body="## Argument Balance Report\n\n### Status: NEEDS REVIEW\n\n### Confidence: 94%\n\n---\n\n### Summary\n\n- Verdict: NEEDS REVIEW"
      ;;
    C7)
      report_body="## Writing Quality Report\n\n### Status: PASS\n\n### Confidence: 96%\n\n---\n\n### Summary\n\n- Verdict: PASS"
      ;;
    *)
      report_body="## ${check_id} Report\n\n### Status: PASS\n\n### Confidence: 90%\n\n---\n\n### Summary\n\n- Verdict: PASS"
      ;;
  esac

  # Decode escaped newline sequences to produce proper markdown content.
  report_body=$(printf '%b' "$report_body")

  jq -n --arg body "$report_body" '{choices: [{message: {content: $body}}]}'
}

# Function to call Mistral API or return mock response
# Args:
#   $1: The full prompt to send
#   $2: Check ID for mock response generation
# Returns:
#   API response JSON via stdout
call_mistral() {
  local full_prompt="$1"
  local check_id="$2"

  if [[ "$MISTRAL_MOCK" == "1" ]]; then
    build_mock_response "$check_id"
    return
  fi

  # Real API call with timeout
  # Use jq to build JSON payload to avoid escaping issues
  # Parameters:
  #   - temperature: 0.3 (low randomness for consistent results)
  #   - max_tokens: 12000 (enough for detailed quality reports on articles up to 2500 words)
  #   - top_p: 0.9 (nucleus sampling for focused output)
  #   - response_format: text (ensure plain text output)
  #   - tool_choice: auto (enable automatic tool use)
  local json_payload
  json_payload=$(jq -n --arg model "$MODEL" --arg content "$full_prompt" \
    '{model: $model, messages: [{role: "user", content: $content}], temperature: 0.3, max_tokens: 12000, top_p: 0.9, response_format: {type: "text"}, tool_choice: "auto"}')

  curl -s --max-time 180 "$ENDPOINT" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $MISTRAL_API_KEY" \
    -d "$json_payload"
}

# Function to run a single manual check
# Args:
#   $1: Check ID (e.g., A2, C6)
#   $2: Path to prompt file
#   $3: Post content
# Returns:
#   Check result via stdout
run_single_check() {
  local check_id="$1"
  local prompt_file="$2"
  local post_content="$3"
  local gate_name
  local response
  local api_error_message
  local max_attempts=3
  local attempt=1

  gate_name=$(basename "$prompt_file")

  # Extract prompt
  local prompt
  prompt=$(extract_prompt "$prompt_file")

  if [[ -z "$prompt" ]]; then
    echo "Warning: Could not extract prompt from $gate_name" >&2
    return 1
  fi

  # Replace placeholder with post content
  local full_prompt
  full_prompt=$(echo "$prompt" | awk -v content="$post_content" '
    BEGIN { gsub(/\\n/, "\\\\n", content) }
    { gsub(/<INSERT BLOG POST CONTENT HERE>/, content) }
    { print }
  ')

  if [[ -z "$full_prompt" ]]; then
    echo "Warning: Prompt generation failed for $check_id" >&2
    return 1
  fi

  # Call Mistral (real or mock) with retries for transient API issues.
  while [[ "$attempt" -le "$max_attempts" ]]; do
    if ! response=$(call_mistral "$full_prompt" "$check_id" 2>/dev/null); then
      response=""
    fi

    if [[ -z "$response" ]]; then
      api_error_message="Empty response from API"
    elif ! echo "$response" | jq -e '.' >/dev/null 2>&1; then
      api_error_message="Invalid JSON response from API"
    elif echo "$response" | jq -e '.error' >/dev/null 2>&1; then
      api_error_message=$(echo "$response" | jq -r '.error.message // .error // "Unknown API error"')
      if [[ "$api_error_message" =~ [Rr]ate[[:space:]-]?[Ll]imit|429|5[0-9]{2}|[Tt]imeout|[Tt]emporar|[Uu]navailable|[Oo]verload ]]; then
        :
      else
        echo "Error: $api_error_message" >&2
        return 1
      fi
    elif ! echo "$response" | jq -e '.choices[0].message.content and (.choices[0].message.content | type == "string") and (.choices[0].message.content | length > 0)' >/dev/null 2>&1; then
      api_error_message="Invalid response structure from API"
    else
      echo "$response" | jq -r '.choices[0].message.content'
      return 0
    fi

    attempt=$((attempt + 1))
  done

  echo "Error: $api_error_message" >&2
  return 1
}

# Function to validate check name
# Args:
#   $1: Check name to validate
# Returns:
#   0 if valid, 1 if invalid
validate_check() {
  local check="$1"
  if [[ -n "${AVAILABLE_CHECKS[$check]:-}" ]]; then
    return 0
  else
    return 1
  fi
}

# Function to extract normalized status from a check report.
# Args:
#   $1: Check report content
# Returns:
#   PASS | FAIL | PARTIAL | NOT_APPLICABLE | NEEDS_REVIEW | UNKNOWN
extract_report_status() {
  local report_content="$1"
  local status_line
  local status_value

  status_line=$(printf '%s\n' "$report_content" | grep -im1 -E '^### Status:|^\*\*Status:\*\*') || true
  if [[ -z "$status_line" ]]; then
    echo "UNKNOWN"
    return
  fi

  status_value=$(printf '%s\n' "$status_line" | sed -E 's/^### Status:[[:space:]]*//I; s/^\*\*Status:\*\*[[:space:]]*//I' | tr '[:lower:]' '[:upper:]')
  status_value=$(echo "$status_value" | sed -E 's/[[:space:]]+/_/g; s/_+$//')

  case "$status_value" in
    PASS | FAIL | PARTIAL | NOT_APPLICABLE | NEEDS_REVIEW)
      echo "$status_value"
      ;;
    *)
      echo "UNKNOWN"
      ;;
  esac
}

# Function to normalize a status-like token.
# Args:
#   $1: Raw status text
# Returns:
#   Uppercase normalized token (spaces -> underscores)
normalize_status_token() {
  local raw_value="$1"
  raw_value=$(printf '%s' "$raw_value" | tr '[:lower:]' '[:upper:]')
  raw_value=$(printf '%s' "$raw_value" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/[[:space:]]+/_/g')
  raw_value=$(printf '%s' "$raw_value" | sed -E 's/[^A-Z_].*$//')
  raw_value=$(printf '%s' "$raw_value" | sed -E 's/_+$//')
  echo "$raw_value"
}

# Function to extract normalized verdict status from a check report.
# Args:
#   $1: Check report content
# Returns:
#   PASS | FAIL | PARTIAL | NOT_APPLICABLE | NEEDS_REVIEW | UNKNOWN | MISSING
extract_report_verdict_status() {
  local report_content="$1"
  local verdict_line
  local verdict_value

  verdict_line=$(printf '%s\n' "$report_content" | grep -im1 -E '^[[:space:]]*-[[:space:]]*(\*\*)?[Vv]erdict(\*\*)?:|^[[:space:]]*(\*\*)?[Vv]erdict(\*\*)?:|^\|[[:space:]]*\*\*Verdict\*\*[[:space:]]*\|') || true
  if [[ -z "$verdict_line" ]]; then
    echo "MISSING"
    return
  fi

  if [[ "$verdict_line" == \|* ]]; then
    verdict_value=$(printf '%s\n' "$verdict_line" | awk -F'|' '
      {
        for (i = 1; i <= NF; i++) {
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)
          if ($i ~ /\*\*Verdict\*\*/) {
            if ((i + 1) <= NF) {
              gsub(/^[[:space:]]+|[[:space:]]+$/, "", $(i + 1))
              print $(i + 1)
              exit
            }
          }
        }
      }
    ')
  else
    verdict_value=$(printf '%s\n' "$verdict_line" | sed 's/\*//g' | sed -E 's/^.*[Vv]erdict:[[:space:]]*//')
  fi

  verdict_value=$(normalize_status_token "$verdict_value")
  if [[ -z "$verdict_value" ]]; then
    echo "UNKNOWN"
    return
  fi

  case "$verdict_value" in
    PASS | FAIL | PARTIAL | NOT_APPLICABLE | NEEDS_REVIEW)
      echo "$verdict_value"
      ;;
    *)
      echo "UNKNOWN"
      ;;
  esac
}

# Function to validate generated report schema and structural constraints.
# Args:
#   $1: Check ID
#   $2: Check report content
# Returns:
#   0 when schema is valid, 1 otherwise
validate_report_schema() {
  local check_id="$1"
  local report_content="$2"
  local status_line_count=0
  local top_status
  local verdict_status
  local issues=()

  status_line_count=$(printf '%s\n' "$report_content" | grep -Eic '^### Status:|^\*\*Status:\*\*') || true
  if [[ "$status_line_count" -ne 1 ]]; then
    issues+=("expected exactly one status line")
  fi

  if printf '%s\n' "$report_content" | awk 'prev=="---" && $0=="---" {found=1} {prev=$0} END {exit found ? 0 : 1}'; then
    issues+=("contains consecutive section separators")
  fi

  top_status=$(extract_report_status "$report_content")
  verdict_status=$(extract_report_verdict_status "$report_content")
  if [[ "$verdict_status" == "MISSING" ]]; then
    issues+=("missing verdict")
  elif [[ "$verdict_status" != "$top_status" ]]; then
    issues+=("status/verdict mismatch (${top_status} vs ${verdict_status})")
  fi

  case "$check_id" in
    A6)
      local report_header_count=0
      report_header_count=$(printf '%s\n' "$report_content" | grep -Ec '^## Link Relevance Report') || true
      if [[ "$report_header_count" -ne 1 ]]; then
        issues+=("A6 must contain exactly one report header")
      fi
      if printf '%s\n' "$report_content" | grep -Eiq 'corrected below|initial table had an error|canonical inventory is corrected|\brevised\b'; then
        issues+=("A6 contains forbidden correction narrative")
      fi
      ;;
    C5)
      if printf '%s\n' "$report_content" | grep -qi 'Not present'; then
        issues+=("C5 contains forbidden placeholder row text")
      fi
      ;;
  esac

  if [[ ${#issues[@]} -gt 0 ]]; then
    echo "Schema validation failed for $check_id: ${issues[*]}" >&2
    return 1
  fi

  return 0
}

# Function to normalize generated report markdown for robust schema checks.
# Args:
#   $1: Raw report content
# Returns:
#   Normalized report content via stdout
sanitize_report_content() {
  local report_content="$1"

  # Remove a leading separator only when it is the first non-empty content line,
  # and collapse repeated section separators (---) that can appear in model output.
  printf '%s\n' "$report_content" | awk '
    {
      line = $0
      trimmed = line
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", trimmed)

      # Drop the first non-empty content line only when it is a separator.
      if (trimmed != "" && first_content_seen == 0) {
        first_content_seen = 1
        if (trimmed == "---") {
          next
        }
      }

      if (trimmed == "---" && prev_sep == 1) {
        next
      }

      print line
      if (trimmed == "---") {
        prev_sep = 1
      } else if (trimmed != "") {
        prev_sep = 0
      }
    }
  '
}

# Function to update summary counters from a normalized status.
# Args:
#   $1: PASS | FAIL | PARTIAL | NOT_APPLICABLE | NEEDS_REVIEW | UNKNOWN
update_summary_counters() {
  local status="$1"
  case "$status" in
    PASS)
      pass_count=$((pass_count + 1))
      ;;
    FAIL)
      fail_count=$((fail_count + 1))
      ;;
    PARTIAL)
      partial_count=$((partial_count + 1))
      ;;
    NOT_APPLICABLE)
      not_applicable_count=$((not_applicable_count + 1))
      ;;
    NEEDS_REVIEW)
      needs_review_count=$((needs_review_count + 1))
      ;;
    *)
      unknown_count=$((unknown_count + 1))
      ;;
  esac
}

# Function to get article name from post file path
# Args:
#   $1: Path to post file
# Returns:
#   Article name (basename without extension)
get_article_name() {
  local post_file="$1"
  local basename
  basename=$(basename "$post_file")
  local article_name
  article_name="${basename%.md}"
  echo "$article_name"
}

# Function to run all checks (filtered if CHECK_FILTER is set)
# Args:
#   $1: Post content
run_all_checks() {
  local post_content="$1"
  local article_name
  article_name=$(get_article_name "$POST_FILE")
  local article_identity
  article_identity=$(cd "$(dirname "$POST_FILE")" && pwd)/"$(basename "$POST_FILE")"
  local report_dir="$REPORTS_DIR/$article_name"
  local post_content_hash
  post_content_hash=$(printf '%s' "$post_content" | sha256sum 2>/dev/null | awk '{print $1}') || true

  # Create report directory if writing reports is enabled
  if [[ "$WRITE_REPORTS" == "true" ]]; then
    mkdir -p "$report_dir"
  fi

  # Use a temp file to capture all output for caching
  local temp_output_file
  temp_output_file=$(mktemp /tmp/ai_checks_output_XXXXXX) || true
  # Initialize the temp file
  : >"$temp_output_file"

  # Build list of checks to run
  local checks_to_run=()

  if [[ -z "$CHECK_FILTER" ]]; then
    # Run all checks
    for check_id in "${CHECK_ORDER[@]}"; do
      checks_to_run+=("$check_id")
    done
  else
    # Parse comma-separated list
    IFS=',' read -ra check_list <<<"$CHECK_FILTER"
    for check_id in "${check_list[@]}"; do
      check_id=$(echo "$check_id" | tr -d '[:space:]')
      if validate_check "$check_id"; then
        checks_to_run+=("$check_id")
      else
        echo "Warning: Unknown check '$check_id', skipping" >&2
      fi
    done

    if [[ ${#checks_to_run[@]} -eq 0 ]]; then
      echo "Error: No valid checks specified in '$CHECK_FILTER'" >&2
      echo "Available checks: ${!AVAILABLE_CHECKS[*]}" >&2
      exit 1
    fi
  fi

  # Helper function to output to both stdout and temp file
  output_to_both() {
    echo "$1"
    echo "$1" >>"$temp_output_file"
  }

  output_to_both "Running AI-assisted manual quality checks"
  output_to_both "Model: $MODEL"
  output_to_both "Post: $POST_FILE"
  output_to_both "Reports: $report_dir/"
  if [[ "$MISTRAL_MOCK" == "1" ]]; then
    output_to_both "Mode: MOCK (no API calls)"
  fi
  if [[ -n "$CHECK_FILTER" ]]; then
    output_to_both "Checks: ${checks_to_run[*]}"
  else
    output_to_both "Checks: ALL (${#checks_to_run[@]})"
  fi
  output_to_both "----------------------------------------"

  for check_id in "${checks_to_run[@]}"; do
    local prompt_file="${AVAILABLE_CHECKS[$check_id]}"

    if [[ -f "$prompt_file" ]]; then
      total_checks=$((total_checks + 1))

      output_to_both ""
      output_to_both "=== $check_id - $(basename "$prompt_file" .md) ==="

      # Check if this specific check is cached
      local check_cache_key=""
      local check_cached_output=""
      local cache_hit=false

      if [[ "$AI_CACHE_ENABLED" == "true" ]]; then
        local prompt_hash
        local sanitized_cached_output
        prompt_hash=$(sha256sum "$prompt_file" 2>/dev/null | awk '{print $1}') || true
        check_cache_key=$(compute_ai_check_cache_key "$article_identity" "$MODEL" "$check_id" "$MISTRAL_MOCK" "$post_content_hash" "$prompt_hash")
        if check_cached_output=$(cache_get_ai_by_key "$check_cache_key" 2>/dev/null); then
          sanitized_cached_output=$(sanitize_report_content "$check_cached_output")
          if validate_report_schema "$check_id" "$sanitized_cached_output"; then
            cache_hit=true
            output_to_both "$sanitized_cached_output"
            local cached_status
            cached_status=$(extract_report_status "$sanitized_cached_output")
            update_summary_counters "$cached_status"
            # Save cached result to report file if writing reports is enabled
            if [[ "$WRITE_REPORTS" == "true" ]]; then
              local report_file="$report_dir/${check_id}.md"
              echo "$sanitized_cached_output" >"$report_file"
              output_to_both "Saved report: $report_file"
            fi
            if [[ "$sanitized_cached_output" != "$check_cached_output" ]]; then
              cache_set_ai_by_key "$check_cache_key" "$sanitized_cached_output"
            fi
            output_to_both "[CACHE] Using cached result for $check_id"
          else
            output_to_both "[SCHEMA] Cached result invalid for $check_id; regenerating"
          fi
        fi
      fi

      # Only run the check if it wasn't cached
      if [[ "$cache_hit" == "false" ]]; then
        local result
        local sanitized_result
        local error_file
        error_file=$(mktemp /tmp/ai_check_error_XXXXXX)
        if result=$(run_single_check "$check_id" "$prompt_file" "$post_content" 2>"$error_file"); then
          sanitized_result=$(sanitize_report_content "$result")
          if validate_report_schema "$check_id" "$sanitized_result"; then
            output_to_both "$sanitized_result"
            local result_status
            result_status=$(extract_report_status "$sanitized_result")
            update_summary_counters "$result_status"
            # Save result to report file if writing reports is enabled
            if [[ "$WRITE_REPORTS" == "true" ]]; then
              local report_file="$report_dir/${check_id}.md"
              echo "$sanitized_result" >"$report_file"
              output_to_both "Saved report: $report_file"
            fi
            # Cache the result if caching is enabled
            if [[ "$AI_CACHE_ENABLED" == "true" && -n "$check_cache_key" ]]; then
              cache_set_ai_by_key "$check_cache_key" "$sanitized_result"
            fi
          else
            output_to_both "$result"
            output_to_both "[SCHEMA] Report failed structural validation for $check_id"
            fail_count=$((fail_count + 1))
            # Save invalid result to report file for manual inspection
            if [[ "$WRITE_REPORTS" == "true" ]]; then
              local report_file="$report_dir/${check_id}.md"
              echo "$(sanitize_report_content "$result")" >"$report_file"
              output_to_both "Saved report: $report_file"
            fi
          fi
        else
          local error_output=""
          if [[ -f "$error_file" ]]; then
            error_output=$(cat "$error_file")
          fi
          echo "$error_output" >&2
          output_to_both "Check failed for $check_id"
          fail_count=$((fail_count + 1))
          # Save error to report file if writing reports is enabled
          if [[ "$WRITE_REPORTS" == "true" ]]; then
            local report_file="$report_dir/${check_id}.md"
            echo "Error: $error_output" >"$report_file"
          fi
          # Cache the error result if caching is enabled
          if [[ "$AI_CACHE_ENABLED" == "true" && -n "$check_cache_key" ]]; then
            cache_set_ai_by_key "$check_cache_key" "Check failed for $check_id: $error_output"
          fi
        fi
        rm -f "$error_file"
      fi
    else
      echo "Warning: Prompt file not found: $prompt_file" >&2
    fi
  done

  output_to_both ""
  output_to_both "----------------------------------------"
  output_to_both "Summary: $pass_count PASS, $fail_count FAIL, $total_checks total"
  output_to_both "Status Breakdown: $partial_count PARTIAL, $not_applicable_count NOT_APPLICABLE, $needs_review_count NEEDS_REVIEW, $unknown_count UNKNOWN"
  if [[ "$WRITE_REPORTS" == "true" ]]; then
    output_to_both "Reports saved to: $report_dir/"
  fi

  # Clean up temp file
  rm -f "$temp_output_file"
}

# Main execution
main() {
  local post_content

  # Read post content, handling potential errors
  if ! post_content=$(cat "$POST_FILE" 2>/dev/null); then
    echo "Error: Could not read post file '$POST_FILE'" >&2
    exit 1
  fi

  run_all_checks "$post_content"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
