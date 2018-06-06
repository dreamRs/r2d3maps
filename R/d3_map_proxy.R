
#' Proxy for updating d3_map in Shiny
#'
#' @param shinyId single-element character vector indicating the output ID of the
#'   chart to modify (if invoked from a Shiny module, the namespace will be added
#'   automatically)
#' @param data An object containing data to map, must be the same object used in \code{d3_map}.
#' @param session the Shiny session object to which the chart belongs; usually the
#'   default value will suffice
#'
#' @export
#'
#' @importFrom shiny getDefaultReactiveDomain
#'
#' @examples
#' \dontrun{
#'
#' # todo
#'
#' }
d3_map_proxy <- function(shinyId, data = NULL, session = shiny::getDefaultReactiveDomain()) {

  if (is.null(session)) {
    stop("d3_map_proxy must be called from the server function of a Shiny app")
  }

  if (!is.null(session$ns) && nzchar(session$ns(NULL)) && substring(shinyId, 1, nchar(session$ns(""))) != session$ns("")) {
    shinyId <- session$ns(shinyId)
  }

  structure(
    list(
      session = session,
      id = shinyId,
      x = structure(
        list(data = extract_data(data))
      )
    ),
    class = "d3_map_proxy"
  )
}


# call r2d3maps proxy
.r2d3maps_proxy <- function(proxy, name, ...) {

  proxy$session$sendCustomMessage(
    type = sprintf("update-r2d3maps-%s-%s", name, proxy$id),
    message = list(id = proxy$id, data = list(...))
  )

  proxy
}



#' Update a continuous scale in Shiny
#'
#' @param proxy A \code{d3_map_proxy} object.
#' @param var New var to use on the map.
#' @param palette Color palette, you can use Viridis or Brewer color palette.
#' @param direction Sets the order of colors in the scale.
#'  If 1, the default, colors are ordered from darkest to lightest.
#'  If -1, the order of colors is reversed.
#' @param n_breaks Number of breaks to cut data (depending on \code{style}, number of breaks can be re-computed).
#' @param style Style for computing breaks, see \code{\link[classInt]{classIntervals}}.
#'
#' @export
#'
#' @importFrom classInt classIntervals
#'
#' @examples
#' \dontrun{
#'
#' # todo
#'
#' }
update_continuous_breaks <- function(proxy, var, palette = NULL, direction = 1, n_breaks = 5, style = "pretty") {
  if (!"d3_map_proxy" %in% class(proxy))
    stop("This function must be used with a d3_map_proxy object", call. = FALSE)
  data <- proxy$x$data
  if (is.null(data))
    stop("No data provided!", call. = FALSE)
  var_ <- data[[var]]
  if (is.null(var_)) {
    warning("Invalid variable!", call. = FALSE)
    return(invisible(proxy))
  }
  .r2d3maps_proxy(
    proxy = proxy,
    name = "continuous-breaks",
    color_var = var,
    scale = scale_breaks(
      data = data,
      vars = var,
      palette = palette,
      direction = direction,
      n_breaks = n_breaks,
      style = style
    )
  )
}




update_continuous_gradient <- function(proxy, var, low = NULL, high = NULL, range = NULL) {
  if (!"d3_map_proxy" %in% class(proxy))
    stop("This function must be used with a d3_map_proxy object", call. = FALSE)
  data <- proxy$x$data
  if (is.null(data))
    stop("No data provided!", call. = FALSE)
  var_ <- data[[var]]
  if (is.null(var_)) {
    warning("Invalid variable!", call. = FALSE)
    return(invisible(proxy))
  }
  if (!is.null(range))
    var_ <- c(var_, range)
  var_ <- sort(unique(var_))
  var_scale <- rescale(var_, to = c(0, 1))
  if (!is.null(low) & !is.null(high)) {
    pal <- seq_gradient_pal(low = low, high = high)
    colors <- pal(var_scale)
    colors_legend <- pal(seq(from = 0, to = 1, along.with = var_scale))
  } else {
    colors <- NULL
    colors_legend <- NULL
  }
  .r2d3maps_proxy(
    proxy = proxy,
    name = "continuous-gradient",
    color_var = var,
    range_var = var_,
    scale_var = var_scale,
    colors = if (!is.null(colors)) c(colors, "#fafafa") else NULL,
    colors_legend = colors_legend,
    legend_label = append(
      x = range(var_, na.rm = TRUE),
      values = diff(range(var_, na.rm = TRUE))/2,
      after = 1
    )
  )
}




