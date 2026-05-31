# ============================================================
# TidyTuesday 2026-05-26  |  Sustainable Energy for All
# Electricity access: who gained the most (and who fell back)?
# Data: SE4ALL / World Bank via rfordatascience #TidyTuesday
# ============================================================

library(tidyverse)
library(ggtext)
library(ggrepel)
library(glue)

# ── 1. Load data ─────────────────────────────────────────────
energy <- readr::read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-05-26/energy_cleaned.csv",
  show_col_types = FALSE
)

# ── 2. Filter to the three data years ────────────────────────
access <- energy |>
  filter(yr %in% c(1990, 2000, 2010)) |>
  select(country_name, country_code, yr, access_electricity_total_pop_pct)

# ── 3. Identify top 10 gainers and any decreasers ────────────
change <- access |>
  filter(yr %in% c(1990, 2010)) |>
  pivot_wider(
    names_from  = yr,
    values_from = access_electricity_total_pop_pct,
    names_prefix = "yr_"
  ) |>
  filter(!is.na(yr_1990), !is.na(yr_2010)) |>
  mutate(change = yr_2010 - yr_1990)

top10 <- change |> slice_max(change, n = 10) |> pull(country_code)

# ── 4. Flag each country's role ──────────────────────────────
access <- access |>
  mutate(
    group = case_when(
      country_code %in% top10 ~ "top10",
      TRUE                    ~ "other"
    )
  )

# Labels pinned to the 2010 endpoint
labels_2010 <- access |>
  filter(yr == 2010, group != "other")

# ── 5. Palette ────────────────────────────────────────────────
bg        <- "#0d0d1a"
ink       <- "#e8e8f0"
muted     <- "#8888a8"
col_top10 <- "#f5c842"
col_other <- "#2a2a4a"

# ── 6. Bluesky logo ───────────────────────────────────────────
bsky_logo_path <- "tidytuesday Resources/bsky_logo.png"
if (!file.exists(bsky_logo_path)) {
  download.file(
    url      = "https://web-cdn.bsky.app/static/apple-touch-icon.png",
    destfile = bsky_logo_path,
    mode     = "wb",
    quiet    = TRUE
  )
}

# ── 7. Plot ───────────────────────────────────────────────────
p <- ggplot(access, aes(x = yr, y = access_electricity_total_pop_pct,
                        group = country_name)) +

  # Background: all other countries
  geom_line(
    data  = filter(access, group == "other"),
    color = col_other,
    linewidth = 0.4,
    alpha = 0.8
  ) +

  # Top 10 gainers
  geom_line(
    data  = filter(access, group == "top10"),
    color = col_top10,
    linewidth = 1,
    alpha = 0.9
  ) +
  geom_point(
    data  = filter(access, group == "top10"),
    color = col_top10,
    size  = 2
  ) +

  # Labels at 2010
  geom_text_repel(
    data          = labels_2010,
    aes(label = country_name, color = group),
    hjust         = 0,
    nudge_x       = 0.8,
    size          = 3,
    segment.size  = 0.3,
    segment.color = muted,
    direction     = "y",
    show.legend   = FALSE
  ) +

  scale_color_manual(values = c(top10 = col_top10)) +
  scale_x_continuous(
    breaks = c(1990, 2000, 2010),
    limits = c(1988, 2018),
    labels = c("1990", "2000", "2010")
  ) +
  scale_y_continuous(
    labels = function(x) paste0(x, "%"),
    limits = c(0, 100)
  ) +

  theme_minimal(base_family = "sans") +
  theme(
    plot.background  = element_rect(fill = bg, color = NA),
    panel.background = element_rect(fill = bg, color = NA),
    panel.grid.major = element_line(color = "#1e1e38", linewidth = 0.4),
    panel.grid.minor = element_blank(),
    axis.text        = element_text(color = muted, size = 10),
    axis.title       = element_blank(),
    plot.title       = element_text(
      size = 18, face = "bold", color = ink, margin = margin(b = 5)
    ),
    plot.subtitle    = element_markdown(
      size = 10, color = muted, lineheight = 1.5, margin = margin(b = 16)
    ),
    plot.caption     = element_markdown(
      size = 7.5, color = muted, hjust = 0, margin = margin(t = 12)
    ),
    plot.margin      = margin(18, 22, 14, 22),
    legend.position  = "none"
  ) +
  labs(
    title    = "Lights On",
    subtitle = glue(
      "% of total population with access to electricity in 1990, 2000, and 2010.  ",
      "<span style='color:{col_top10}'>Top 10 gainers</span> highlighted."
    ),
    caption  = glue(
      "Data: SE4ALL / World Bank  |  #TidyTuesday 2026-05-26  |  ",
      "<img src='{bsky_logo_path}' width='12'/> @mel-likes-maps.bsky.social"
    )
  )

# ── 8. Save ───────────────────────────────────────────────────
ggsave(
  filename = "tidytuesday Resources/20260526_tidytuesday_cleanenergy.png",
  plot     = p,
  width    = 12,
  height   = 8,
  dpi      = 300,
  bg       = bg
)

message("Saved: tidytuesday Resources/20260526_tidytuesday_cleanenergy.png")
