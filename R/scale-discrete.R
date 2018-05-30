
#' Add discrete scale to a map
#'
#' Display a discrete value on a map. \code{add_discrete_scale} is for using a color palette,
#' \code{add_discrete_scale2} is to attach custom colors to data levels.
#'
#' @param map A \code{r2d3map} \code{htmlwidget} object.
#' @param var Variable to map
#' @param palette Color palette, you can use Viridis or Brewer color palette.
#' @param direction Sets the order of colors in the scale.
#'  If 1, the default, colors are ordered from darkest to lightest.
#'  If -1, the order of colors is reversed.
#' @param na_color Color to use for missing values.
#'
#' @export
#'
#' @name discrete-scale
#'
#' @importFrom scales brewer_pal viridis_pal
#'
#' @examples
#' library( r2d3maps )
#' library( rnaturalearth )
#'
#' # data
#' japan <- ne_states(country = "japan", returnclass = "sf")
#'
#' # Japan's regions
#' d3_map(shape = japan) %>%
#'   add_discrete_scale(var = "region")
#'
#' # different color palette
#' d3_map(shape = japan) %>%
#'   add_discrete_scale(var = "region", palette = "Set2")
#'
#' # custom colors
#' d3_map(shape = japan) %>%
#'   add_discrete_scale2(
#'     var = "region",
#'     values = list(
#'       "Chugoku" = "#000080",
#'       "Kyushu" = "#6B8E23",
#'       "Shikoku" = "#DDA0DD",
#'       "Chubu" = "#4169E1",
#'       "Kinki" = "#2E8B57",
#'       "Hokkaido" = "#4682B4",
#'       "Kanto" = "#FFA07A",
#'       "Tohoku" = "#F08080",
#'       "Okinawa" = "red"
#'     ),
#'     na_color = "#000"
#'   )
#'
#' # with legend
#' d3_map(shape = japan) %>%
#'   add_discrete_scale(var = "region", palette = "Set1") %>%
#'   add_legend(title = "County")
#'
add_discrete_scale <- function(map, var, palette = "viridis", direction = 1, na_color = "#D8D8D8") {
  if (is.null(map$x$options$data))
    stop("No data !", call. = FALSE)
  var_ <- map$x$options$data[[var]]
  if (is.null(var_))
    stop("Invalid variable supplied to continuous scale !", call. = FALSE)
  values <- if (is.factor(var_)) levels(var_) else unique(var_[!is.na(var_)])
  na <- anyNA(var_)
  n <- length(values)
  if (palette %in% c("viridis", "magma", "plasma", "inferno", "cividis")) {
    colors <- viridis_pal(option = palette, direction = direction)(n)
    colors <- substr(colors, 1, 7)
  } else {
    colors <- brewer_pal(palette = palette, direction = direction)(n)
  }
  .r2d3map_opt(
    map = map, name = "colors",
    color_type = "discrete",
    color_var = var,
    values = values,
    colors = if (na) c(colors, na_color) else colors
  )
}

#' @param values Named list mapping data values to colors.
#'  It's recommended to use Hex color code without alpha,
#'  e.g. \code{#} followed by 6 chars \code{[0-9a-f]}.
#'
#' @export
#'
#' @rdname discrete-scale
add_discrete_scale2 <- function(map, var, values, na_color = "#D8D8D8") {
  if (is.null(map$x$options$data))
    stop("No data !", call. = FALSE)
  var_ <- map$x$options$data[[var]]
  if (is.null(var_))
    stop("Invalid variable supplied to continuous scale !", call. = FALSE)
  na <- anyNA(var_)
  colors <- unlist(values, use.names = FALSE)
  values <- names(values)
  if (is.null(values)) {
    values <- if (is.factor(var_)) levels(var_) else unique(var_[!is.na(var_)])
  }
  .r2d3map_opt(
    map = map, name = "colors",
    color_type = "discrete",
    color_var = var,
    values = values,
    colors = if (na) c(colors, na_color) else colors
  )
}

