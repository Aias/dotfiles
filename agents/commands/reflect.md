---
name: reflect
description: Analyze diary entries to identify patterns and propose AGENTS.md updates
---

# Reflect on Diary Entries and Synthesize Insights

You are going to analyze multiple diary entries to identify recurring patterns, synthesize insights, and propose updates to the user's global `AGENTS.md` file.

**Important context**: The global agent instructions live at `~/Code/dotfiles/agents/AGENTS.md`, which is symlinked to `~/.claude/CLAUDE.md`. All updates should be made to the dotfiles source file.

## AGENTS.md Structure and Philosophy

The AGENTS.md file has a specific structure and philosophy that MUST be respected:

**Existing sections** (in order):

1. **Quick Rules** — High-priority, frequently-needed rules
2. **User-Agent Working Relationship** — How to interact with the user
3. **Self-Review & Memory** — Rules about maintaining this document
4. **Permission & Risk Guardrails** — Safety constraints
5. **Git & Version Control** — Git workflows and conventions
6. **Tools** — Preferred CLI tools and when to use them
7. **Type Safety & Style** — TypeScript and code style rules
8. **Frontend Semantics & Styling** — HTML/CSS conventions
9. **React** — React-specific patterns
10. **Debugging** — How to debug issues

**Document philosophy** (from the document itself):

- "prefer editing or merging existing rules over adding near-duplicates"
- "limit new rules to high-value items"
- "aim to keep this document about one printed page"
- "When adding new rules, place them next to related items to keep logical grouping and avoid redundancy"
- "If a rule in this file appears to contribute to a failure, propose a revision or deletion"

**Key constraint**: This document is read into EVERY session, so brevity and density are critical. Propose deletion of underperforming rules, not just additions.

## Parameters

The user can provide:

- **Date range**: "from YYYY-MM-DD to YYYY-MM-DD" or "last N days"
- **Entry count**: "last N entries" (e.g., "last 10 entries")
- **Project filter**: "for project [project-path]" (optional - filter to specific project)
- **Pattern filter**: "related to [keyword]" (e.g., "related to testing" or "related to React")

If no parameters are provided, default to analyzing the **last 10 diary entries**.

## Steps to Follow

1. **Check processed entries log**:

   - Read `~/Code/vault/reflections/processed.log` to find already-processed diary entries
   - Format: `[diary-date] | [entry-time] | [reflection-date] | [reflection-filename]`
   - Example: `2025-11-07 | 14:30:00 | 2025-11-08 | 2025-11-reflection-1.md`
   - If file doesn't exist, all entries are unprocessed
   - Create the file if it doesn't exist: `touch ~/Code/vault/reflections/processed.log`

2. **Locate diary entries**:

   - Directory: `~/Code/vault/diary/`
   - Files are named: `YYYY-MM-DD.md` (one file per day)
   - Each file may contain multiple entries separated by `---` dividers
   - Each entry has a header: `## Session Diary Entry: HH:MM:SS`
   - List all files, sorted by date (newest first)
   - **Exclude already-processed entries** by checking the date + time combination (unless user explicitly requests re-analysis)

3. **Filter entries based on parameters**:

   - If date range specified: only include entries within that range
   - If entry count specified: take the N most recent entries
   - If project filter specified: only include entries where the Project field matches
   - If pattern filter specified: only include entries that mention the keyword in any section

4. **Read and parse filtered diary entries**:

   - Read each diary entry file
   - Extract information from all sections
   - Pay special attention to:
     - User Preferences Observed
     - Code Patterns and Decisions
     - Solutions Applied (what works well)
     - Challenges Encountered (what to avoid)

