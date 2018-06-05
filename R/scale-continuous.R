
#' @title Add continuous scale to a map
#'
#' @description Map a continuous numerical variables by
#' cutting it into class intervals.
#'
#' @param map A \code{d3_map} \code{htmlwidget} object.
#' @param var Variable to map.
#' @param palette Color palette, you can use Viridis or Brewer color palette.
#' @param direction Sets the order of colors in the scale.
#'  If 1, the default, colors are ordered from darkest to lightest.
#'  If -1, the order of colors is reversed.
#' @param n_breaks Number of breaks to cut data (depending on \code{style}, number of breaks can be re-computed).
#' @param style Style for computing breaks, see \code{\link[classInt]{classIntervals}}.
#' @param na_color Color to use for missing value(s).
#'
#' @export
#'
#' @importFrom scales col_numeric viridis_pal
#' @importFrom utils type.convert
#' @importFrom classInt classIntervals
#'
#' @examples
#' library( r2d3maps )
#' library( rnaturalearth )
#'
#' # data
#' tunisia <- ne_states(country = "tunisia", returnclass = "sf")
#'
#' # fake percentage
#' tunisia$p <- sample.int(100, nrow(tunisia))
#'
#' # fake continuous var
#' tunisia$foo <- sample.int(1e5, nrow(tunisia))
#'
#'
#' # Tunisia
#' d3_map(shape = tunisia) %>%
#'   add_continuous_breaks(var = "p")
#'
#' # different color palette
#' d3_map(shape = tunisia) %>%
#'   add_continuous_breaks(var = "p", palette = "Greens")
#'
#' # legend
#' d3_map(shape = tunisia) %>%
#'   add_continuous_breaks(var = "p",
#'                        palette = "inferno",
#'                        direction = -1) %>%
#'   add_legend(title = "Percentage", suffix = "%")
#'
#'
#'
#' # different style of breaks
#'
#' # equal
#' d3_map(shape = tunisia) %>%
#'   add_continuous_breaks(var = "foo",
#'                        palette = "inferno",
#'                        direction = -1,
#'                        style = "equal") %>%
#'   add_legend(title = "foo", d3_format = ".0f")
#'
#' # quantile
#' d3_map(shape = tunisia) %>%
#'   add_continuous_breaks(var = "foo",
#'                        palette = "inferno",
#'                        direction = -1,
#'                        style = "quantile") %>%
#'   add_legend(title = "foo", d3_format = ".0f")
#'
#' # pretty
#' d3_map(shape = tunisia) %>%
#'   add_continuous_breaks(var = "foo",
#'                        palette = "inferno",
#'                        direction = -1,
#'                        style = "pretty") %>%
#'   add_legend(title = "foo", d3_format = ".0f")
#'
add_continuous_breaks <- function(map, var, palette = "viridis", direction = 1,
                                 n_breaks = 5, style = "pretty", na_color = "#b8b8b8") {
  palette <- match.arg(
    arg = palette,
    choices = c("viridis", "magma", "plasma", "inferno", "cividis",
                "Blues", "BuGn", "BuPu", "GnBu", "Greens",
                "Greys", "Oranges", "OrRd", "PuBu", "PuBuGn", "PuRd", "Purples",
                "RdPu", "Reds", "YlGn", "YlGnBu", "YlOrBr", "YlOrRd")
  )
  if (is.null(map$x$options$data))
    stop("No data !", call. = FALSE)
  var_ <- map$x$options$data[[var]]
  if (is.null(var_))
    stop("Invalid variable supplied to continuous scale !", call. = FALSE)

  if (is.character(var_))
    var_ <- type.convert(var_)
  if (!is.numeric(var_))
    stop("'var' must be a numeric vector!", call. = FALSE)
  range_col <- classIntervals(var = var_, n = n_breaks, style = style)$brks
  n_breaks <- length(range_col) - 1
  if (palette %in% c("viridis", "magma", "plasma", "inferno", "cividis")) {
    colors <- viridis_pal(option = palette, direction = direction)(n_breaks)
    colors <- substr(colors, 1, 7)
  } else {
    pal <- col_numeric(palette = palette, domain = 0:100, na.color = "#808080")
    colors <- pal(seq(from = 20, to = 100, length.out = n_breaks + 1))
    if (direction > 0) {
      colors <- rev(colors)
    }
  }
  map$x$options$cartogram <- TRUE
  .r2d3map_opt(
    map = map, name = "colors",
    color_type = "continuous-breaks",
    color_var = var,
    range_var = c(0, max(var_, na.rm = TRUE)),
    range_col = range_col,
    na_color = na_color,
    colors = c("#fafafa", colors)
  )
}




