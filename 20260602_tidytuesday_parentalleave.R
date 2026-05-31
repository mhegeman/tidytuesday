# ============================================================
# TidyTuesday 2026-06-02  |  European Parenting Leave Policies
# Paid parental leave duration across 21 European countries
# Data: Spitzer et al. (2025) EPLP Dataset via rfordatascience
# ============================================================

library(tidyverse)
library(ggtext)
library(glue)


# ── 1. Load data ─────────────────────────────────────────────
eplp <- readr::read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-06-02/eplp.csv",
  show_col_types = FALSE
)

# ── 2. Country code -> full name lookup ──────────────────────
country_names <- c(
  AT = "Austria", BE = "Belgium", BG = "Bulgaria", CY = "Cyprus",
  CZ = "Czech Republic", DE = "Germany", DK = "Denmark", EE = "Estonia",
  EL = "Greece", GR = "Greece", ES = "Spain", FI = "Finland", FR = "France",
  HR = "Croatia", HU = "Hungary", IE = "Ireland", IT = "Italy",
  LT = "Lithuania", LU = "Luxembourg", LV = "Latvia", MT = "Malta",
  NL = "Netherlands", PL = "Poland", PT = "Portugal", RO = "Romania",
  SE = "Sweden", SI = "Slovenia", SK = "Slovakia", NO = "Norway",
  IS = "Iceland", LI = "Liechtenstein", CH = "Switzerland", UK = "United Kingdom"
)

eplp <- eplp |>
  mutate(country_name = country_names[country])


country_list <- eplp |>
  distinct(country)

# ── 3. Palette ────────────────────────────────────────────────
bg       <- "#0d0d1a"
ink      <- "#e8e8f0"
muted    <- "#8888a8"
col_main <- "#f5c842"
grid_col <- "#1e1e38"

# ── 4. Prep data ──────────────────────────────────────────────
# par1_ld = maximum paid parental leave duration (weeks)
# -98 = not applicable, -99 = missing — exclude both
paid_leave <- eplp |>
  select(country, country_name, year, par1_ld) |>
  filter(!par1_ld %in% c(-98, -99), !is.na(par1_ld))

paid_leave_current <- paid_leave |>
  slice_max(year)

# ── 5. Bluesky logo ───────────────────────────────────────────
bsky_logo_path <- "tidytuesday Resources/bsky_logo.png"
if (!file.exists(bsky_logo_path)) {
  download.file(
    url      = "https://web-cdn.bsky.app/static/apple-touch-icon.png",
    destfile = bsky_logo_path,
    mode     = "wb",
    quiet    = TRUE
  )
}

# ── 6. Plot ───────────────────────────────────────────────────

caption = glue(
  "Data: S. Spitzer et al., 'The European Parenting Leave Policies (EPLP) Dataset'.",
  "<br>Zenodo, Nov. 19, 2025. doi: 10.5281/zenodo.17648712",
  "<br>#TidyTuesday 2026-06-02  |  ",
  "<img src='{bsky_logo_path}' width='12'/> @mel-likes-maps.bsky.social"
)

p <- ggplot() +
  geom_col(
    data = paid_leave_current,
    aes(
      x = par1_ld,
      y = reorder(country_name, par1_ld)
    ),
    fill = col_main
  ) +
  theme_minimal(base_family = "sans") +
  theme(
    plot.background  = element_rect(fill = bg, color = NA),
    panel.background = element_rect(fill = bg, color = NA),
    panel.grid.major = element_line(color = grid_col, linewidth = 0.4),
    panel.grid.minor = element_blank(),
    axis.text        = element_text(color = muted, size = 9),
    axis.title       = element_text(color = muted, size = 9),
    plot.title       = element_text(size = 18, face = "bold", color = ink,
                                    margin = margin(b = 5)),
    plot.subtitle    = element_markdown(size = 10, color = muted,
                                        margin = margin(b = 16)),
    plot.caption     = element_markdown(size = 7.5, color = muted, hjust = 0,
                                        margin = margin(t = 12)),
    plot.margin      = margin(18, 22, 14, 22)
  ) +
  labs(
    title    = "Paid parental leave duration in Europe",
    subtitle = "2024",
    x        = "Leave duration (weeks)",
    y        = NULL,
    caption  = caption
    )



