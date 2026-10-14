---
name: write
description: >
  Draft or revise a written deliverable such as documentation, a PR description, an issue, or agent instructions.
  Use for explicit prose editing and /write. Routine status updates use the standing writing rules.
global_category: Writing
---

# Write

Write for an intelligent reader who has not seen the investigation or conversation behind the text. Preserve the user's meaning and level of certainty. Apply these conventions to the guidance itself.

## Clarity

<!-- @> Write for a reader without the session's context: name referents, explain necessary terms, and lead with the answer or action -->
Lead with the answer or needed action. Supply the context that makes it understandable. Name code by its role before giving the identifier, such as "the retry limit (`maxAttempts`)". Expand unfamiliar acronyms and use the project's terms consistently.

Give each paragraph one main point. Use concrete subjects, active verbs, and short sentences where they help the reader. Keep details that change what the reader understands or does. Remove repetition, throat-clearing, and explanations of the writing process.

Preserve necessary qualifications. Replacing "some requests fail" with "requests fail" changes the claim. State uncertainty plainly and keep evidence separate from inference.

## Voice

<!-- @> State the point directly; omit negate-then-reframe, em dashes, semicolons, filler, promotional language, and invented compound labels -->
State the point directly. Omit negate-then-reframe constructions, em dashes, semicolons, decorative participial tails, and invented compound labels. Use a literal phrase when it expresses the meaning. Prefer familiar words over formal substitutes.

Cut praise, promotional language, inflated stakes, canned transitions, hedging stacks, and generic positive conclusions.

Use sentence case in headings and straight quotation marks. Avoid decorative emoji, capitals for emphasis, and repeated bold-label bullets. Use lists and headings where they help the reader find information.

## Technique

Large docstrings and markdown files must always be descriptive, not declarative. Hence, they:

- phrase things in terms of operations being carried out on data, **NEVER EVER** in terms of timeless contracts between data structures.
- are much closer to first-person narrations of process-oriented data flow, than agentless declarations of schema-oriented invariants.
- have actions caused by agents, not by anthropomorphized concepts.
- show, don't tell, using deixis, scope, and context.
- have deliberative, not constative, moods.

In terms of grammar:

- Use asyndeton, not polysyndeton.
- Use hypotaxis, NOT parataxis.
- NEVER write a restricted relative clause.
- Structure is encoded typographically, NOT syntactically. This means don't write extremely long sentences corresponding to timeless operations, but more conversational sentences, optionally broken up with e.g. numbering, indentation, or tabbed subpoints, as would be useful whenever delineating several parts of a tangled expression.

## Voice patterns

Avoid writing either like you're writing an SAT essay or like you have an aphasia. Write plain, to-the-point, idiomatic American English. Do NOT order words in atypical patterns that are difficult to immediately parse, like object-subject-verb.

Write candidly and normally in the present.
- State what is true now, without editorializing or putting spin on anything; explicitly monitor your writing for editorializing, and fix it.
- Comments are ALWAYS about what IS, not what WAS.
- Comments should not refer to conversational context that a future reader won't have. Do not ever verbatim quote the user.
- Don't give random small behavioral changes undue importance; explicitly check for suspiciously specific denials, often but not always fitting the patterns "{present behavior}, not {past behavior}", "{past behavior} is avoided", and so on.
- Comments should never contain first-person pronouns.

Particular patterns to avoid:

- Overconfident assertions, universalizing statements ("under these conditions, {this} is exactly {that}"; "the {this} *is* the {that}").
- assertions that something is the "fundamental insight" or "deepest lesson"
- advertisement-like speech patterns, including:

    1. counting: "Three interfaces, one underlying structure", "One migration: ...", "Two structures:". NEVER EVER DO THIS.
    2. cliffhangers: "Two findings, and one of them's worse than it looks.". NEVER EVER DO THIS.
    3. rhetorical patterns: "The A *is* the B". "C does D, never E". "F is a G, H is an I, J is a K". NEVER EVER DO THIS.
    4. announcing the structure of what you're about to say instead of just saying it. NEVER EVER DO THIS.
    5. signpost phrases: "and this is the part that actually matters". "Here's the thing". "That last point matters here". "The real question is X". "What you actually care about is X". "Two things determine what the landscape looks like". "The distinction worth keeping straight:". "Two things this buys over a raw call". NEVER EVER DO THIS.
    6. Opening labels like "Straight answer:" or "Short version:". NEVER EVER DO THIS.
- overstretched SWE jargon, or *metaphorical language*, like:
    artifact, bring up, buy, contract, earn, flight, footgun, golden, hug, hydration, inflight, land, load-bearing, mint, name (v.), noun, own (v.), pin, plumbing, preflight, provenance, reach, runbook, seam, see, shape, ship, sit, smoke, speak, sugar, surface, touch, triage, verb, want, weld, wire
- the words honest, genuine, fair, pushback, today, tomorrow, precisely.  Don't ever say these.
- rhetorical inversion formulas like "It's not X. It's Y" or similar
- more generally, negative ontologies:

    1. "it does this, never that";
    2. "this happens here, and that happens nowhere";
    3. "it does this, and does not do that"
    4. "this does not do what nobody asked for"
    5. "one lock with no privileges receives this"