#' @title Add gradient scale to a map
#'
#' @description Create a two colour gradient (low-high) or
#' a diverging colour gradient (low-mid-high) based on a continuous variable.
#'
#' @param map A \code{d3_map} \code{htmlwidget} object.
#' @param var Variable to map.
#' @param low,high Colours for low and high ends of the gradient.
#' @param range A length two vector to force range of data.
#' @param na_color Color to use for missing value(s).
#'
#' @export
#'
#' @name gradient-scale
#'
#' @importFrom scales seq_gradient_pal rescale
#'
#' @examples
#' library( r2d3maps )
#' library( rnaturalearth )
#'
#' # shapes
#' africa <- ne_countries(continent = "Africa", returnclass = "sf")
#'
#' # drinking water data
#' data("water_africa")
#' wa2015 <- water_africa[water_africa$year == "2015", ]
#'
#' # merge with sf object
#' africa <- merge(
#'   x = africa[, c("adm0_a3_is", "name", "geometry")],
#'   y = wa2015[, c("iso3", "national_at_least_basic")],
#'   by.x = "adm0_a3_is", by.y = "iso3"
#' )
#'
#' africa$national_at_least_basic <- round(africa$national_at_least_basic)
#'
#' # two colour gradient
#' d3_map(shape = africa) %>%
#'   add_continuous_gradient(
#'     var = "national_at_least_basic",
#'     range = c(0, 100)
#'   ) %>%
#'   add_tooltip(value = "<b>{name}</b>: {national_at_least_basic}%") %>%
#'   add_legend(title = "Population with at least basic access", suffix = "%") %>%
#'   add_labs(title = "Drinking water in Africa", caption = "Data: https://washdata.org/")
#'
#'
#' # three colour gradient
#' d3_map(shape = africa, stroke_col = "#585858") %>%
#'   add_continuous_gradient2(
#'     var = "national_at_least_basic",
#'     range = c(0, 100)
#'   ) %>%
#'   add_tooltip(value = "<b>{name}</b>: {national_at_least_basic}%") %>%
#'   add_legend(title = "Population with at least basic access", suffix = "%") %>%
#'   add_labs(title = "Drinking water in Africa", caption = "Data: https://washdata.org/")
#'
add_continuous_gradient <- function(map, var, low = "#132B43", high = "#56B1F7", range = NULL, na_color = "#b8b8b8") {
  if (is.null(map$x$options$data))
    stop("No data !", call. = FALSE)
  var_ <- map$x$options$data[[var]]
  if (is.null(var_))
    stop("Invalid variable supplied to continuous scale !", call. = FALSE)

  if (is.character(var_))
    var_ <- type.convert(var_)
  if (!is.numeric(var_))
    stop("'var' must be a numeric vector!", call. = FALSE)
  if (!is.null(range))
    var_ <- c(var_, range)
  var_ <- sort(unique(var_))
  pal <- seq_gradient_pal(low = low, high = high)
  var_scale <- rescale(var_, to = c(0, 1))
  colors <- pal(var_scale)
  colors_legend <- pal(seq(from = 0, to = 1, along.with = var_scale))
  .r2d3map_opt(
    map = map, name = "colors",
    color_type = "continuous-gradient",
    color_var = var,
    range_var = var_,
    scale_var = var_scale,
    colors = c(colors, "#fafafa"),
    colors_legend = colors_legend,
    na_color = na_color,
    legend_label = append(
      x = range(var_, na.rm = TRUE),
      values = diff(range(var_, na.rm = TRUE))/2,
      after = 1
    ),
    gradient_id = paste0("gradient-", sample.int(1e9, 1))
  )
}


#' @param mid Colour for mid point.
#'
#' @export
#'
#' @importFrom scales div_gradient_pal muted
#'
#' @rdname gradient-scale
add_continuous_gradient2 <- function(map, var, low = muted("red"), mid = "white", high = muted("blue"),
                                     range = NULL, na_color = "#b8b8b8") {
  if (is.null(map$x$options$data))
    stop("No data !", call. = FALSE)
  var_ <- map$x$options$data[[var]]
  if (is.null(var_))
    stop("Invalid variable supplied to continuous scale !", call. = FALSE)

  if (is.character(var_))
    var_ <- type.convert(var_)
  if (!is.numeric(var_))
    stop("'var' must be a numeric vector!", call. = FALSE)
  if (!is.null(range))
    var_ <- c(var_, range)
  var_ <- sort(unique(var_), na.last = TRUE)
  pal <- div_gradient_pal(low = low, mid = mid, high = high)
  var_scale <- rescale(var_, to = c(0, 1))
  colors <- pal(var_scale)
  colors_legend <- pal(seq(from = 0, to = 1, along.with = var_scale))
  .r2d3map_opt(
    map = map, name = "colors",
    color_type = "continuous-gradient",
    color_var = var,
    range_var = var_,
    scale_var = var_scale,
    colors = c(colors, "#fafafa"),
    colors_legend = colors_legend,
    na_color = na_color,
    legend_label = append(
      x = range(var_, na.rm = TRUE),
      values = diff(abs(range(var_, na.rm = TRUE)))/2,
      after = 1
    ),
    gradient_id = paste0("gradient-", sample.int(1e9, 1))
  )
}

