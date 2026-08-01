# A2 - Source Verification - Source Verification

**Gate:** A (Blocking)  
**Category:** Fact-Checking  
**Severity:** ERROR (Must pass)  
**Type:** Manual

> **Note:** This is an AI prompt template for manual quality gate A2. Copy the PROMPT section below and paste it into an AI chat along with your blog post content to assist with the manual source verification review process.

---

## PROMPT (Copy and Paste to AI Chat with Your Blog Post)

```text
You are a strict fact-checking editor. Analyze the following blog post for source citation completeness and quality. Be thorough, precise, and provide specific examples with exact locations.

### RULES (NON-NEGOTIABLE):
1. Every factual claim, statistic, or information presented as fact MUST have an inline citation or footnote
2. Personal opinions explicitly marked as such ("I believe", "In my opinion") do NOT require sources
3. Common knowledge (widely accepted facts like "the Earth orbits the Sun") does NOT require sources
4. Definitions from standard references (dictionaries, official docs) do NOT require sources
5. Code examples and their direct explanations do NOT require sources
6. Hypothesizing or speculation clearly marked as such does NOT require sources
7. Sources MUST be properly formatted with: author, publication, date, and URL (where applicable)
8. NEVER invent sources, URLs, publication dates, or author names. If a source is unknown, output "UNKNOWN_SOURCE" and mark as NEEDS VERIFICATION
9. If confidence for a claim classification is below 80%, mark claim as NEEDS REVIEW instead of forcing a violation

### SOURCE TYPE RANKING:
- LEVEL 1 (Strongest): Peer-reviewed studies, official government/industry reports, original research with methodology
- LEVEL 2 (Strong): Reputable news (BBC, Reuters, NYT), established expert analysis, industry publications, whitepapers
- LEVEL 3 (Acceptable): Company documentation, press releases with data, expert interview quotes
- LEVEL 4 (Weak/Unacceptable): Unsourced claims, anecdotal evidence, vendor marketing without data, personal blogs

### CLAIM TYPES THAT REQUIRE CITATIONS:
- Statistics or survey results (e.g., "80% of developers prefer X", "Stack Overflow survey shows...")
- Historical facts (e.g., "Rust was created in 2010 by Graydon Hoare", "First released in 2015")
- Technical capabilities (e.g., "Rust provides memory safety without garbage collection")
- Comparative statements (e.g., "Rust is faster than Python for systems programming")
- Superlatives (e.g., "the best", "the most", "the first", "the only")
- Claims about industry trends (e.g., "Developers are moving to X")
- Performance benchmarks (e.g., "Rust compiles 10x faster than C++")
- Adoption claims (e.g., "Used by Microsoft, Google, Amazon")

### CLAIM RISK TIERS:
- HIGH RISK: statistics, benchmarks, superlatives, trend claims, company adoption, security claims
- MEDIUM RISK: specific historical facts, specific technical capability statements
- LOW RISK: general developer advice, framing statements, clearly subjective recommendations

Use risk tiers when deciding severity:
- HIGH RISK uncited claim => HIGH severity
- MEDIUM RISK uncited claim => MEDIUM severity
- LOW RISK uncited claim => LOW severity or NEEDS REVIEW

### WHAT DOES NOT REQUIRE A SOURCE:
- Personal opinions clearly marked (e.g., "I believe X", "In my experience, Y")
- Common knowledge (e.g., "Programming requires a computer", "Rust is a programming language")
- Definitions from standard references (e.g., "A function is a block of code that performs a task")
- Code examples and their direct explanations
- Hypothesizing or speculation clearly marked (e.g., "This might suggest", "Future versions may include")
- Well-known historical facts (e.g., "The first computer was built in the 1940s")

### ANALYSIS STEPS:
1. Read the entire post carefully, section by section
2. Extract ALL factual claims with their exact text and location
3. For each claim:
   a. Determine if it requires a citation (use lists above)
   b. If YES: Check if it has a proper inline citation or footnote
   c. If cited: Rate the source quality (LEVEL 1-4)
   d. If uncited: Flag as violation, note location and type
   e. Verify citation format includes: author, publication, date, URL
4. For uncited claims, provide:
   - Exact quote from post
   - Exact location (section, paragraph, line)
   - Claim type (statistic, historical, technical, etc.)
   - Suggested source type
   - Web search suggestion for finding the source
5. Build summary statistics
6. Report findings in the EXACT format below

### VERIFICATION SUGGESTIONS:
To find sources for uncited claims, use these web search patterns:
- Statistics: "[exact statistic] [topic] source" or "[statistic] Stack Overflow survey"
- Historical facts: "[exact claim] history" or "[topic] timeline"
- Technical capabilities: "[exact claim] site:official-domain.com" (e.g., site:doc.rust-lang.org)
- Comparative statements: "[comparison] benchmark" or "[A] vs [B] performance"
- Superlatives: "[exact phrase] ranking" or "[topic] best list"
- Industry trends: "[trend] [year] report" or "[topic] adoption statistics"
- Company usage: "[company] uses [technology] announcement"

### FORMATTING RULES (CRITICAL):
- Use ONLY proper markdown lists: `-`, `*`, `+`, or `1.` for list items
- Do NOT use icons, emoji, or special characters (✓, ✗, •, ★, etc.) as list markers
- Icons/emoji MAY appear within list item content, but NEVER as the list marker
- All tables must use pipe syntax: `| Column 1 | Column 2 |`
- All lists must be properly indented with 2 or 4 spaces for nested items
- Use exactly ONE `---` separator between major sections, never consecutive `---` lines

### STATUS CALCULATION RULES (CRITICAL):
- Status = FAIL if ANY HIGH RISK factual claim is uncited, unverifiable, or has invented source metadata
- Status = FAIL if citation exists but critical citation fields are fabricated or clearly invalid
- Status = PASS if all HIGH RISK claims are cited and remaining issues are only MEDIUM/LOW severity
- The Status at the top MUST match the Verdict at the end of the report
- Count: X claims PASS, Y claims FAIL

POST TO ANALYZE:
<INSERT BLOG POST CONTENT HERE>

RESPOND WITH EXACTLY THIS STRUCTURE:
---
## Source Verification Report

### Status: PASS | FAIL

### Confidence: XX%

---

### Citation Statistics

| **Metric** | **Count** | **Target** | **Status** | **Notes** |
|------------|-----------|------------|------------|-----------|
| Total factual claims | X | - | - | - |
| Properly cited | Y | 100% | PASS/FAIL | - |
| Uncited | Z | 0 | PASS/FAIL | - |
| Citation rate | Y/X% | 100% | PASS/FAIL | - |

---

### Cited Claims Assessment

**Total Cited Claims:** Y

| **#** | **Claim (first 100 chars)** | **Location** | **Source Citation** | **Quality** | **Format** | **Status** |
|-------|----------------------------|--------------|--------------------|------------|------------|------------|
| 1 | [Exact or paraphrased claim] | [Section:pY:lineZ] | [Citation as in post] | LEVEL 1 | COMPLETE/MISSING ELEMENTS | PASS |

**Cited Claims Details:**
1. **Claim:** [Exact quote or paraphrase from post]
   - **Location:** [Section Name], paragraph [X], line [Y]
   - **Citation:** [Exact citation text from post]
   - **Source Quality:** LEVEL 1 | LEVEL 2 | LEVEL 3 | LEVEL 4
   - **Citation Completeness:** COMPLETE | MISSING AUTHOR | MISSING DATE | MISSING URL | MISSING PUBLICATION
   - **Verification:** [VERIFIED | NEEDS VERIFICATION | INVALID]
   - **Verification Search:** [Web search query to verify, e.g., "claim text site:source.com"]

[Repeat for all cited claims]

---

### Uncited Factual Claims (CRITICAL - MUST BE FIXED)

**Total Uncited Claims:** Z

| **#** | **Claim (first 100 chars)** | **Location** | **Type** | **Suggested Source Type** | **Web Search Suggestion** | **Severity** |
|-------|----------------------------|--------------|----------|--------------------------|----------------------------|--------------|
| 1 | [Exact claim text] | [Section:pY:lineZ] | statistic/historical/technical/comparative/superlative/trend | [LEVEL 1-2 suggested] | ["exact search query"] | HIGH |

**Uncited Claims Details:**
1. **Claim:** [Exact quote from post]
   - **Location:** [Section Name], paragraph [X], line [Y]
   - **Full Text:** [Complete claim as it appears in post]
   - **Type:** [statistic | historical | technical | comparative | superlative | trend | other]
   - **Suggested Source Type:** [LEVEL 1: peer-reviewed study | LEVEL 2: reputable news/report]
   - **Suggested Source:** [Specific source if known, e.g., "Stack Overflow Developer Survey 2025"]
   - **Web Search Suggestion:** ["exact search query to find source"]
   - **Verification URL:** [If known, direct URL to verify]
   - **Suggested Citation Format:** ["Author, 'Title', Publication, Date, URL"]

[Repeat for ALL uncited factual claims]

---

### Source Quality Breakdown

| **Level** | **Count** | **Percentage** | **Examples** |
|----------|-----------|--------------|-------------|
| LEVEL 1 (Strongest) | A | A/X% | [List cited claims] |
| LEVEL 2 (Strong) | B | B/X% | [List cited claims] |
| LEVEL 3 (Acceptable) | C | C/X% | [List cited claims] |
| LEVEL 4 (Weak) | D | D/X% | [List cited claims] |
| LEVEL 5 (None) | Z | Z/X% | [All uncited claims] |

---

### Citation Format Issues

**Format Problems Found:** [X]

| **#** | **Claim** | **Location** | **Missing Element** | **Current Citation** | **Suggested Fix** |
|-------|----------|--------------|---------------------|----------------------|-------------------|
| 1 | [Claim] | [Section:pY:lineZ] | AUTHOR/PUBLICATION/DATE/URL | ["Current citation"] | ["Complete citation"] |

[Repeat for all claims with incomplete citations]

---

### Summary

- **Total factual claims:** X
- **Properly cited:** Y
- **Level 1 sources:** A (X%)
- **Level 2 sources:** B (X%)
- **Level 3 sources:** C (X%)
- **Level 4 sources:** D (X%)
- **Uncited factual claims:** Z (X%)
- **Verdict:** PASS (All factual claims properly cited) | FAIL (Z uncited claims found)

---

### Recommendations

[If FAIL, provide specific, actionable recommendations for EACH uncited claim]

1. **Location:** [Section Name], paragraph [X], line [Y]
   - **Claim:** ["Exact claim text"]
   - **Current:** ["Current text without citation"]
   - **Suggested:** ["Text with added citation"]
   - **Source:** [Suggested citation in proper format]
   - **Verification:** [Web search query or URL to verify]

[Repeat for all uncited claims]

---

### Quick Fix Actions

- [ ] Add inline citations for all Z uncited claims
- [ ] Fix X claims with incomplete citation formats
- [ ] Verify all cited claims using: [list of verification searches]
- [ ] Add footnotes section if using footnote-style citations
- [ ] Standardize citation format throughout post

---

### Direct Verification Links

[Provide clickable search links for top uncited claims]
- [Verify Claim 1](https://www.google.com/search?q=[URL-encoded+search+query])
- [Verify Claim 2](https://www.google.com/search?q=[URL-encoded+search+query])
```

