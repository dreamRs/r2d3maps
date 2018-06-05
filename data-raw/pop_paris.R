
#  ------------------------------------------------------------------------
#
# Title : Paris population
#    By : Victor
#  Date : 2018-06-05
#
#  ------------------------------------------------------------------------



# Packages ----------------------------------------------------------------

library( data.table )
library( sf)
library( CARTElette )
library( dplyr )


# Population data ---------------------------------------------------------

# https://www.insee.fr/fr/statistiques/2863610?sommaire=2867849
tmp <- tempdir()
download.file(
  url = "https://www.insee.fr/fr/statistiques/fichier/2863610/BTT_TD_POP1A_2014.zip",
  destfile = file.path(tmp, "BTT_TD_POP1A_2014.zip")
)
path <- unzip(zipfile = file.path(tmp, "BTT_TD_POP1A_2014.zip"), exdir = tmp)

pop_communes <- fread(input = path, encoding = "UTF-8")
pop_communes

pop_paris <- pop_communes[substr(CODGEO, 1, 2) == "75"]
pop_paris[SEXE == 1, SEXE_LIB := "M"]
pop_paris[SEXE == 2, SEXE_LIB := "F"]
pop_paris[, NB := round(NB)]
pop_paris[, AGEPYR10 := paste0("AGE_", sprintf("%02d", AGEPYR10))]

pop_paris <- dcast(data = pop_paris, formula = CODGEO ~ AGEPYR10, value.var = "NB", fun.aggregate = sum)
pop_paris <- pop_paris[CODGEO != "75056"]

pop_paris <- pop_paris[, TOTAL := Reduce("+", .SD), .SDcols = names(pop_paris)[-1]]




# Polygons data -----------------------------------------------------------

# fond de carte
library(geojsonio)
# https://opendata.paris.fr/explore/dataset/arrondissements/
download.file(
  url = "https://opendata.paris.fr/explore/dataset/arrondissements/download/?format=geojson&timezone=Europe/Berlin",
  destfile = file.path(tmp, "paris.geojson")
)
parisgeo <- geojson_read(
  x = file.path(tmp, "paris.geojson"), what = "sp",
  stringsAsFactors = FALSE, encoding = "UTF-8", use_iconv = TRUE
)
parisgeo <- as(parisgeo, "sf")
parisgeo
plot(st_geometry(parisgeo))





# Merge -------------------------------------------------------------------

paris <- left_join(
  x = mutate(parisgeo, c_arinsee = as.character(c_arinsee)) %>%
    select(CODE_INSEE = c_arinsee, LIB = l_ar, NAME = l_aroff),
  y = pop_paris,
  by = c("CODE_INSEE" = "CODGEO")
) %>%
  arrange(CODE_INSEE) %>%
  mutate(
    LIB = stringi::stri_trans_general(str = LIB, id = "ASCII-Latin"),
    NAME = stringi::stri_trans_general(str = NAME, id = "ASCII-Latin")
  )
paris




# Use data ----------------------------------------------------------------

usethis::use_data(paris, overwrite = TRUE)



# Tests -------------------------------------------------------------------


library(r2d3maps)
d3_cartogram(shape = paris) %>%
  add_continuous_breaks(var = "AGE_3", palette = "Blues")

# %
paris <- paris %>%
  mutate(
    M_80_P = M_80 / TOTAL * 100,
    M_11_P = M_11 / TOTAL * 100,
    M_25_P = M_25 / TOTAL * 100
  )

d3_cartogram(shape = paris) %>%
  add_continuous_breaks(var = "M_80_P", palette = "Blues")



test <- as.data.frame(paris[, grep(pattern = "AGE_", x = names(paris), value = TRUE)])
test$geometry <- NULL
cor(test)
library(corrplot)
M <- cor(test)
corrplot(M, cl.lim = c(0.7, 1), is.corr = FALSE)

