# A6 - Link Relevance - Ensure all links are relevant and add value

**Gate:** A (Blocking)
**Category:** Links
**Severity:** ERROR (Must pass)
**Type:** Manual

> **Note:** This is an AI prompt template for manual quality gate A6. Copy the PROMPT section below and paste it into an AI chat along with your blog post content to assist with the manual link relevance review process.

---

## PROMPT (Copy and paste to AI chat with your blog post)

```text
You are a critical link quality reviewer. Analyze ALL links in the following blog post for relevance, descriptiveness, value, and accessibility. Be thorough and provide specific examples with exact locations.

### RULES (NON-NEGOTIABLE):
1. Every link MUST be relevant to the content it appears with
2. Every link in prose MUST have descriptive text (no "click here", "this", "that", or bare URLs)
3. Every link MUST add tangible value to the reader
4. Links in code blocks are EXEMPT from descriptive text requirement
5. All external links MUST be working (no broken links)
6. Affiliate links MUST be disclosed with "(affiliate link)" or similar
7. Links MUST use HTTPS where available (no HTTP unless HTTPS unavailable)
8. If the post contains ZERO links, return Status = NOT_APPLICABLE and do not fabricate link rows
9. Build exactly one canonical link inventory first, then derive all counts/tables from that inventory only
10. Do NOT include revised/corrected duplicate sections; output each section once
11. Emit exactly one report header (`## Link Relevance Report`) and exactly one `### Status:` line
12. Do not include any correction narrative (forbidden: "corrected below", "initial table had an error", "revised")

### LINK QUALITY CRITERIA (1-5 scale):

