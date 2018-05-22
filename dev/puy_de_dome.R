
#  ------------------------------------------------------------------------
#
# Title : Puy-de-Dome
#    By : Victor
#  Date : 2018-05-09
#
#  ------------------------------------------------------------------------



# Packages ----------------------------------------------------------------

library( r2d3maps )
library( sf )
library( dplyr )
library( rmapshaper )



# Data --------------------------------------------------------------------

# from: https://www.data.gouv.fr/fr/datasets/decoupage-administratif-communal-francais-issu-d-openstreetmap/#_

communes <- read_sf("dev/communes-20180101-shp/communes-20180101.shp")
plot(st_geometry(communes))
communes

puy_de_dome <- communes %>%
  filter(substr(insee, 1, 2) %in% "63")
plot(st_geometry(puy_de_dome))


# Simplify polygons
puy_de_dome2 <- ms_simplify(puy_de_dome)
plot(st_geometry(puy_de_dome2))


# pryr::object_size(puy_de_dome)
# ##> 5.16 MB
# pryr::object_size(puy_de_dome2)
# ##> 567 kB



# D3 map ------------------------------------------------------------------


d3_map(shape = puy_de_dome2) %>%
  add_labs(title = "Puy de Dôme") %>%
  add_tooltip(value = "{nom}")





