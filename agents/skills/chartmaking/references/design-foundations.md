# Design foundations

The skill applies these sources to contemporary chartmaking. Its ggplot2 preference, high-DPI
export workflow, accessibility checks, and specific defaults are implementation choices.

## Jacques Bertin

Bertin distinguishes qualitative, ordered, and quantitative components. Their visual encodings
must support the corresponding kind of perception. This supports choosing encodings from the
data's structure and preserving meaningful order. See pages 34–39 of *Semiology of Graphics* in
the [publisher's sample](https://www.esri.com/content/dam/esrisites/en-us/esri-press/book-pages/sample-page/semiology-graphics-diagrams-networks-maps.pdf).

The English-edition preface calls for seeing structure, groups, and exceptions together with
detail. The "Image theory" section judges efficiency by the effort needed to answer a particular
question. A display that permits individual lookup can still impede recognition of a distribution.
Use these principles to organize dense evidence and reduce unnecessary symbol decoding.

"Graphic processing by matrices" demonstrates permutations shared across aligned variable
profiles. The entity order stays consistent so relationships survive the rearrangement.
"The reorderable matrix," page 256, integrates quantitative and binary indicators, missing states,
identifiers, and descriptions. These examples support density through structured alignment.
The [publisher's contents](https://www.esri.com/content/dam/esrisites/en-us/esri-press/book-pages/toc/semiology-graphics-diagrams-networks-maps.pdf)
locate these sections. Perin, Fekete, and Dragicevic's
[research on Bertin's matrices](https://www.researchgate.net/publication/325052190_Jacques_Bertin%27s_Legacy_in_Information_Visualization_and_the_Reorderable_Matrix)
documents the method and extends it through computer-assisted reordering.

## Eduard Imhof

Imhof relates saturation to area and surrounding context. Muted base colors allow smaller areas
of strong color to remain distinct. Apply this relationship to contextual layers, uncertainty
bands, and emphasis. See page 72 of *Cartographic Relief Presentation* in the
[book preview](https://books.google.com/books/about/Cartographic_Relief_Presentation.html?id=cVy1Ms43fFYC).
This principle does not prescribe an earth-tone palette.

## Edward Tufte

Tufte joins detailed evidence with comparison and graphical integrity. His
[sparkline essay](https://www.edwardtufte.com/notebook/sparkline-theory-and-practice-edward-tufte/)
shows miniature histories integrated with numerical tables, using typographic resolution to
place extensive evidence within the reader's field of view. Nearby numbers and words supply
quantitative context. Apply that ambition to high-DPI displays without carrying forward the
essay's historical claims about monitor resolution.

His books connect high information content with small multiples, layering, and separation.
See [The Visual Display of Quantitative Information](https://www.edwardtufte.com/book/the-visual-display-of-quantitative-information/)
and [Envisioning Information](https://www.edwardtufte.com/book/envisioning-information/).
The skill's use of restrained aesthetics preserves the detail needed for comparison.

In his own contribution to the [color discussion](https://www.edwardtufte.com/notebook/generating-n-optimally-differentiatable-colours/),
Tufte stresses perceived proportionality, surrounding context, and quantitative labels.
This supports ordered lightness scales and numerical context alongside color.

## William S. Cleveland

Cleveland and McGill's [Graphical Perception](https://faculty.washington.edu/aragon/classes/hcde511/s12/readings/cleveland84.pdf)
develops a theory of perceptual tasks and tests particular position, length, and angle judgments.
Its experiments favor position on a common scale for the comparisons tested. The paper also
considers area, volume, and shading. The full proposed ordering is broader than the experiments.
Use this work to select encodings for the reader's task, without treating a ranking as a universal
verdict on every chart form.

Their grouped dot charts demonstrate multivariate comparisons with aligned quantitative scales.
This supports arranging groups and variables so readers can compare values directly.
Tufte's sparkline essay also explains Cleveland's banking-to-45-degrees approach to aspect ratios.
Consider it when comparing slopes, alongside panel alignment and the physical reading size.

The skill also favors scatterplot matrices and conditioned scatterplots when they preserve
multivariate relationships. Its preference for displays that reward sustained study concerns
the richness of evidence. Bertin's efficiency criterion concerns answering a specified question.
Apply both by preserving useful complexity and removing obstacles to reading it.
