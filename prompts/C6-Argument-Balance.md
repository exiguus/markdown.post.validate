# C6 - Argument Balance - Ensure fair and balanced presentation

**Gate:** C (Accessibility & Style)
**Category:** Argument Balance
**Severity:** WARNING
**Type:** Manual

> **Note:** This is an AI prompt template for manual quality gate C6. Copy the PROMPT section below and paste it into an AI chat along with your blog post content to assist with the manual argument balance review process.

---

## PROMPT (Copy and paste to AI chat with your blog post)

```text
You are an impartial editorial reviewer specializing in bias detection and argument fairness. Analyze this blog post thoroughly for argument balance, fairness, and potential bias. Be critical and provide specific evidence from the text.

### BIAS INDICATOR WORD LISTS:

**Loaded Language (often biased):**
- Positive bias: "undeniably", "clearly", "obviously", "everyone knows", "proven", "it's a fact that", "without a doubt"
- Negative bias: "so-called", "allegedly", "claims to", "pretends to", "supposedly", "hype"
- Exaggeration: "always", "never", "every", "none", "completely", "absolutely", "totally"
- Minimization: "just", "only", "merely", "simply"
- Sensational: "revolutionary", "game-changing", "miraculous", "unbelievable"

**Logical Fallacies to Check For:**
- **STRAW MAN:** Misrepresenting opponent's argument to make it easier to attack
- **FALSE DICHOTOMY:** Presenting only two options when more exist (black/white thinking)
- **APPEAL TO AUTHORITY:** Using authority as evidence when authority is not a real expert on this topic
- **CHERRY PICKING:** Selecting only data that supports your position while ignoring contradictory data
- **CONFIRMATION BIAS:** Interpreting evidence to only support pre-existing beliefs
- **SLIPPERY SLOPE:** Arguing that a small first step will inevitably lead to an extreme chain of events
- **AD HOMINEM:** Attacking the person instead of the argument
- **HASTY GENERALIZATION:** Drawing broad conclusions from limited evidence
- **APPEAL TO POPULARITY:** Arguing that something is true because many people believe it

### CONTROVERSY LEVEL GUIDE:
- **LOW:** Widely accepted facts, standard knowledge (e.g., "water boils at 100C at sea level")
- **MEDIUM:** Topics with some debate but general consensus (e.g., "Rust provides memory safety")
- **HIGH:** Hotly debated topics with strong opinions on all sides (e.g., "Programming language X is better than Y")

### RULES (NON-NEGOTIABLE):
1. The post MUST present information fairly and without undue bias
2. HIGH controversy topics MUST acknowledge multiple legitimate viewpoints
3. MEDIUM controversy topics SHOULD acknowledge alternative perspectives
4. Counterarguments MUST be addressed fairly, not ignored or straw-manned
5. Language MUST be neutral and factual, not inflammatory or loaded
6. Facts MUST be clearly separated from opinions (use "I believe", "In my opinion", etc.)
7. ANY author bias, conflict of interest, or affiliation MUST be disclosed
8. Claims about competitors or alternatives MUST be accurate and fair
9. For LOW controversy topics, absence of opposing viewpoints is acceptable unless the text makes strong comparative or exclusionary claims
10. Require explicit evidence from text before flagging logical fallacies or severe bias
11. Only require bias/conflict disclosure when there is a plausible conflict signal in the post (financial ties, affiliation, sponsorship, or explicit advocacy role)

### ANALYSIS STEPS:
1. **Identify the main argument:**
   - Extract the primary thesis or position of the post
   - Note where it's stated (introduction, conclusion, or implied)
   - Quote the exact text if explicitly stated

2. **Determine controversy level:**
   - Research or use general knowledge to assess topic controversy
   - Justify the level assignment
   - Apply expectations by controversy level:
     - LOW: focus on neutrality and clarity; opposing-view coverage optional
     - MEDIUM: some alternative perspective expected
     - HIGH: multiple perspectives and fair treatment required

3. **Map all viewpoints presented:**
   - Primary position (author's view)
   - Acknowledged alternative perspectives
   - Mentioned but dismissed perspectives
   - Missing legitimate perspectives

4. **Evaluate balance:**
   - For each viewpoint, note:
     - How much space/attention it receives
     - Whether it's presented fairly or as a straw man
     - Whether counterarguments are addressed
     - Whether evidence supports the presentation

5. **Scan for bias indicators:**
   - Use the word lists above to find loaded language
   - Note exact locations (section, paragraph, line) of each biased term
   - Count occurrences by category (positive bias, negative bias, exaggeration)

6. **Check for logical fallacies:**
   - For each fallacy detected, provide:
     - Fallacy type
     - Exact text example from post
     - Location (section, paragraph, line)
     - Severity (HIGH/MEDIUM/LOW)
     - How to fix

7. **Evaluate language neutrality:**
   - Overall tone assessment
   - Facts vs. opinions separation
   - Bias disclosure check

8. **Research missing perspectives:**
   - Identify legitimate viewpoints not covered
   - Provide web search suggestions to find these perspectives
   - Suggest how they could be incorporated

9. **Provide specific recommendations** with exact text references

10. **Report findings** in the EXACT format below

### EVALUATION QUESTIONS:
- Would someone with the opposite view feel this post is fair?
- Are all legitimate perspectives acknowledged?
- Are counterarguments addressed respectfully?
- Is the language neutral or does it reveal bias?
- Are facts and opinions clearly distinguished?
- Is any bias or conflict of interest disclosed?

### VERIFICATION SUGGESTIONS:
To find missing perspectives, use web searches:
- "[topic] pros and cons"
- "[topic] alternative viewpoints"
- "arguments against [position]"
- "[topic] debate"
- "criticism of [position]"

### FORMATTING RULES (CRITICAL):
- Use ONLY proper markdown lists: `-`, `*`, `+`, or `1.` for list items
- Do NOT use icons, emoji, or special characters (✓, ✗, •, ★, etc.) as list markers
- Icons/emoji MAY appear within list item content, but NEVER as the list marker
- All tables must use pipe syntax: `| Column 1 | Column 2 |`
- All lists must be properly indented with 2 or 4 spaces for nested items
- Use exactly ONE `---` separator between major sections, never consecutive `---` lines
- Do not emit repeated empty separators; never output `---` on consecutive lines

### OUTPUT INTEGRITY CHECKS (RUN BEFORE FINALIZING):
1. `Viewpoints Covered` summary must equal counted viewpoint rows
2. Bias indicator totals must equal the sum of category counts
3. Fallacy totals must equal rows in the fallacy table
4. Evidence labels in viewpoint table must not claim CITED when no citation evidence is presented in-text
5. If mismatch exists, fix internally and output only final corrected report

### STATUS CALCULATION RULES (CRITICAL):
- If Balance Score >= 80 AND no HIGH-severity bias/fallacy findings AND Facts/Opinions Separation is YES or PARTIAL (with minor issues): Status = PASS
- If Balance Score is 60-79 or mixed criteria with material but fixable issues: Status = PARTIAL
- If Balance Score < 60 OR HIGH-severity bias/fallacy findings are present: Status = FAIL
- Bias Disclosure should affect status only when a plausible conflict signal exists in the post
- The Status at the top MUST match the Verdict at the end of the report
- Count: X criteria PASS, Y criteria FAIL
- Final gate: if Status/Verdict mismatch exists, regenerate internally and output only the corrected final report

POST TO ANALYZE:
<INSERT BLOG POST CONTENT HERE>

RESPOND WITH EXACTLY THIS STRUCTURE:
---
## Argument Balance Report

### Status: PASS | PARTIAL | FAIL

### Confidence: XX%

---

### Main Argument Analysis

| **Property** | **Value** | **Assessment** |
|-------------|-----------|----------------|
| **Primary Thesis** | [Exact quote or paraphrase from post] | - |
| **Thesis Location** | [Section Name, paragraph X, line Y] | - |
| **Explicit or Implied** | EXPLICIT | YES/NO - ["Exact quote if explicit"] |
| **Topic** | [Main topic of the post] | - |
| **Controversy Level** | LOW/MEDIUM/HIGH | [Justification: why this level?] |

---

### Viewpoints Presentation Table

| **#** | **Viewpoint** | **Position** | **Space Given** | **Presentation** | **Evidence** | **Counterarguments Addressed** | **Status** |
|-------|---------------|--------------|----------------|------------------|--------------|--------------------------------|------------|
| 1 | PRIMARY | [Author's position] | [X words/Y% of post] | FAIR | ACCURATE | YES/NO | PASS |
| 2 | ALTERNATIVE | [Opposing view] | [X words/Y% of post] | FAIR | STRAW MAN | YES/NO | PASS/FAIL |
| 3 | MISSING | [Not covered] | 0% | - | - | - | FLAGGED |

**Viewpoint Details:**
1. **Viewpoint:** [PRIMARY | ALTERNATIVE | MINOR]
   - **Position:** [Brief description of the position]
   - **Representative Text:** ["Exact quote from post representing this viewpoint"]
   - **Location:** [Section:pY:lineZ]
   - **Space Allocated:** [X words, Y% of total post]
   - **Presentation Style:** FAIR | STRAW MAN | CARICATURE | DISMISIVE
   - **Supporting Evidence:** [CITED | UNCITED | NONE]
   - **Counterarguments Raised:** YES | NO | PARTIAL
   - **Counterarguments Addressed:** YES | NO | PARTIAL

[Repeat for all viewpoints mentioned]

---

### Missing Perspectives Analysis

**Missing Legitimate Viewpoints:** [X found]

| **#** | **Missing Perspective** | **Description** | **Why It Matters** | **Web Search Suggestion** | **Severity** |
|-------|------------------------|-----------------|-------------------|----------------------------|--------------|
| 1 | [Perspective name] | [What this perspective believes] | [Why including this would improve balance] | ["search query to find this perspective"] | HIGH/MEDIUM/LOW |

[Repeat for all missing perspectives]

---

### Bias Indicators Found

| **Category** | **Count** | **Severity** | **Example Locations** | **Examples from Post** |
|--------------|-----------|--------------|----------------------|-------------------------|
| Positive Bias Words | X | MEDIUM | [Section:pY:lineZ, ...] | ["word1", "word2", ...] |
| Negative Bias Words | X | MEDIUM | [Section:pY:lineZ, ...] | ["word1", "word2", ...] |
| Exaggerations | X | HIGH | [Section:pY:lineZ, ...] | ["always", "never", ...] |
| Inflammatory Terms | X | HIGH | [Section:pY:lineZ, ...] | ["word1", "word2", ...] |

**Bias Word Details:**
1. **Word:** ["exact word or phrase from post"]
   - **Category:** [POSITIVE BIAS | NEGATIVE BIAS | EXAGGERATION | INFLAMMATORY]
   - **Location:** [Section Name], paragraph [X], line [Y]
   - **Context:** ["Surrounding text to show usage"]
   - **Suggested Replacement:** [Neutral alternative word or phrase]
   - **Severity:** HIGH | MEDIUM | LOW

[Repeat for all bias words found]

---

### Logical Fallacies Detected

**Total Fallacies Found:** X

| **#** | **Fallacy Type** | **Example Text** | **Location** | **Problem** | **Severity** | **Suggested Fix** |
|-------|------------------|-----------------|--------------|-------------|--------------|-------------------|
| 1 | STRAW MAN/FALSE DICHOTOMY/etc. | ["Exact text from post"] | [Section:pY:lineZ] | [Explanation of the fallacy] | HIGH/MEDIUM/LOW | [How to restructure] |

[Repeat for all fallacies found]

---

### Facts vs. Opinions Assessment

**Facts Clearly Separated:** YES | PARTIAL | NO

If PARTIAL or NO:
| **#** | **Type** | **Text** | **Location** | **Issue** | **Suggested Fix** |
|-------|----------|---------|--------------|-----------|-------------------|
| 1 | FACT PRESENTED AS OPINION | ["Exact text"] | [Section:pY:lineZ] | [Why it's actually fact] | [Add "It is a fact that" or cite source] |
| 2 | OPINION PRESENTED AS FACT | ["Exact text"] | [Section:pY:lineZ] | [Why it's actually opinion] | [Add "In my opinion" or "I believe"] |

---

### Bias and Conflict of Interest Disclosure

**Bias Disclosure Present:** YES | NO

If YES:
- **Disclosure Text:** ["Exact disclosure text from post"]
- **Location:** [Section:pY:lineZ]
- **Adequacy:** COMPLETE | PARTIAL | INSUFFICIENT

If NO or INSUFFICIENT:
- **Potential Biases to Disclose:**
  - [Financial interests: list any]
  - [Personal connections: list any]
  - [Employer relationships: list any]
  - [Affiliations: list any]
  - [Suggested Disclosure Text: "[Complete disclosure statement]"]

---

### Language Assessment

| **Aspect** | **Rating** | **Details** |
|------------|------------|-------------|
| **Neutral tone** | YES/PARTIAL/NO | [Assessment with examples if not YES] |
| **Facts vs. opinions separation** | YES/PARTIAL/NO | [Assessment with examples if not YES] |
| **Bias disclosure** | PRESENT/PARTIAL/MISSING | [Assessment] |

---

### Fairness Test

**Test Question:** Would someone with the opposite view feel this post is fair?

**Answer:** YES | PARTIAL | NO

**Evidence:**
- Supporting: [List aspects that support fairness]
- Detracting: [List aspects that reduce fairness]

---

### Summary

| **Metric** | **Value** |
|------------|-----------|
| **Viewpoints Covered** | X of Y legitimate viewpoints |
| **Balance Score** | [0-100] |
| **Bias Indicators** | X found (HIGH: A, MEDIUM: B, LOW: C) |
| **Logical Fallacies** | X found (HIGH: A, MEDIUM: B, LOW: C) |
| **Facts/Opinions Separation** | PASS/PARTIAL/FAIL |
| **Bias Disclosure** | PASS/PARTIAL/FAIL |
| **Verdict** | PASS/PARTIAL/FAIL |

---

### Recommendations

[If FAIL or any issues found, provide specific, actionable recommendations]

1. **Issue:** [MISSING PERSPECTIVE | BIAS INDICATOR | LOGICAL FALLACY | FACT/OPINION CONFUSION | MISSING DISCLOSURE]
   - **Location:** [Section:pY:lineZ]
   - **Problem:** [Detailed description with exact text from post]
   - **Suggested Fix:** [Specific improvement]
   - **Verification:** [Web search query to find missing perspectives or verify claims]

[Repeat for all recommendations]

---

### Quick Fix Checklist

- [ ] Acknowledge missing viewpoints: [list]
- [ ] Replace biased language at: [locations]
- [ ] Fix logical fallacies at: [locations]
- [ ] Separate facts from opinions at: [locations]
- [ ] Add bias disclosure statement
- [ ] Research and include: [web search queries for missing perspectives]
```

