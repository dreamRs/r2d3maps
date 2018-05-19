
#' Create a map in D3
#'
#' @param shape A \code{sf} or \code{sp} object.
#' @param projection D3 projection to use.
#' @param width Desired width for output widget.
#' @param height Desired height for output widget.
#'
#' @export
#'
#' @importFrom geojsonio geojson_json geo2topo geojson_sf
#' @importFrom r2d3 r2d3
#' @importFrom htmltools htmlDependency
#'
#' @examples
#' library( sf )
#' library( rnaturalearth )
#' library( r2d3maps )
#'
#' # Hello world!
#' world <- st_as_sf(countries110)
#' r2d3map(shape = world)
#'
#' # Brazil!
#' brazil <- ne_states(country = "brazil", returnclass = "sf")
#' r2d3map(shape = brazil)
#'
#' # Italy!
#' italy <- ne_states(country = "italy", returnclass = "sf")
#' r2d3map(shape = italy)
#'
#' # Oceania!
#' oceania <- ne_countries(continent = "oceania", returnclass = "sf")
#' oceania <- sf::st_crop(oceania, xmin = 112, ymin = -56, xmax = 194, ymax = 12)
#' r2d3map(shape = oceania) %>%
#'   add_tooltip()
#'
r2d3map <- function(shape, projection = "Mercator", width = NULL, height = NULL) {

  projection <- match.arg(arg = projection, choices = c("Mercator", "Albers", "ConicEqualArea", "NaturalEarth"))

  # convert to geojson
  suppressWarnings({
    shape <- geojson_json(input = shape)
  })

  # keep data
  data <- geojson_sf(shape)
  data <- as.data.frame(data)
  data$geometry <- NULL

  # convert to topojson
  shape <- geo2topo(x = shape, object_name = "states")

  map <- r2d3(
    data = shape,
    d3_version = 5,
    dependencies = c(
      system.file("js/topojson.min.js", package = "r2d3maps"),
      system.file("js/d3-legend.min.js", package = "r2d3maps")
    ),
    # dependencies = list(
    #   htmlDependency(
    #     name = "topojson", version = "3.0.2",
    #     src = system.file("js", package = "r2d3maps"),
    #     script = "topojson.min.js"
    #   ),
    #   htmlDependency(
    #     name = "d3-legend", version = "2.25.6",
    #     src = system.file("js", package = "r2d3maps"),
    #     script = "d3-legend.min.js"
    #   )
    # ),
    script = system.file("js/r2d3maps2.js", package = "r2d3maps"),
    options = list(
      data = data, projection = projection,
      tooltip = FALSE, legend = FALSE, zoom = FALSE
    )
  )
  map$dependencies <- rev(map$dependencies)
  return(map)
}


#' @importFrom utils modifyList
.r2d3map_opt <- function(map, name, ...) {

  if(!any(class(map) %in% c("r2d3"))){
    stop("map must be a r2d3 object")
  }

  if (is.null(map$x$options[[name]])) {
    map$x$options[[name]] <- list(...)
  } else {
    map$x$options[[name]] <- utils::modifyList(
      x = map$x$options[[name]],
      val = list(...),
      keep.null = TRUE
    )
  }

  return(map)
}



#' Labs for a r2d3 map
#'
#' @param map A \code{r2d3map} \code{htmlwidget} object.
#' @param title The map title.
#' @param caption Brief explanation of the source of the data.
#'
#' @return A \code{r2d3map} \code{htmlwidget} object.
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # todo
#'
#' }
add_labs <- function(map, title = NULL, caption = NULL) {
  .r2d3map_opt(map, "labs", title = title, caption = caption)
}



#' Add continuous scale to a map
#'
#' @param map A \code{r2d3map} \code{htmlwidget} object.
#' @param var Variable to map.
#' @param palette Color palette, you can use Viridis or Brewer color palette.
#' @param direction Sets the order of colors in the scale.
#'  If 1, the default, colors are ordered from darkest to lightest.
#'  If -1, the order of colors is reversed.
#' @param n_breaks Number of breaks to cut data.
#' @param range Range of data, if \code{NULL} (default) range is calculated from data.
#' You can specify custom value, e.g. \code{c(0, 100)} to force palette to go from 0 to 100.
#'
#' @export
#'
#' @importFrom scales col_numeric viridis_pal
#' @importFrom utils type.convert
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
#' r2d3map(shape = tunisia) %>%
#'   add_continuous_scale(var = "p")
#'
#' # different color palette
#' r2d3map(shape = tunisia) %>%
#'   add_continuous_scale(var = "p", palette = "Greens")
#'
#' # legend
#' r2d3map(shape = tunisia) %>%
#'   add_continuous_scale(var = "p",
#'                        palette = "inferno",
#'                        direction = -1,
#'                        range = c(0, 100)) %>%
#'   add_legend(title = "Percentage", suffix = "%")
#'
add_continuous_scale <- function(map, var, palette = "viridis", direction = 1,
                                 n_breaks = 5, range = NULL) {
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
  if (is.null(range)) {
    range_col <- seq(from = min(var_, na.rm = TRUE), to = max(var_, na.rm = TRUE), length.out = n_breaks + 1)
  } else {
    range_col <- seq(from = range[1], to = range[2], length.out = n_breaks + 1)
  }
  .r2d3map_opt(
    map = map, name = "colors",
    color_type = "continuous",
    color_var = var,
    range_var = c(0, max(var_, na.rm = TRUE)),
    range_col = range_col,
    colors = c("#fafafa", colors)
  )
}




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
#' @param na.color Color to use for missing values.
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
#' r2d3map(shape = japan) %>%
#'   add_discrete_scale(var = "region")
#'
#' # different color palette
#' r2d3map(shape = japan) %>%
#'   add_discrete_scale(var = "region", palette = "Set2")
#'
#' # custom colors
#' r2d3map(shape = japan) %>%
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
#'     na.color = "#000"
#'   )
#'
#' # with legend
#' r2d3map(shape = japan) %>%
#'   add_discrete_scale(var = "region", palette = "Set1") %>%
#'   add_legend(title = "County")
#'
add_discrete_scale <- function(map, var, palette = "viridis", direction = 1, na.color = "#D8D8D8") {
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
    colors = if (na) c(colors, na.color) else colors
  )
}

