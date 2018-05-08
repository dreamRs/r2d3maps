

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



# Basic examples ----------------------------------------------------------

### France
fr_dept <- ne_states(country = "france", returnclass = "sf")
fr_dept <- fr_dept[fr_dept$type_en %in% "Metropolitan department", ]

r2d3map(shape = fr_dept)


### Africa
africa <- ne_countries(continent = "Africa", returnclass = "sf")
r2d3map(shape = africa)


### New Zealand
nz <- ne_states(country = "New Zealand", returnclass = "sf")
nz <- st_crop(nz, xmin = 159.104, ymin = -48.385, xmax = 193.601, ymax = -33.669)
r2d3map(shape = nz)





