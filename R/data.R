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



#' French population by department (in 2014).
#'
#'
#' @format A data frame with 100 rows and 5 variables:
#' \describe{
#'   \item{code_departement}{Department's code}
#'   \item{nom_du_departement}{Name of department}
#'   \item{population_totale}{Population}
#'   \item{adm1_code}{Code ADM1 (for join with NaturalEarth data)}
#'   \item{code_hasc}{Code HASC (for join with NaturalEarth data)}
#' }
#' @source data.gouv (\url{https://www.data.gouv.fr/fr/datasets/population/})
"pop_fr"

