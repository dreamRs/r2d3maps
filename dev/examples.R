

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

r2d3map(shape = fr_dept) %>%
  add_labs(title = "France")


### Africa
africa <- ne_countries(continent = "Africa", returnclass = "sf")
r2d3map(shape = africa) %>%
  add_labs(title = "Africa")


### New Zealand
nz <- ne_states(country = "New Zealand", returnclass = "sf")
nz <- st_crop(nz, xmin = 159.104, ymin = -48.385, xmax = 193.601, ymax = -33.669)
r2d3map(shape = nz) %>%
  add_labs(title = "New Zealand")





# Continuous colors -------------------------------------------------------

fr_dept <- fr_dept %>%
  mutate(foo_col = sample.int(n = 200, size = n(), replace = TRUE))


r2d3map(shape = fr_dept) %>%
  add_continuous_scale(var = "foo_col") %>%
  add_labs(title = "France")

r2d3map(shape = fr_dept) %>%
  add_continuous_scale(var = "foo_col", palette = "Blues") %>%
  add_labs(title = "France")


