

#  ------------------------------------------------------------------------
#
# Title : Bay Area
#    By : Victor
#  Date : 2018-05-09
#
#  ------------------------------------------------------------------------



# Packages ----------------------------------------------------------------

library( r2d3maps )
library( sf )




# Data --------------------------------------------------------------------

# from: https://data.sfgov.org/Geographic-Locations-and-Boundaries/Bay-Area-ZIP-Codes/u5j3-svi6

bay_area <- read_sf("dev/bay-area/geo_export_bb694795-f052-42b5-a0a1-01db0b2d41a6.shp")
plot(st_geometry(bay_area))
bay_area




# D3 map ------------------------------------------------------------------

r2d3map(shape = bay_area) %>%
  add_labs(title = "Bay Area") %>%
  add_tooltip(value = "{po_name}")





