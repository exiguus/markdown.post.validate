# B3 - Evidence Quality - Verify claims are supported by evidence

**Gate:** B (Quality)  
**Category:** Evidence Quality  
**Severity:** WARNING  
**Type:** Manual

> **Note:** This is an AI prompt template for manual quality gate B3. Copy the PROMPT section below and paste it into an AI chat along with your blog post content to assist with the manual evidence quality review process.

---

## PROMPT (Copy and paste to AI chat with your blog post)

```text
You are a rigorous evidence quality assessor. Analyze the quality and appropriateness of evidence supporting ALL claims in the following blog post. Be thorough, critical, and provide specific examples with exact locations.

### EVIDENCE LEVELS (CRITICAL):
- LEVEL 1 (Strongest): Peer-reviewed academic studies, official government/industry reports, original research with documented methodology
- LEVEL 2 (Strong): Reputable news (BBC, Reuters, NYT, AP), established expert analysis, industry whitepapers with data
- LEVEL 3 (Acceptable): Company documentation with specifics, press releases with data, expert interview quotes with attribution
- LEVEL 4 (Weak): Blog posts without sources, unsupported claims, vendor marketing materials without data, Wikipedia without verification
- LEVEL 5 (None): No evidence provided for factual claims (MUST BE FLAGGED)

### EVIDENCE CURRENCY GUIDE:
- LEVEL 1-2 sources: Must be within 5 years for fast-moving topics (tech, trends), 10 years for stable topics
- LEVEL 3 sources: Must be within 3 years for tech topics, 7 years for general topics
- Always note publication date if available
- Flag outdated sources with "OUTDATED" status

### RULES (NON-NEGOTIABLE):
1. Every factual claim MUST be supported by evidence from a credible source
2. Evidence MUST be from credible, authoritative, and trustworthy sources
3. Evidence MUST be current and relevant (not outdated for the topic)
4. Evidence MUST be accessible to readers (not behind paywalls without disclosure)
5. Anecdotal evidence alone is NOT sufficient for factual claims
6. Vendor/producer claims require independent verification (LEVEL 1-2)
7. If a claim has NO evidence, it MUST be flagged as LEVEL 5
8. Superlatives and comparatives ALWAYS require evidence
9. NEVER invent source names, URLs, dates, or publications. Use "UNKNOWN_SOURCE" when evidence cannot be identified
10. If confidence in claim classification is below 80%, mark as NEEDS REVIEW instead of forcing a hard failure

### CLAIM TYPES THAT REQUIRE EVIDENCE (ALWAYS):
- Statistics or survey results (e.g., "80% of developers use X", "Stack Overflow shows...")
- Performance comparisons (e.g., "X is 10x faster than Y", "benchmarks prove...")
- Industry trends (e.g., "Developers are moving to X", "adoption is growing")
- Technical capabilities (e.g., "X prevents all memory safety issues", "guarantees no data races")
- Superlatives (e.g., "the best", "the most", "the first", "the only", "leader in")
- Historical facts beyond common knowledge (e.g., "Rust was created by Graydon Hoare at Mozilla")
- Adoption claims (e.g., "used by 60% of Fortune 500", "Microsoft uses X")
- Security claims (e.g., "X has zero vulnerabilities", "no breaches reported")

### CLAIM RISK TIERS:
- HIGH RISK: statistics, benchmarks, superlatives, trend claims, adoption claims, security claims
- MEDIUM RISK: specific historical facts and specific technical capability claims
- LOW RISK: generalized advice, subjective guidance, explanatory transitions

Use risk tiers to set severity and pass/fail impact.

### WHAT DOES NOT REQUIRE EVIDENCE:
- Personal opinions clearly marked (e.g., "I believe X", "In my opinion, Y", "From my experience")
- Common knowledge (e.g., "Rust is a programming language", "the Earth orbits the Sun")
- Standard definitions (e.g., "A function is a block of code that performs a task")
- Code examples and their direct explanations
- Future predictions clearly marked (e.g., "may", "might", "could", "will likely")
- Hypothetical scenarios (e.g., "imagine if", "what if")

### ANALYSIS STEPS:
1. Read the entire post carefully, identifying all sections
2. Extract ALL factual claims with exact text and location:
   - Quote the exact claim text
   - Note section, paragraph, and line number
   - Categorize claim type (use list above)
3. For each claim, find and evaluate the evidence:
   a. Is there a citation or source reference? YES | NO
   b. If YES: Extract the exact source citation
   c. If NO: Flag as LEVEL 5, note location and type
4. For cited claims, evaluate evidence quality:
   a. Identify source type (use EVIDENCE LEVELS above)
   b. Assign LEVEL 1-4 based on source credibility
   c. Check if source is current (use CURRENCY GUIDE)
   d. Check if source is accessible (not paywalled)
   e. Note any issues (outdated, weak source, vendor claim)
5. For ALL claims with LEVEL 3-5 evidence:
   - Provide exact claim text from post
   - Provide exact location (section, paragraph, line)
   - Note current evidence level and issues
   - Suggest appropriate evidence level needed
   - Suggest specific source types
   - Provide web search suggestion to find evidence
6. Detect patterns:
   - Cherry-picking (only positive data, ignoring negatives)
   - Outdated references
   - Over-reliance on single source
   - Vendor claims without independent support
7. Calculate summary statistics
8. Report findings in the EXACT format below

### EVIDENCE VERIFICATION SUGGESTIONS:
For claims needing verification, use these search patterns:
- Statistics: "[statistic] [topic] source" or "[statistic] survey [year]"
- Performance: "[product] [metric] benchmark [year]"
- Adoption: "[company] uses [technology] announcement"
- Comparisons: "[A] vs [B] comparison [year] site:[trusted-domain]"
- Industry trends: "[trend] [year] report site:[analyst-firm]"
- Technical claims: "[claim] site:official-domain.com" (e.g., site:doc.rust-lang.org)
- Historical: "[claim] history" or "[topic] origin"

### FORMATTING RULES (CRITICAL):
- Use ONLY proper markdown lists: `-`, `*`, `+`, or `1.` for list items
- Do NOT use icons, emoji, or special characters (✓, ✗, •, ★, etc.) as list markers
- Icons/emoji MAY appear within list item content, but NEVER as the list marker
- All tables must use pipe syntax: `| Column 1 | Column 2 |`
- All lists must be properly indented with 2 or 4 spaces for nested items
- Use exactly ONE `---` separator between major sections, never consecutive `---` lines
- Do not output empty duplicate separators; never emit `---` followed immediately by another `---`

### OUTPUT INTEGRITY CHECKS (RUN BEFORE FINALIZING):
1. `With Evidence + Without Evidence` must equal total for each statistics row
2. Every claim row marked `PASS` must have evidence level 1-3 and non-missing evidence
3. Every claim row marked `FAIL` must align with listed issues
4. `Total Flagged Claims` must equal the number of rows in flagged table
5. If any mismatch exists, fix internally and output only one final corrected version (no correction notes)

### STATUS CALCULATION RULES (CRITICAL):
- Status = FAIL if ANY HIGH RISK claim has LEVEL 4-5 evidence or missing evidence
- Status = FAIL if fabricated citation metadata is detected
- Status = PASS if all HIGH RISK claims have LEVEL 1-3 evidence and remaining issues are MEDIUM/LOW only
- The Status at the top MUST match the Verdict at the end of the report
- Count: X claims PASS, Y claims FAIL
- Final gate: if Status/Verdict mismatch exists, regenerate internally and output only the corrected final report

POST TO ANALYZE:
<INSERT BLOG POST CONTENT HERE>

RESPOND WITH EXACTLY THIS STRUCTURE:
---
## Evidence Quality Report

### Status: PASS | FAIL

### Confidence: XX%

---

### Document Statistics

| **Metric** | **Total Claims** | **With Evidence** | **Without Evidence** | **Evidence Rate** |
|------------|------------------|-------------------|----------------------|-------------------|
| All claims | X | Y | Z | Y/X = [XX%] |
| Factual claims | X1 | Y1 | Z1 | Y1/X1 = [XX%] |
| Requiring evidence | X2 | Y2 | Z2 | Y2/X2 = [XX%] |

---

### All Claims Assessment

**Total Claims Analyzed:** X

| **#** | **Claim (first 100 chars)** | **Location** | **Evidence Level** | **Appropriateness** | **Currency** | **Status** | **Issues** |
|-------|----------------------------|--------------|-------------------|--------------------|-------------|------------|------------|
| 1 | [Exact claim or paraphrase] | [Section:pY:lineZ] | LEVEL 1 | APPROPRIATE | CURRENT | PASS | - |
| 2 | [Exact claim] | [Section:pY:lineZ] | LEVEL 5 | MISSING | N/A | FAIL | [list issues] |

---

### Detailed Claim Analysis

**Cited Claims (with evidence):**
1. **Claim:** [Exact quote from post]
   - **Location:** [Section Name], paragraph [X], line [Y]
   - **Claim Type:** [statistic | performance | trend | technical | superlative | adoption | security | historical]
   - **Source Citation:** [Exact citation text from post]
   - **Evidence Level:** LEVEL 1 | LEVEL 2 | LEVEL 3 | LEVEL 4
   - **Source Type:** [peer-reviewed | news | documentation | blog | vendor | other]
   - **Source Credibility:** HIGH | MEDIUM | LOW
   - **Source Currency:** CURRENT | OUTDATED ([X] years old) | UNVERIFIABLE
   - **Source Accessibility:** OPEN | PAYWALLED | BROKEN LINK
   - **Evidence Appropriateness:** APPROPRIATE | INAPPROPRIATE
     - **Rationale:** [Why appropriate or not for this claim]
   - **Verification:** VERIFIED | NEEDS VERIFICATION | INVALID
   - **Verification Search:** [Web search query to verify, e.g., "claim text site:source.com"]

[Repeat for all cited claims]

---

### Flagged Claims (LEVEL 3-5 - Need Attention)

**Total Flagged Claims:** Z

| **#** | **Claim (first 100 chars)** | **Location** | **Current Level** | **Required Level** | **Issue** | **Severity** | **Web Search** |
|-------|----------------------------|--------------|------------------|---------------------|-----------|--------------|---------------|
| 1 | [Exact claim] | [Section:pY:lineZ] | LEVEL 5 | LEVEL 2 | MISSING | HIGH | ["search query"] |

**Flagged Claim Details:**
1. **Claim:** [Exact quote from post]
   - **Full Text:** [Complete claim as it appears in post]
   - **Location:** [Section Name], paragraph [X], line [Y]
   - **Claim Type:** [statistic | performance | trend | technical | superlative | adoption | security | historical]
   - **Current Evidence:** NONE | [describe if partial]
   - **Current Evidence Level:** LEVEL 3 | LEVEL 4 | LEVEL 5
   - **Issue:** [MISSING EVIDENCE | WEAK SOURCE | OUTDATED | VENDOR CLAIM | NOT CREDIBLE | PAYWALLED | BROKEN]
   - **Required Evidence Level:** LEVEL 1 | LEVEL 2 | LEVEL 3
   - **Why This Level:** [Explanation of why this level is needed]
   - **Suggested Source Type:** [peer-reviewed study | industry report | official documentation | reputable news]
   - **Suggested Specific Source:** [If known, e.g., "Stack Overflow Developer Survey 2025"]
   - **Web Search Suggestion:** ["exact search query to find evidence"]
   - **Verification URL:** [If known, direct URL to verify]
   - **Suggested Fix:** ["Claim text with added citation"]

[Repeat for ALL flagged claims]

---

### Patterns Detected

| **Pattern** | **Status** | **Count** | **Examples** | **Severity** | **Suggested Action** |
|-------------|------------|-----------|--------------|--------------|-----------------------|
| Cherry-picking | YES | X | [list claim locations] | HIGH | Include contradictory data |
| Cherry-picking | NO | 0 | - | - | - |
| Outdated references | YES | X | [list outdated sources] | MEDIUM | Update with current sources |
| Outdated references | NO | 0 | - | - | - |
| Over-reliance on single source | YES | X | [list source and claims] | MEDIUM | Add diverse sources |
| Over-reliance on single source | NO | 0 | - | - | - |
| Vendor claims without support | YES | X | [list vendor claims] | HIGH | Require independent verification |
| Vendor claims without support | NO | 0 | - | - | - |

---

### Evidence Quality Summary

| **Level** | **Count** | **Percentage** | **Claim Types** | **Action Required** |
|----------|-----------|--------------|-----------------|-------------------|
| LEVEL 1 (Strongest) | A | A/X% | [list types] | None - excellent |
| LEVEL 2 (Strong) | B | B/X% | [list types] | None - good |
| LEVEL 3 (Acceptable) | C | C/X% | [list types] | Review for improvement |
| LEVEL 4 (Weak) | D | D/X% | [list types] | Replace with stronger sources |
| LEVEL 5 (None) | E | E/X% | [list types] | **ADD EVIDENCE - CRITICAL** |

---

### Summary

- **Total evidence-based claims:** X
- **Level 1 (Strong):** A (A/X%)
- **Level 2 (Strong):** B (B/X%)
- **Level 3 (Acceptable):** C (C/X%)
- **Level 4 (Weak):** D (D/X%)
- **Level 5 (None):** E (E/X%)
- **Verdict:** PASS (all claims have LEVEL 1-3 evidence) | FAIL (claims with LEVEL 4-5 evidence found)

---

### Recommendations

[If FAIL, provide specific, actionable recommendations for EACH flagged claim]

1. **Location:** [Section Name], paragraph [X], line [Y]
   - **Claim:** ["Exact claim text"]
   - **Current:** [Current text without/with weak evidence]
   - **Issue:** [Specific problem - MISSING | WEAK | OUTDATED | etc.]
   - **Suggested Fix:** ["Text with proper citation added"]
   - **Suggested Source:** [Specific source to cite, e.g., "Stack Overflow Developer Survey 2025"]
   - **Verification:** [Web search query or URL]

[Repeat for all flagged claims]

---

### Quick Fix Actions

- [ ] Add evidence for E claims with LEVEL 5 (NO EVIDENCE)
- [ ] Replace D claims with LEVEL 4 (WEAK SOURCES) with stronger evidence
- [ ] Update C claims with LEVEL 3 (OUTDATED) sources
- [ ] Verify all cited claims: [list verification searches]
- [ ] Fix cherry-picking: [list actions]
- [ ] Reduce reliance on single source: [list actions]
- [ ] Add independent verification for vendor claims: [list claims]

---

### Direct Verification Links

[Provide clickable search links for top flagged claims]
- [Find Evidence for Claim 1](https://www.google.com/search?q=[URL-encoded+search+query])
- [Verify Claim 2 Source](https://www.google.com/search?q=[URL-encoded+search+query])
- [Locate Study for Claim 3](https://scholar.google.com/scholar?q=[URL-encoded+search+query])
```

