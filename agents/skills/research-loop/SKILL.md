---
name: research-loop
description: >-
  Run a seed-driven research round that widens a project's possibility space and records the
  findings in a private dataroom. Use when the user supplies a seed or asks for the next round.
  Design, prototyping, data tests, and write-ups of settled ideas are separate tasks.
---

# Research loop

A round starts from a seed the user chooses: a page, paper, site, or concept that shows what good looks like. The round follows the seed in one direction through many small steps, saves what it finds in the dataroom, and closes with a synthesis for the user's review. The method adapts "Alpha generation p1: self-editing heartbeats with seeds": a single thread edits its own scratchpad as working memory, the dataroom grows behind it, and rare sources count for more than consensus ones.

## Stance

Widen the space of what the project could be. The project's existing work and repositories show where an idea would attach, and the round ranges beyond them. When steps start specifying how one solution would work (routing rules, thresholds, caching, data shapes), the round has drifted into design. Return to finding more applications, especially ones that pair older ideas from the field with current models and tools.

Stay in research until the user ends the exploration phase. Read code and data to ground or rule out an idea. Proposals for sketches, prototypes, data tests, or builds wait for that signal.

Cite only sources you opened, and open an example before presenting it as evidence. Label each claim as external evidence with its read depth, as confirmed in the code, or as a hypothesis. When the user rejects a direction, record it as a dead end with the reason and steer later rounds away from it. Adopt the user's terms for recurring concepts.

## The round

Keep the round's state in `round<N>-scratchpad.md` in the dataroom, with these sections: current objective, what good looks like (the seed, past rare finds, source types that paid off), guardrails, ranked leads, deprioritized directions, step log, stop condition. Hold it to ranked conclusions with absolute dates. Overwrite stale sections instead of appending.

Each step takes a few minutes and is done by the main thread, which steers between steps:

1. Read the scratchpad, pick one lead, and scope the step in a line.
2. Do one search or one close read of one specific example.
3. Verify the load-bearing quotes and every image against the source.
4. Write `notes/round<N>/step-NN.md`: what led here and by which route (seed link, recall, first-page search, citation chain, non-English query, adjacent field), the source and its read depth, the finding with its claim labels, and any images.
5. Rewrite the scratchpad: re-rank, prune, and add leads. New directions enter the round here.
6. Commit the dataroom.

A subagent fits a small side task you direct, such as reading one long PDF for one question or capturing one screenshot, on a mid-tier model. Re-fetch any image a subagent reports from its original source before using it, and check that it shows what the note claims. A ten-minute subagent sweep inside a step dissolves the loop: it costs more than a round should, returns consensus sources, and takes the steering away from the thread that holds the scratchpad. Short steps by the main thread are where the rare finds come from.

Write a short checkpoint synthesis every few steps. Stop at the step budget the user set (8 to 15 is typical) or after two consecutive steps with no new high-signal find. Then write `notes/round<N>-synthesis.md`: what the seed changed, editorial picks with evidence and read depth, supporting finds, dead ends, open questions.

The main thread runs on the strongest tier. The user decides the step budget and the quality-against-cost trade-off for each round. Report the round's actual cost when the harness exposes it.

## Fan-out round

When the user asks for breadth across source kinds in one pass, split the extension into four or five tracks, each on a different kind of source: academic lineage, practitioners and industry, adjacent fields (games, libraries, museums, scholarly apparatus, print and pre-web traditions), non-English traditions, the project's own code. Run the tracks as parallel subagents on a cheaper model, with no frontier model or high reasoning effort, each with a self-contained prompt that repeats the source rules below. A track logs about eight to ten sources, reads about three in full, reports one or two that a plain search would miss and why each matters, and looks for counter-evidence. The main thread chooses the tracks, spot-checks the load-bearing claims, re-fetches the images, and writes the synthesis.

## Sources

Follow citations backward to references and forward to citing works through Semantic Scholar, OpenAlex, or Google Scholar. Dissertations, archived lab pages, standards, patents with figures, vendor and theme source code, conference talks, and mailing-list archives hold what the first page of results omits. Query a tradition in its own language. Look for counter-evidence: abandoned features, negative results, critiques, postmortems.

Seed links, recall, and first-page web search are the easy routes, and they return consensus sources that agree with each other. Before writing the synthesis, count the round's sources by route. If none came from a citation chain, a non-English query, or an adjacent field, spend the next steps on those routes before stopping.

Record what led to each source and how deeply you read it (full, excerpts, abstract, snippet). Keep the key quotes in the notes with where they appear in the source. Save a full copy only when a source is hard to fetch again or needs long quotation.

When a finding describes an interface, capture it: a screenshot or a crop of a figure, saved in the dataroom with its source and a caption, embedded in the note, and included in the round's closing message.

## Dataroom

The dataroom is private working space on the local machine. Nothing from it goes into tickets or shared documents until the user asks for a write-up. Its location and layout are in [references/dataroom.md](references/dataroom.md).

## Ending a round

Commit the dataroom, then message the user with: what the seed changed, the strongest leads with evidence and read depth, the rarest or most surprising find, the round's sources counted by route, the key images, anything about the process that should change, the round's cost if known, and two or three candidate seeds for the next round with one recommended. Attach the synthesis. Stop for review, unless the user has said to continue on your own, in which case the recommended seed opens the next round.

When the user corrects the process itself, apply the correction in the current round and add it to this skill's `skill.feedback.md` in the dotfiles source.

## Consolidation

After several rounds, when the user asks for a map or a pattern language of everything so far, reread the conversation, every note, and the log rather than working from memory. Build a digest of findings and decisions with their sources first, then write the patterns from it. Each pattern cites its digest rows and carries an evidence tag: a source showed it, a source proposed it, it is a hypothesis, or something like it already exists in the project. Close with the ideas set aside and the open questions, having resolved the ones that code or sources can answer.
