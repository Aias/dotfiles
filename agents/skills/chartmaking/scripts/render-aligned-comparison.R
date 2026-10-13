library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
script_arg <- grep("^--file=", commandArgs(), value = TRUE)
script_dir <- dirname(normalizePath(sub("^--file=", "", script_arg[[1]])))
output_file <- if (length(args)) args[[1]] else file.path(script_dir, "..", "references", "aligned-comparison.png")

cars <- datasets::mtcars[datasets::mtcars$cyl == 4, ]
cars$model <- rownames(cars)
cars <- cars[order(-cars$mpg, cars$model), ]
cars$y <- rev(seq_len(nrow(cars)))
cars$gearbox <- c("Automatic", "Manual")[cars$am + 1]
cars$weight_lb <- cars$wt * 1000
cars$mpg_x <- 50 + (cars$mpg - 15) / 20 * 19
cars$weight_x <- 84 + (cars$weight_lb - 1500) / 2000 * 19
cars$mpg_label <- sprintf("%.1f", cars$mpg)
cars$weight_label <- format(round(cars$weight_lb), big.mark = ",", scientific = FALSE, trim = TRUE)
stopifnot(nrow(cars) == 11L, all(cars$mpg >= 15 & cars$mpg <= 35), all(cars$weight_lb >= 1500 & cars$weight_lb <= 3500))

fuel_ticks <- data.frame(value = c(15, 20, 25, 30, 35))
fuel_ticks$x <- 50 + (fuel_ticks$value - 15) / 20 * 19
weight_ticks <- data.frame(value = c(1500, 2000, 2500, 3000, 3500))
weight_ticks$x <- 84 + (weight_ticks$value - 1500) / 2000 * 19
median_mpg <- median(datasets::mtcars$mpg)
median_x <- 50 + (median_mpg - 15) / 20 * 19

paper <- "#FAF9F6"
ink <- "#292E2B"
quiet <- "#69736E"
rule <- "#E3E3DC"
accent <- "#25665C"
font <- "Helvetica Neue"

p <- ggplot() +
  geom_segment(data = data.frame(y = cars$y - 0.5), aes(x = 0, xend = 114, y = y, yend = y), color = rule, linewidth = 0.25) +
  geom_segment(data = fuel_ticks, aes(x = x, xend = x, y = 0.55, yend = 11.45), color = rule, linewidth = 0.3) +
  geom_segment(data = weight_ticks, aes(x = x, xend = x, y = 0.55, yend = 11.45), color = rule, linewidth = 0.3) +
  geom_segment(aes(x = median_x, xend = median_x, y = 0.55, yend = 11.45), color = "#8CA7A0", linewidth = 0.55) +
  geom_point(data = cars, aes(x = mpg_x, y = y), color = accent, size = 2.2) +
  geom_point(data = cars, aes(x = weight_x, y = y), color = accent, size = 2.2) +
  geom_text(data = cars, aes(x = 0, y = y, label = model), hjust = 0, color = ink, family = font, size = 10, size.unit = "pt") +
  geom_text(data = cars, aes(x = 32, y = y, label = gearbox), hjust = 0, color = quiet, family = font, size = 10, size.unit = "pt") +
  geom_text(data = cars, aes(x = 76, y = y, label = mpg_label), hjust = 1, color = accent, family = font, size = 10, size.unit = "pt") +
  geom_text(data = cars, aes(x = 111, y = y, label = weight_label), hjust = 1, color = ink, family = font, size = 10, size.unit = "pt") +
  annotate("text", x = 0, y = 15.6, label = "Four-cylinder cars", hjust = 0, color = ink, family = font, fontface = "bold", size = 15, size.unit = "pt") +
  annotate("text", x = c(0, 32, 50, 84), y = 14.1, label = c("Model", "Gearbox", "Fuel economy (mpg)", "Weight (lb)"), hjust = 0, color = ink, family = font, fontface = "bold", size = 10, size.unit = "pt") +
  annotate("text", x = 50, y = 13.25, label = sprintf("All-car median · %.1f", median_mpg), hjust = 0, color = quiet, family = font, size = 8.5, size.unit = "pt") +
  geom_text(data = fuel_ticks, aes(x = x, y = 12.35, label = value), color = quiet, family = font, size = 8.5, size.unit = "pt") +
  geom_text(data = weight_ticks, aes(x = x, y = 12.35, label = format(value, big.mark = ",", scientific = FALSE, trim = TRUE)), color = quiet, family = font, size = 8.5, size.unit = "pt") +
  coord_cartesian(xlim = c(-0.5, 115), ylim = c(0.2, 16.2), expand = FALSE, clip = "off") +
  theme_void(base_family = font) +
  theme(plot.margin = margin(10, 16, 10, 16, unit = "pt"), plot.background = element_rect(fill = paper, color = NA))

ggsave(output_file, plot = p, device = ragg::agg_png, width = 1100 / 96, height = 500 / 96, units = "in", dpi = 192, bg = paper)
