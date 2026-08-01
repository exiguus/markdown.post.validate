# C7 - Writing Quality - Assess Tone, Readability, and Style

**Gate:** C (Accessibility & Style)
**Category:** Writing Quality
**Severity:** WARNING
**Type:** Manual

> **Note:** This is an AI prompt template for manual quality gate C7. Copy the PROMPT section below and paste it into an AI chat along with your blog post content to assist with the manual writing quality review process.

---

## PROMPT (Copy and Paste to AI Chat with Your Blog Post)

```text
You are a professional copy editor and writing coach with expertise in technical communication. Analyze this blog post for writing quality, tone, readability, style consistency, and technical execution.
Be thorough and provide specific examples with exact locations.

### MEASURABLE CRITERIA:

**Content Profile Detection (apply before scoring):**
- TUTORIAL/HOW-TO (step-by-step, commands, code walkthroughs)
- EXPLAINER/REFERENCE (concept-heavy technical explanation)
- OPINION/EDITORIAL (argument or perspective-driven)

Use profile-aware thresholds where appropriate. Do not penalize concise tutorial paragraphs as strongly as long-form essays.

**Readability Metrics:**
- IDEAL sentence length: 15-25 words average
- MAX sentence length: 35 words (flag sentences longer than this)
- IDEAL paragraph length: 3-6 sentences, 75-150 words
- Target reading level: 8th-12th grade for technical content, 6th-8th for general audience
- MAX paragraph length: 200 words (flag longer paragraphs)

**Profile-aware paragraph guidance:**
- Tutorial/How-to: 1-5 sentences, 30-140 words (short instructional blocks are acceptable)
- Explainer/Reference: 2-6 sentences, 60-180 words
- Opinion/Editorial: 3-7 sentences, 75-220 words

**Style Rules:**
- Voice: Active voice preferred over passive (passive should be < 10% of sentences)
- Terminology: Consistent use of terms (don't switch between synonyms unnecessarily)
- Capitalization: Consistent heading style (Title Case for headings, Sentence case for subheadings)
- Punctuation: Oxford comma required, consistent quote style (double quotes for prose, single for nested)
- Numbers: Spell out zero through nine, use numerals for 10 and above
- Number formatting exceptions (do NOT flag):
   - Version numbers, ranges, commands, CLI arguments, code literals, measurements, and technical identifiers
   - Examples: "Python 3.12", "1-100", "RFC 7231", "rustup-init", "v2"
- Contractions: Use sparingly in technical content, avoid in formal contexts

**Tone Guidelines:**
- Professional yet approachable
- Confident but not arrogant or condescending
- Engaging without being sensational or clickbaity
- Appropriate for target audience (assume technical audience unless specified)
- Avoid: hyperbole, absolutes (always, never), overly emotional language

**FLOW CHECKLIST:**
- Each paragraph has exactly one main idea
- Clear topic sentence at the beginning of each paragraph
- Logical progression between paragraphs (old info to new info)
- Smooth transitions between sections
- No abrupt topic changes without signposting
- Conclusion follows naturally from body content
- Headings and subheadings create clear structure

### ANALYSIS STEPS:

**Phase 1: Structural Analysis**
1. Count total words, sentences, and paragraphs
2. Identify all sections and their lengths
3. Analyze paragraph structure:
   a. For each paragraph, identify the main idea
   b. Check if topic sentence is clear and at the beginning
   c. Verify logical flow within paragraph
   d. Flag paragraphs with multiple main ideas
   e. Flag paragraphs without clear topic sentences
4. Check section transitions:
   a. Note all section headings
   b. Evaluate transition smoothness between sections
   c. Flag abrupt changes without proper signposting

**Phase 2: Sentence-Level Analysis**
1. Extract ALL sentences from the post
2. For each sentence:
   a. Count words (flag if > 35)
   b. Identify voice (active/passive)
   c. Check for clarity and conciseness
   d. Flag convoluted or confusing sentences
   e. Note location (section, paragraph, sentence number)
3. Calculate statistics:
   a. Average sentence length
   b. Percentage of sentences > 35 words
   c. Active vs. passive voice ratio

**Phase 3: Paragraph-Level Analysis**
1. For each paragraph:
   a. Count words (flag if > 200)
   b. Count sentences (flag if < 2 or > 6)
   c. Calculate average sentence length
   d. Identify main idea
   e. Check for topic sentence
   f. Evaluate internal flow
2. Calculate statistics:
   a. Average paragraph length
   b. Percentage of paragraphs > 200 words
   c. Percentage of paragraphs with single main idea

**Phase 4: Style Consistency**
1. **Voice Consistency:**
   a. Count active vs. passive sentences
   b. Calculate passive percentage
   c. Flag passive sentences with location and suggestion
2. **Terminology Consistency:**
   a. Build glossary of all technical terms used
   b. Check for synonym switching (e.g., "function" vs. "method" vs. "procedure")
   c. Flag inconsistent usage with location
3. **Capitalization Consistency:**
   a. Check all headings for consistent style (Title Case vs. Sentence case)
   b. Flag inconsistencies with location
4. **Number Formatting:**
   a. Check all numbers for consistent formatting
   b. Flag violations (e.g., "5" instead of "five" for zero-nine)
5. **Punctuation:**
   a. Check for Oxford comma usage
   b. Check quote style consistency
   c. Flag punctuation errors with location

**Phase 5: Tone and Appropriateness**
1. Evaluate overall tone consistency
2. Check for appropriateness for technical audience
3. Flag tone shifts with location and example
4. Check for hyperbole, absolutes, emotional language
5. Evaluate professionalism level

**Phase 6: Error Detection**
1. Spelling errors:
   a. Identify all spelling mistakes
   b. Note exact word and location
   c. Provide correction
2. Grammar errors:
   a. Identify all grammar mistakes
   b. Note exact text and location
   c. Provide correction
3. Punctuation errors:
   a. Identify all punctuation mistakes
   b. Note exact location
   c. Provide correction

**Phase 7: Specific Improvement Opportunities**
1. For each issue found, provide:
   - Exact location (section, paragraph, sentence/line number)
   - Exact problematic text
   - Specific issue description
   - Suggested fix
   - Severity (HIGH/MEDIUM/LOW)

**Phase 8: Scoring**
1. Assign scores for each category (0-100)
2. Calculate overall score
3. Determine PASS/FAIL based on thresholds

**Phase 9: Report findings** in the EXACT format below

### SCORING THRESHOLDS:
- **Readability (25% weight):** Score based on sentence/paragraph metrics
  - 90-100: All metrics within ideal ranges
  - 70-89: Minor deviations from ideal
  - 50-69: Several metrics outside ideal ranges
  - 0-49: Major readability issues

- **Style Consistency (25% weight):** Score based on voice, terminology, capitalization, numbers, punctuation
  - 90-100: All style rules followed consistently
  - 70-89: Minor style inconsistencies
  - 50-69: Several style issues
  - 0-49: Major style inconsistencies

- **Tone (20% weight):** Score based on professionalism, appropriateness, consistency
  - 90-100: Professional, appropriate, consistent tone
  - 70-89: Minor tone issues
  - 50-69: Noticeable tone problems
  - 0-49: Unprofessional or inappropriate tone

- **Flow (20% weight):** Score based on paragraph structure, transitions, logical progression
  - 90-100: Excellent flow, smooth transitions
  - 70-89: Good flow with minor issues
  - 50-69: Flow problems that affect readability
  - 0-49: Major flow issues that confuse reader

- **Technical Accuracy (10% weight):** Score based on spelling, grammar, punctuation
  - 100: No errors
  - 80-99: Minor errors (1-2)
  - 60-79: Several errors (3-5)
  - 40-59: Many errors (6-10)
  - 0-39: Numerous errors (>10)

- **Overall PASS:** Score >= 85
- **Overall FAIL:** Score < 85

### FORMATTING RULES (CRITICAL):
- Use ONLY proper markdown lists: `-`, `*`, `+`, or `1.` for list items
- Do NOT use icons, emoji, or special characters (✓, ✗, •, ★, etc.) as list markers
- Icons/emoji MAY appear within list item content, but NEVER as the list marker
- All tables must use pipe syntax: `| Column 1 | Column 2 |`
- All lists must be properly indented with 2 or 4 spaces for nested items
- Use exactly ONE `---` separator between major sections, never consecutive `---` lines
- Do NOT duplicate sections or output revised/corrected copies later in the report

### OUTPUT INTEGRITY CHECKS (RUN BEFORE FINALIZING):
1. Number-formatting issues must only include true violations (respect all documented exceptions)
2. Counts in quick-fix checklist must match issue counts in prior sections
3. Category weighted scores must sum to Overall score
4. Include an explicit final verdict line in Summary and ensure it matches top Status
5. If mismatch exists, correct internally and output only one final report

### STATUS CALCULATION RULES (CRITICAL):
- If Overall Score >= 85 AND all categories score >= 70: Status = PASS
- If Overall Score < 85 OR any category scores < 70: Status = FAIL
- Apply profile-aware adjustments before final status (especially for paragraph length in tutorials)
- The Status at the top MUST match the Verdict at the end of the report
- Count: X categories PASS, Y categories FAIL
- Final gate: if Status/Verdict mismatch exists, regenerate internally and output only the corrected final report

POST TO ANALYZE:
<INSERT BLOG POST CONTENT HERE>

RESPOND WITH EXACTLY THIS STRUCTURE:
---
## Writing Quality Report

### Status: PASS | FAIL

### Confidence: XX%

### Overall Score: XX/100

---

### Document Statistics

| **Metric** | **Value** | **Target** | **Status** | **Notes** |
|------------|-----------|------------|------------|-----------|
| Total words | X | - | - | - |
| Total sentences | X | - | - | - |
| Total paragraphs | X | - | - | - |
| Total sections | X | - | - | - |
| Avg words per section | X | 300-600 | PASS/WARN/FAIL | [notes] |

---

### Readability Analysis

| **Metric** | **Value** | **Target** | **Status** | **Flagged Items** | **Flagged Locations** |
|------------|-----------|------------|------------|------------------|-----------------------|
| Avg sentence length | X words | 15-25 words | PASS/WARN/FAIL | X sentences | [Section:pY:sZ, ...] |
| Long sentences (>35 words) | X | < 5% | PASS/WARN/FAIL | X sentences | [Section:pY:sZ, ...] |
| Avg paragraph length | X words | 75-150 words | PASS/WARN/FAIL | X paragraphs | [Section:pY, ...] |
| Long paragraphs (>200 words) | X | 0 | PASS/WARN/FAIL | X paragraphs | [Section:pY, ...] |
| Estimated reading level | Grade X | [8-12 for technical] | PASS/WARN/FAIL | - | - |

**Long Sentences Detail:**
1. **Sentence:** ["Exact sentence text"]
   - **Length:** X words
   - **Location:** [Section Name], paragraph [Y], sentence [Z]
   - **Issue:** [Describe why it's too long]
   - **Suggested Fix:** [How to shorten or split]

[Repeat for all sentences > 35 words]

**Long Paragraphs Detail:**
1. **Paragraph:** [First 100 characters...]
   - **Length:** X words, Y sentences
   - **Location:** [Section Name], paragraph [Y]
   - **Issue:** [Describe why it's too long]
   - **Suggested Fix:** [How to split]

[Repeat for all paragraphs > 200 words]

---

### Style Consistency Analysis

| **Aspect** | **Value** | **Target** | **Status** | **Issues Found** | **Issue Locations** |
|------------|-----------|------------|------------|------------------|--------------------|
| **Voice: Active** | X% | > 90% | PASS/WARN/FAIL | X passive sentences | [Section:pY:sZ, ...] |
| **Voice: Passive** | X% | < 10% | PASS/WARN/FAIL | - | - |
| **Terminology** | CONSISTENT/INCONSISTENT | CONSISTENT | PASS/FAIL | X instances | [list] |
| **Headings** | CONSISTENT/INCONSISTENT | Title Case | PASS/FAIL | X issues | [list] |
| **Numbers** | CONSISTENT/INCONSISTENT | Spell 0-9 | PASS/FAIL | X issues | [list] |
| **Punctuation** | CORRECT/ISSUES FOUND | Correct | PASS/FAIL | X issues | [list] |

**Passive Voice Instances:**
1. **Sentence:** ["Exact passive sentence"]
   - **Location:** [Section:pY:sZ]
   - **Suggested Active Rewrite:** ["Active version"]

[Repeat for all passive sentences]

**Terminology Inconsistencies:**
1. **Issue:** [Term1] used in [location], [Term2] used in [location] for same concept
   - **Suggested Fix:** Use [preferred term] consistently

[Repeat for all terminology inconsistencies]

**Capitalization Issues:**
1. **Heading:** ["Exact heading text"]
   - **Location:** [Section name]
   - **Issue:** [Should be Title Case | Should be Sentence case]
   - **Suggested Fix:** ["Corrected heading"]

[Repeat for all capitalization issues]

**Number Formatting Issues:**
1. **Text:** ["Exact text with number"]
   - **Location:** [Section:pY:sZ]
   - **Issue:** [Should be spelled out | Should be numeral]
   - **Suggested Fix:** [Corrected text]

[Repeat for all number formatting issues]

**Punctuation Issues:**
1. **Issue:** [Missing Oxford comma | Inconsistent quotes | Other]
   - **Text:** ["Exact text with issue"]
   - **Location:** [Section:pY:sZ]
   - **Suggested Fix:** [Corrected text]

[Repeat for all punctuation issues]

---

### Tone Assessment

| **Aspect** | **Rating** | **Details** | **Example Locations** |
|------------|------------|-------------|----------------------|
| **Consistency** | CONSISTENT/VARIES | [Assessment] | [Section:pY, ...] |
| **Appropriateness** | APPROPRIATE/NEEDS ADJUSTMENT | [Assessment] | [Section:pY, ...] |
| **Professionalism** | HIGH/MEDIUM/LOW | [Assessment] | [Section:pY, ...] |
| **Engagement** | HIGH/MEDIUM/LOW | [Assessment] | [Section:pY, ...] |

**Tone Issues:**
1. **Issue:** [TOO FORMAL | TOO CASUAL | INCONSISTENT | INAPPROPRIATE]
   - **Text:** ["Exact text example"]
   - **Location:** [Section:pY:sZ]
   - **Suggested Fix:** [How to adjust tone]

[Repeat for all tone issues]

---

### Flow Assessment

| **Aspect** | **Rating** | **Details** | **Problem Locations** |
|------------|------------|-------------|----------------------|
| **Paragraph Structure** | GOOD/NEEDS WORK | [Assessment] | [Section:pY, ...] |
| **Transitions** | SMOOTH/ABRUPT | [Assessment] | [Section:pY, ...] |
| **Logical Progression** | CLEAR/CONFUSING | [Assessment] | [Section:pY, ...] |

**Paragraph Structure Issues:**
1. **Paragraph:** [First 100 characters...]
   - **Location:** [Section:pY]
   - **Issue:** [NO TOPIC SENTENCE | MULTIPLE MAIN IDEAS | POOR FLOW]
   - **Suggested Fix:** [Specific suggestion]

[Repeat for all paragraph structure issues]

**Transition Issues:**
1. **Between:** [Section A] and [Section B]
   - **Issue:** [ABRUPT | MISSING | WEAK]
   - **Suggested Fix:** [Add transition sentence or improve existing]

[Repeat for all transition issues]

**Logical Progression Issues:**
1. **Issue:** [CONFUSING SEQUENCE | MISSING CONNECTION]
   - **Location:** [Section:pY to Section:pZ]
   - **Suggested Fix:** [How to improve flow]

[Repeat for all logical progression issues]

---

### Error Analysis

| **Error Type** | **Count** | **Target** | **Status** | **Severity** |
|---------------|-----------|------------|------------|--------------|
| **Spelling** | X | 0 | PASS/FAIL | HIGH/MEDIUM/LOW |
| **Grammar** | X | 0 | PASS/FAIL | HIGH/MEDIUM/LOW |
| **Punctuation** | X | 0 | PASS/FAIL | HIGH/MEDIUM/LOW |

**Spelling Errors:**
1. **Word:** ["misspelled word"]
   - **Location:** [Section:pY:sZ]
   - **Correction:** [correct spelling]
   - **Severity:** HIGH | MEDIUM | LOW

[Repeat for up to 10 spelling errors]

**Grammar Errors:**
1. **Issue:** [Description of grammar error]
   - **Text:** ["Exact text with error"]
   - **Location:** [Section:pY:sZ]
   - **Correction:** [Corrected text]
   - **Severity:** HIGH | MEDIUM | LOW

[Repeat for up to 10 grammar errors]

**Punctuation Errors:**
1. **Issue:** [Description of punctuation error]
   - **Text:** ["Exact text with error"]
   - **Location:** [Section:pY:sZ]
   - **Correction:** [Corrected text]
   - **Severity:** HIGH | MEDIUM | LOW

[Repeat for up to 10 punctuation errors]

---

### Category Scores

| **Category** | **Score** | **Weight** | **Weighted Score** | **Issues** |
|--------------|----------|------------|---------------------|-----------|
| **Readability** | XX | 25% | XX.X | [list main issues] |
| **Style Consistency** | XX | 25% | XX.X | [list main issues] |
| **Tone** | XX | 20% | XX.X | [list main issues] |
| **Flow** | XX | 20% | XX.X | [list main issues] |
| **Technical Accuracy** | XX | 10% | XX.X | [list main issues] |
| **Overall** | **XX** | **100%** | **XX.X/100** | - |

---

### Summary

- **Categories Passing:** X
- **Categories Failing:** Y
- **Verdict:** PASS | FAIL

---
### Suggestions

[List specific, actionable suggestions for improvement]

1. **Location:** [Section:pY:sZ]
   - **Issue:** [Brief description]
   - **Current:** ["Exact current text"]
   - **Suggested:** ["Exact suggested text"]
   - **Rationale:** [Why this improves quality]
   - **Severity:** HIGH | MEDIUM | LOW

[Repeat for all suggestions, prioritized by severity]

---

### Quick Fix Summary

- [ ] Fix X long sentences (>35 words) at: [locations]
- [ ] Split X long paragraphs (>200 words) at: [locations]
- [ ] Convert X passive sentences to active at: [locations]
- [ ] Fix X terminology inconsistencies at: [locations]
- [ ] Fix X capitalization issues at: [locations]
- [ ] Fix X number formatting issues at: [locations]
- [ ] Fix X punctuation errors at: [locations]
- [ ] Fix X spelling errors at: [locations]
- [ ] Fix X grammar errors at: [locations]
- [ ] Fix X tone issues at: [locations]
- [ ] Fix X flow issues at: [locations]
```

