---
name: what
description: >
  Use the moment the user signals your last message did not land: "wait, what", "bruh", "huh?",
  "you lost me", "in English", "say that again", "I don't follow", "what does that mean",
  "too much jargon", "explain that like I'm not you", "stfu and speak properly", or a bare "???".
  Also triggers on rereads of your own draft that read as dense, hedged, or corporate.
  Re-pitches the last message in plain language: restores the context you skipped, cuts the
  padding, and speaks in the project's own words.
global_category: Writing
---

# What

The user did not ask you to be brief. They told you where they fell off.

Those are different requests, and the difference is the whole skill. An agent told "be brief" writes a telegram. It deletes words, and the first words to go are the setup that would have made the rest land. An agent told "you lost me" backs up and explains. Delete the padding, keep the meaning, and add back whatever you assumed the reader already had.

<!-- @> "You lost me" = re-pitch, not compress: name the failure (missing context vs padding), restore skipped context before cutting, open with the answer, speak in the project's own terms -->

## First, find where they fell off

Reread your last message and name the actual failure before rewriting. There are two, and they pull in opposite directions:

**Missing context.** You referenced something the user has no reason to know: a file they have not opened, a decision made three turns ago, a term you coined mid-sentence, an acronym, a constraint you discovered but never stated. The repair *adds* words. Plain does not mean short.

**Padding.** The meaning was there, buried under hedging ("it may be worth considering whether"), corporate voice ("we should look to align on"), throat-clearing, or jargon standing in for a concrete noun. The repair *cuts* words, and nothing is lost.

Most stuck messages are both. Fix both, in that order: restore first, then cut. Cutting first throws away the sentence you needed to keep.

## Then re-pitch it

Lead with the thing they need. If your last message buried the answer under its own reasoning, the rewrite opens with the answer.

Say it straight, like you are leveling with a friend at the next desk. Not writing a report, not softening a verdict. If something is broken, say it is broken. If you do not know, say you do not know. Hedging reads as padding because it usually is.

Use short sentences, one idea each, active voice, present tense. This is roughly [ASD-STE100 Simplified Technical English](https://www.asd-ste100.org/), the controlled-language spec aviation uses so maintenance manuals cannot be misread: approved words, one meaning per word, short sentences, no noun stacks. You do not need the word list. You need its instinct.

While you cut, hunt the AI tells cataloged in `/write`: hedging stacks, dead transitions, and filler phrases are exactly the padding that loses people. The standing craft rules for chat updates live there too.

Ground every explanation in something the user can point at: a file, a command, a symptom they saw, a number. Abstractions are what lost them.

## Speak the project's language

Before you rewrite, check what this codebase calls things. Look at `CONTEXT.md`, `AGENTS.md`, `CLAUDE.md`, and the surrounding source for the ubiquitous language: the domain terms the team already shares.

Use those words. A term you invented to explain a term you invented is how the message got stuck in the first place. When the project has a name for something, that name is the plain-English version, even if it is technical.

If no shared term exists, use the ordinary word and say plainly that it is your shorthand.

## You got it right when

- The rewrite is **shorter and clearer**, not shorter and blunter. Blunt-and-still-confusing is the failure mode to watch for. It feels like progress because the word count dropped.
- Context you skipped is now stated, not merely deleted.
- Every invented term is gone, replaced by a project term or a plain one.
- The user could act on it without asking a follow-up.

Do not apologize, do not narrate the rewrite, do not explain what went wrong with the first attempt. Just say the thing again, properly.
