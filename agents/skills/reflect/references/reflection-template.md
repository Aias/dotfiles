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
