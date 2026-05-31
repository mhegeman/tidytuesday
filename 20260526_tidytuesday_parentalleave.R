library(tidyverse)


# european parental leave polices
eplp <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-06-02/eplp.csv')

# Country code -> full name lookup
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

# Parental leave duration by year
# Filter out not applicable (-98) and missing (-99) values
paid_leave <- eplp |>
  select(country, country_name, year, par1_ld) |>
  filter(!par1_ld %in% c(-98, -99), !is.na(par1_ld))

paid_leave_current <- paid_leave |>
  slice_max(year)

ggplot() +
  geom_col(
    data = paid_leave_current,
    aes(
      x = par1_ld,
      y = reorder(country_name, par1_ld)
    )
  ) +
  theme_minimal() +
  labs(
    title = "Paid parental leave duration in Europe",
    subtitle = "2024"
    x = "Year",
    y = "Leave duration (weeks)"
  )