```text

---

## Expected Output Format

```text
## Source Verification Report

### Status: FAIL

### Confidence: 100%

---

### Cited Claims (with source quality)

1. **Claim:** "Rust provides memory safety without garbage collection"
   - **Location:** Why Learn Rust section, paragraph 2
   - **Source:** Rust Official Documentation, 2024
   - **Quality:** LEVEL 1

### Uncited Factual Claims (CRITICAL - must be fixed)

1. **Claim:** "Rust has consistently been voted the most loved programming language in the Stack Overflow Developer Survey for several years running"
   - **Location:** Introduction, sentence 1
   - **Type:** statistic
   - **Suggested Source:** Stack Overflow Developer Survey 2023, Stack Overflow Inc.

2. **Claim:** "This catches many bugs before your code even runs, saving you countless hours of debugging"
   - **Location:** Why Learn Rust section, paragraph 3
   - **Type:** technical
   - **Suggested Source:** Rust official documentation on borrow checker

---

### Summary

- Total factual claims: 15
- Properly cited: 1
- Level 1 sources: 1
- Level 2 sources: 0
- Level 3 sources: 0
- Level 4 sources: 0
- Uncited factual claims: 14

### Verdict

**FAIL** - 14 uncited factual claims found. Each must have a proper citation.

---

### Recommendations

1. Add inline citations for all statistical claims referencing Stack Overflow Developer Surveys
2. Add inline citations for all technical claims referencing Rust official documentation
3. Use footnotes for repeated sources to avoid clutter
4. Format citations consistently: Author, Publication, Date, URL
```

---

## Notes

- This is a BLOCKING check - the post CANNOT be published with uncited factual claims
- If a claim states a fact (not opinion), it REQUIRES a source
- When in doubt between fact and opinion, treat as FACT and require citation
- Common knowledge (e.g., "the Earth orbits the Sun") does not need citation
- Company claims about their own products still require sources
- Code examples and their direct explanations do not require sources
- Personal experiences should be clearly marked as opinion, not fact
