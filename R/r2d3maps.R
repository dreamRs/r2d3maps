
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
#' \dontrun{
#'
#' # todo
#'
#' }
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

  r2d3(
    data = shape,
    d3_version = 5,
    dependencies = htmlDependency(
      name = "topojson", version = "3.0.2",
      src = system.file("js", package = "r2d3maps"),
      script = "topojson.min.js"
    ),
    script = system.file("js/r2d3maps.js", package = "r2d3maps"),
    options = list(
      data = data, projection = projection,
      tooltip = FALSE, legend = FALSE
    )
  )

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
add_labs <- function(map, title = NULL) {
  .r2d3map_opt(map, "labs", title = title)
}



#' Add continuous scale to a map
#'
#' @param map A \code{r2d3map} \code{htmlwidget} object.
#' @param var Variable to map.
#' @param palette Color palette
#' @param direction Sets the order of colors in the scale.
#'  If 1, the default, colors are ordered from darkest to lightest.
#'  If -1, the order of colors is reversed.
#' @param n_breaks Number of breaks to cut data.
#' @param range Range of data, if \code{NULL} (default) range is calculated from data.
#' You can specify custom value, e.g. \code{c(0, 100)} to force palette to go from 0 to 100.
#'
#' @export
#'
#' @importFrom viridisLite viridis magma plasma inferno cividis
#' @importFrom scales col_numeric
#' @importFrom utils type.convert
#'
#' @examples
#' \dontrun{
#'
#' # todo
#'
#' }
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
    colors <- do.call(palette, list(n = n_breaks, direction = direction))
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



#' Add a tooltip on a map
#'
#' @param map A \code{r2d3map} \code{htmlwidget} object.
#' @param value A \code{glue} string matching vars in \code{data}.
#' @param as_glue Use a \code{glue} string, if \code{FALSE}
#'  you can pass a character vector as tooltip.
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
add_tooltip <- function(map, value = "<b>{name}</b><<scale_var>>", as_glue = TRUE) {
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
    tooltip <- glue_data(tooltip, .x = map$x$options$data)
  } else {
    tooltip <- value
  }
  map$x$options$tooltip_value <- tooltip
  map$x$options$tooltip <- TRUE
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

