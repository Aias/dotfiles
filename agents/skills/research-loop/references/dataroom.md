# Dataroom

Keep one dataroom per project at `~/Code/datarooms/<project>/`, as its own git repository. A workspace directory such as Conductor's `.context/` is gitignored and goes away with the workspace, so a dataroom placed there loses its history and its commits silently do nothing. Create the repository on the first round and commit after every step.

| Path | Contents |
| --- | --- |
| `README.md` | The project and the research objective, in a few lines. |
| `round<N>-scratchpad.md` | The round's self-edited working memory: objective, what good looks like, guardrails, ranked leads, deprioritized directions, step log, stop condition. Short, ranked, conclusions only. |
| `notes/round<N>/step-NN.md` | One note per step: what led here, source and read depth, finding with claim labels, images. |
| `notes/round<N>-synthesis.md` | The round's closing synthesis. |
| `index.md` | One row per URL: title, round and step, what led to it, read depth, saved path, and a one-line note on why it matters. |
| `log.md` | One entry per round: the seed, what changed in the thinking, the path to the synthesis. |
| `overview.md` | A reading map grouped by thread, editorial picks, and open disagreements, revised as the dataroom grows. The pattern language from a consolidation lives here too. |
| `sources/` | Copies of sources that are hard to fetch again or quoted at length. Keep a PDF beside its extracted text. |
| `images/` | Screenshots and figure crops, named by source, captioned where a note embeds them. |

The scratchpad is the short store and the dataroom is the growing one. A dataroom made of a few summary files is a second scratchpad. The index lets a later round, or a later agent, see the path the research took.
