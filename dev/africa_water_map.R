
#  ------------------------------------------------------------------------
#
# Title : Basic access to water in Africa
#    By : Victor
#  Date : 2018-05-08
#
#  ------------------------------------------------------------------------



# Packages ----------------------------------------------------------------

library( r2d3maps )
library( rnaturalearth )
library( magrittr )
library( dplyr )




# Data --------------------------------------------------------------------

# shapes
africa <- ne_countries(continent = "Africa", returnclass = "sf")


# drinking water data
data("water_africa")
glimpse(water_africa)


# add data to shapes

africa <- left_join(
  x = africa %>% select(adm0_a3_is, name, geometry),
  y = water_africa %>% filter(year == 2015) %>% select(iso3, national_at_least_basic),
  by = c("adm0_a3_is" = "iso3")
)
africa$national_at_least_basic <- round(africa$national_at_least_basic)



# Map ---------------------------------------------------------------------

# with pretty breaks
map_africa <- d3_map(shape = africa) %>%
  add_continuous_breaks(var = "national_at_least_basic") %>%
  add_tooltip(value = "<b>{name}</b>: {national_at_least_basic}%") %>%
  add_legend(title = "Population with at least basic access", suffix = "%") %>%
  add_labs(title = "Drinking water in Africa", caption = "Data: https://washdata.org/")

map_africa


# With gradient
d3_map(shape = africa) %>%
  add_continuous_gradient2(
    var = "national_at_least_basic",
    # low = "#440154", high = "#FDE725",
    range = c(0, 100)
  ) %>%
  add_tooltip(value = "<b>{name}</b>: {national_at_least_basic}%") %>%
  add_legend(title = "Population with at least basic access", suffix = "%") %>%
  add_labs(title = "Drinking water in Africa", caption = "Data: https://washdata.org/")




