# TidyTuesday Script Style Guide

Inferred from existing scripts. Update this file whenever a new convention is established.

---

## Script Structure

Every script follows the same numbered section order, separated by section dividers.

### 1. Header block

```r
# ============================================================
# TidyTuesday YYYY-MM-DD  |  Dataset Name
# One-line description of the specific angle or question
# Data: Source name via rfordatascience #TidyTuesday
# ============================================================
```

### 2. Libraries

All libraries loaded at the top, immediately after the header. No inline `library()` calls later in the script.

### 3. Section dividers

Use this format throughout:

```r
# ── 1. Section name ──────────────────────────────────────────
```

Sections are numbered sequentially. Typical order:

1. Load data
2. Wrangle / filter / join
3. Palette
4. Bluesky logo (if used in caption)
5. Labels (if pre-building label strings)
6. Plot

---

## Code Style

- Use the native pipe `|>`, not `%>%`
- Use `readr::read_csv()` with explicit namespace for data loading
- Align related variable assignments for readability:
  ```r
  bg    <- "#0d0d1a"
  ink   <- "#e8e8f0"
  muted <- "#8888a8"
  ```
- After the first run, comment out the raw data download block and load from a local file in `data/` instead
- Use `options(scipen = 999)` when the data involves large numbers

---

## Palette

Define all colors as named variables before the plot block. Use semantic names:

| Variable | Role |
|---|---|
| `bg` | Background fill |
| `ink` | Primary text / foreground |
| `muted` | Secondary text, grid lines, labels |
| `col_main` or a descriptive name | Primary data color |

---

## Labels and Caption

- Use `glue()` for any string that includes a variable
- Use `ggtext` (`element_markdown`) for HTML in titles, subtitles, and captions — but never use backticks in text passed to ggplot; use plain text instead
- Pre-build long or complex label strings as variables before `labs()`

**Caption format** (always include all three):

```r
glue(
  "Data: [Source]  |  #TidyTuesday YYYY-MM-DD  |  ",
  "<img src='{bsky_logo_path}' width='12'/> @mel-likes-maps.bsky.social"
)
```

**Bluesky logo block** (include whenever the caption uses the logo):

```r
bsky_logo_path <- "tidytuesday Resources/bsky_logo.png"
if (!file.exists(bsky_logo_path)) {
  download.file(
    url      = "https://web-cdn.bsky.app/static/apple-touch-icon.png",
    destfile = bsky_logo_path,
    mode     = "wb",
    quiet    = TRUE
  )
}
```

---

## Theme

- Base theme is `theme_void()` (maps) or `theme_minimal(base_family = "sans")` (everything else)
- Set theme elements explicitly — never rely on defaults for background, text color, or grid
- Standard theme settings:
  ```r
  plot.background  = element_rect(fill = bg, color = NA)
  panel.background = element_rect(fill = bg, color = NA)
  plot.title       = element_text(size = 18, face = "bold", color = ink, margin = margin(b = 5))
  plot.subtitle    = element_markdown(size = 10, color = muted, margin = margin(b = 16))
  plot.caption     = element_markdown(size = 7.5, color = muted, hjust = 0, margin = margin(t = 12))
  plot.margin      = margin(18, 22, 14, 22)
  ```

