
#  ------------------------------------------------------------------------
#
# Title : US
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

us <- ne_states(country = "united states of america", returnclass = "sf")
plot(st_geometry(us))

us <- filter(us, !name %in% c("Alaska", "Hawaii"))

# us <- st_crop(x = us, ymin = 22.513, xmax = -57.920, ymax = 52.803, xmin = -126.914)
plot(st_geometry(us))
# we'll try to bring back Alaska and Hawaii later...


# # proj
# proj <- "+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs"
# us_albers <- st_transform(x = us, crs = proj)
# plot(st_geometry(us_albers))
#
# us_albers <- ms_simplify(us_albers)



# Maps --------------------------------------------------------------------

# Mercator
r2d3map(shape = us) %>%
  add_labs(title = "US (mercator)")

# Albers
r2d3map(shape = us, projection = "Albers") %>%
  add_labs(title = "US (albers)")







# Alaska & Hawaii ---------------------------------------------------------

library( sp )
library( maptools )
library( mapproj )

us_aea <- ne_states(country = "united states of america", returnclass = "sp")

# Move Alaska and Hawai (Bob Rudis)
# https://rud.is/b/2014/11/16/moving-the-earth-well-alaska-hawaii-with-r/
us_aea <- spTransform(us_aea, CRS("+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs"))
us_aea@data$id <- rownames(us_aea@data)
alaska <- us_aea[us_aea$name == "Alaska", ]
alaska <- elide(alaska, rotate = -50)
alaska <- elide(alaska, scale = max(apply(bbox(alaska), 1, diff)) / 2.3)
alaska <- elide(alaska, shift = c(-2100000, -2800000))
proj4string(alaska) <- proj4string(us_aea)
hawaii <- us_aea[us_aea$name == "Hawaii", ]
hawaii <- elide(hawaii, rotate = -35)
hawaii <- elide(hawaii, shift = c(5400000, -1800000))
proj4string(hawaii) <- proj4string(us_aea)
us_aea <- us_aea[!us_aea$name %in% c("Alaska", "Hawaii"),]
us_aea <- rbind(us_aea, alaska, hawaii)
plot(us_aea)

# back to sf
us_aea <- st_as_sf(us_aea)
plot(st_geometry(us_aea))

# change proj
us_aea <- st_transform(x = us_aea, crs = "+proj=longlat +datum=WGS84 +no_defs")

us_aea <- ms_simplify(us_aea)


# Maps
# Mercator
r2d3map(shape = us_aea) %>%
  add_labs(title = "US (mercator)")

# Albers
r2d3map(shape = us_aea, projection = "Albers") %>%
  add_labs(title = "US (albers)") %>%
  add_tooltip("{name}")