5. **Create the reflections directory** (if it doesn't exist):

   - Directory: `~/Code/vault/reflections/`
   - Use `mkdir -p` to create it automatically

6. **Read current AGENTS.md to understand existing rules and structure**:

   - Read `~/Code/dotfiles/agents/AGENTS.md` to understand what rules already exist
   - This is the global agent instructions file (symlinked to `~/.claude/CLAUDE.md`)
   - **Map each potential new rule to an existing section** — do NOT create new sections
   - **Identify rules that could be strengthened** rather than duplicated
   - **Note the document length** — if it's already ~one page, deletions may be needed to make room
   - This is CRITICAL for the next step

7. **Analyze entries for patterns AND rule violations**:

   - **Frequency analysis**: What preferences/patterns appear in multiple entries?
   - **Consistency check**: Are preferences consistent or contradictory?
   - **Context awareness**: Do patterns apply globally or to specific project types?
   - **Abstraction level**: Can specific instances be generalized into rules?
   - **Signal vs. noise**: Distinguish between:
     - **One-off requests**: "Make this button pink" (appears once)
     - **Recurring patterns**: "Always use TypeScript strict mode" (appears 3+ times)
   - **CRITICAL - Rule Violation Detection**: Check if diary entries show violations of EXISTING AGENTS.md rules
     - Look in "Code Review & PR Feedback", "Challenges Encountered", "User Preferences Observed" sections
     - If a diary mentions user correcting Claude for violating an existing rule, this is HIGH PRIORITY
     - Example: AGENTS.md says "no AI attribution" but diary shows "User corrected: Don't add Claude attribution"
     - These violations mean the existing rule needs STRENGTHENING (more explicit, moved to top, zero tolerance language)

8. **Synthesize insights** organized by category:

   **CRITICAL**: Focus on extracting concise, actionable rules suitable for AGENTS.md (which is read into every session).

   **PRIORITY: Rule Violations** (MUST address first):

   - Did any diary entries document violations of existing AGENTS.md rules?
   - If YES, these are HIGHEST PRIORITY and require rule strengthening
   - Document the violation pattern and propose specific strengthening (e.g., "move to top", "add ZERO TOLERANCE", "make more explicit")

   **A. PR Review Feedback Patterns** (from code reviews):

   - Common feedback themes from reviewers
   - Code quality issues flagged repeatedly
   - What reviewers appreciate vs. criticize
   - Patterns in "looks AI-generated" feedback

   **B. Persistent Preferences** (appear 2+ times):

   - Commit and PR style requirements
   - Code organization and structure
   - Testing and linting workflows
   - Tool and framework choices
   - Communication style

   **C. Design Decisions That Worked** (successful approaches):

   - Architecture choices that solved problems well
   - Technology selections with clear rationale
   - Patterns that led to clean, maintainable code
   - Decision-making frameworks that helped

   **D. Anti-Patterns to Avoid** (caused problems 2+ times):

   - Approaches that failed or needed rework
   - Common mistakes that waste time
   - What NOT to do and why
   - Alternatives that work better

   **E. Efficiency Lessons** (save time in future):

   - What workflows worked smoothly
   - What caused delays or friction
   - Tools/commands that proved useful
   - Processes to streamline

   **F. Project-Specific Patterns** (context-dependent):

   - Patterns specific to certain project types (React, CLI, Python, etc.)
   - Technology-specific preferences
   - Framework-specific conventions

9. **Generate a reflection document** with this structure:

````markdown
# Reflection: [Date Range or "Last N Entries"]

**Generated**: [YYYY-MM-DD HH:MM:SS]
**Entries Analyzed**: [count]
**Date Range**: [first-date] to [last-date]
**Projects**: [list of projects if filtered, or "All projects"]

## Summary

[2-3 paragraph overview of key insights discovered across these entries]

## CRITICAL: Rule Violations Detected

[ONLY include this section if violations of existing AGENTS.md rules were found]

**Rule**: [The existing AGENTS.md rule that was violated]
**Violation Pattern**: [How it appeared in diary entries - quote specific examples]
**Frequency**: [X/Y entries showed this violation]
**Impact**: [Why this is serious - user had to correct multiple times]
**Root Cause**: [Why the existing rule failed - too weak, buried in list, ambiguous wording]
**Strengthening Action**: [Specific changes made to AGENTS.md rule]

- Move to top of section: [YES/NO]
- Add emphasis (CAPS, ZERO TOLERANCE): [YES/NO]
- Make more explicit/specific: [YES/NO]
- Add override language: [YES/NO]

## Patterns Identified

### A. PR Review Feedback Patterns

[What reviewers commonly flag or appreciate]

1. **[Feedback Pattern]** (appeared in X/Y entries)
   - **Observation**: [What reviewers said/flagged]
   - **Examples**: [Specific feedback quotes]
   - **Lesson**: [What to do/avoid]
   - **AGENTS.md rule**: `- [succinct actionable rule]`

### B. Persistent Preferences (2+ occurrences)

[Recurring user preferences across sessions]

1. **[Preference Name]** (appeared in X/Y entries)
   - **Observation**: [What was consistently preferred]
   - **Evidence**: [Which sessions, what happened]
   - **Confidence**: High/Medium/Low
   - **AGENTS.md rule**: `- [succinct actionable rule]`

### C. Design Decisions That Worked

[Successful technical decisions and approaches]

1. **[Decision Name]**
   - **What worked**: [Brief description]
   - **Why it worked**: [Key reason]
   - **When to use**: [Context/applicability]
   - **AGENTS.md rule** (if generalizable): `- [succinct rule]`

### D. Anti-Patterns to Avoid

[Things that failed or caused problems 2+ times]

1. **[Anti-pattern Name]** (appeared in X/Y entries)
   - **What didn't work**: [Brief description]
   - **Why it failed**: [Key reason]
   - **What to do instead**: [Alternative]
   - **AGENTS.md rule**: `- [avoid X, use Y instead]`

### E. Efficiency Lessons

[Workflows, tools, and processes that save time]

1. **[Efficiency Pattern]**
   - **What worked well**: [Description]
   - **Time/effort saved**: [Impact]
   - **When to apply**: [Context]
   - **AGENTS.md rule** (if applicable): `- [succinct rule]`

### F. Project-Specific Patterns

[Patterns that apply to specific project types or technologies]

1. **[Pattern Name]** (for [project type/technology])
   - **Observation**: [What was observed]
   - **Context**: [When this applies]
   - **AGENTS.md rule**: `- [context]: [action]`

## Notable Mistakes and Learnings

[Key mistakes that taught valuable lessons]

- **Mistake**: [What went wrong]
  - **Why**: [Root cause]
  - **Learning**: [What was learned]
  - **Prevention**: [How to avoid in future]

## One-Off Observations

[Preferences that appeared only once - not patterns yet, but worth noting]

- [Observation from single session]

## Proposed AGENTS.md Updates

**CRITICAL FORMAT REQUIREMENTS**:

- AGENTS.md is read into EVERY session, so keep updates **succinct and non-verbose**
- Prefer editing existing rules over adding new ones
- Place new rules next to related existing rules (not at end of section)
- Use bullet points with imperative tone: "do X", "use Y", "avoid Z"
- NO explanations or rationale — just the rule
- Aim to keep the document ~one printed page; propose deletions if needed

**Good Example** (succinct, actionable):

```markdown
- git commits: use conventional format (feat:, fix:, refactor:, docs:, test:)
- PR descriptions: no Claude Code attribution or AI tool mentions
```
````

**Bad Example** (too verbose):

```markdown
- When you are creating git commits, it's important to follow the conventional
  commit format which includes prefixes like feat: for features...
```

### Rules to Strengthen (edit existing)

| Current Rule         | Proposed Change        | Rationale |
| -------------------- | ---------------------- | --------- |
| [existing rule text] | [strengthened version] | [why]     |

### Rules to Add (place next to related rules)

**Section: [Quick Rules / Git & Version Control / Type Safety & Style / etc.]**

- [New rule to insert after: "existing related rule"]
- [Actionable rule]

### Rules to Delete (if document too long)

| Rule        | Section   | Rationale for Deletion                                 |
| ----------- | --------- | ------------------------------------------------------ |
| [rule text] | [section] | [never relevant / contributed to failure / superseded] |

## Metadata

- **Diary entries analyzed**: [list of filenames]
- **Total user messages**: [count across all entries]
- **Total actions taken**: [count across all entries]
- **Challenges documented**: [count]
- **Projects covered**: [list of unique projects]

```

9. **Save the reflection document**:
   - Filename format: `YYYY-MM-reflection-N.md` (increment N if multiple reflections in same month)
   - Save to: `~/Code/vault/reflections/[filename]`

10. **Automatically update AGENTS.md**:

   **PRIORITY 1: Strengthen violated rules (if any rule violations detected)**
   - FIRST, handle any rule violations by strengthening existing AGENTS.md rules
   - Use Edit tool to modify the existing rule (not append)
   - Apply strengthening actions: move to top of section, add emphasis, make explicit, add override language
   - Example: Change "no AI attribution" → "NEVER add AI attribution (ZERO TOLERANCE)"

   **PRIORITY 2: Edit or merge with existing rules**
   - Check if a similar rule already exists — if so, strengthen or clarify it rather than adding a duplicate
   - Place new rules next to related existing rules within the appropriate section
   - **Use existing sections only** — do NOT create new sections:
     - Quick Rules (high-priority, frequently-needed)
     - Permission & Risk Guardrails (safety constraints)
     - Git & Version Control (git workflows)
     - Tools (CLI tool preferences)
     - Type Safety & Style (TypeScript, code style)
     - Frontend Semantics & Styling (HTML/CSS)
     - React (React-specific patterns)
     - Debugging (debugging approaches)

   **PRIORITY 3: Propose deletions**
   - If the document is already ~one page, identify underperforming rules that could be removed
   - Rules that contributed to failures should be revised or deleted
   - Rules that are never relevant can be removed

   **Show the user what changed**:
   - List any strengthened rules (with before/after)
   - List any new rules added (and which section)
   - List any rules proposed for deletion (with rationale)

11. **Update processed entries log**:
   - Append processed diary entries to `~/Code/vault/reflections/processed.log`
   - Format: `[diary-date] | [entry-time] | [YYYY-MM-DD] | [reflection-filename]`
   - One line per diary entry processed
   - Example: `2025-11-07 | 14:30:00 | 2025-11-08 | 2025-11-reflection-1.md`

12. **Present completion summary to user**:
   - **FIRST**: Highlight any rule violations detected and how rules were strengthened
   - Display the reflection filename and location
   - Show how many patterns were identified
   - List the AGENTS.md changes:
     - Rules strengthened (before/after)
     - Rules added (which section, placed after which rule)
     - Rules deleted (if any)
   - Confirm that processed.log was updated

## Important Guidelines

### Pattern Recognition Principles

1. **Frequency matters**: Require 2+ occurrences before calling something a "pattern"
   - **Strong patterns**: 3+ occurrences with consistency
   - **Emerging patterns**: 2 occurrences worth noting
   - **One-off**: Single occurrence, document but don't add to AGENTS.md yet

2. **Context matters**: Note whether patterns are:
   - Universal (apply everywhere)
   - Project-specific (only for certain types of projects)
   - Tool-specific (only when using certain technologies)

3. **Consistency matters**: Flag contradictory preferences for user review

4. **Actionability matters**: Only propose rules that Claude can actually follow

5. **Abstraction matters**: Find the right level:
   - Too specific: "The login button should be blue" ❌
   - Too broad: "Users like colors" ❌
   - Just right: "Use the design system's primary color for CTAs" ✅

6. **Succinctness matters for AGENTS.md**:
   - Each rule should be ONE line (or short bullet)
   - Use imperative tone: "do X", "use Y", "avoid Z"
   - Add context prefix when needed: "for Python:", "when testing:"
   - NO explanations or rationale in AGENTS.md — just the rule

7. **Edit over add**: Before proposing a new rule, check if strengthening an existing rule would achieve the same goal. The document should stay ~one page.

### Distinguishing Signal from Noise

**SIGNAL** (add to AGENTS.md):
- "Always use TypeScript strict mode" (appears in 5 sessions across 3 projects)
- "Prefer functional components in React" (appears in 4 React projects)
- "Run tests before committing" (appears in 6 sessions)

**NOISE** (document but don't add to AGENTS.md):
- "Make this button pink" (appears once, specific task)
- "Use dark mode for this demo" (appears once, context-specific)
- "Skip tests this time" (contradicted by usual pattern)

### Quality Checks

Before proposing an AGENTS.md update, verify:
- ✅ Does this apply to future sessions? (not just the past)
- ✅ Is this actionable? (Claude can actually do it)
- ✅ Is this generalizable? (not too specific to one case)
- ✅ Is this consistent? (doesn't contradict other patterns)
- ✅ Is this valuable? (will it improve future interactions)
- ✅ Does a similar rule already exist? (prefer strengthening over adding)
- ✅ Which existing section does this belong in? (never create new sections)
- ✅ Is this high-value enough to justify the token cost? (document is read every session)
- ✅ Can an existing underperforming rule be removed to make room?

## Error Handling

- If no diary entries exist, inform the user and suggest running `/diary` first
- If all diary entries have been processed and no new entries are found, inform the user
- If fewer than 3 entries are found, proceed but note that pattern confidence is low
- If diary entries are malformed, skip them and document which ones had issues
- If the reflections directory cannot be created, report the error
- If AGENTS.md cannot be read or written, report the error but continue with reflection
- If processed.log cannot be read, assume no entries have been processed yet
- If processed.log cannot be written, report the error

## Handling Already-Processed Entries

**Default behavior**: Skip entries already listed in `~/Code/vault/reflections/processed.log`

**User can override** with these flags:
- "include all entries" - re-analyze everything including processed entries
- "reprocess [filename]" - re-analyze specific entry
- "last N entries including processed" - analyze N most recent, even if processed

**When to suggest re-processing**:
- User significantly changed their workflow
- User wants to validate previous patterns
- User wants to extract different insights from same sessions

## Example Usage

```

# Analyze last 10 unprocessed entries (default)

/reflect

# Analyze last 20 unprocessed entries

/reflect last 20 entries

# Analyze entries from a date range

/reflect from 2025-01-01 to 2025-01-31

# Analyze entries for specific project

/reflect for project /Users/rlm/Desktop/Code/my-app

# Analyze entries related to testing

/reflect related to testing

# Combine filters

/reflect last 15 entries for project /Users/rlm/Desktop/Code/my-app related to React

# Re-analyze including already-processed entries

/reflect include all entries

# Re-analyze specific entry (by date and time)

/reflect reprocess 2025-11-07 14:30:00

```

```
