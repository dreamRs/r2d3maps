

#  ------------------------------------------------------------------------
#
# Title : London
#    By : Victor
#  Date : 2018-05-11
#
#  ------------------------------------------------------------------------



# Packages ----------------------------------------------------------------

library( r2d3maps )
library( sf )
library( rmapshaper )




# Data --------------------------------------------------------------------

# from: https://data.london.gov.uk/dataset/statistical-gis-boundary-files-london

london <- read_sf("dev/London-wards-2014/London-wards-2014_ESRI/London_Ward.shp")
plot(st_geometry(london))
london

london <- st_transform(london, crs = 4326)


# Simplify shapes
london2 <- ms_simplify(london)

# pryr::object_size(london)
# ##> 2.96 MB
# pryr::object_size(london2)
# ##> 532 kB



# D3 map ------------------------------------------------------------------

d3_map(shape = london2) %>%
  add_tooltip("{NAME}") %>%
  add_labs("London city")





