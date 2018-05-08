

#  ------------------------------------------------------------------------
#
# Title : Water data Africa
#    By : Vic
#  Date : 2018-05-08
#
#  ------------------------------------------------------------------------


# Source data: https://washdata.org


# Packages ----------------------------------------------------------------

library( data.table )




# Data --------------------------------------------------------------------

water <- readRDS(file = "data-raw/water.rds")
water

africa <- ne_countries(continent = "Africa", returnclass = "sf")



# Munging -----------------------------------------------------------------

water <- water[, 1:9]
water_africa <- water[iso3 %chin% africa$adm0_a3_is]
water_africa <- as.data.frame(water_africa)

usethis::use_data(water_africa)