---

## Expected Output Format

```text
## Argument Balance Report

### Status: FAIL

### Confidence: 90%

---

### Main Argument Analysis

| **Property** | **Value** | **Assessment** |
|-------------|-----------|----------------|
| **Primary Thesis** | "Rust is the best programming language for systems programming" | Unqualified superlative |
| **Thesis Location** | Introduction, paragraph 1, line 12 | Stated explicitly |
| **Explicit or Implied** | EXPLICIT/YES | "Rust has consistently been voted the most loved..." |
| **Topic** | Programming language choice for systems programming | - |
| **Controversy Level** | HIGH | Programming language preferences are highly subjective |

---

### Viewpoints Presentation Table

| **#** | **Viewpoint** | **Position** | **Space Given** | **Presentation** | **Evidence** | **Counterargs Addressed** | **Status** |
|-------|---------------|--------------|----------------|------------------|--------------|--------------------------------|------------|
| 1 | PRIMARY | Rust is superior | 800 words (72%) | FAIR | UNCITED | NO | PASS |
| 2 | MISSING | C/C++ advantages | 0% | - | - | - | FLAGGED |
| 3 | MISSING | Go language perspective | 0% | - | - | - | FLAGGED |
| 4 | MISSING | Performance tradeoffs | 0% | - | - | - | FLAGGED |

**Viewpoint Details:**
1. **Viewpoint:** PRIMARY
   - **Position:** Rust provides unique combination of performance, reliability, and productivity
   - **Representative Text:** "Rust offers a unique combination of performance, reliability, and productivity"
   - **Location:** Why Learn Rust, paragraph 1, line 16
   - **Space Allocated:** 800 words, 72% of post
   - **Presentation Style:** FAIR (presents Rust's strengths accurately)
   - **Supporting Evidence:** UNCITED (no sources for claims)
   - **Counterarguments Raised:** NO (no mention of other languages)
   - **Counterarguments Addressed:** NO (no counterarguments to address)

---

### Missing Perspectives Analysis

**Missing Legitimate Viewpoints:** 4 found

| **#** | **Missing Perspective** | **Description** | **Why It Matters** | **Web Search Suggestion** | **Severity** |
|-------|------------------------|-----------------|-------------------|----------------------------|--------------|
| 1 | C/C++ for systems programming | C/C++ offers fine-grained control and mature ecosystem | Readers considering systems programming need this comparison | "C++ vs Rust systems programming comparison" | HIGH |
| 2 | Go language simplicity | Go offers simpler concurrency and faster compile times | Provides alternative for readers who prioritize simplicity | "Go vs Rust for systems programming" | HIGH |
| 3 | Performance tradeoffs | Rust has compile-time overhead, C has runtime efficiency | Honest discussion of tradeoffs builds credibility | "Rust compile time vs C runtime performance" | MEDIUM |
| 4 | Learning curve critique | Rust's complexity can be a barrier | Acknowledging downsides increases fairness | "Rust learning curve criticism" | MEDIUM |

---

### Bias Indicators Found

| **Category** | **Count** | **Severity** | **Example Locations** | **Examples from Post** |
|--------------|-----------|--------------|----------------------|-------------------------|
| Superlatives | 3 | HIGH | Intro:p1:l12, Why Rust:p1:l16, Conclusion:p1:l109 | "most loved", "unique combination", "compelling combination" |
| Positive Bias | 5 | MEDIUM | Why Rust:p1:l16, p2:l18, Conclusion:p1:l109 | "special", "ideal", "powerful tool" |

**Bias Word Details:**
1. **Word:** "most loved"
   - **Category:** SUPERLATIVE
   - **Location:** Introduction, paragraph 1, line 12
   - **Context:** "Rust has consistently been voted the most loved programming language"
   - **Suggested Replacement:** "highly ranked" or "frequently voted among the most loved"
   - **Severity:** HIGH

2. **Word:** "ideal"
   - **Category:** POSITIVE BIAS
   - **Location:** Conclusion, paragraph 1, line 109
   - **Context:** "Rust offers a compelling combination... that makes it ideal for systems programming"
   - **Suggested Replacement:** "well-suited" or "a good choice"
   - **Severity:** MEDIUM

---

### Logical Fallacies Detected

**Total Fallacies Found:** 1

| **#** | **Fallacy Type** | **Example Text** | **Location** | **Problem** | **Severity** | **Suggested Fix** |
|-------|------------------|-----------------|--------------|-------------|--------------|-------------------|
| 1 | FALSE DICHOTOMY | "Rust offers a unique combination of performance, reliability, AND productivity" | Why Learn Rust, p1, l16 | Implies only Rust offers all three, ignoring C++ with careful coding | MEDIUM | Qualify: "Rust offers unique ..." |

---

### Facts vs. Opinions Assessment

**Facts Clearly Separated:** PARTIAL

| **#** | **Type** | **Text** | **Location** | **Issue** | **Suggested Fix** |
|-------|----------|---------|--------------|-----------|-------------------|
| 1 | OPINION PRESENTED AS FACT | "Rust offers a unique combination of performance, reliability, and productivity" | Why Learn Rust, p1, l16 | Subjective assessment presented as objective fact | Add "In my experience," or cite survey data |

---

### Bias and Conflict of Interest Disclosure

**Bias Disclosure Present:** NO

**Potential Biases to Disclose:**
- Financial interests: None apparent
- Personal connections: Author may be Rust enthusiast
- Employer relationships: Not disclosed
- Affiliations: Not disclosed
- **Suggested Disclosure Text:** "Note: I am a Rust enthusiast and have been using Rust for [X] years. My perspective may be biased toward Rust's strengths."

---

### Language Assessment

| **Aspect** | **Rating** | **Details** |
|------------|------------|-------------|
| **Neutral tone** | PARTIAL | Positive bias toward Rust detected |
| **Facts vs. opinions separation** | PARTIAL | Subjective claims not qualified as opinions |
| **Bias disclosure** | MISSING | No author bias disclosed |

---

### Fairness Test

**Test Question:** Would someone with the opposite view (e.g., a C++ advocate) feel this post is fair?

**Answer:** NO

**Evidence:**
- Supporting: Clear explanation of Rust's features
- Detracting: No mention of alternatives, uses superlatives without qualification, presents opinions as facts

---

### Summary

| **Metric** | **Value** |
|------------|-----------|
| **Viewpoints Covered** | 1 of 5 legitimate viewpoints |
| **Balance Score** | 40/100 |
| **Bias Indicators** | 8 found (HIGH: 3, MEDIUM: 5, LOW: 0) |
| **Logical Fallacies** | 1 found (MEDIUM: 1) |
| **Facts/Opinions Separation** | PARTIAL |
| **Bias Disclosure** | FAIL |
| **Verdict** | FAIL |

---

### Recommendations

1. **Issue:** MISSING PERSPECTIVES at Introduction
   - **Problem:** Post presents Rust as superior without acknowledging alternatives like C++, Go, or Zig
   - **Suggested Fix:** Add section: "## How Rust Compares to Alternatives" discussing C++ (control, maturity), Go (simplicity, fast compiles), Zig (simplicity, C interop)
   - **Verification:** Search "Rust vs C++ vs Go systems programming comparison"

2. **Issue:** BIAS INDICATORS throughout post
   - **Location:** Introduction:p1:l12, Why Rust:p1:l16, Conclusion:p1:l109
   - **Problem:** Uses superlatives and positive bias without qualification
   - **Suggested Fix:** Qualify claims: "Rust is AMONG the most loved" instead of "THE most loved"; "Rust is WELL-SUITED for" instead of "IDEAL for"

3. **Issue:** FACT/OPINION CONFUSION at Why Learn Rust, paragraph 1, line 16
   - **Problem:** "Rust offers a unique combination..." presented as fact
   - **Suggested Fix:** Add: "In my experience and according to developer surveys, Rust offers..."

4. **Issue:** MISSING DISCLOSURE
   - **Problem:** No author bias or perspective disclosed
   - **Suggested Fix:** Add disclosure at beginning: "Note: I've been using Rust for 3 years and am enthusiastic about its capabilities. This guide reflects my positive experience."

---

### Quick Fix Checklist

- [ ] Acknowledge missing viewpoints: C/C++, Go, Zig, performance tradeoffs
- [ ] Replace biased language: "most loved" -> "highly ranked", "ideal" -> "well-suited"
- [ ] Fix logical fallacy: Qualify "unique combination" claim
- [ ] Separate facts from opinions: Add "In my experience" or cite sources
- [ ] Add bias disclosure statement at introduction
- [ ] Research and include: "Rust vs C++ comparison", "Rust vs Go comparison"
```

---

## Notes

- This is a WARNING-level check
- HIGH controversy topics require multiple viewpoints
- MEDIUM controversy topics should acknowledge alternatives
- LOW controversy topics may only need the primary position
- Opinion pieces should be clearly labeled as "OPINION" or "PERSONAL PERSPECTIVE"
- Disclose: financial interests, personal connections, employer relationships, enthusiast status
- Test: Would someone with the opposite view feel this post is fair and accurate?
- Always provide specific text examples from the post when flagging issues
- Include line and paragraph numbers for all location references
- Provide web search queries for finding missing perspectives
- Suggest specific text replacements for biased language
