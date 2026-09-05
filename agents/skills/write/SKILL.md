---
name: write
description: >
  Use when drafting or revising prose: PR descriptions, docs, READMEs, commit messages, agent rules,
  comments, tickets, chat explanations, or `/write`. Triggers on "revise", "edit this", "how does this
  read", "wordsmith", "tighten", "draft". Sentence-level craft and clarity.
global_category: Writing
---

# Write

Sentence-level prose craft for explanatory and technical writing: documentation, research, PR and commit prose, agent rules, and chat explanations. Distilled from Klinkenborg, Pinker, Strunk & White, Graham, Nielsen, Orwell, and working practitioners (Saunders, McPhee, Constantin, Karlsson, Might, Luu).

These rules apply to this file and to every other rule file: good guidance is self-effacing, in the sense Tufte intends for a well-printed book. Nothing in its presentation may contradict what it teaches.

## Principles

<!-- @> The sentence is the unit of work. Omit needless words. Clarity over style. Active voice, positive form -->
**The sentence is the unit of work.** Know what each sentence says, what it doesn't say, and what it implies. If something feels off (the internal quaver), find the cause and fix it.

**Omit needless words.** Every word must tell. When a sentence is made stronger, it usually becomes shorter. Concision means every word earns its place, not that every sentence is clipped.

**Clarity over style.** Pursue clarity. Style reveals itself in that pursuit. Style is not a garnish: it is nondetachable, unfilterable.

**Classic style: prose as a window.** Orient the reader's gaze so they can see for themselves. Assume equality between writer and reader. Good writing makes the reader feel like a genius. Bad writing makes the reader feel like a dunce.

**Classic style implies mastery. Earn it or drop it.** Writing about a subject you're still exploring in a confident window-pane voice fakes mastery. Name the limits of your knowledge plainly and describe the exploration instead.

**Defeat the curse of knowledge.** The better you know something, the less you remember about how hard it was to learn. Spell out the logic, explain the jargon, supply the necessary detail. The order in which thoughts occur to the writer is different from the order in which they are easily discovered by a reader.

<!-- @> Reader is highly intelligent but has zero context: restate referents (even from a few turns back), expand acronyms, name code by its role with the identifier as a parenthetical -->
**Assume a reader who is highly intelligent and has no context.** Intelligence is not context. The reader can follow any reasoning but has not seen the file you just read, the decision from three turns back, or the constraint you discovered along the way. Restate the referent when you mention it. Expand acronyms unless the acronym is the term everyone uses (URL, API).

**Call code by its real name.** An identifier, function, or constant enters prose as a parenthetical after the name of the thing it is: the role it occupies in the conceptual model. Write "the retry backoff cap (`MAX_RETRY_DELAY`)", never bare "`MAX_RETRY_DELAY`". Write "the nightly session cleanup job (`pruneStaleSessions`)", never "`pruneStaleSessions` runs nightly". The real name carries the sentence. The identifier is a pointer for whoever opens the code.

**Active voice. Positive form.** _"He usually came late"_ not _"He was not very often on time."_ The reader wishes to be told what is, not only what is not. If every sentence admits a doubt, writing lacks authority.

**No clichés.** A cliché is the debris of someone else's thinking. If a phrase comes too easily, it probably came from somewhere else.

**No nominalizations.** Use verbs, not zombie nouns. _"We excluded people who failed to understand"_ not _"Comprehension checks were used as exclusion criteria."_

**Prefer the specific and concrete.** Prefer the specific to the general, the definite to the vague, the concrete to the abstract.

**Look at the thing, not the words.** Bad writing comes from moving words around on the page instead of staring at the real thing (the code, the data, the behavior) and adjusting the words to fit it.

**No elegant variation.** Repeating a word is better than straining to avoid it. A banana is never "the elongated yellow fruit."

**No indirection.** Introduce new information before referencing it. Don't smuggle in details via modifiers that imply prior mention.

**No inside-out sentences.** An inverted appositive ("A former resident of Brooklyn, Mrs. Jones is survived by...") starts in one direction and swerves. Nobody speaks this way. Unstack noun pileups for the same reason: a phrase carrying three nouns as adjectives needs a verb.

**Put modifiers next to what they qualify.** Push "only" and "not" against the thing they quantify: "We choose to go to the moon not because it is easy" beats "We don't choose to go to the moon because it is easy."

**Parallel construction.** Expressions similar in content and function should be outwardly similar. The reader absorbs parallel structure effortlessly.

**Emphatic words at the end.** The most prominent position in a sentence is the end. Same for paragraphs and compositions. Land on a statement, not a rhetorical question.

**Begin paragraphs with the topic.** Open each paragraph with a sentence that states the topic or carries the transition. Readers scan at paragraph grain, and the first sentence is what they scan.

