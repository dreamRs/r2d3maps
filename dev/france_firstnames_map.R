
#  ------------------------------------------------------------------------
#
# Title : French popular firstnames
#    By : Victor
#  Date : 2018-05-18
#
#  ------------------------------------------------------------------------



# Packages ----------------------------------------------------------------

library( r2d3maps )
library( rnaturalearth )
library( dplyr )



# Boys in 1992 ------------------------------------------------------------

# map data
fr_dept <- ne_states(country = "france", returnclass = "sf")
fr_dept <- fr_dept[fr_dept$type_en %in% "Metropolitan department", ]


# firstnames data
data("prenoms_fr", package = "r2d3maps")
head(prenoms_fr)

prenoms_fr_92 <- prenoms_fr %>%
  filter(annais == 1992, sexe == 1) %>%
  group_by(preusuel) %>%
  mutate(n = n()) %>%
  ungroup() %>%
  mutate(prenom = if_else(n <= 2, "AUTRE", preusuel))

fr_dept <- left_join(
  x = fr_dept,
  y = prenoms_fr_92,
  by = "adm1_code"
)


# map
r2d3map(shape = fr_dept) %>%
  add_discrete_scale(var = "prenom", palette = "viridis") %>%
  add_tooltip(value = "<b>{name}</b>: {prenom}", .na = NULL) %>%
  add_legend(title = "Prénoms") %>%
  add_labs(
    title = "Prénoms masculins les plus attribués en 1992",
    caption = "Data: Insee"
  )





# Girls in 1989 -----------------------------------------------------------

# map data
fr_dept <- ne_states(country = "france", returnclass = "sf")
fr_dept <- fr_dept[fr_dept$type_en %in% "Metropolitan department", ]


# firstnames data
data("prenoms_fr", package = "r2d3maps")
head(prenoms_fr)

prenoms_fr_89 <- prenoms_fr %>%
  filter(annais == 1989, sexe == 2) %>%
  group_by(preusuel) %>%
  mutate(n = n()) %>%
  ungroup() %>%
  mutate(prenom = if_else(n < 2, "AUTRE", preusuel))

fr_dept <- left_join(
  x = fr_dept,
  y = prenoms_fr_89,
  by = "adm1_code"
)


# map
r2d3map(shape = fr_dept) %>%
  add_discrete_scale(var = "prenom", palette = "viridis") %>%
  add_tooltip(value = "<b>{name}</b>: {prenom}", .na = NULL) %>%
  add_legend(title = "Prénoms") %>%
  add_labs(
    title = "Prénoms féminins les plus attribués en 1989",
    caption = "Data: Insee"
  )


r2d3map(shape = fr_dept) %>%
  add_discrete_scale2(
    var = "prenom",
    values = list(
      "ELODIE" = "indianred",
      "JULIE" = "cornflowerblue",
      "LAURA" = "gold",
      "MARION" = "mediumpurple",
      "AUTRE" = "grey",
      "AURÉLIE" = "forestgreen"
    )
  ) %>%
  add_tooltip(value = "<b>{name}</b>: {prenom}", .na = NULL) %>%
  add_legend(title = "Prénoms") %>%
  add_labs(
    title = "Prénoms féminins les plus attribués en 1989",
    caption = "Data: Insee"
  )



