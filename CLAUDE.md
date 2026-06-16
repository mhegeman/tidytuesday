# tidytuesday Project

## Goal

Produce a clean, well-crafted R visualization each week using the #TidyTuesday dataset — from raw data to finished chart, ready to share.

## Project-Specific Workflow

1. **Load the data** — Pull the week's dataset (manually or via `tidytuesdayR`). Take a quick look at structure, dimensions, and obvious quirks before touching anything.
2. **Explore** — Profile the data: check for NAs, spot distributions, identify the most interesting angle. Don't start cleaning until you know what you're working with.
3. **Clean** — Tidy the data for the specific story you want to tell. Keep cleaning scoped — only transform what the visualization actually needs.
4. **Visualize** — Build the chart in ggplot2. Start with a rough version, then layer in polish: labels, theme, color, annotations.
5. **Save outputs** — Scripts live directly in the `tidytuesday/` folder (not in an `R/` subfolder). Exported plots go to `tidytuesday Resources/`. Use the naming convention `YYYYMMDD_tidytuesday_description.R` and `YYYYMMDD_tidytuesday_description.png`.

## Project-Specific Rules

- Follow voice principles in `00_Resources/voice-principles.md` for any social captions or write-ups.
- Do not use backticks in any text passed to ggplot (titles, subtitles, captions, labels) when using ggtext — they break rendering. Use plain text instead.
- Default stack is tidyverse + ggplot2. Suggest additional packages only when they meaningfully improve the output.
- This is an RStudio project. All file paths in R scripts should be relative to the project root (where the `.Rproj` file lives) — never use absolute paths or `setwd()`.
- Keep R scripts self-contained: load all libraries at the top, use relative paths, and include a brief comment block at the top describing the dataset and week.
- Raw data copies live in the `data/` folder at the project root. Load data from there rather than always pulling from the web.
- If a chart angle isn't working after one or two iterations, step back and re-examine the data rather than forcing the original idea.
