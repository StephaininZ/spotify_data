#### Preamble ####
# Purpose: Access data retrieved from Spotify API
# Author: Yingying Zhou
# Data: 01 February 2021
# Contact: yingying.zhou@utoronto.ca 
# License: MIT
# Pre-requisites: 
# - Register for a Spotify developer account
# - Obtain Client ID and Client Secret from App and save locally in .Renviron
# - Need to have downloaded data needed and saved it to inputs/data
# - Don't forget to gitignore it!


#### Workspace setup ####
#devtools::install_github('charlie86/spotifyr')
library(spotifyr)
library(usethis)
usethis::edit_r_environ() 
library(dplyr)
library(ggplot2)
library(httr)
library(httpuv)
library(kableExtra)
library(purrr)


#### Download data of interest ####
bts <- get_artist_audio_features('bts')
saveRDS(bts, "inputs/bts.rds")
bts <- readRDS("inputs/bts.rds")
names(bts)   # check column variables 


# View artist name, track name, and album name for BTS 
bts %>% 
  select(artist_name, track_name, album_name) %>% 
  head()


# Compare the sentiment score distribution of BTS vs. BlackPink
bp <- get_artist_audio_features('blackpink')
saveRDS(bp, "inputs/bp.rds")
bp <- readRDS("inputs/bp.rds")

tibble(name = c(bp$artist_name, bts$artist_name),
       year = c(bp$album_release_year, bts$album_release_year),
       valence = c(bp$valence, bts$valence)
) %>% 
  ggplot(aes(x = year, y = valence, color = name)) +
  geom_point() +
  theme_minimal() +
  labs(x = "Year",
       y = "Valence",
       color = "Name") +
  scale_color_brewer(palette = "Set1")


# Find All Time Favorite Artists
top_artists <- get_my_top_artists_or_tracks(type = 'artists', time_range = 'long_term', limit = 15)
saveRDS(top_artists, "inputs/top_artists.rds")
top_artists <- readRDS("inputs/top_artists.rds")

top_artists %>% 
  select(name, popularity) %>%
  kableExtra::kbl(caption = "All Time Favorite Artists") %>%
  kableExtra::kable_styling()


# Find Favorite Tracks at the Moment
get_my_top_artists_or_tracks(type = 'tracks', time_range = 'short_term', limit = 5) %>% 
  mutate(artist.name = map_chr(artists, function(x) x$name[1])) %>% 
  select(name, artist.name, album.name) %>% 
  kableExtra::kbl(caption = "Favorite Tracks at the Moment") %>%
  kableExtra::kable_styling()