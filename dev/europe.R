
#  ------------------------------------------------------------------------
#
# Title : Europe
#    By : Victor
#  Date : 2018-05-24
#
#  ------------------------------------------------------------------------



# Packages ----------------------------------------------------------------

library( r2d3maps )
library( rnaturalearth )
library( sf )




# Data --------------------------------------------------------------------


europe <- ne_countries(continent = "Europe", returnclass = "sf", scale = 10)
plot(st_geometry(europe))


eu_countries <- list(
  "1958" = c("Belgium", "France", "Germany", "Italy", "Luxembourg", "Netherlands"),
  "1973" = c("Denmark", "Ireland", "United Kingdom"),
  "1981" = c("Greece"),
  "1986" = c("Portugal", "Spain"),
  "1995" = c("Austria", "Finland", "Sweden"),
  "2004" = c("Cyprus", "Czech Rep.", "Estonia", "Hungary", "Latvia",
             "Lithuania", "Malta", "Poland", "Slovakia", "Slovenia"),
  "2007" = c("Bulgaria", "Romania"),
  "2013" = c("Croatia")
)


europe <- europe[europe$name %in% unlist(eu_countries), ]
europe <- st_crop(europe, ymax = 70.109, ymin = 34.162, xmin = -16.963, xmax = 41.616)
# ue$geometry <- st_combine(ue$geometry)
plot(st_geometry(europe))

eu_entry_df <- data.frame(
  year = rep(names(eu_countries), sapply(eu_countries, length)),
  country = unlist(eu_countries, use.names = FALSE)
)
europe$ue_entry <- eu_entry_df$year[match(x = europe$name, table = eu_entry_df$country)]




# Map - entry in EU -------------------------------------------------------

d3_map(shape = europe) %>%
  add_discrete_scale(var = "ue_entry", palette = "viridis") %>%
  add_tooltip(value = "<b>{name}</b>: {ue_entry}", .na = NULL) %>%
  add_legend(title = "Année") %>%
  add_labs(
    title = "European Union",
    caption = "Data: wikipedia"
  )





