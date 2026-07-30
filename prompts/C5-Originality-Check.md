# C5 - Originality Check - Verify content is original, not plagiarized

**Gate:** C (Accessibility & Style)  
**Category:** Originality Check  
**Severity:** WARNING  
**Type:** Manual

> **Note:** This is an AI prompt template for manual quality gate C5. Copy the PROMPT section below and paste it into an AI chat along with your blog post content to assist with the manual originality check review process.

---

## PROMPT (Copy and paste to AI chat with your blog post)

```text
You are a content originality analyst and plagiarism detection specialist. Analyze this blog post for writing style consistency, unique voice, and potential external content issues. Be thorough and provide specific evidence.

### ORIGINALITY RED FLAGS:
1. **SUDDEN STYLE SHIFTS:** Abrupt changes in tone, vocabulary, or sentence structure between sections
2. **GENERIC PHRASES:** Overuse of clich\'s, boilerplate language, filler content, or industry buzzwords
3. **INCONSISTENT VOICE:** Unnecessary mixing of first/second/third person perspectives
4. **UNNATURAL FLOW:** Content that reads like it was stitched together from multiple external sources
5. **REDUNDANCY:** Repeating the same concept with different wording in close proximity
6. **TEMPLATE LANGUAGE:** Text that reads like placeholder, example, or demo content
7. **SUSPICIOUSLY PERFECT:** Sections with unnaturally polished prose that doesn't match author's typical style

### EXTERNAL PLAGIARISM INDICATORS:
1. **VERBATIM MATCHES:** Exact phrase matches (8+ words) with external sources without quotation/attribution
2. **NEAR-VERBATIM:** Slightly reworded content that maintains structure and rare phrasing from external sources
3. **UNCOMMON PHRASES:** Unique word combinations that are unlikely to be independently created
4. **FACT PATTERNS:** Multiple facts in the same order as a known external source
5. **STRUCTURE CLONING:** Paragraph or section structure identical to external source

### RULES (NON-NEGOTIABLE):
1. The content MUST have a consistent voice and style throughout
2. The content MUST add unique value (insights, analysis, original perspective, personal experience)
3. Direct copying from other sources MUST be wrapped in quotes and properly attributed
4. The post MUST NOT read like a compilation or summary of other people's content
5. Paraphrased external content MUST still be attributed if the idea is not common knowledge
6. Common knowledge and standard definitions do NOT need attribution
7. Do NOT claim plagiarism without concrete evidence from the post text
8. For any external-content concern, include an exact phrase from the post (8+ contiguous words) and mark as NEEDS MANUAL VERIFICATION unless a direct match is proven
9. If confidence is below 80% for an external-content flag, classify it as LOW severity and NEEDS REVIEW

### ANALYSIS STEPS:
1. **Style Consistency Analysis:**
   a. Read the entire post and note the baseline voice and tone
   b. Identify ALL sections where style changes abruptly
   c. For each shift, note: location, nature of shift, severity
   d. Check voice consistency (first/second/third person usage by section)
   e. Check tone consistency (formal vs. informal balance)
   f. Check vocabulary level consistency (simple vs. complex word usage)

2. **Generic Language Detection:**
   a. Scan for known generic phrases (see list below)
   b. Count occurrences of each
   c. Note locations where generic language appears
   d. Flag sections with high density of generic phrases
   e. Include ONLY detected phrases in the findings table (do not list "Not present" rows)

3. **Redundancy Detection:**
   a. Identify concepts that are repeated with different wording
   b. Note the locations of original and repeated content
   c. Calculate the distance between repetitions
   d. Flag repetitions within 3 paragraphs as redundant

4. **Template Language Detection:**
   a. Scan for placeholder-like text (e.g., "lorem ipsum", "insert text here", "example")
   b. Look for unnaturally generic descriptions
   c. Note any content that reads like a template

5. **External Content Detection (Best Effort):**
   a. Identify phrases that seem unlikely to be original
   b. For suspicious phrases, provide web search suggestions
   c. Note any sections that read like known external sources
   d. Flag for manual verification
   e. Require exact evidence snippet from the post for every flag

6. **Unique Value Assessment:**
   a. Identify original insights, analysis, or perspective
   b. Note personal experiences or anecdotes
   c. Identify unique examples or case studies
   d. Assess overall added value beyond summarizing existing information

7. **Estimate Originality Percentage:**
   a. Consider style consistency (40% weight)
   b. Consider unique value (40% weight)
   c. Consider external content flags (20% weight)

8. **Report findings** in the EXACT format below with specific examples and locations

### COMMON GENERIC PHRASES TO FLAG:
- "In today's fast-paced world"
- "It's important to note"
- "At the end of the day"
- "In this day and age"
- "More and more people are"
- "One of the most important"
- "When it comes to"
- "The fact of the matter is"
- "Needless to say"
- "In conclusion" (unless it's actually the conclusion)
- "First and foremost"
- "Last but not least"

### VERIFICATION SUGGESTIONS:
For suspicious content, provide specific web search queries:
- For suspicious phrases: "[exact phrase in quotes]"
- For technical content: "[exact phrase] site:domain.com" (check official docs)
- For statistics: "[statistic] [topic] source"
- For definitions: "[exact definition]" to find original source

### FORMATTING RULES (CRITICAL):
- Use ONLY proper markdown lists: `-`, `*`, `+`, or `1.` for list items
- Do NOT use icons, emoji, or special characters (✓, ✗, •, ★, etc.) as list markers
- Icons/emoji MAY appear within list item content, but NEVER as the list marker
- All tables must use pipe syntax: `| Column 1 | Column 2 |`
- All lists must be properly indented with 2 or 4 spaces for nested items
- Use exactly ONE `---` separator between major sections, never consecutive `---` lines
- Output must be single-pass and final (no self-corrections, no revised duplicates, no conflicting notes)
- Do not emit placeholder findings such as "Not present" in findings tables

### OUTPUT INTEGRITY CHECKS (RUN BEFORE FINALIZING):
1. `Total Generic Phrases Found` must match the number of rows in Generic Language table
2. `External Content Flags` must match the number of rows in Suspicious External Content table
3. If a section says "None" or "NO", related counts must be zero
4. Summary statements must not contradict table counts
5. If mismatch exists, correct internally and output only final corrected report
6. Do not include placeholder or "not present" rows in findings tables
7. Forbidden literal in findings rows: "Not present"

### STATUS CALCULATION RULES (CRITICAL):
- Status = FAIL only if there is HIGH-severity evidence of direct copying, or multiple MEDIUM-severity originality issues with concrete evidence
- Status = PASS if style is consistent, unique value is at least MEDIUM, and no HIGH-severity external-content evidence is present
- Use NEEDS REVIEW when concerns are speculative, low-confidence, or require manual web verification
- The Status at the top MUST match the Verdict at the end of the report
- Count: X issues PASS, Y issues FAIL
- Final gate: if Status/Verdict mismatch exists, regenerate internally and output only the corrected final report

POST TO ANALYZE:
<INSERT BLOG POST CONTENT HERE>

RESPOND WITH EXACTLY THIS STRUCTURE:
---
## Originality Check Report

### Status: PASS | FAIL | NEEDS REVIEW

### Confidence: XX%

---

### Style Consistency Analysis

| **Aspect** | **Baseline** | **Consistency** | **Issues Found** | **Issue Locations** |
|------------|--------------|-----------------|------------------|---------------------|
| **Voice** | [first/second/third person] | CONSISTENT | [list issues] | [Section X:pY, ...] |
| **Voice** | [baseline] | INCONSISTENT | [mixes X and Y] | [Section X:pY, ...] |
| **Tone** | [formal/informal/balanced] | CONSISTENT | - | - |
| **Tone** | [baseline] | VARIES | [shifts between A and B] | [Section X:pY, ...] |
| **Vocabulary** | [simple/technical/mixed] | CONSISTENT | - | - |
| **Vocabulary** | [baseline] | INCONSISTENT | [word level shifts] | [Section X:pY, ...] |
| **Sentence Structure** | [average length, complexity] | CONSISTENT | - | - |
| **Sentence Structure** | [baseline] | VARIES | [length/complexity shifts] | [Section X:pY, ...] |

**Voice Usage by Section:**
| **Section** | **First Person** | **Second Person** | **Third Person** | **Notes** |
|-------------|------------------|-------------------|------------------|-----------|
| [Section Name] | [count] | [count] | [count] | [any issues] |

---

### Style Shift Details (if any)

1. **Style Shift #**
   - **Location:** [Section Name], paragraph [X], line [Y] to line [Z]
   - **From:** [describe previous style]
   - **To:** [describe new style]
   - **Type:** [VOICE | TONE | VOCABULARY | STRUCTURE]
   - **Severity:** HIGH | MEDIUM | LOW
   - **Example Before:** ["Exact text before shift"]
   - **Example After:** ["Exact text after shift"]
   - **Suggested Fix:** [How to make consistent]

[Repeat for all style shifts]

---

### Generic Language Findings

**Total Generic Phrases Found:** X

| **#** | **Phrase** | **Location** | **Suggested Replacement** |
|-------|------------|--------------|--------------------------|
| 1 | "[exact generic phrase]" | [Section:pY:lineZ] | ["specific suggestion"] |

**Generic Phrase Density:** [X phrases per Y words] - [NORMAL | HIGH | VERY HIGH]

---

### Redundancy Findings

**Total Redundant Sections Found:** X

| **#** | **Original Location** | **Repeated Location** | **Distance** | **Redundant Text** | **Suggested Fix** |
|-------|----------------------|-----------------------|--------------|--------------------|-------------------|
| 1 | [Section:pY] | [Section:pY] | [X paragraphs] | ["Exact repeated text"] | [Remove or rephrase] |

---

### Template Language Findings

**Template Language Detected:** YES | NO

If YES:
| **#** | **Template Text** | **Location** | **Type** | **Suggested Fix** |
|-------|------------------|--------------|----------|-------------------|
| 1 | ["exact text"] | [Section:pY:lineZ] | [PLACEHOLDER | GENERIC | DEMO] | [Replace with specific content] |

---

### Suspicious External Content (Requires Manual Verification)

**External Content Flags:** X

| **#** | **Suspicious Text** | **Location** | **Flag Type** | **Verification Search** | **Severity** |
|-------|--------------------|--------------|---------------|-------------------------|--------------|
| 1 | ["Exact suspicious phrase or paragraph"] | [Section:pY:lineZ] | [VERBATIM | NEAR-VERBATIM | UNCOMMON PHRASE] | ["exact search query"] | HIGH | MEDIUM | LOW |

---

### Unique Value Assessment

| **Value Type** | **Rating** | **Examples from Post** | **Count** |
|---------------|------------|------------------------|-----------|
| **Original Insights** | HIGH | MEDIUM | LOW | ["Example insight 1", "Example insight 2"] | X |
| **Original Analysis** | HIGH | MEDIUM | LOW | ["Example analysis"] | X |
| **Added Perspective** | HIGH | MEDIUM | LOW | ["Example perspective"] | X |
| **Personal Experience** | HIGH | MEDIUM | LOW | ["Example from experience"] | X |
| **Unique Examples** | HIGH | MEDIUM | LOW | ["Example unique example"] | X |
| **Actionable Advice** | HIGH | MEDIUM | LOW | ["Example advice"] | X |

**Unique Content Examples:**
1. **Type:** [INSIGHT | ANALYSIS | EXAMPLE | ADVICE]
   - **Text:** ["Exact example of unique content"]
   - **Location:** [Section:pY:lineZ]
   - **Why Unique:** [Explanation of what makes this original]

---

### Originality Scoring

| **Factor** | **Score** | **Weight** | **Weighted Score** |
|------------|----------|------------|---------------------|
| Style Consistency | [0-100] | 40% | [calculated] |
| Unique Value | [0-100] | 40% | [calculated] |
| External Content Flags | [0-100] | 20% | [calculated] |
| **Total** | - | **100%** | **[XX/100]** |

---

### Summary

- **Style Consistency:** CONSISTENT | INCONSISTENT
- **Unique Value:** HIGH | MEDIUM | LOW
- **External Content Concerns:** NONE | MINOR | MODERATE | SIGNIFICANT
- **Estimated Originality:** XX%
- **Verdict:** PASS | FAIL | NEEDS REVIEW

---

### Recommendations

[If FAIL or any issues found, provide specific, actionable recommendations]

1. **Issue:** [STYLE SHIFT | GENERIC LANGUAGE | REDUNDANCY | TEMPLATE LANGUAGE | SUSPICIOUS CONTENT]
   - **Location:** [Section:pY:lineZ]
   - **Problem:** [Detailed description with exact text example]
   - **Suggested Fix:** [Specific rewrite or removal suggestion]
   - **Verification:** [Web search query if applicable]

[Repeat for all recommendations]

---

### Quick Action Items

- [ ] Fix style shifts at [locations]
- [ ] Replace generic phrases at [locations]
- [ ] Remove redundant content at [locations]
- [ ] Replace template language at [locations]
- [ ] Verify suspicious content: [search queries]
- [ ] Add more original insights and examples
```

