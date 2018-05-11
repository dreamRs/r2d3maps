
#  ------------------------------------------------------------------------
#
# Title : Projection
#    By : Victor
#  Date : 2018-05-11
#
#  ------------------------------------------------------------------------



# Packages ----------------------------------------------------------------

library( r2d3maps )
library( rnaturalearth )
library( dplyr )
library( sf )
library( rmapshaper )




# Data --------------------------------------------------------------------

countries110 <- st_as_sf(countries110)
plot(st_geometry(countries110))
countries110



# Mercator ----------------------------------------------------------------

r2d3map(shape = countries110) %>%
  add_tooltip()



# Albers ------------------------------------------------------------------

r2d3map(shape = countries110, projection = "Albers") %>%
  add_tooltip()



# Natural Earth -----------------------------------------------------------

# needed to remove antarctica...
countries110 <- filter(countries110, !continent %in% c("Antarctica"))
r2d3map(shape = countries110, projection = "NaturalEarth") %>%
  add_tooltip()



# ConicEqualArea ----------------------------------------------------------

# needed to remove antarctica...
countries110 <- filter(countries110, !continent %in% c("Antarctica"))
r2d3map(shape = countries110, projection = "ConicEqualArea") %>%
  add_tooltip()