**No anxiety of sequence.** You can get anywhere from anywhere. There is no single necessary order. Good writing is significant everywhere, not a conveyor belt to "the point."

**Do not overstate.** A single overstatement diminishes the whole. The reader loses confidence in your judgment.

**Kill darlings without guilt.** Don't protect sentences because you remember the excitement of writing them. The piece won't come together until they're removed or revised.

**Sound is a heuristic for correctness.** Good prose rhythm matches the shape of the ideas. If a sentence sounds wrong, the ideas are probably wrong too. The converse needs care: distrust your own fluency. A nice turn of phrase can wallpaper over a structural flaw in the argument. Be extra skeptical of ideas expressed in prose you like.

**Write for both logic and vibe.** Logic: is it coherent and true? Vibe: what associations does a skimming reader absorb? Both channels must work. Avoid "not X" where X is vivid, because readers absorb the vivid word and skip "not."

**Single overriding purpose.** Every piece needs a compelling answer to "what is this about?" Content not serving that purpose must go, no matter how good.

**Grammar is logic.** A colon delivers the goods invoiced in the previous clause. A periodic sentence builds tension by delaying the main verb. These are logical relationships, not ornaments.

**Don't announce interestingness.** "It's interesting to consider..." signals that the subject sounds boring. Make it interesting by getting on with it.

**Opening sentences matter disproportionately.** A mediocre opening signals you won't make good use of the reader's time. Don't compromise.

**Break any rule sooner than say anything barbarous.** Rules prompt conscious choice. They are not dogma.

## Process

### Writing new prose

1. **Understand the purpose.** What does the reader need to know or do after reading this? You must have a compelling answer to "what is this about?"
2. **Get unstuck fast.** "What are you trying to say? Just write that." When blocked, write the truest sentence you know. Then go from there. Write a bad first version fast. Expect most of the ideas to arrive after you start.
3. **Write sentences, not paragraphs.** Audition many sentences. One gets the part. Build outward from sentences that earn their place.
4. **Read each sentence in isolation.** Does it say what it means? Does it imply something unintended? Is it ambiguous?
5. **Arrange by ear.** Try different orders. The right sequence will feel inevitable, but it's discovered, not predetermined.
6. **Cut.** If a sentence doesn't teach, clarify, or move, remove it.
7. **Stop when you know what comes next.** End each session mid-stride. You'll never be stuck.

### Editing existing prose

1. **Read the whole piece first.** Understand its shape before touching anything.
2. **Sentence by sentence.** Read with a positive/negative meter. Thousands of small intuitive choices: this word or that, here or there. Each makes the piece more distinctly yours. What does each sentence actually say? Is that what it should say? Can it be shorter?
3. **Hunt clichés, nominalizations, weasel words, and filler.** Phrases that arrive pre-assembled ("in order to", "it should be noted that", "at the end of the day"): replace or remove. Verbs turned into nouns: turn them back. Three kinds of weasel words: salt-and-pepper words that sound technical and convey nothing ("various", "a number of", "fairly", "quite"), beholder words whose meaning depends on the reader ("interestingly", "surprisingly", "remarkably", "clearly"), and lazy words that dodge quantification ("very", "extremely", "several", "many", "most", "few", "vast"). A flagged word carrying the sentence's only quantification isn't filler. Replace it with the real figure or keep it: a deletion that turns a partial claim absolute is a miscorrection.
4. **Check transitions.** Earned by the sentences themselves, or scaffolding ("However", "Additionally", "Furthermore") hiding weak connections?
5. **Apply constraint.** Arbitrary constraints (shorten by one line, cut 10%) shake the bin of ideas. Any change must be a change for the better. If you write "in other words...", delete everything before it.
6. **The boxing method.** In later drafts, bracket uncertain words. Then hunt for replacements systematically.
7. **Read it aloud.** The ear catches what the eye forgives.

## AI writing tells

LLMs produce recognizable tics. Hunt and eliminate these during every editing pass. If even one appears, the reader's trust is broken. AI prose is recognizable even with no single tell present, because it overfits on quality markers (em dashes everywhere, everything pivotal) and exhausts its content at a glance: if the reader could predict the piece from its prompt, no information was added.

<!-- @> No negate-then-reframe (either order), no em dashes or semicolons, no -ing tails, no dead AI vocabulary, no hedging stacks, no throat-clearing, no sycophancy. Tells are the filler use, not literal domain use -->
**Never negate-then-reframe.** "This isn't X. This is Y." / "Not X. Y." / "Forget X. This is Y." / "Less X, more Y." Any sentence that negates one framing then asserts a corrected one. The reversed order is the same move: "you're cultivating, not constructing" fails identically. Delete the negation. State the positive claim. This is the single most fatal AI marker.

