
#  ------------------------------------------------------------------------
#
# Title : Exemple avec CARTElette
#    By : Victor
#  Date : 2018-05-30
#
#  ------------------------------------------------------------------------



# Packages ----------------------------------------------------------------

library( r2d3maps )
library( sf )
library( CARTElette )
library( dplyr )
library( rmapshaper )



# Data --------------------------------------------------------------------

# fond de carte
dept <- loadMap(nivsupra = "DEP")
dept <- st_transform(dept, crs = 4326)
dept <- ms_simplify(dept)

# population france
data("pop_fr", package = "r2d3maps")
dept <- left_join(
  x = dept,
  y = pop_fr,
  by = c("DEP" = "code_departement")
)



# Carte -------------------------------------------------------------------

d3_map(dept) %>%
  add_continuous_breaks(var = "population_totale", na_color = "#b8b8b8") %>%
  add_legend(d3_format = ".2s") %>%
  add_tooltip(value = "{nom} : {population_totale}")

d3_map(dept) %>%
  add_continuous_gradient(var = "population_totale") %>%
  add_legend(d3_format = ".2s") %>%
  add_tooltip(value = "{nom} : {population_totale}")



