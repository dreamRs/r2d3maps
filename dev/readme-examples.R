
#  ------------------------------------------------------------------------
#
# Title : Readme examples
#    By : Victor
#  Date : 2018-05-09
#
#  ------------------------------------------------------------------------



# Packages ----------------------------------------------------------------

library( r2d3 )
library( r2d3maps )
library( rnaturalearth )
library( magrittr )
library( dplyr )
library( magick )



# Basic examples ----------------------------------------------------------


# Japan
japan <- ne_states(country = "japan", returnclass = "sf")
japan_map <- r2d3map(shape = japan) %>%
  add_labs(title = "Japan")
japan_map

image_read(path = "img/japan.png") %>%
  image_resize(geometry = "400x") %>%
  image_write(path = "img/japan.png")


# save_d3_png(
#   d3 = japan_map, file = "img/japan.png",
#   width = 380, height = 400, zoom = 2
# )


# New Zealand
nz <- ne_states(country = "New Zealand", returnclass = "sf")
nz <- sf::st_crop(nz, xmin = 159.104, ymin = -48.385, xmax = 193.601, ymax = -33.669)
r2d3map(shape = nz) %>%
  add_labs(title = "New Zealand")

image_read(path = "img/new_zealand.png") %>%
  image_resize(geometry = "400x") %>%
  image_write(path = "img/new_zealand.png")



# South america
south_america <- ne_countries(continent = "south america", returnclass = "sf")
r2d3map(shape = south_america) %>%
  add_labs(title = "South America")

image_read(path = "img/south_america.png") %>%
  image_resize(geometry = "400x") %>%
  image_write(path = "img/south_america.png")



# France
fr_dept <- ne_states(country = "france", returnclass = "sf")
fr_dept <- fr_dept[fr_dept$type_en %in% "Metropolitan department", ]

r2d3map(shape = fr_dept) %>%
  add_labs(title = "France")


image_read(path = "img/france.png") %>%
  image_resize(geometry = "400x") %>%
  image_write(path = "img/france.png")




# Projection --------------------------------------------------------------

library( r2d3maps )
library( rnaturalearth )

us <- ne_states(country = "united states of america", returnclass = "sf")
us <- filter(us, !name %in% c("Alaska", "Hawaii"))

# Mercator
r2d3map(shape = us) %>%
  add_labs(title = "US (mercator)")

# Albers
r2d3map(shape = us, projection = "Albers") %>%
  add_labs(title = "US (albers)")


library(magick)
image_read(path = "img/us_mercator.png") %>%
  image_resize(geometry = "400x") %>%
  image_write(path = "img/us_mercator.png")

image_read(path = "img/us_albers.png") %>%
  image_resize(geometry = "400x") %>%
  image_write(path = "img/us_albers.png")