**No em dashes, no semicolons.** If the sentence seems to need one, it is two sentences. Use commas, periods, colons, or parentheses.

**No copula avoidance.** "X is Y", not "X serves as Y" or "X stands as Y."

**No false ranges.** "From prototyping to production, it handles it all": the endpoints aren't on a scale. Name the two things. "Works for prototyping and production."

**No -ing phrase tails.** Cut participial phrases tacked onto sentences for fake depth: "ensuring better maintainability", "showcasing the team's commitment."

**No dead AI vocabulary.** "Load bearing", "real", "genuinely", "points to", "delve", "dive into", "unpack", "leverage", "harness", "utilize", "ensure", "robust", "seamless", "comprehensive", "streamline", "foster", "empower", "supercharge", "unlock", "future-proof", "straightforward", "showcase", "underscore", "meticulous", "intricate", "nuanced", "multifaceted", "holistic", "navigate" (figurative), "elevate", "embark", "resonate", "synergy." If it sounds like a press release, cut it. The ban is on the filler use. A domain term used literally ("ensure the lock is held", "robust to noise", "the stack trace points to the allocator") stays.

**No abstract place-words.** "Landscape", "realm", "tapestry", "journey" (figurative). AI uses spatial metaphors for everything because it can't experience the world.

**No inflated significance.** "Testament", "pivotal", "crucial", "vital", "paramount", "integral", "profound", "cornerstone", "transformative", "groundbreaking", "paradigm shift", "game-changing", "cutting-edge." Formulaic phrases ("plays a vital role in shaping", "stands as a testament to") are the strongest single markers of all. State the fact.

**No promotional language.** "Vibrant", "bustling", "breathtaking", "stunning", "renowned", "nestled", "boasts", "rich" (figurative). Advertising tone has no place in a neutral register.

**No dead transitions.** "Furthermore", "Additionally", "Moreover", "Moving forward", "At the end of the day", "It goes without saying", "It's worth noting", "In summary", "In conclusion", "Overall." If the connection needs a transition word to work, the sentences are in the wrong order.

**No hedging stacks.** "It might potentially help to consider" collapses to "consider". One hedge per sentence maximum. Prefer zero.

**No knowledge-cutoff disclaimers.** "As of this writing", "based on available information", "while specific details are limited." State what you know or say nothing.

**No throat-clearing.** "In today's [anything]...", "In the age of [anything]...", "To put this in perspective...", "What makes this particularly interesting is..." Delete. Start with the actual content.

**No manufactured stakes.** "Let that sink in", "Read that again", "Full stop", "This changes everything." Asserting significance proves the writing failed to create it.

**No generic positive conclusions.** "The future looks bright", "exciting times ahead", "a major step in the right direction." End on a fact.

**No insider posturing.** "Here's the part nobody's talking about", "What nobody tells you." State the insight directly.

**No rhythmic triplets.** Two items or a full list. Three adjectives in a row is a tell. One triplet in a paragraph can work. Two in adjacent sentences is a stuck pattern.

**No sycophantic tone.** "Great question!", "You're absolutely right!", "I hope this helps!", "I'd be happy to help." Cut entirely.

**No filler phrases.** "In order to" = "to". "Due to the fact that" = "because". "At this point in time" = "now". "Has the ability to" = "can". "In the event that" = "if". "It is important to note that" = delete.

**No bold-word-colon bullets.** A list of "**Speed:** faster iteration cycles" lines is generated filler. Write the sentence. (Run-in headings in a reference catalog, as in this file, are a different device: they name rules rather than decorate prose.)

**No emoji decoration.** Emojis on headings or bullets signal generated text.

**No mannered prose.** Metaphor and flourish in place of direct statement: "a dial worth turning" for "a parameter worth varying", "earns its keep" for "still matters". The phrases display the writer, drag in connotations the writer did not choose, and make the reader work harder. When a literal phrase is available, use it.

**No invented compound labels.** "Exact-head checks", "editorial-row layouts": a hyphenated coinage standing in for the ordinary noun and a plain verb. Say what the thing is and what it does.

**Vary semantic density.** AI treats every sentence as independently self-contained. Human writing varies: some sentences carry heavy freight, others breathe, and meaning accumulates non-linearly. Let some sentences depend on their neighbors. Uniform polish is the same tell at the surface: contractions, fragments, and a plain sentence where plainness serves are markers of a mind, not carelessness.

**Sentence case in headings.** AI defaults to title case. Use sentence case in every heading, including in files like this one.

The vocabulary drifts with model generations: "delve" spiked in 2023 and had faded by 2025 while other words rose. Word lists date. The instinct behind them doesn't: hunt the safe, formal, approving word chosen over the plain one, whatever this year's list says.

