# ============================================================
# TidyTuesday 2026-05-12  |  Twinned Cities
# Beijing's twin cities — and the farthest one, Buenos Aires
# Data: Wikidata via bothness.github.io/twin-cities
# ============================================================

library(tidyverse)
library(sf)
library(rnaturalearth)
library(ggtext)
library(glue)

options(scipen = 999)

# ── 1. Load data ─────────────────────────────────────────────
# cities <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-05-12/cities.csv')
# links <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-05-12/links.csv')
#
# matches <- cities |>
#   select(id, name, country, lng, lat) |>
#   left_join(links, by = c("id" = "source")) |>
#   left_join(cities |>
#               select(target = id, name, country, lng, lat),
#             by = "target",
#             suffix = c(".source", ".target")
#             ) |>
#   filter(!is.na(target)) |>
#   mutate(
#     distance_m = map2_dbl(
#       .x = seq_along(lng.source),
#       .y = seq_along(lng.target),
#       .f = ~st_distance(
#         st_sfc(st_point(c(lng.source[.x], lat.source[.x])), crs = 4326),
#         st_sfc(st_point(c(lng.target[.x], lat.target[.x])), crs = 4326)
#       ) |> as.numeric()
#     ),
#     distance_km = distance_m / 1000
#   )
#
# saveRDS(matches, "data/matches.rds")

# ── 2. Prepare spatial data ───────────────────────────────────
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
df    <- readRDS("data/matches.rds")

summary_df <- df |>
  group_by(name.source, country.source) |>
  summarise(
    n_pairs  = n(),
    min_dist = min(distance_km),
    max_dist = max(distance_km),
    .groups  = "drop"
  )

Beijing <- df |>
  filter(name.source == "Beijing") |>
  select(id, name.source, country.source, lng.source, lat.source) |>
  st_as_sf(coords = c("lng.source", "lat.source"), crs = 4326, remove = FALSE) |>
  distinct(name.source, lng.source, lat.source, geometry)

twin_cities <- df |>
  filter(name.source == "Beijing") |>
  select(target, name.target, country.target, lng.target, lat.target, distance_m, distance_km) |>
  st_as_sf(coords = c("lng.target", "lat.target"), crs = 4326, remove = FALSE)

max_dist <- twin_cities |>
  slice_max(distance_km)

world_robin <- world |>
  st_transform(crs = "ESRI:54030")

# ── 3. Palette ────────────────────────────────────────────────
bg              <- "#ffffff"
ink             <- "#1a1a1a"
muted           <- "#6b6b6b"
map_land        <- "#ececec"
map_border      <- "#d0d0d0"
twin_cities_col <- "#1f78b4"
beijing_col     <- "#b2df8a"

# ── 4. Bluesky logo ───────────────────────────────────────────
bsky_logo_path <- "tidytuesday Resources/bsky_logo.png"
if (!file.exists(bsky_logo_path)) {
  download.file(
    url      = "https://web-cdn.bsky.app/static/apple-touch-icon.png",
    destfile = bsky_logo_path,
    mode     = "wb",
    quiet    = TRUE
  )
}

# ── 5. Labels ─────────────────────────────────────────────────
plot_title    <- glue('<span style="color:{beijing_col}">Beijing\'s</span> Twin Cities')
plot_subtitle <- glue(
  "{max_dist$name.target} is the farthest away at ",
  "{format(round(max_dist$distance_km, digits = 0), big.mark = ',')} km"
)

# ── 6. Plot ───────────────────────────────────────────────────
p <- ggplot() +
  geom_sf(data = world_robin, fill = map_land, color = map_border,
          linewidth = 0.25, alpha = 0.8) +
  geom_sf(data = twin_cities, color = twin_cities_col, size = 2, alpha = 0.5) +
  geom_sf(data = Beijing, color = beijing_col, size = 5) +
  geom_sf_text(data = Beijing,
               aes(label = name.source),
               nudge_y = -600000,
               size    = 3.2,
               color   = muted) +
  geom_sf(data = max_dist, color = twin_cities_col, size = 5) +
  geom_sf_text(data = max_dist,
               aes(label = name.target),
               nudge_y = -600000,
               size    = 3.2,
               color   = muted) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = bg, color = NA),
    panel.background = element_rect(fill = bg, color = NA),
    plot.title    = element_markdown(size = 16, face = "bold", color = ink,
                                     margin = margin(b = 4)),
    plot.subtitle = element_text(size = 9.5, color = muted, lineheight = 1.4,
                                 margin = margin(b = 14)),
    plot.caption  = element_markdown(size = 7.5, color = muted, hjust = 0,
                                     margin = margin(t = 10)),
    plot.margin   = margin(16, 20, 12, 20)
  ) +
  labs(
    title    = plot_title,
    subtitle = plot_subtitle,
    caption  = glue::glue(
      "Data: Rfordatascience #TidyTuesday 2026-05-12  | #rstats #dataviz | ",
      "<img src='{bsky_logo_path}' width='12'/> @mel-likes-maps.bsky.social"
    )
  )

# ── 7. Save ───────────────────────────────────────────────────
ggsave(
  filename = "tidytuesday Resources/20260512_tidytuesday_twincities.png",
  plot     = p,
  width    = 11,
  height   = 7,
  dpi      = 300,
  bg       = bg
)

message("Saved: tidytuesday Resources/20260512_tidytuesday_twincities.png")