**Descriptiveness:**
- 5: Link text perfectly describes the destination (user knows exactly what they'll get)
- 4: Link text is clear and mostly descriptive
- 3: Link text is somewhat descriptive but could be improved
- 2: Link text is vague (e.g., "click here", "this article", "read more")
- 1: Link text is non-descriptive (bare URL in prose, "here")

**Contextual Relevance:**
- 5: Link is directly relevant and essential to understanding the content
- 4: Link is relevant and supportive of the point being made
- 3: Link is somewhat relevant but connection is weak
- 2: Link is tangentially relevant at best
- 1: Link is not relevant or is off-topic

**Reader Value:**
- 5: Link provides significant, unique value that reader cannot get elsewhere
- 4: Link provides good value and useful information
- 3: Link provides some value but may be redundant
- 2: Link provides minimal value (could be removed without loss)
- 1: Link provides no value or is self-serving

### ANALYSIS STEPS:
1. Extract ALL links from the blog post with their exact context
2. For each link, record:
   - Link text (exact as appears in post)
   - URL (full)
   - Location (section, paragraph, line)
   - Context (surrounding text to understand relevance)
   - In code block: YES | NO
3. For each link NOT in a code block, evaluate:
   a. Descriptiveness (1-5)
   b. Contextual relevance (1-5)
   c. Reader value (1-5)
4. Calculate Quality Score: (Descriptiveness + Relevance + Value) / 3
5. Quality Score Assessment:
   - 4.5-5.0: EXCELLENT
   - 3.5-4.4: GOOD
   - 2.5-3.4: FAIR
   - 1.0-2.4: POOR
6. Flag problematic links:
   - Bare URLs in prose (not in code blocks)
   - Non-descriptive link text
   - Irrelevant links
   - Broken links
   - Low-value links
   - Affiliate links without disclosure
7. Check link density and assess if excessive
8. For problematic links, provide:
   - Exact link text and URL
   - Exact location (section, paragraph, line)
   - All issues identified
   - Suggested fix
   - Web verification suggestion (for broken links)
9. Report findings in the EXACT format below

### SPECIAL CONSIDERATIONS:
- Bare URLs are acceptable ONLY in code blocks (for installation commands, package names, etc.)
- Affiliate links must be clearly disclosed
- Links to your own content should be minimal, relevant, and add value
- Internal links (same domain) should follow the same quality rules
- Link to authoritative sources where possible
- Avoid linking to competitors unless for fair comparison

### VERIFICATION SUGGESTIONS:
For broken or questionable links:
- Check if URL is valid: "site:[domain]" to find current URL
- Find alternative source: "[link topic] site:[trusted-domain]"
- Verify resource still exists: Use web archive or cached version

### FORMATTING RULES (CRITICAL):
- Use ONLY proper markdown lists: `-`, `*`, `+`, or `1.` for list items
- Do NOT use icons, emoji, or special characters (✓, ✗, •, ★, etc.) as list markers
- Icons/emoji MAY appear within list item content, but NEVER as the list marker
- All tables must use pipe syntax: `| Column 1 | Column 2 |`
- All lists must be properly indented with 2 or 4 spaces for nested items
- Use exactly ONE `---` separator between major sections, never consecutive `---` lines
- Output must be single-pass and final: do NOT include self-corrections, notes about corrections, or duplicate/revised sections
- Forbidden phrases: "Corrected below", "initial table had an error", "revised", "canonical inventory corrected"

### OUTPUT INTEGRITY CHECKS (RUN BEFORE FINALIZING):
1. Build ONE canonical link inventory and use it for all downstream counts and tables
2. Ensure `Total links` in statistics equals the number of rows in `Complete Link Assessment Table`
3. Ensure `Prose + Code Block` counts equal `Total links`
4. Ensure summary distribution counts match table-derived counts
5. If a mismatch is found, fix it internally and output only the corrected final report (no correction notes)
6. Final output must contain exactly one occurrence of each of these headers:
   - `## Link Relevance Report`
   - `### Document Link Statistics`
   - `### Complete Link Assessment Table`
   - `### Summary`

### STATUS CALCULATION RULES (CRITICAL):
- If total links = 0: Status = NOT_APPLICABLE
- If total links > 0 and ALL links have Quality Score >= 3.5 AND all links are working AND no affiliate links without disclosure: Status = PASS
- If total links > 0 and ANY link has Quality Score < 3.5 OR is broken OR has missing disclosure: Status = FAIL
- The Status at the top MUST match the Verdict at the end of the report
- Count: X links PASS, Y links FAIL (or 0/0 when NOT_APPLICABLE)
- Final gate: if Status/Verdict mismatch exists, regenerate internally and output only the corrected final report

POST TO ANALYZE:
<INSERT BLOG POST CONTENT HERE>

RESPOND WITH EXACTLY THIS STRUCTURE:
---
## Link Relevance Report

### Status: PASS | FAIL | NOT_APPLICABLE

### Confidence: XX%

---

### Document Link Statistics

| **Metric** | **Value** | **In Code Blocks** | **In Prose** | **Notes** |
|------------|-----------|-------------------|--------------|-----------|
| Total links | X | A | B | - |
| External links | Y | A1 | B1 | - |
| Internal links | Z | A2 | B2 | - |
| Affiliate links | W | - | W | DISCLOSURE: YES/NO |

---

### Complete Link Assessment Table

| **#** | **Link Text** | **URL** | **In Code Block** | **Descriptiveness** | **Relevance** | **Value** | **Quality Score** | **Status** | **Issues** |
|-------|--------------|---------|------------------|---------------------|--------------|-----------|------------------|------------|------------|
| 1 | [exact text] | [full URL] | YES | N/A | N/A | N/A | N/A | EXEMPT | - |
| 2 | [exact text] | [full URL] | NO | 5 | 5 | 5 | 5.0 | EXCELLENT | - |
| 3 | [exact text] | [full URL] | NO | 2 | 3 | 2 | 2.3 | POOR | non-descriptive |

---

### Detailed Link Analysis

**Prose Links (require full analysis):**
1. **Link Text:** [Exact text from post]
   - **URL:** [full URL]
   - **Location:** [Section Name], paragraph [X], line [Y]
   - **Context:** ["Surrounding text to show relevance"]
   - **In Code Block:** NO
   - **Descriptiveness Score:** [1-5]
     - **Rationale:** [Why this score - e.g., "text clearly describes destination"]
   - **Contextual Relevance Score:** [1-5]
     - **Rationale:** [Why this score - e.g., "directly supports the point being made"]
   - **Reader Value Score:** [1-5]
     - **Rationale:** [Why this score - e.g., "provides essential additional information"]
   - **Quality Score:** [calculated: (D+R+V)/3]
   - **Quality Rating:** EXCELLENT | GOOD | FAIR | POOR
   - **Status:** PASS | FAIL
   - **Issues:** [list all: non-descriptive text, weak relevance, low value]
   - **Suggested Fix:** ["Improved link text"]
   - **Verification:** [For broken links: "site:[domain]" or specific search]

[Repeat for all prose links]

**Code Block Links (exempt from descriptiveness but must work):**
1. **Link Text:** [exact code text]
   - **URL:** [full URL]
   - **Location:** [Section Name], code block [X], line [Y]
   - **Purpose:** [installation, package, dependency, etc.]
   - **Status:** WORKING | BROKEN | NEEDS VERIFICATION
   - **Verification:** ["curl -I [URL]" or web search suggestion]

[Repeat for all code block links]

---

### Problematic Links (if any)

**Total Problematic Links:** D

| **#** | **Link Text** | **URL** | **Location** | **Issues** | **Severity** | **Suggested Fix** | **Verification** |
|-------|--------------|---------|--------------|------------|--------------|-------------------|----------------|
| 1 | [text] | [url] | [Section:pY:lineZ] | [list issues] | HIGH | [fix] | [search/query] |

**Problematic Link Details:**
1. **Issue Type:** [BARE URL IN PROSE | NON-DESCRIPTIVE TEXT | IRRELEVANT | BROKEN | LOW VALUE | AFFILIATE NOT DISCLOSURED | HTTP NOT HTTPS]
   - **Link Text:** [Exact text from post]
   - **URL:** [full URL]
   - **Location:** [Section Name], paragraph [X], line [Y]
   - **Context:** ["Surrounding text"]
   - **Issues Found:** [List all that apply]
   - **Severity:** HIGH | MEDIUM | LOW
   - **Why Problematic:** [Explanation of each issue]
   - **Suggested Fix:** ["Exact replacement text or URL"]
   - **Verification Search:** [Web search to verify or find replacement]

[Repeat for all problematic links]

---

### Link Density Analysis

| **Metric** | **Value** | **Assessment** | **Recommendation** |
|------------|-----------|----------------|------------------|
| **Total Links** | X | - | - |
| **Links per 1000 words** | Y | Normal (3-8)/High (>8)/Low (<3) | [Adjust if outside normal range] |
| **External vs Internal Ratio** | A:B | Balanced/Too external/Too internal | [Diversify or reduce] |
| **Density Assessment** | - | NORMAL/LOW/HIGH | [Explanation] |

---

### Affiliate Link Disclosure Check

**Affiliate Links Found:** W

| **#** | **Link Text** | **URL** | **Location** | **Disclosure Status** | **Fix Required** |
|-------|--------------|---------|--------------|---------------------|------------------|
| 1 | [text] | [url] | [Section:pY:lineZ] | DISCLOSURE PRESENT | NO |
| 2 | [text] | [url] | [Section:pY:lineZ] | NO DISCLOSURE | YES |

---

### Summary

| **Category** | **Count** | **Percentage** | **Quality Distribution** |
|--------------|-----------|--------------|---------------------------|
| **Excellent links** | A | A/B% | Quality score 4.5-5.0 |
| **Good links** | B | B/B% | Quality score 3.5-4.4 |
| **Fair links** | C | C/B% | Quality score 2.5-3.4 |
| **Poor links** | D | D/B% | Quality score 1.0-2.4 |
| **Problematic links** | D | D/B% | [list specific issues] |
| **Verdict** | - | - | PASS/FAIL/NOT_APPLICABLE |

---

### Recommendations

[If FAIL, provide specific, actionable recommendations for each problematic link]

1. **Location:** [Section Name], paragraph [X], line [Y]
   - **Issue:** [BARE URL | NON-DESCRIPTIVE | IRRELEVANT | BROKEN | LOW VALUE | MISSING DISCLOSURE]
   - **Current:** ["Exact current text with link"]
   - **Suggested:** ["Exact suggested text with improved link"]
   - **Rationale:** [Why this fix improves quality]
   - **Verification:** [Web search or command to verify]

[Repeat for all recommendations]

---

### Quick Fix Checklist

- [ ] Fix D problematic links at: [list locations]
- [ ] Add descriptive text to: [list locations with non-descriptive links]
- [ ] Remove or replace irrelevant links at: [list locations]
- [ ] Fix broken links at: [list locations with verification queries]
- [ ] Add affiliate disclosure to: [list locations]
- [ ] Convert HTTP to HTTPS at: [list locations]
- [ ] Verify all code block links: [list commands or searches]

---

### Direct Verification Commands/Links

[For broken links, provide verification]
- [Verify Link 1](https://www.google.com/search?q=[URL-encoded+search])
- [Check Link 2 Status](curl -I [URL])
- [Find Alternative for Link 3](https://www.google.com/search?q=[topic]+site:[trusted-domain])
```

---

## Expected Output Format

```text
## Link Relevance Report

### Status: FAIL

### Confidence: 100%

---

### Link Assessment Table

| # | **Link Text** | **URL** | **Descriptiveness** | **Contextual Relevance** | **Reader Value** | **Quality Score** | **Status** |
|---|--------------|---------|---------------------|-------------------------|-----------------|------------------|------------|
| 1 | The Rust Programming Language | https://doc.rust-lang.org/book/ | 5 | 5 | 5 | EXCELLENT | PASS |
| 2 | Rust by Example | https://doc.rust-lang.org/rust-by-example/ | 5 | 5 | 5 | EXCELLENT | PASS |
| 3 | Rustlings | https://github.com/rust-lang/rustlings | 5 | 5 | 5 | EXCELLENT | PASS |
| 4 | Rust Documentation | https://doc.rust-lang.org/ | 5 | 5 | 5 | EXCELLENT | PASS |
| 5 | https://sh.rustup.rs | (bare URL in code block) | 1 | 3 | 2 | POOR | EXEMPT |

### Flagged Problematic Links

None in prose. Note: Bare URL in code block (line 25) is acceptable for installation commands.

---

### Link Density Analysis

- Total Links: 4 (all in Resources section) + 1 bare URL (in code)
- Links per 1000 words: 4.5
- Density Assessment: Normal

---

### Summary

- Excellent links: 4
- Good links: 0
- Acceptable links: 0
- Problematic links: 0
- Verdict: PASS

---

### Recommendations

1. All links are well-formatted and relevant
2. Consider adding more resources for beginners
```

---

## Notes

- This is a BLOCKING check - the post CANNOT be published with broken or irrelevant links
- Bare URLs are only acceptable in code blocks (for commands, installation scripts)
- All links in prose must have descriptive text
- Link density should be natural and value-adding, not excessive
- Check all links work (use lychee or similar tool)
