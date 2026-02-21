---
name: write
description: >
  Prose writing and editing guidance grounded in sentence-level craft. Use when
  writing, editing, or revising any prose: PR descriptions, documentation,
  commit messages, agent instructions, READMEs, comments, or freeform text.
  Triggers on: "write this", "edit this", "revise", "rewrite", "tighten the
  prose", "how does this read", "draft", "wordsmith", /write.
---

# Write

Sentence-level prose craft, grounded in three canonical sources:

- [Klinkenborg, *Several Short Sentences About Writing*](references/klinkenborg.md)
- [Pinker, *The Sense of Style*](references/pinker.md)
- [Strunk & White, *The Elements of Style*](references/strunk-white.md)
- [Owen, *The Objectively Objectionable Grammatical Pet Peeve*](references/owen.md)

## Principles

**The sentence is the unit of work.** Know what each sentence says, what it doesn't say, and what it implies. If something feels off (the internal quaver), find the cause and fix it.

**Omit needless words.** Every word must tell. When a sentence is made stronger, it usually becomes shorter. This does not mean all sentences should be short; it means every word earns its place.

**Clarity over style.** Pursue clarity; style reveals itself in that pursuit. Style is not a garnish; it is nondetachable, unfilterable. The approach to style is by way of plainness, simplicity, orderliness, sincerity.

**Classic style: prose as a window.** Orient the reader's gaze so they can see for themselves. Assume equality between writer and reader. Good writing makes the reader feel like a genius; bad writing makes the reader feel like a dunce.

**Defeat the curse of knowledge.** The better you know something, the less you remember about how hard it was to learn. Spell out the logic, explain the jargon, supply the necessary detail. The order in which thoughts occur to the writer is different from the order in which they are easily discovered by a reader.

**Active voice. Positive form.** *"He usually came late"* not *"He was not very often on time."* The reader wishes to be told what is, not only what is not. If every sentence admits a doubt, writing lacks authority.

**No clichés.** A cliché is the debris of someone else's thinking. If a phrase comes too easily, it probably came from somewhere else.

**No nominalizations.** Use verbs, not zombie nouns. *"We excluded people who failed to understand"* not *"Comprehension checks were used as exclusion criteria."*

**Prefer the specific and concrete.** Prefer the specific to the general, the definite to the vague, the concrete to the abstract.

**No elegant variation.** Repeating a word is better than straining to avoid it. A banana is never "the elongated yellow fruit."

**No indirection.** Introduce new information before referencing it. Don't smuggle in details via modifiers that imply prior mention.

**Parallel construction.** Expressions similar in content and function should be outwardly similar. The reader absorbs parallel structure effortlessly.

**Emphatic words at the end.** The most prominent position in a sentence is the end. Same for paragraphs and compositions.

**No anxiety of sequence.** You can get anywhere from anywhere. There is no single necessary order. Good writing is significant everywhere, not a conveyor belt to "the point."

**Do not overstate.** A single overstatement diminishes the whole. The reader loses confidence in your judgment.

**Kill darlings without guilt.** Don't protect sentences because you remember the excitement of writing them. The piece won't come together until they're removed or revised.

**Squander material.** Don't ration, saving the best for last. You don't know what the best is. Or the last.

**Distrust "flow."** Flow is often a synonym for ignorance and laziness. It's the urge to be done.

**Composition and revision are the same act.** Revise at the point of composition. Every word is a decision: this word or that, here or there, now or later.

## Process

### Writing new prose

1. **Understand the purpose.** What does the reader need to know or do after reading this?
2. **Write sentences, not paragraphs.** Audition many sentences. One gets the part. Build outward from sentences that earn their place.
3. **Read each sentence in isolation.** Does it say what it means? Does it imply something unintended? Is it ambiguous?
4. **Arrange by ear.** Try different orders. The right sequence will feel inevitable, but it's discovered, not predetermined.
5. **Cut.** If a sentence doesn't teach, clarify, or move, remove it.

### Editing existing prose

1. **Read the whole piece first.** Understand its shape before touching anything.
2. **Sentence by sentence.** What does it actually say? Is that what it should say? Can it be shorter?
3. **Hunt clichés, nominalizations, and filler.** Phrases that arrive pre-assembled ("in order to", "it should be noted that", "at the end of the day"): replace or remove. Verbs turned into nouns: turn them back.
4. **Check transitions.** Earned by the sentences themselves, or scaffolding ("However", "Additionally", "Furthermore") hiding weak connections?
5. **Read it aloud.** The ear catches what the eye forgives.

## AI Writing Tells

LLMs produce recognizable tics. Hunt and eliminate these during every editing pass. For the full catalog with before/after examples: [references/ai-tells.md](references/ai-tells.md)

**Never use "not just X, but Y."** Any construction using "just" to contrast or elevate: "not just X, but Y", "it's X, not just Y", "more than just X". The single most reliable AI marker. State the stronger claim directly.

**No em dashes.** Use commas, periods, colons, semicolons, or parentheses.

**No copula avoidance.** "X is Y", not "X serves as Y" or "X stands as Y."

**No -ing phrase tails.** Cut participial phrases tacked onto sentences for fake depth: "ensuring better maintainability", "showcasing the team's commitment."

**No AI vocabulary.** "Delve", "leverage", "ensure", "robust", "seamless", "comprehensive", "streamline", "foster", "harness", "empower", "bolster", "facilitate." If it sounds like a press release, cut it.

**No inflated significance.** "Testament", "pivotal", "crucial", "cornerstone", "transformative", "groundbreaking", "paradigm shift." State the fact.

**No hedging stacks.** "It might potentially help to consider" collapses to "consider". One hedge per sentence maximum; prefer zero.

**No rhythmic triplets.** Two items or a full list. Three adjectives in a row is a tell.

**No sycophantic tone.** "Great question!", "You're absolutely right!", "I hope this helps!" Cut entirely.

**No filler phrases.** "In order to" = "to". "Due to the fact that" = "because". "It is important to note that" = delete.

**Sentence case in headings.** Title Case Is An AI Tell.

## Context-Specific Guidance

### PR descriptions and commit messages
Problem before solution. Direct, no filler. Present tense. Every sentence carries information. No throat-clearing ("This PR adds..."), no status narration, no file listings.

### Documentation and READMEs
Significant everywhere. Each section useful on its own, not a waypoint to the next. Prefer examples over explanation — show, then name. Do not explain too much: it is seldom advisable to tell all.

### Agent instructions and CLAUDE.md rules
Maximum density. Each rule one sentence if possible. Pair principles with examples. Imperative mood. No hedging ("should probably", "might want to").

### Comments in code
Comments explain WHY, not WHAT. If explaining WHAT, refactor the code. A comment that could be a better function name is not worth keeping.
