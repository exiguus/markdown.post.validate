# B7 - Quote Accuracy - Verify Quotes Are Accurate and Properly Attributed

**Gate:** B (Quality)  
**Category:** Quote Accuracy  
**Severity:** WARNING  
**Type:** Manual

> **Note:** This is an AI prompt template for manual quality gate B7. Copy the PROMPT section below and paste it into an AI chat along with your blog post content to assist with the manual quote accuracy review process.

---

## PROMPT (Copy and Paste to AI Chat with Your Blog Post)

```text
You are a meticulous fact-checker specializing in quote verification and attribution accuracy. Analyze ALL quotes and attributions in this blog post with extreme precision. Be strict and thorough.

### CRITICAL RULES (NON-NEGOTIABLE):
1. Every direct quote MUST have complete and accurate attribution
2. Every quote MUST be properly formatted with quotation marks (" ") or blockquote (> ) syntax
3. Complete attribution REQUIRES all applicable elements:
   - Full name of the person (not initials, not first name only)
   - Title/position (if relevant to credibility)
   - Organization/affiliation (if relevant)
   - Source type (article, book, interview, speech, documentation, etc.)
   - Source name (publication name, book title, event name, etc.)
   - Date (month/year minimum, exact date preferred)
   - URL (for online sources - MUST be verifiable)
4. Paraphrased content MUST NOT be presented as a direct quote
5. Blockquotes must contain properly attributed quotes, not just stylistic formatting
6. Ellipsis (...) in quotes must use bracket notation [...] if text was omitted
7. ANY missing attribution element reduces the completeness score
8. If there are ZERO quotes, output an empty inventory and stop quote-level analysis (no fabricated quote rows)
9. Every quote listed MUST include exact text copied from the post (no invented or paraphrased substitute text)
10. If attribution/source details are unknown, use UNKNOWN_SOURCE instead of inventing metadata

### ATTRIBUTION QUALITY LEVELS:
- LEVEL 1 (Complete): All 7 elements present and verifiable
- LEVEL 2 (Good): Missing 1 non-critical element (date or URL)
- LEVEL 3 (Fair): Missing 2-3 elements but source is still identifiable
- LEVEL 4 (Poor): Missing critical elements (name, source type, or source name)
- LEVEL 5 (Missing): No attribution at all

### QUOTE TYPES TO IDENTIFY:
- Direct quotes (in " " or > blockquote)
- Blockquotes (multi-line with >)
- Code block quotes (if presenting code as a quote)
- Paraphrased statements that should be quotes
- Misformatted quotes (missing quotes, wrong punctuation)

### ANALYSIS STEPS:
1. Extract ALL quotes from the blog post with their exact location
2. For each quote, evaluate:
   a. Quote text accuracy (does it match the original source?)
   b. Formatting correctness (quotes, blockquotes, punctuation)
   c. Attribution completeness (use LEVEL 1-5 scale)
   d. Context preservation (does it appear in original context?)
   e. Verifiability (can the source be found and confirmed?)
3. Identify:
   - All direct quotes with their location
   - Formatting issues with specific examples
   - Attribution issues with specific examples
   - Context distortion issues
   - Paraphrasing presented as direct quotes
4. For ANY issues found (LEVEL 2-5), provide:
   - The EXACT quote text from the post
   - The EXACT location (section name, paragraph number, line number)
   - What's missing or incorrect
   - Web search suggestion to verify/find proper source
5. Report findings in the EXACT format below
6. If no quotes exist, fill summary with zeros and mark quote-specific sections as N/A or None

### VERIFICATION GUIDANCE:
When sources are questionable or missing, provide web search suggestions:
- For person quotes: Search "[Person Name] [quote keywords]" or "[Person Name] interview [topic]"
- For documentation quotes: Search "[exact phrase] site:official-domain.com"
- For article quotes: Search "[exact phrase]" to find original source
- For statistics in quotes: Search "[statistic] [topic] source"

### FORMATTING RULES (CRITICAL):
- Use ONLY proper markdown lists: `-`, `*`, `+`, or `1.` for list items
- Do NOT use icons, emoji, or special characters (✓, ✗, •, ★, etc.) as list markers
- Icons/emoji MAY appear within list item content, but NEVER as the list marker
- All tables must use pipe syntax: `| Column 1 | Column 2 |`
- All lists must be properly indented with 2 or 4 spaces for nested items
- Use exactly ONE `---` separator between major sections, never consecutive `---` lines

### STATUS CALCULATION RULES (CRITICAL):
- If total quotes = 0: Status = PASS (no quote-attribution violations present)
- If total quotes > 0 and ALL quotes have LEVEL 1-2 attribution AND all formatting is CORRECT: Status = PASS
- If total quotes > 0 and ANY quote has LEVEL 3-5 attribution OR has formatting issues: Status = FAIL
- The Status at the top MUST match the Verdict at the end of the report
- Count: X quotes PASS, Y quotes FAIL

POST TO ANALYZE:
<INSERT BLOG POST CONTENT HERE>

RESPOND WITH EXACTLY THIS STRUCTURE:
---
## Quote Accuracy Report

### Status: PASS | FAIL

### Confidence: XX%

---

### Quote Inventory Table

| # | **Quote Text (first 80 chars)** | **Location** | **Formatting** | **Attribution Level** | **Context** | **Status** |
|---|--------------------------------|--------------|---------------|----------------------|-------------|------------|
| 1 | [text] | Section X, para Y, line Z | CORRECT | LEVEL 1 | PRESERVED | PASS |

---

### Detailed Quote Assessment

1. **Quote:** [EXACT full quote text from post]
   - **Location:** [Section Name], paragraph [X], line [Y]
   - **Original Source:** [What the quote is attributed to in the post]
   - **Formatting:** CORRECT | MISSING QUOTES | SHOULD BE BLOCKQUOTE | PUNCTUATION ERROR
   - **Attribution Level:** LEVEL 1 | LEVEL 2 | LEVEL 3 | LEVEL 4 | LEVEL 5
   - **Attribution Details:** [List what's present and what's missing]
     - Full Name: [present/missing] - [value if present]
     - Title: [present/missing] - [value if present]
     - Organization: [present/missing] - [value if present]
     - Source Type: [present/missing] - [value if present]
     - Source Name: [present/missing] - [value if present]
     - Date: [present/missing] - [value if present]
     - URL: [present/missing] - [value if present]
   - **Context Preserved:** YES | PARTIAL | NO - [explanation if not YES]
   - **Verifiable:** YES | NO | NEEDS VERIFICATION
   - **Web Search Suggestion:** [Specific search query to verify]

[Repeat for ALL quotes found]

---

### Issues Summary Table

| **Issue Type** | **Count** | **Severity** | **Example Locations** |
|---------------|-----------|--------------|----------------------|
| Formatting problems | X | HIGH/MEDIUM/LOW | [Section X:para Y, ...] |
| Missing attributions (LEVEL 5) | X | HIGH | [Section X:para Y, ...] |
| Incomplete attributions (LEVEL 2-4) | X | MEDIUM | [Section X:para Y, ...] |

---

### Problematic Quotes (if any)

1. **Issue:** [MISSING ATTRIBUTION | INCOMPLETE ATTRIBUTION | FORMATTING ERROR]
   - **Quote Text:** [EXACT text from post]
   - **Location:** [Section], paragraph [X], line [Y]
   - **Current Attribution:** [What's currently in the post, or "NONE"]
   - **Missing Elements:** [List all missing attribution elements]
   - **Severity:** HIGH | MEDIUM | LOW
   - **Verification Search:** ["exact search query to find source"]
   - **Suggested Fix:** [How to properly attribute]

[Repeat for all problematic quotes]

---

### Summary

- **Total quotes found:** X
- **Properly formatted and fully attributed (LEVEL 1):** A
- **Needs minor improvement (LEVEL 2):** B
- **Needs significant improvement (LEVEL 3-4):** C
- **Unacceptable/missing attribution (LEVEL 5):** D
- **Verdict:** PASS | FAIL

---

### Recommendations

[If FAIL, provide specific, actionable recommendations]

---

### Quick Verification Links

[If applicable, provide direct verification search links]
```

