
#  ------------------------------------------------------------------------
#
# Title : Examples
#    By : Victor
#  Date : 2018-05-08
#
#  ------------------------------------------------------------------------



# Packages ----------------------------------------------------------------

library( r2d3maps )
library( rnaturalearth )
library( magrittr )
library( dplyr )



# Basic examples ----------------------------------------------------------

### France
fr_dept <- ne_states(country = "france", returnclass = "sf")
fr_dept <- fr_dept[fr_dept$type_en %in% "Metropolitan department", ]

d3_map(shape = fr_dept) %>%
  add_labs(title = "France")


### Africa
africa <- ne_countries(continent = "Africa", returnclass = "sf")
d3_map(shape = africa) %>%
  add_labs(title = "Africa")

### South America
south_america <- ne_countries(continent = "south america", returnclass = "sf")
d3_map(shape = south_america) %>%
  add_labs(title = "South America")


### Japan
japan <- ne_states(country = "japan", returnclass = "sf")
d3_map(shape = japan) %>%
  add_labs(title = "Japan")


### New Zealand
nz <- ne_states(country = "New Zealand", returnclass = "sf")
nz <- sf::st_crop(nz, xmin = 159.104, ymin = -48.385, xmax = 193.601, ymax = -33.669)
d3_map(shape = nz) %>%
  add_labs(title = "New Zealand")





# Continuous colors -------------------------------------------------------

fr_dept <- fr_dept %>%
  mutate(foo_col = sample.int(n = 200, size = n(), replace = TRUE))


d3_map(shape = fr_dept) %>%
  add_continuous_scale(var = "foo_col") %>%
  add_labs(title = "France")

d3_map(shape = fr_dept) %>%
  add_continuous_scale(var = "foo_col", palette = "Blues") %>%
  add_labs(title = "France")






# Tooltip -----------------------------------------------------------------

# simple
d3_map(shape = africa) %>%
  add_tooltip(value = "{name}")


d3_map(shape = fr_dept) %>%
  add_continuous_scale(var = "foo_col") %>%
  add_tooltip() %>%
  add_labs(title = "France")


### Tunisia
tunisia <- ne_states(country = "tunisia", returnclass = "sf")
d3_map(shape = tunisia) %>%
  add_tooltip(value = "{woe_name}") %>%
  add_labs(title = "Tunisia")



# Legend ------------------------------------------------------------------

d3_map(shape = fr_dept) %>%
  add_continuous_breaks(var = "foo_col") %>%
  add_tooltip() %>%
  add_legend(title = "Random data") %>%
  add_labs(title = "France")


