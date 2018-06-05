
#' Create a cartogram in D3
#'
#' @param shape A \code{sf} or \code{sp} object.
#' @param projection D3 projection to use.
#' @param stroke_col Color of shape contours.
#' @param stroke_width Width of shape contour in pixels.
#' @param width Desired width for output widget.
#' @param height Desired height for output widget.
#'
#' @export
#'
#' @importFrom utils packageVersion
#'
#' @importFrom geojsonio geojson_json geo2topo geojson_list
#' @importFrom jsonlite toJSON
#'
#' @examples
#' # todo
d3_cartogram <- function(shape, projection = "Mercator", stroke_col = "#fff", stroke_width = 0.5, width = NULL, height = NULL) {
  if (packageVersion("geojsonio") < "0.6.0.9100")
    stop("You need geojsonio >= 0.6.0.9100 to use this function.", call. = FALSE)

  projection <- match.arg(
    arg = projection,
    choices = c("Mercator", "Albers", "ConicEqualArea", "NaturalEarth")
  )


  geo_list <- geojson_list(input = shape)
  for (i in seq_along(geo_list$features)) {
    geo_list$features[[i]]$id <- as.character(i)
    geo_list$features[[i]]$properties$id <- as.character(i)
  }
  geo_json <- geojson_json(input = geo_list)

  # topojson
  geo_topo <- geo2topo(x = geo_json, object_name = "states", quantization = 1e5)

  raw_data <- extract_data(shape)
  raw_data$id <- as.character(seq_len(nrow(raw_data)))

  r2d3(
    data = geo_topo, d3_version = 5,
    dependencies = c(
      system.file("js/topojson.min.js", package = "r2d3maps"),
      system.file("js/d3-cartogram.min.js", package = "r2d3maps")
    ),
    script = system.file("js/r2d3cartogram.js", package = "r2d3maps"),
    options = list(
      projection = projection,
      tooltip = FALSE, legend = FALSE,
      cartogram = FALSE,
      stroke_col = stroke_col, stroke_width = stroke_width,
      data = raw_data,
      json_data = jsonlite::toJSON(raw_data)
    )
  )

}

