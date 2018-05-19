#' Drinking water access in Africa (2000 - 2015)
#'
#' Drinking water services refers to the accessibility,
#' availability and quality of the main source used by
#' households for drinking, cooking, personal hygiene and
#' other domestic uses
#'
#' @format A data frame with 784 rows and 8 variables:
#' \describe{
#'   \item{iso3}{ISO3 code}
#'   \item{year}{Year}
#'   \item{population_thousands}{Population (in thousands)}
#'   \item{urban}{Proportion of urban population}
#'   \item{national_at_least_basic}{Basic access}
#'   \item{national_limited_more_than_30_mins}{Drinking water from an improved source for which collection time exceeds 30 minutes for a roundtrip including queuing}
#'   \item{national_unimproved}{Drinking water from an unprotected dug well or unprotected spring}
#'   \item{national_surface_water}{Drinking water directly from a river, dam, lake, pond, stream, canal or irrigation canal}
#' }
#' @source UNICEF (\url{https://washdata.org})
"water_africa"



#' French population by county (in 2014).
#'
#'
#' @format A data frame with 100 rows and 5 variables:
#' \describe{
#'   \item{code_departement}{County code}
#'   \item{nom_du_departement}{County name}
#'   \item{population_totale}{Population}
#'   \item{adm1_code}{Code ADM1 (for join with NaturalEarth data)}
#'   \item{code_hasc}{Code HASC (for join with NaturalEarth data)}
#' }
#' @source data.gouv (\url{https://www.data.gouv.fr/fr/datasets/population/})
"pop_fr"



#' Most popular first names in France (1988-2016).
#'
#' First names most attributed to children born in France
#' (mainland France and Dom) between 1988 and 2016 and the
#' number of children by sex associated with each first name.
#'
#' @format A data frame with 5684 rows and 7 variables:
#' \describe{
#'   \item{dpt}{County code}
#'   \item{sexe}{'2' for women, '1' for men}
#'   \item{annais}{Year of birth}
#'   \item{preusuel}{Most given firstname}
#'   \item{nombre}{Number of children given the first name}
#'   \item{nom_du_departement}{County name}
#'   \item{adm1_code}{Code ADM1 (for join with NaturalEarth data)}
#' }
#' @source Insee (\url{https://www.insee.fr/fr/statistiques/2540004})
"prenoms_fr"


