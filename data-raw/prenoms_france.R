
#  ------------------------------------------------------------------------
#
# Title : French firstname
#    By : Victor
#  Date : 2018-05-15
#
#  ------------------------------------------------------------------------



# Packages ----------------------------------------------------------------

library( sf )
library( rnaturalearth )
library( data.table )




# Raw ---------------------------------------------------------------------

tmp <- tempdir()
download.file(
  url = "https://www.insee.fr/fr/statistiques/fichier/2540004/dpt2016_txt.zip",
  destfile = file.path(tmp, "dpt2016_txt.zip")
)
path <- unzip(zipfile = file.path(tmp, "dpt2016_txt.zip"), exdir = tmp)

firstnames <- fread(input = path, encoding = "UTF-8")
firstnames


# Munging -----------------------------------------------------------------

# filter xxxx values
firstnames <- firstnames[annais != "XXXX" & dpt != "XX"]
firstnames <- firstnames[!preusuel %chin% c("_PRENOMS_RARES")]

# keep top firstname by annais/sexe/dpt
firstnames <- firstnames[, .SD[which.max(nombre)], by = list(sexe, annais, dpt)]
firstnames

# last 30 years (since 2018)
firstnames[, annais := as.numeric(annais)]
firstnames <- firstnames[annais >= 1988]

# order rows
setorder(firstnames, -sexe, annais, dpt)
firstnames




# NE code -----------------------------------------------------------------

data("pop_fr", package = "r2d3maps") # already done here
pop_fr <- as.data.table(pop_fr)
head(pop_fr)

firstnames <- merge(
  x = firstnames,
  y = pop_fr[, list(code_departement, nom_du_departement, adm1_code)],
  by.x = "dpt", by.y = "code_departement"
)

firstnames



# End ---------------------------------------------------------------------

prenoms_fr <- copy(firstnames)
setDF(prenoms_fr)

usethis::use_data(prenoms_fr, overwrite = TRUE)









