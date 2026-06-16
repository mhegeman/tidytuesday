# ============================================================
# TidyTuesday 2026-06-09  |  Films Based on Video Games
#
# Data: Wikipedia via rfordatascience #TidyTuesday
# ============================================================

library(tidyverse)
library(ggtext)
library(glue)

options(scipen = 999)

# ── 1. Load data ─────────────────────────────────────────────
game_films <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-06-09/game_films.csv')

game_films_clean <- game_films |>
  mutate(release_year = year(release_date))

# ── 2. Wrangle ───────────────────────────────────────────────

x <- game_films_clean |>
  group_by(category, subcategory, release_year) |>
  summarise(num_films = n())

peak_labels <- x |>
  group_by(release_year) |>
  summarise(total = sum(num_films)) |>
  filter(total > 20)

# ── 3. Palette ───────────────────────────────────────────────

bg    <- "#0d0d1a"
ink   <- "#e8e8f0"
muted <- "#8888a8"

area_cols <- c(
  "#f5c842",  # gold
  "#56B4E9",  # sky blue
  "#009E73",  # teal
  "#CC79A7",  # mauve
  "#E69F00"   # orange
)

# ── 4. Bluesky logo ──────────────────────────────────────────

bsky_logo_path <- "tidytuesday Resources/bsky_logo.png"
if (!file.exists(bsky_logo_path)) {
  download.file(
    url      = "https://web-cdn.bsky.app/static/apple-touch-icon.png",
    destfile = bsky_logo_path,
    mode     = "wb",
    quiet    = TRUE
  )
}

# ── 5. Labels ────────────────────────────────────────────────


# ── 6. Plot ──────────────────────────────────────────────────

p <- ggplot(x, aes(x = release_year, y = num_films, fill = category)) +
  geom_area(alpha = 0.9) +
  geom_text(
    data  = peak_labels,
    aes(x = release_year, y = total, label = total),
    inherit.aes = FALSE,
    color   = ink,
    size    = 3.5,
    nudge_y = 0.8,
    fontface = "bold"
  ) +
  scale_fill_manual(values = area_cols) +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 6)) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 5)) +
  theme_minimal(base_family = "sans") +
  theme(
    plot.background  = element_rect(fill = bg, color = NA),
    panel.background = element_rect(fill = bg, color = NA),
    panel.grid.major = element_line(color = "#1e1e38", linewidth = 0.4),
    panel.grid.minor = element_blank(),
    axis.text        = element_text(color = muted, size = 9),
    axis.title       = element_text(color = muted, size = 9),
    legend.text      = element_text(color = muted, size = 8),
    legend.title     = element_blank(),
    legend.position  = "bottom",
    plot.title       = element_text(size = 18, face = "bold", color = ink,
                                    margin = margin(b = 5)),
    plot.subtitle    = element_markdown(size = 10, color = muted,
                                        margin = margin(b = 16)),
    plot.caption     = element_markdown(size = 7.5, color = muted, hjust = 0,
                                        margin = margin(t = 12)),
    plot.margin      = margin(18, 22, 14, 22)
  ) +
  labs(
    title    = "Video Game Films Over Time",
    subtitle = "Number of films released each year, by category",
    x        = NULL,
    y        = "Number of films",
    caption  = glue(
      "Data: Wikipedia via rfordatascience #TidyTuesday 2026-06-09  |  ",
      "<img src='{bsky_logo_path}' width='12'/> @mel-likes-maps.bsky.social"
    )
  )

p

