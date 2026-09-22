# library(tidytuesdayR)
library(tidyverse)
library(ggtext)
library(sf)
library(rnaturalearth)

# First time only, copy data ----------------------------------------------

# urban <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-09-22/urban.csv')
# write_csv(urban, "data/urban_green_space.csv")



# Setup -------------------------------------------------------------------

options(scipen = 999)

# remove legend and minor grid lines
theme_set(
  theme_minimal() +
    theme(
      legend.position = 'none',
      panel.grid.minor = element_blank()
    )
  )

# Read data ---------------------------------------------------------------

urban <- read_csv("data/urban_green_space.csv")
urban_clean <- urban |>
  rename(
    country = countryOrTerritoryName,
    avgSharePct = averageShareOfGreenAreaInCityUrbanAreaPct
  ) |>
  filter(year <= 2020)





# Urban Green Space by Country --------------------------------------------

by_country <- urban_clean |>
  group_by(country, year) |>
  summarise(
    mean_pct = mean(avgSharePct),
    mean_m2 = mean(greenAreaPerCapitaM2),
    min_m2 = min(greenAreaPerCapitaM2),
    max_m2 = max(greenAreaPerCapitaM2)) |>
  ungroup() |>
  rowwise() |>
  mutate(range_m2 = max_m2 - min_m2)


p1 <- ggplot(
    data = by_country |> select(-mean_pct),
    aes(
      x = year,
      y = mean_m2,
      group = country
    )) +
  geom_line() +
  # theme_minimal() +
  labs(
    x = "Year",
    y = "Average m2 of greenspace per person",
    title = "Average Urban Greenspace per Person"
  )

plot(p1)

# Biggest change from 1990 - 2020 -----------------------------------------

biggest_change <- urban_clean |>
  filter((year == 1990 | year == 2020) & !is.na(country)) |>
  select(country, year, greenAreaPerCapitaM2) |>
  group_by(country, year) |>
  summarise(avgGreenAreaM2perCapita = mean(greenAreaPerCapitaM2)) |>
  pivot_wider(id_cols = country, names_from = year, values_from = avgGreenAreaM2perCapita) |>
  mutate(diff = `2020` - `1990`,
         perc_diff = diff/`1990`)

biggest_gain <- biggest_change |>
  arrange(-perc_diff) |>
  head(n=5)

biggest_gains_1 <- biggest_gain |>
  select(country, `1990`, `2020`) |>
  pivot_longer(!country, names_to = "year", values_to = "greenAreaM2") |>
  ungroup()

biggest_gains_1_labels <- biggest_gains_1 |>
  filter(year == 2020) |>
  left_join(
    biggest_gain,
    by = "country"
  ) |>
  mutate(label_str = glue::glue("<strong>{country},</strong>: +{round(diff, 1)} m2 ({round(perc_diff * 100, 1)}%)"))



biggest_loss <- biggest_change |>
  arrange(diff) |>
  head(n=5)

biggest_loss_1 <- biggest_loss |>
  select(country, `1990`, `2020`) |>
  pivot_longer(!country, names_to = "year", values_to = "greenAreaM2")

p2 <- ggplot() +
  geom_line(
    data = biggest_gains_1,
    aes(
      x = year,
      y = greenAreaM2,
      group = country
    ),
    color = "darkgreen",
    linewidth = 1
  ) +
  geom_point(
    data = biggest_gains_1,
    aes(
      x = year,
      y = greenAreaM2,
      group = country
    ),
    color = "darkgreen"
  ) +
  geom_text(
    data = biggest_gains_1_labels,
    aes(
      x = year,
      y = greenAreaM2,
      label = label_str
    ),
    color = "darkgreen",
    check_overlap = FALSE,
    hjust = "outward"
  ) +
  labs(
    title = "Countries with the biggest improvements in urban green space per capita",
    y = "Green Space per capita (m2)",
    x = element_blank()
  )

plot(p2)



# World Map, 1990 - 2020 -----------------------------------------


world <- ne_countries(scale = "medium", returnclass = "sf") |>
  select(
    iso_a3, name_en, geometry
  )

change_for_map <- biggest_change |>
  filter(!is.na(diff)) |>
  mutate(
    iso_a3 = countrycode::countrycode(
      country,
      origin = "country.name",
      destination = "iso3c"
    ),
    direction = if_else(diff > 0, "Increase", "Decrease")
  )

world_change <- world |>
  left_join(change_for_map, by = "iso_a3") |>
  mutate(direction = if_else(is.na(direction), "NoData", direction))

increasing_color <- "#2166AC"
decreasing_color <- "#E66101"
no_data_color <- "gray85"

title_text <- glue::glue(
  "<span style='color:{increasing_color};'>**Blue**</span> = increase | <span style='color:{decreasing_color};'>**Orange**</span> = decrease | <span style='color:{no_data_color};'>**Grey**</span> = no data"
)

bsky_logo_path <- "tidytuesday Resources/bsky_logo.png"
if (!file.exists(bsky_logo_path)) {
  download.file(
    url      = "https://web-cdn.bsky.app/static/apple-touch-icon.png",
    destfile = bsky_logo_path,
    mode     = "wb",
    quiet    = TRUE
  )
}

caption_text <- glue::glue(
  "Data: UN-Habitat Urban Indicators Database via rfordatascience #TidyTuesday 2026-09-22  |  ",
  "<img src='{bsky_logo_path}' width='12'/> @mel-likes-maps.bsky.social"
)

p3 <- ggplot(world_change) +
  geom_sf(aes(fill = direction), color = "white", linewidth = 0.1) +
  scale_fill_manual(
    values = c("Increase" = increasing_color, "Decrease" = decreasing_color, "NoData" = no_data_color),
    name = NULL,
    na.translate = FALSE
  ) +
  coord_sf(crs = "+proj=eqearth") +
  labs(
    title = "Change in Urban Green Space per Capita, 1990-2020",
    subtitle = title_text,
    caption = caption_text
  ) +
  theme(
    legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.subtitle = ggtext::element_markdown(),
    plot.caption = ggtext::element_markdown(size = 7.5, hjust = 0, margin = margin(t = 12))
  )

plot(p3)
