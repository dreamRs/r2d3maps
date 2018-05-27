

#  ------------------------------------------------------------------------
#
# Title : Ireland population
#    By : Victor
#  Date : 2018-05-27
#
#  ------------------------------------------------------------------------


# Data source: https://www.cso.ie/en/releasesandpublications/ep/p-cpr/censusofpopulation2016-preliminaryresults/geochan/


# Packages ----------------------------------------------------------------

library( data.table )
library( r2d3maps )
library( rnaturalearth )
library( sf )



# Import ------------------------------------------------------------------

pop <- fread("data-raw/irishpop.csv", encoding = "UTF-8")
pop[, V10 := NULL]
vars <- c("persons_2011", "persons_2016", "males_2016", "females_2016", "changes_actual")
pop[, (vars) := lapply(.SD, gsub, pattern = " ", replacement = ""), .SDcols = vars]
pop[, (vars) := lapply(.SD, as.numeric), .SDcols = vars]
pop[, changes_percentage := gsub(pattern = ",", replacement = ".", x = changes_percentage)]
pop[, changes_percentage := as.numeric(changes_percentage)]




# Merge geo ---------------------------------------------------------------

ireland <- ne_states(country = "ireland", returnclass = "sf")
iredt <- as.data.table(ireland[, c("name", "gn_name", "adm1_code")])
iredt$geometry <- NULL

pop_ireland <- merge(
  x = pop,
  y = iredt
)
pop_ireland[, name := NULL]
pop_ireland[, gn_name := NULL]
pop_ireland[, type_en := NULL]
setcolorder(pop_ireland, c("adm1_code", "persons_2011", "persons_2016", "males_2016", "females_2016",
                           "changes_actual", "changes_percentage"))




# Example -----------------------------------------------------------------

ireland <- ne_states(country = "ireland", returnclass = "sf")
# data("pop_ireland")

ireland <- merge(x = ireland, y = pop_ireland, by = "adm1_code")

d3_map(shape = ireland) %>%
  add_tooltip(value = "{gn_name}: {females_2016}") %>%
  add_continuous_gradient(var = "females_2016") %>%
  add_labs(
    title = "Women in Ireland (2016)",
    caption = "Data from NaturalEarth"
  )



# Save --------------------------------------------------------------------

pop_irl <- as.data.frame(pop_ireland)
usethis::use_data(pop_irl, overwrite = TRUE)


