# ggplot2 implementation

Read this when building or exporting a chart in R. Use the project's R environment and dependency conventions. Check `Rscript --version` and `Rscript -e 'packageVersion("ggplot2")'` before promising a render. When a dependency is unavailable, identify it and prepare the work that can be completed. Keep ggplot2 as the default engine unless the user chooses another.

Keep imports proportional to the task. ggplot2 handles layers, scales, facets, and themes. Add packages such as ragg or svglite for the output device that needs them. A reproducible source file should load the real data, perform the transformations, construct the chart, and export it with explicit dimensions.

## Data and comparisons

Keep grouping variables in the plotting data and set factor levels explicitly for meaningful ordering. Use named manual scales when category identity must remain consistent across charts. Share scale limits and breaks across panels whose magnitudes should be comparable.

Preserve missing periods as explicit gaps in time series. Omitting a row can make `geom_line()` connect observations across a missing interval. Distinguish an observed zero from an absent observation. Include the facet variables in panel-specific reference data so a benchmark is assigned to the correct panel.

| Reading task | Useful ggplot2 construction |
| --- | --- |
| Compare estimates and uncertainty | `geom_point()` with `geom_linerange()` or `geom_errorbar()` on a common scale |
| Compare change over time | `geom_line()` with explicit groups, contextual series, and relevant reference lines |
| Compare many groups | `facet_wrap(vars(group))`, with ordered factors and shared scales |
| Compare two categorical conditions | `facet_grid(rows = vars(row_group), cols = vars(column_group))` |
| Compare relationships across groups | `geom_point()` with facets for conditioning variables and consistent scales |
| Inspect pairwise relationships among measurements | A scatterplot matrix, using GGally when its panel system fits the task |
| Inspect a matrix | `geom_tile()` with deliberate row and column ordering, a meaningful fill scale, and distinguishable missing values |
| Compare distributions | Raw observations where legible, or summaries that retain spread, tails, and sample size when relevant |

Use free facet scales for within-panel shape only when the different ranges remain clear. Shared units alone do not make independently scaled panels comparable. Repeated reference layers can give every panel a useful population or historical comparison. See the official [facet wrap](https://ggplot2.tidyverse.org/reference/facet_wrap.html) and [facet grid](https://ggplot2.tidyverse.org/reference/facet_grid.html) references.

Use `coord_cartesian()` for a visual zoom that preserves data used by statistics. Scale limits remove out-of-range observations and can change summaries or fitted curves. Check exclusions deliberately. See [Cartesian coordinates](https://ggplot2.tidyverse.org/reference/coord_cartesian.html).

## Scatterplot matrices

For a pairwise matrix, consider `GGally::ggpairs()` as an optional ggplot2 extension. Select measurement columns explicitly. Its default upper triangle shows correlations, so choose point panels there when the task calls for inspecting raw relationships in both orientations. Use variable names and units in diagonal or marginal labels, and preserve readable quantitative ticks. See [ggpairs](https://ggobi.github.io/ggally/reference/ggpairs.html).

Keep each variable's domain and transformation consistent wherever it appears, while allowing different variables their own units and ranges. Use small open points or restrained transparency where these expose overlap. Retain visible outliers and nonlinear structure. Record whether panels use pairwise or complete cases, and expose differing sample sizes when they affect comparisons. Correlation coefficients can supplement the plotted relationships but cannot show their shape.

## Sparklines and tables

Build sparklines from grouped lines in short, aligned panels. Integrate them with compact columns for the entity name, current value, change, or benchmark when those quantities answer the question. Keep row ordering identical across the numeric and graphical columns, align numbers by precision, and use tabular numerals when available.

Use a shared time domain and aligned reference dates. Share the value scale when comparing absolute magnitudes. For shape comparisons across different units or ranges, identify the scale through ranges, units, or a stated index baseline. Preserve missing intervals and important outliers. Remove repeated axes only when surrounding labels and reference marks still establish time, magnitude, and the comparison.

Determine row heights from legible text and discernible variation at the final display size. Add rows or panels while those distinctions remain readable. A longer figure or multiple pages can preserve more information than squeezing every row into a fixed thumbnail.

## Typography and hierarchy

Start from `theme_minimal()` and adapt it to the comparison. Keep major gridlines where they support estimation, quiet supporting layers, and remove minor grids or panel furniture that add no information. Apply chart-specific choices through `theme()` rather than imposing one fixed theme on every geometry. See [theme components](https://ggplot2.tidyverse.org/reference/theme.html).

Use the destination's typeface when available. Choose text size at the intended display dimensions. Use alignment, regular spacing, tabular numbers, compact facet labels, and clear weight differences to support dense reading. Keep data labels close to their marks. Reserve annotation for values, events, units, and definitions that change interpretation.

Theme text sizes are in points. Geometric text uses millimeters by default, while `geom_text(size.unit = "pt")` accepts point sizes. Set `linewidth` explicitly for thin line layers and judge it in the exported artifact. See [aesthetic specifications](https://ggplot2.tidyverse.org/articles/ggplot2-specs.html).

Sequential color should preserve ordered lightness. Diverging scales need a meaningful center. For categorical color, verify distinctions on the actual small marks. Do not assign a sequential palette to nominal categories merely because it is available. The built-in [viridis scales](https://ggplot2.tidyverse.org/reference/scale_viridis.html) offer perceptually ordered options for quantitative values.

## Export at the reading size

Prefer SVG for screen use and PDF for print or document workflows when the destination supports vectors. They preserve crisp type and fine geometry under scaling. Use PNG when the destination needs raster output, or selectively rasterize dense mark layers when vector complexity becomes impractical while retaining vector labels where supported.

For raster screen output, distinguish display dimensions from file pixels. At a display width of 1,200 CSS pixels, a 2× export needs 2,400 file pixels. Using the CSS conversion of 96 pixels per inch, set the physical width to `1200 / 96` inches and export at `96 * 2` DPI. Keep those physical dimensions fixed when increasing DPI so typography retains its intended displayed size.

This export example assumes `p` is the completed chart. Adapt the display dimensions to the destination:

```r
display_width <- 1200
display_height <- 720
pixel_ratio <- 2

ggplot2::ggsave(
  "chart.svg",
  plot = p,
  device = svglite::svglite,
  width = display_width / 96,
  height = display_height / 96,
  units = "in",
  bg = "white"
)

ggplot2::ggsave(
  "chart.png",
  plot = p,
  device = ragg::agg_png,
  width = display_width / 96,
  height = display_height / 96,
  units = "in",
  dpi = 96 * pixel_ratio,
  bg = "white"
)
```

For print, set the intended physical dimensions and the destination's required DPI. Increasing raster resolution does not make text readable at a smaller physical size. See [ggsave](https://ggplot2.tidyverse.org/reference/ggsave.html) and [ragg's PNG device](https://ragg.r-lib.org/reference/agg_png.html).

Inspect the saved output both at its intended display size and enlarged. Check that thin lines survive, type remains legible, facet scales support the stated comparison, and labels are unclipped. Confirm the exported dimensions and review warnings about removed observations. SVG text can depend on font availability at the destination, so verify it in the receiving renderer. See [svglite's font guidance](https://svglite.r-lib.org/).