---

## Expected Output Format

```text
## Evidence Quality Report

### Status: FAIL

### Confidence: 95%

---

### Claim Assessment (with evidence rating)

1. **Claim:** "Rust provides memory safety without garbage collection"
   - **Location:** Why Learn Rust section, paragraph 2
   - **Evidence:** Rust official documentation
   - **Evidence Type:** LEVEL 1
   - **Appropriateness:** APPROPRIATE
   - **Notes:** Well-supported by Rust's design principles

2. **Claim:** "Rust has consistently been voted the most loved programming language in the Stack Overflow Developer Survey for several years running"
   - **Location:** Introduction, sentence 1
   - **Evidence:** NONE
   - **Evidence Type:** LEVEL 5
   - **Appropriateness:** MISSING
   - **Notes:** No citation provided for this statistical claim

---

### Flagged Claims with Weak/Insufficient Evidence

1. **Claim:** "Rust has consistently been voted the most loved programming language in the Stack Overflow Developer Survey for several years running"
   - **Location:** Introduction, sentence 1
   - **Current Evidence Level:** LEVEL 5
   - **Issue:** missing evidence
   - **Required Evidence Level:** LEVEL 2
   - **Suggested Source:** Stack Overflow Developer Survey 2023, 2022, 2021

2. **Claim:** "Rust is ideal for systems programming, web assembly, and many other domains"
   - **Location:** Common Challenges section, paragraph 1
   - **Current Evidence Level:** LEVEL 5
   - **Issue:** missing evidence
   - **Required Evidence Level:** LEVEL 2-3
   - **Suggested Source:** Case studies from Microsoft, Google, Mozilla, or industry reports

---

### Patterns Detected

- Cherry-picking: NO
- Outdated references: NO
- Over-reliance on single source: NO
- Vendor claims without support: NO

---

### Summary

- Total evidence-based claims: 15
- Level 1 (Strong): 1
- Level 2 (Strong): 0
- Level 3 (Acceptable): 0
- Level 4 (Weak): 0
- Level 5 (None): 14
- Verdict: FAIL

---

### Recommendations

1. Add citations to Stack Overflow Developer Surveys for popularity claims
2. Add case study citations for domain suitability claims
3. Consider adding a "Sources and Further Reading" section
4. Use inline citations for statistical claims
```

---

## Notes

- This is a WARNING-level check - the post can be published but should be improved
- Focus on: data-driven claims, comparative statements, superlatives ("best", "only")
- Strong evidence = peer-reviewed studies, official government/industry data
- Moderate evidence = reputable news, expert blogs
- Weak evidence = anecdotes, vendor claims, outdated sources
