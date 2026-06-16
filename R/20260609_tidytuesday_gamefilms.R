# TidyTuesday 2026 — Week 23 (2026-06-09)
# Dataset: Films Based on Video Games
# Source: Wikipedia (List of films based on video games)
# Curator: Georgios Karamanis
# Columns include: title, release_date, worldwide_box_office, rotten_tomatoes,
#   metacritic, cinema_score, budget, original_game_publisher, distributor, category

library(tidyverse)

# Load data
game_films <- read_csv("data/game_films.csv")

# Quick look
glimpse(game_films)