#' @param values Named list mapping data values to colors.
#'  It's recommended to use Hex color code without alpha,
#'  e.g. \code{#} followed by 6 chars \code{[0-9a-f]}.
#'
#' @export
#'
#' @rdname discrete-scale
add_discrete_scale2 <- function(map, var, values, na.color = "#D8D8D8") {
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
    colors = if (na) c(colors, na.color) else colors
  )
}


#' Add a tooltip on a map
#'
#' @param map A \code{r2d3map} \code{htmlwidget} object.
#' @param value A \code{glue} string matching vars in \code{data}.
#' @param as_glue Use a \code{glue} string, if \code{FALSE}
#'  you can pass a character vector as tooltip.
#' @param .na Value to replace NA values with (if \code{value} is a \code{glue} string).
#'  Use \code{NULL} to don't display tooltip if there is NAs.
#'
#' @return A \code{r2d3map} \code{htmlwidget} object.
#' @export
#'
#' @importFrom glue glue glue_data
#'
#' @examples
#' \dontrun{
#'
#' # todo
#'
#' }
add_tooltip <- function(map, value = "<b>{name}</b><<scale_var>>", as_glue = TRUE, .na = "no data") {
  if (is.null(map$x$options$data))
    stop("No data !", call. = FALSE)
  if (as_glue) {
    var <- map$x$options$colors$color_var
    if (is.null(var)) {
      var <- ""
    } else {
      var <- paste0(": {", var, "}")
    }
    tooltip <- glue(value, scale_var = var, .open = "<<", .close = ">>")
    tooltip <- glue_data(tooltip, .x = map$x$options$data, .na = .na)
  } else {
    tooltip <- value
  }
  map$x$options$tooltip_value <- tooltip
  map$x$options$tooltip <- TRUE
  return(map)
}



#' Add zoom capacity
#'
#' @param map A \code{r2d3map} \code{htmlwidget} object.
#' @param enabled Logical, enable zooming.
#' @param type Type of zoom: \code{"click"} for zooming to clicked polygon,
#'  or \code{"wheel"} for zooming with mouse wheel. Both can be supplied.
#'
#' @note Zoom with mousewheel doesn't work in RStudio viewer.
#' Zooming can be slow for a map with lot of polygons.
#'
#' @export
#'
#' @examples
#' library( r2d3maps )
#' library( rnaturalearth )
#'
#'
#' turkey <- ne_states(country = "turkey", returnclass = "sf")
#' r2d3map(shape = turkey)
#'
#' # zoom with click
#' r2d3map(shape = turkey) %>% add_zoom()
#'
#' # zoom with mousewheel (open in browser)
#' r2d3map(shape = turkey) %>% add_zoom(type = "wheel")
#'
add_zoom <- function(map, enabled = TRUE, type = "click") {
  type <- match.arg(type, c("click", "wheel"), TRUE)
  map$x$options$zoom <- enabled
  map$x$options$zoom_opts <- list(
    click = "click" %in% type,
    wheel = "wheel" %in% type
  )
  return(map)
}



#' Add a legend to a map
#'
#' @param map A \code{r2d3map} \code{htmlwidget} object.
#' @param title Title for the legend.
#' @param prefix A prefix of legend labels.
#' @param suffix A suffix of legend labels.
#' @param d3_format A string passed to \code{d3.format},
#'  see \url{https://github.com/d3/d3-format}.
#'  If used \code{prefix} and \code{suffix} are ignored.
#'
#' @return A \code{r2d3map} \code{htmlwidget} object.
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # todo
#'
#' }
add_legend <- function(map, title = "", prefix = "", suffix = "", d3_format = NULL) {
  map$x$options$legend <- TRUE
  .r2d3map_opt(
    map, "legend_opts",
    title = title, prefix = prefix, suffix = suffix,
    d3_format = d3_format
  )
}

