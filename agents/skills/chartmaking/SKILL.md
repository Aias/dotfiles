---
name: chartmaking
description: >
  Create or revise charts from data, defaulting to R and ggplot2. Make data-dense,
  multivariate graphics guided by Jacques Bertin, Eduard Imhof, Edward Tufte,
  and William S. Cleveland. Use for chart artifacts and chart design, not general illustration.
---

# Chartmaking

Make charts rich in information and restrained in aesthetics. Use the resolution of typography,
high-DPI displays, and the human eye to reveal patterns, comparisons, and individual details.
Default to reproducible R and ggplot2 with a static export and its source.
Honor explicit requests for another tool, format, or established visual system.

Bertin leads the encoding and arrangement of information. Imhof informs hierarchy and color.
Tufte informs density, context, and graphical integrity. Cleveland informs perceptual accuracy
and multivariate comparison. These working defaults synthesize their principles.

## Compared to what?

Every chart must answer "compared to what?" Establish a meaningful comparison through peers,
history, a control, a target, a reference distribution, or another relevant baseline.
Put the comparison in the graphic where readers can see it. An isolated value needs context.
Use available evidence. Ask for a missing comparator when inventing one would change the meaning.

Inspect the data before choosing the form. Identify the observational unit, measurement units,
denominators, time coverage, and the distinction between nominal, ordered, and quantitative fields.
Preserve differences between zero, missing, and not applicable. Check aggregation, incomplete
periods, and uncertainty when they affect interpretation. Keep transformations in the source.

## Encode and arrange

Choose visual variables whose perceptual properties match the information and reading task.

| Information | Working default |
| --- | --- |
| Quantity requiring precise comparison | Position on a shared scale, or length from a common baseline |
| Ordered magnitude | Ordered position or a clear progression in lightness |
| Nominal identity | Distinct hue, shape, or position without implying rank |
| Additional grouping variables | Facets, grouped displays, or matrix rows and columns |
| Geographic relationships | A map when location or spatial structure matters |

Favor aligned position for close quantitative comparisons over judgments of angle or area.
Use proportional symbols when overall magnitude matters, with area proportional to quantity.
Texture and orientation remain available when they are legible at the export size.
Give each visible distinction a stable meaning. For many categories, use grouping, position, or
facets so readers can perceive distributions without decoding a large inventory of symbols.

Order categories by a relevant measure, meaningful grouping, or similarity rather than accepting
input order. Preserve chronology and other inherent orders when position carries that meaning.
For entities described by multiple variables, consider a matrix or aligned profiles. Try row and
column arrangements that expose groups, gradients, and exceptions. Apply a common entity order
across variables so each row or column retains its identity. Preserve the order in the source.
Integrate descriptions, identifiers, and distinct quantitative, binary, and missing states as needed.
With different units, use explicit scales or disclosed normalization so visual similarity does not
imply false comparability. Fine rules or spacing can clarify groups without overpowering the marks.

## Dense, multivariate displays

Show relevant relationships, distributions, variation, and uncertainty together. Add variables that
deepen the comparison. Preserve observations where they matter instead of reducing everything
to a few averages. Organize the view to reveal overall structure, groups, exceptions, and detail.
Support sustained study when it yields useful discoveries. Reduce effort spent decoding the display
while retaining evidence worth examining closely. Judge efficiency against the question being asked.

Use facets and small multiples as standard tools for multivariate comparison. Align panels and keep
scales consistent when comparing magnitudes. Use free scales for within-panel patterns only when
their differences are explicit. Keep category order and visual encodings stable across panels.

Use scatterplot matrices to expose pairwise relationships among several quantitative variables.
Use conditioned scatterplots to examine how a relationship changes across groups or ranges of
another variable. Preserve the raw observations when possible, with marks that reveal overlap.
Keep each variable's scale consistent across its panels and integrate variable names and units.
Outer axes and diagonal labels can reduce repetition while preserving a readable matrix.

Integrate sparklines with names and numerical columns when histories enrich a table or summary.
Place the current value, units, time span, and useful reference values beside the miniature series.
Align time domains. Share y scales when comparing levels or amplitudes. When comparing shapes
on separate scales, make the different units, ranges, or normalization clear.
Preserve missing intervals as gaps. Connect across them only when an explicit model justifies it.

Use finely set, readable typography and sufficient plotting area for detailed marks.
Spend available resolution on evidence, including longer histories and more comparable panels.
Increase the canvas or organize panels when necessary to preserve legibility.
Choose aspect ratios that reveal variation without flattening or exaggerating it. Consider banking
line segments toward 45 degrees when slope differences matter, while preserving comparable panels.

## Restrained visual hierarchy

Keep large backgrounds and supporting layers quiet. Give the data the strongest visual signal.
Concentrate saturation and contrast where they carry meaning. Use sequential lightness for ordered
magnitude, diverging color around a meaningful reference, and qualitative colors for categories.
Check distinctions against the actual marks and background. Reinforce essential color differences
with labels, position, shape, or line type when needed.

Use direct labels when they improve association without obscuring evidence. Use legends when
they make a dense display easier to read. Retain sufficient contrast for text, fine lines, and intervals.
Derive the style from these relationships. Historical influence does not require antique paper,
decorative typography, simulated printing, or a fixed palette.

Remove chartjunk: ornamental effects, redundant framing, and visual variation unrelated to data.
Retain useful axes, gridlines, reference marks, and annotations. Information density comes from
readable evidence and efficient arrangement, not from shrinking everything or stripping context.

## Integrity and delivery

Make visible lengths, areas, and progressions agree with their stated scales. Use zero baselines
when bar length represents magnitude. For position-based displays, choose limits that reveal
relevant variation and keep the scale clear. Show uncertainty and sample size when consequential.
Identify units, transformations, and reference values where readers need them.

Use vector output or a raster rendered for the intended display dimensions and pixel density.
Inspect the exported artifact at its intended reading size. Check collisions, clipping, fine marks,
scale comparability, and whether emphasis follows the evidence. Deliver the chart and reproducible
source, with material data limitations or unverified rendering details in the handoff.

Use [ggplot2 implementation](references/ggplot2.md) for rendering and export mechanics.
See [design foundations](references/design-foundations.md) for source principles and attribution.
