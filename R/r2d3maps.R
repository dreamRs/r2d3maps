
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
    script = system.file("js/r2d3maps.js", package = "r2d3maps")
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