## Mechanics

No CAPS for emphasis. Use sentence structure and word position instead. Straight quotes, never curly quotes. Logical punctuation: period and comma go inside quotes only when the quoted text is a standalone sentence. Single quotes for terms used as terms ('working in public'). Double quotes for actual speech or direct quotation.

## Context-specific guidance

### Chat updates and explanations

<!-- @> Chat updates: the needed action or headline first, why after. Subject of the sentence = the thing acted on. Short sentences, one idea each. A detail earns its place only if it changes what the reader does. Plain verbs unless naming the actual mechanism -->
Status updates, findings, and explanations in conversation follow every rule above, plus:

- **The actionable part comes first.** If something needs a decision or an action, open with it. Say what to do, then why. A decision buried at the end of a paragraph is a decision missed.
- **Make the subject the subject.** The thing the update is about is the grammatical subject of the first sentence.
- **Short sentences, one idea each.** The reader is parsing your message between other tasks.
- **Form follows the content.** Prose for explanation, each paragraph developing one idea. A list when the items are genuinely parallel or ordered steps. A table when the reader compares items across shared attributes. Headings only when distinct sections need navigation. Prefer familiar, literal wording throughout.
- **A detail earns its place only if it changes what the reader does.** A count ("installed 16 packages") matters only when one member of the count needs calling out. Otherwise the fact is "dependencies were stale and are now installed."
- **Plain verbs.** A dramatic verb ("armed", "fired", "tripped") only when it names the actual mechanism. Prefer "turned on", "started", "scheduled".

Identifiers follow the real-name principle. A rewrite in that shape:

> Before: "This armed a nightly sweep. purgeExpiredDrafts queues a deletion job per workspace, so the 2am tick will fire."
> After: "Decide whether nightly draft cleanup should stay on. Enabling the flag scheduled a nightly job (`purgeExpiredDrafts`) that deletes expired drafts in every workspace, including ones you may still want."

### PR descriptions and commit messages

<!-- @> PR/commit: problem before solution, present tense, no throat-clearing. Docs: significant everywhere, prefer examples. Rules: maximum density, imperative, no hedging -->
Problem before solution. Direct, no filler. Present tense. Every sentence carries information. No throat-clearing ("This PR adds..."), no status narration, no file listings.

### Documentation and READMEs

Significant everywhere. Each section useful on its own, not a waypoint to the next. Prefer examples over explanation: show, then name. Do not explain too much. It is seldom advisable to tell all.

<!-- @> Docs: match the codebase's existing altitude and scope. Don't document internals (payloads, data attributes) nothing else documents, or present non-public surface as public. Keep feature docs durable (concepts, synonyms, product placement), not pinned to fast-changing UI. Ground claims against code across the whole stack -->
**Match the surrounding altitude and scope.** Document at the level the codebase already documents: don't introduce internals (wire payloads, data attributes, private helpers) that nothing else documents, and don't describe a non-public surface as if it were public API. Keep feature docs durable. Name the concept and its synonyms, where the feature lives in the product, and how users reach it. Omit fast-changing specifics (exact layout, control labels, copy) that drift. Ground every claim against the actual code on each side of the stack the feature touches, not just the repo you are editing.

**File links in markdown docs** (review docs, `.context/` files, etc.):

- **Relative paths** resolve from the containing file's directory. **Workspace-root paths** start with `/` and resolve from the project root, which survives restructuring.
- **Line numbers** use `#L<number>` fragment syntax: `[link](/path/to/file.ts#L21)`. The `:line` suffix does not work in editor markdown preview.
- **Display text** can use the familiar `file.ts:21-45` format. Only the link target needs `#L` syntax.
- **Cursor-specific:** `cursor://file/<absolute-path>:line:col` opens a file at a line but requires absolute paths. Use only in machine-local documents.

### Agent instructions, rules, and prompts

Maximum density. Each rule one sentence if possible. Imperative mood. No hedging ("should probably", "might want to"). Pair principles with examples, and generalize every example: never the case that prompted the rule (see GLOBAL.md, "Examples teach the principle, not the incident"). Generalize without sanding to a truism. The example must keep a real decision point, showing where the rule does *not* apply, or it teaches nothing. This holds for LLM and image prompts too: abstract the one vendor, brand, or customer the prompt was written against into a representative form. For prompt-specific craft (affirmative framing, caching, length), see `/llm-prompt-authoring`.

**Rule files obey their own rules.** A writing guide with title-case headings under a sentence-case rule, or em dashes beside an em-dash ban, reads as pasted rather than examined. Audit the file against its own contents before shipping it.

### Comments in code

Comments explain why, not what. If a comment explains what, refactor the code until it doesn't need to. A comment that could be a better function name is not worth keeping.