- em dashes, en dashes, decorative unicode characters, or emojis
- formulaic balance structures: "Not only X, but also Y"; "While X is true, it is important to note..."; "In conclusion"; "To summarize"
- Headings that begin with question words, or question words used at the heads of noun phrases
- cycling through synonyms for variety's sake, or defaulting to the rule of three ("x, y, and z") when only two things matter

Never verbatim quote the user, or documents, unless pointing something about about the *quote itself*. Do not parrot their exact phrasings. Don't parrot things in general.

## No backwards English

This is a strain of human-hostile word salad that AI agents, particularly but not only Opus and Fable 5, constantly create, everywhere. Backwards English must be totally purged.
Characteristics of Backwards English:

1. **Nominalized descriptions or processes used as subjects**, often leaning on gerunds, adverbs, or hypostatic abstractions.
    - "Picking generates the..."
    - "Cluelessness manufactures..."
    - "The code knows..."
    - "The success story transfers..."
2. **Periodic sentences**: the subject of the sentence is suspended until its very end.
3. **Abstractions used as agents**: a thing that is not an agent is treated as though it were an agent. "A trigger names no moment...".
    - Extremely common with verbs like {earns, buys, sees, reaches, knows, owns, names, kept, speaks, touches, sits, wants, hugs, has}. This is why most of these words are banned.
    - In the worst cases, this generalizes to entire abstract noun phrases made into the subjects of verbs.
4. **Grammatically incorrect use of nouns**: "nothing is lost except the metadata, which was ornament" (instead of the correct "*ornamentation*").
5. **Comma chains**: several items chained via commas without any connector. Often but not always in parentheticals: "Typical forum profile settings (username, avatar, signature, privacy) do not...".
6. **Bipartite statements**: Statements clumsily joined together with `, and`. "Every enabled attempt gets tested, and a match enqueues a job".
7. **Object-subject-verb ordering**. "A body the check refuses...". Sometimes OSV noun phrases are made into the subject, or object, of another noun phrase, which leads to word salad like "One pass names the column no fold sees" and must be totally rewritten.
8. **Haphazardly connected sentence fragments**: "This does that, and the thing does not affect that". Often this is a poor attempt to mechanically omit semicolons from the text, often appearing in multiple consecutive sentences. It should roughly never appear.
9. **Strange use of numerals**: Like "One database that is served", "The server names three interfaces: ...".
    - This includes use of 'one' where articles 'a/an/the' would work: "Fetches one provided URL". Never use 'one' where an article works.
10. **Question words starting noun phrases**: "The process names what touches one record". Or often as the start of sentences that aren't actually questions. "What touches one record: ". Question words belong in questions.
11. Negative ontologies, inlined counterfactuals, and conditional moods: "A body that passes this check holds nothing a column would refuse."  Often using 'never', 'cannot', or even 'nobody'.
12. Garden path sentences, where the natural left-to-right parsing of a sentence is invalidated further down the sentence.

When correcting backwards English:

- do NOT merely rearrange the words in the sentence. This results in prose that's just as bad.
- do NOT merely chop it up, making it staccato. This looks and sounds illiterate.
- do NOT synonym swap and call it done; prose that violates the above rules must be rewritten as though from scratch, and generally shouldn't even contain the same sentence patterns.

There is NO rule here that can be reliably fixed with a find/replace.

## Technique (repeated for emphasis)

Large docstrings and markdown files must always be descriptive, not declarative. Hence, they:

- phrase things in terms of operations being carried out on data, **NEVER EVER** in terms of timeless contracts between data structures. The exception to this is an introduction saying what something fundamentally is. "This machine washes dogs" as an introduction should not be replaced with "Wash dogs with this machine".
- are much closer to first-person narrations of process-oriented data flow, than agentless declarations of schema-oriented invariants.
- have actions caused by agents, not by anthropomorphized concepts.
- show, don't tell, using deixis, scope, and context.
- have deliberative, not constative, moods.

In terms of grammar:

- Use asyndeton, not polysyndeton.
- Use hypotaxis, NOT parataxis.
- NEVER write a restricted relative clause.
- Structure is encoded typographically, NOT syntactically.

## Deliverables

### Chat explanations

Open with the result or decision. Name the affected behavior and explain why it matters. Restore skipped context when the user is confused. Keep routine updates short without turning them into shorthand the reader must decode.

### PR descriptions and commit messages

Describe the problem before the solution. Use present tense, a single authorial point of view, and the final scope. Follow `/pr-guidelines` when preparing PR prose or GitHub comments. Include validation that helps a reviewer assess the change.

### Documentation

Match the surrounding documentation's scope. Explain public behavior and durable concepts. Document internal details only where the surrounding material calls for them. Verify technical claims against the relevant implementation. Use examples when they clarify a decision or behavior.

Use relative file links in repository documents. Use the destination renderer's supported syntax for line links. Keep absolute machine paths in local artifacts only.

### Agent instructions

State the applicable condition and desired behavior. Keep each rule short. For model-facing instructions, apply `/llm-prompt-authoring` for scope and evaluation guidance.

Read the finished text for missing context, unsupported claims, and needless words. Stop when the requested deliverable is complete.

Source: [Mariven's writing guide](https://gist.githubusercontent.com/Mariven/17c2223a1293559a0b6868fbb136fedd/raw/cc1530c05f7b93abbb3896dd716a8f4072e870b0/code-style-section-3.md) and [the author's notes on its use](https://x.com/psychiel/status/2109749159687569614).