---

## Expected Output Format

```text
## Writing Quality Report

### Status: PASS

### Confidence: 95%

### Overall Score: 92/100

---

### Document Statistics

| **Metric** | **Value** | **Target** | **Status** | **Notes** |
|------------|-----------|------------|------------|-----------|
| Total words | 1111 | - | - | - |
| Total sentences | 55 | - | - | - |
| Total paragraphs | 14 | - | - | - |
| Total sections | 8 | - | - | - |
| Avg words per section | 139 | 300-600 | PASS | Slightly short but acceptable |

---

### Readability Analysis

| **Metric** | **Value** | **Target** | **Status** | **Flagged Items** | **Flagged Locations** |
|------------|-----------|------------|------------|------------------|-----------------------|
| Avg sentence length | 20 words | 15-25 words | PASS | 0 sentences | - |
| Long sentences (>35 words) | 0 | < 5% | PASS | 0 sentences | - |
| Avg paragraph length | 80 words | 75-150 words | PASS | 0 paragraphs | - |
| Long paragraphs (>200 words) | 0 | 0 | PASS | 0 paragraphs | - |
| Estimated reading level | Grade 8 | 8-12 | PASS | - | - |

---

### Style Consistency Analysis

| **Aspect** | **Value** | **Target** | **Status** | **Issues Found** | **Issue Locations** |
|------------|-----------|------------|------------|------------------|--------------------|
| Voice: Active | 98% | > 90% | PASS | 1 passive sentence | Common Challenges:p1:s1 |
| Voice: Passive | 2% | < 10% | PASS | - | - |
| Terminology | CONSISTENT | CONSISTENT | PASS | 0 instances | - |
| Headings | CONSISTENT | Title Case | PASS | 0 issues | - |
| Numbers | CONSISTENT | Spell 0-9 | PASS | 0 issues | - |
| Punctuation | CORRECT | Correct | PASS | 0 issues | - |

**Passive Voice Instances:**
1. **Sentence:** "Don't be discouraged if you struggle with these concepts at first"
   - **Location:** Common Challenges, paragraph 1, sentence 1
   - **Suggested Active Rewrite:** "These concepts may challenge you at first, but don't be discouraged"

---

### Tone Assessment

| **Aspect** | **Rating** | **Details** | **Example Locations** |
|------------|------------|-------------|----------------------|
| Consistency | CONSISTENT | Professional and approachable throughout | - |
| Appropriateness | APPROPRIATE | Suitable for technical beginners | - |
| Professionalism | HIGH | No casual or unprofessional language | - |
| Engagement | HIGH | Active voice, clear examples | - |

---

### Flow Assessment

| **Aspect** | **Rating** | **Details** | **Problem Locations** |
|------------|------------|-------------|----------------------|
| Paragraph Structure | GOOD | Most paragraphs have clear topic sentences | Common Challenges:p1 |
| Transitions | SMOOTH | Logical flow between sections | - |
| Logical Progression | CLEAR | Each section builds on previous | - |

**Paragraph Structure Issues:**
1. **Paragraph:** "While Rust is powerful, it does have a steep learning curve..."
   - **Location:** Common Challenges, paragraph 1
   - **Issue:** NO CLEAR TOPIC SENTENCE - starts with contrast
   - **Suggested Fix:** Move "While Rust is powerful..." after topic sentence about challenges

---

### Error Analysis

| **Error Type** | **Count** | **Target** | **Status** | **Severity** |
|---------------|-----------|------------|------------|--------------|
| Spelling | 0 | 0 | PASS | - |
| Grammar | 0 | 0 | PASS | - |
| Punctuation | 0 | 0 | PASS | - |

---

### Category Scores

| **Category** | **Score** | **Weight** | **Weighted Score** | **Issues** |
|--------------|----------|------------|---------------------|-----------|
| Readability | 100 | 25% | 25.0 | None |
| Style Consistency | 95 | 25% | 23.8 | 1 passive sentence |
| Tone | 100 | 20% | 20.0 | None |
| Flow | 95 | 20% | 19.0 | 1 paragraph structure issue |
| Technical Accuracy | 100 | 10% | 10.0 | None |
| **Overall** | **98** | **100%** | **97.8/100** | - |

---

### Suggestions

1. **Location:** Common Challenges, paragraph 1, sentence 1
   - **Issue:** Passive voice usage
   - **Current:** "Don't be discouraged if you struggle with these concepts at first"
   - **Suggested:** "These concepts may challenge you at first, but don't be discouraged"
   - **Rationale:** Active voice improves clarity and engagement
   - **Severity:** LOW

2. **Location:** Common Challenges, paragraph 1
   - **Issue:** No clear topic sentence
   - **Current:** "While Rust is powerful, it does have a steep learning curve..."
   - **Suggested:** "Common challenges include understanding ownership. While Rust is powerful, it does have a steep learning curve..."
   - **Rationale:** Clear topic sentence improves paragraph structure and readability
   - **Severity:** LOW

---

### Quick Fix Summary

- [ ] Fix 1 long sentence (>35 words): None found
- [ ] Split 0 long paragraphs (>200 words): None found
- [x] Convert 1 passive sentence to active at: Common Challenges:p1:s1
- [ ] Fix 0 terminology inconsistencies: None found
- [ ] Fix 0 capitalization issues: None found
- [ ] Fix 0 number formatting issues: None found
- [ ] Fix 0 punctuation errors: None found
- [ ] Fix 0 spelling errors: None found
- [ ] Fix 0 grammar errors: None found
- [ ] Fix 0 tone issues: None found
- [x] Fix 1 flow issue at: Common Challenges:p1
```

---

## Notes

- This is a WARNING-level check
- Target readability: 8th-12th grade for technical content, 6th-8th for general audience
- Avoid: passive voice overuse (>10%), inconsistent terminology, long complex sentences (>35 words)
- Style guide: Use Oxford comma, spell out zero-nine, use Title Case for headings
- Flow test: Read the post aloud - if you stumble, the flow needs improvement
- Each paragraph should have: clear topic sentence, supporting details, logical conclusion
- Always provide specific text examples from the post when flagging issues
- Include exact line and paragraph numbers for all location references
- Prioritize suggestions by severity (HIGH, MEDIUM, LOW)
- For technical content: prefer active voice, be precise with terminology
