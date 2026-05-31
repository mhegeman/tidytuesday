# tidytuesday Memory

## Status

Project created 2026-05-21. Week 1 (2026-05-12, Twinned Cities) in progress.

## Key Context

- Weekly challenge using publicly posted datasets from the #TidyTuesday GitHub repo.
- Primary tools: R, tidyverse, ggplot2.
- Set up as an RStudio project (.Rproj). Working directory is always the project root.
- Project has a `data/` folder for local copies of each week's dataset.
- R scripts live in the `R/` folder. Naming convention: `YYYYMMDD_tidytuesday_description.R`.
- Exported plots saved to `tidytuesday Resources/`. Naming convention: `YYYYMMDD_tidytuesday_description.png`.
- Week of 2026-05-12 (Twinned Cities): script at `R/20260512_tidytuesday_twincities.R`.

## Working Notes

### 2026-05-26 — Sustainable Energy for All
- Dataset: `energy_cleaned.csv` — country-year data from the SE4ALL / World Bank initiative, 1990 to ~2019. ~50 columns covering electricity access, renewable energy by type, and energy intensity.
- Visualization: world choropleth map of electricity access (% of total population), most recent year with 150+ countries. Dark background, indigo-to-gold gradient — "lights on vs. off" metaphor.
- Script: `20260526_tidytuesday_cleanenergy.R`. Output: `tidytuesday Resources/20260526_tidytuesday_cleanenergy.png`.
- Key design choices: `ESRI:54030` Robinson projection, `#0d0d1a` background, gold high (#f5c842) / indigo low (#1a1560), `ne_countries(scale = "medium")` joined on `iso_a3` = `country_code`.

### 2026-05-12 — Twinned Cities
- Joined `cities` and `links` tables; added calculated fields for distance between twin cities in metres and km.
- Beijing has the most twin cities of any city in the dataset.
- Visualization: map of Beijing and its twin cities, with Buenos Aires highlighted as the farthest twin (Beijing–Buenos Aires is the longest link).
- Chart angle: Beijing as hub, distance as the story hook.
