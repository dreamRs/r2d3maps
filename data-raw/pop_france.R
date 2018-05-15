

#  ------------------------------------------------------------------------
#
# Title : French population
#    By : Victor
#  Date : 2018-05-14
#
#  ------------------------------------------------------------------------
# naturalearth data

library( sf )
library( rnaturalearth )
fr_dept <- ne_states(country = "france", returnclass = "sf")




# data.gouv data
# Source data : https://www.data.gouv.fr/fr/datasets/population/

pop_fr <- read.table(
  file = "data-raw/population_departements.csv",
  header = TRUE, sep = ";", quote = "",
  stringsAsFactors = FALSE, encoding = "UTF-8"
)
pop_fr <- pop_fr[, c(3, 4, 9)]

clean <- function(x) {
  x <- stringi::stri_trans_general(str = x, id = "Latin-ASCII")
  x <- tolower(x)
  x <- gsub(pattern = "[^[:alnum:]]+", replacement = "_", x = x)
  x <- gsub(pattern = "^_", replacement = "", x = x)
  x <- gsub(pattern = "_$", replacement = "", x = x)
  x
}
names(pop_fr) <- clean(names(pop_fr))

pop_fr$nom_du_departement <- stringi::stri_trans_general(str = pop_fr$nom_du_departement, id = "ASCII-Latin")


# ajout code iso
fr_dept$name[fr_dept$name == "Seien-et-Marne"] <- "Seine-et-Marne"
fr_dept$name[fr_dept$name == "Meurhe-et-Moselle"] <- "Meurthe-et-Moselle"
fr_dept$name[fr_dept$name == "Haute-Rhin"] <- "Haut-Rhin"
fr_dept$name[fr_dept$name == "Guyane française"] <- "Guyane"


key_ne <- clean(fr_dept$name)
key_dg <- clean(pop_fr$nom_du_departement)

sum(key_dg %in% key_ne)

pop_fr$adm1_code <- fr_dept$adm1_code[match(x = key_dg, table = key_ne)]
pop_fr$code_hasc <- fr_dept$code_hasc[match(x = key_dg, table = key_ne)]

pop <- stringi::stri_replace_all(str = pop_fr$population_totale, replacement = "", regex = "[:space:]")
pop_fr$population_totale <- as.numeric(pop)


# use data
usethis::use_data(pop_fr, overwrite = TRUE)


