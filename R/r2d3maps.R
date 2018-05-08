
#' Create a map in D3
#'
#' @param shape A \code{sf} or \code{sp} object.
#' @param width Desired width for output widget.
#' @param height Desired height for output widget.
#'
#' @export
#'
#' @importFrom geojsonio geojson_json geo2topo
#' @importFrom r2d3 r2d3
#'
#' @examples
#' \dontrun{
#'
#' # todo
#'
#' }
r2d3map <- function(shape, width = NULL, height = NULL) {

  suppressWarnings({
    shape <- geojson_json(input = shape)
  })
  shape <- geo2topo(x = shape, object_name = "states")

  r2d3(
    data = shape,
    d3_version = 5,
    dependencies = system.file("js/topojson.js", package = "r2d3maps"),
    script = system.file("js/maps_v1.js", package = "r2d3maps")
  )

}