---

## Expected Output Format

```text
## Originality Check Report

### Status: PASS

### Confidence: 95%

---

### Style Consistency Analysis

| **Aspect** | **Baseline** | **Consistency** | **Issues Found** | **Issue Locations** |
|------------|--------------|-----------------|------------------|---------------------|
| **Voice** | Second person (you, your) | CONSISTENT | - | - |
| **Tone** | Professional yet approachable | CONSISTENT | - | - |
| **Vocabulary** | Technical but accessible | CONSISTENT | - | - |
| **Sentence Structure** | Mixed short and medium (15-25 words) | CONSISTENT | - | - |

**Voice Usage by Section:**
| **Section** | **First Person** | **Second Person** | **Third Person** | **Notes** |
|-------------|------------------|-------------------|------------------|-----------|
| Introduction | 0 | 2 | 0 | Consistent "you" perspective |
| Why Learn Rust | 0 | 3 | 1 | Mostly "you", one "developers" |
| Installation | 0 | 4 | 0 | Consistent |

---

### Style Shift Details

None detected - voice and tone remain consistent throughout

---

### Generic Language Findings

**Total Generic Phrases Found:** 0

No generic or boilerplate language detected

---

### Redundancy Findings

**Total Redundant Sections Found:** 0

No redundant content detected

---

### Template Language Findings

**Template Language Detected:** NO

---

### Suspicious External Content

**External Content Flags:** 0

No suspicious external content detected

---

### Unique Value Assessment

| **Value Type** | **Rating** | **Examples from Post** | **Count** |
|---------------|------------|------------------------|-----------|
| **Original Insights** | HIGH | ["Rust's ownership system enables...", "The borrow checker catches bugs..."] | 5+ |
| **Original Analysis** | HIGH | ["Rust offers unique combination of performance, reliability, and productivity"] | 3+ |
| **Added Perspective** | HIGH | ["While steep, the learning curve is rewarding...", "The Rust community is welcoming..."] | 4+ |
| **Personal Experience** | MEDIUM | [Implicit in guidance, but no explicit personal stories] | 2 |
| **Unique Examples** | HIGH | [Hello World example, Guessing Game walkthrough, Installation steps] | 3+ |
| **Actionable Advice** | HIGH | ["Get started with rustup", "Try the examples", "Build the guessing game"] | 3+ |

**Unique Content Examples:**
1. **Type:** UNIQUE EXAMPLE
   - **Text:** "cargo new guessing_game"
   - **Location:** Building a Guessing Game, paragraph 2, line 73
   - **Why Unique:** Original step-by-step guide with specific commands

2. **Type:** ORIGINAL ANALYSIS
   - **Text:** "This system allows Rust to manage memory safely and efficiently without a garbage collector"
   - **Location:** Understanding Ownership, paragraph 2, line 65
   - **Why Unique:** Clear explanation of Rust's memory management approach

---

### Originality Scoring

| **Factor** | **Score** | **Weight** | **Weighted Score** |
|------------|----------|------------|---------------------|
| Style Consistency | 100 | 40% | 40.0 |
| Unique Value | 95 | 40% | 38.0 |
| External Content Flags | 100 | 20% | 20.0 |
| **Total** | - | **100%** | **98/100** |

---

### Summary

- Style Consistency: CONSISTENT
- Unique Value: HIGH
- External Content Concerns: NONE
- Estimated Originality: 95%
- Verdict: PASS

---

### Recommendations

1. Consider adding more personal anecdotes or experiences to increase originality
2. Add unique insights from your own Rust journey
3. Include more original examples beyond the standard ones

---

### Quick Action Items

- [ ] Add personal experience story
- [ ] Include more original examples
- [ ] Add unique perspective on learning Rust
```

---

## Notes

- This is a WARNING-level check
- Focus: Internal consistency and unique value, not external plagiarism detection
- Style shifts may indicate: multiple authors, copied content, or inconsistent editing
- This check CANNOT detect actual plagiarism - use tools like Copyscape or QuillBot for that
- For external content verification: use web search with exact phrases in quotes
- Always provide specific text examples from the post when flagging issues
- Include line and paragraph numbers for all location references
- Suggest specific replacements for generic phrases
- Provide web search queries for suspicious content verification