---

## Expected Output Format

```text
## Quote Accuracy Report

### Status: FAIL

### Confidence: 98%

---

### Quote Inventory Table

| # | **Quote Text (first 80 chars)** | **Location** | **Formatting** | **Attr Level** | **Context** | **Status** |
|---|--------------------------------|--------------|---------------|----------------|-------------|------------|
| 1 | "The borrow checker enforces... | Ownership, p2, l18 | CORRECT | LEVEL 5 | PRESERVED | FAIL |

---

### Detailed Quote Assessment

1. **Quote:** "The borrow checker enforces these safety guarantees at compile time."
   - **Location:** Understanding Ownership section, paragraph 2, line 18
   - **Original Source:** (none provided)
   - **Formatting:** CORRECT
   - **Attribution Level:** LEVEL 5
   - **Attribution Details:**
     - Full Name: missing
     - Title: missing
     - Organization: missing
     - Source Type: missing
     - Source Name: missing
     - Date: missing
     - URL: missing
   - **Context Preserved:** YES
   - **Verifiable:** NO
   - **Web Search Suggestion:** "borrow checker enforces safety guarantees" site:doc.rust-lang.org

---

### Issues Summary Table

| **Issue Type** | **Count** | **Severity** | **Example Locations** |
|---------------|-----------|--------------|----------------------|
| Missing attributions (LEVEL 5) | 1 | HIGH | Ownership:p2:l18 |
| Formatting problems | 0 | - | - |

---

### Problematic Quotes

1. **Issue:** MISSING ATTRIBUTION
   - **Quote Text:** "The borrow checker enforces these safety guarantees at compile time."
   - **Location:** Understanding Ownership, paragraph 2, line 18
   - **Current Attribution:** NONE
   - **Missing Elements:** All 7 elements
   - **Severity:** HIGH
   - **Verification Search:** "borrow checker enforces safety guarantees at compile time" site:doc.rust-lang.org
   - **Suggested Fix:** Attribute to Rust docs: "Rust Documentation, 'The Borrow Checker', Rust Team, doc.rust-lang.org, 2026"

---

### Summary

- Total quotes found: 1
- Properly formatted and fully attributed (LEVEL 1): 0
- Needs minor improvement (LEVEL 2): 0
- Needs significant improvement (LEVEL 3-4): 0
- Unacceptable/missing attribution (LEVEL 5): 1
- Verdict: FAIL

---

### Recommendations

1. Understanding Ownership, paragraph 2, line 18: Add complete attribution to Rust official documentation
2. Verify all technical quotes against official sources
3. Use web search to locate exact source for any unattributed quotes

---

### Quick Verification Links

- [Verify on Rust Docs](https://www.google.com/search?q=%22borrow+checker+enforces+these+safety+guarantees+at+compile+time%22+site%3Adoc.rust-lang.org)
```

---

## Notes

- This is a WARNING-level check
- Blockquote syntax: > for single line, >\n> for multi-line in Markdown
- For documentation: "[Doc Name], '[Section]', [Org], [URL], [Date]"
- For interviews: "[Full Name], [Title] at [Company] - [Type], [Publication], [Date], [URL]"
- Long quotes (>50 words) should use blockquote formatting
- Ellipsis in quotes: use [...] for omitted text
- If a quote cannot be verified, either remove it or mark as "allegedly stated by [source]"
- Always provide web search suggestions for unverified quotes
