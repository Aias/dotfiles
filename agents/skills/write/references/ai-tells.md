# AI Writing Tells

Patterns that mark prose as AI-generated. Derived from Wikipedia's "Signs of AI writing" guide and direct observation. Each pattern includes before/after examples.

## Constructions

### "Not just X, but Y"

Any use of "just" to contrast or elevate. The single most reliable AI marker.

- "not just X, but Y"
- "it's X, not just Y"
- "more than just X"

> Before: "It's not just a linter; it's a way to enforce team standards."
> After: "It enforces team standards."

### Copula avoidance

Using "serves as", "stands as", "functions as", "acts as" instead of "is".

> Before: "This module serves as the entry point for the application."
> After: "This module is the entry point."

### Negative parallelism

"Not only...but also", "It's not about X, it's about Y."

> Before: "It's not about speed, it's about correctness."
> After: "Correctness matters more than speed."

### False ranges

"From X to Y" where X and Y aren't on a meaningful scale.

> Before: "From initial prototyping to production deployment, the framework handles it all."
> After: "The framework works for prototyping and production."

### Superficial -ing phrases

Tacking participial phrases onto sentences to add fake depth: "highlighting", "underscoring", "emphasizing", "ensuring", "reflecting", "showcasing", "fostering", "contributing to".

> Before: "The refactor simplifies the data layer, ensuring better maintainability and showcasing the team's commitment to code quality."
> After: "The refactor simplifies the data layer."

## Vocabulary

### Inflated significance

"testament", "pivotal", "crucial", "vital", "key" (adj.), "landscape" (abstract), "tapestry" (abstract), "cornerstone", "paradigm shift", "groundbreaking", "game-changing", "transformative", "indelible mark", "deeply rooted"

### AI filler words

"Additionally", "Furthermore", "Moreover", "delve", "leverage", "ensure", "robust", "seamless", "comprehensive", "streamline", "bolster", "spearhead", "facilitate", "harness", "empower", "cutting-edge"

### Promotional language

"vibrant", "rich" (figurative), "profound", "nestled", "in the heart of", "breathtaking", "stunning", "renowned", "must-visit", "boasts"

## Punctuation and Formatting

### Em dashes

LLMs overuse em dashes as all-purpose connectors. Use commas, periods, colons, semicolons, or parentheses instead.

### Curly quotes

ChatGPT produces curly quotes ("\u201c...\u201d") instead of straight quotes ("..."). Use straight quotes.

### Emoji decoration

Emojis before headings or bullet points signal generated text.

### Boldface overuse

Mechanically bolding terms on first mention or bolding headers within list items.

### Inline-header lists

The bold-word-colon-description pattern in bullet lists:

> Before:
> - **Speed:** Faster iteration cycles
> - **Quality:** Better test coverage
> - **Adoption:** Growing usage

> After: Faster iterations, better test coverage, growing usage.

### Title case in headings

AI defaults to title case. Use sentence case unless the project convention requires otherwise.

## Tone

### Sycophantic/servile language

"Great question!", "You're absolutely right!", "That's an excellent point!", "I hope this helps!", "Let me know if you'd like me to expand on any section."

### Generic positive conclusions

"The future looks bright", "Exciting times lie ahead", "This represents a major step in the right direction." Replace with specific facts or cut entirely.

### Hedging stacks

Multiple qualifiers in one sentence: "It could potentially possibly be argued that this might have some effect." Collapse to the actual claim.

### Knowledge-cutoff disclaimers

"As of [date]", "While specific details are limited", "based on available information." State what you know or say nothing.

## Structure

### Rhythmic triplets (rule of three)

LLMs force ideas into groups of three to appear comprehensive. Two items or a full list. Three adjectives in a row is a tell.

> Before: "Fast, flexible, and reliable."
> After: "Fast and flexible."

### Elegant variation

Straining to avoid repeating a word by cycling through synonyms. "The protagonist", "the main character", "the central figure", "the hero." Repeat the word.

### "Challenges and future prospects" formula

Formulaic section: "Despite its [strengths], [subject] faces challenges typical of [category]. Despite these challenges, [optimistic conclusion]." Cut entirely or replace with specifics.

### Filler phrases

| Before | After |
|--------|-------|
| In order to | To |
| Due to the fact that | Because |
| At this point in time | Now |
| In the event that | If |
| Has the ability to | Can |
| It is important to note that | *(delete)* |
| It should be noted that | *(delete)* |
| At the end of the day | *(delete)* |
