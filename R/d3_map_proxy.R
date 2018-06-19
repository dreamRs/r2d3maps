
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
#' @name proxy
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

#' @export
#'
#' @rdname proxy
d3_cartogram_proxy <- function(shinyId, data = NULL, session = shiny::getDefaultReactiveDomain()) {

  if (is.null(session)) {
    stop("d3_cartogram_proxy must be called from the server function of a Shiny app")
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
    class = "d3_cartogram_proxy"
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
#'
#' @examples
#' \dontrun{
#'
#' if (interactive()) {
#'
#' library(r2d3maps)
#' library(shiny)
#'
#' # data about Paris
#' data("paris")
#'
#'
#' # app
#' ui <- fluidPage(
#'   fluidRow(
#'     column(
#'       width = 8, offset = 2,
#'       tags$h2("Proxy for continuous breaks scale"),
#'       d3Output(outputId = "mymap"),
#'       selectInput(
#'         inputId = "var", label = "Variable:",
#'         choices = grep(pattern = "AGE", x = names(paris), value = TRUE)
#'       )
#'     )
#'   )
#' )
#'
#' server <- function(input, output, session) {
#'
#'   output$mymap <- renderD3({
#'     d3_map(shape = paris) %>%
#'       add_continuous_breaks(var = "AGE_00", palette = "Blues") %>%
#'       add_legend(d3_format = ".2s")
#'   })
#'
#'   observeEvent(input$var, {
#'     d3_map_proxy(shinyId = "mymap", data = paris) %>%
#'       update_continuous_breaks(var = input$var, palette = "Blues")
#'   }, ignoreInit = TRUE)
#'
#' }
#'
#' shinyApp(ui, server)
#'
#' }
#'
#' }
update_continuous_breaks <- function(proxy, var, palette = NULL, direction = 1, n_breaks = 5, style = "pretty") {
  if (!any(c("d3_map_proxy", "d3_cartogram_proxy") %in% class(proxy)))
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




#' Update a gradient scale in Shiny
#'
#' @param proxy A \code{d3_map_proxy} object.
#' @param var New var to use on the map.
#' @param low,high Colours for low and high ends of the gradient.
#' @param range A length two vector to force range of data.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' if (interactive()) {
#'
#' library(r2d3maps)
#' library(shiny)
#'
#' # data about Paris
#' data("paris")
#'
#'
#' # app
#' ui <- fluidPage(
#'   fluidRow(
#'     column(
#'       width = 8, offset = 2,
#'       tags$h2("Proxy for continuous breaks scale"),
#'       d3Output(outputId = "mymap"),
#'       selectInput(
#'         inputId = "var", label = "Variable:",
#'         choices = grep(pattern = "AGE", x = names(paris), value = TRUE)
#'       )
#'     )
#'   )
#' )
#'
#' server <- function(input, output, session) {
#'
#'   output$mymap <- renderD3({
#'     d3_map(shape = paris) %>%
#'       add_continuous_gradient(var = "AGE_00", low = "#FEE0D2", high = "#CB181D") %>%
#'       add_legend(d3_format = ".2s")
#'   })
#'
#'   observeEvent(input$var, {
#'     d3_map_proxy(shinyId = "mymap", data = paris) %>%
#'       update_continuous_gradient(var = input$var)
#'   }, ignoreInit = TRUE)
#'
#' }
#'
#' shinyApp(ui, server)
#'
#' }
#'
#' }
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
  .r2d3maps_proxy(
    proxy = proxy,
    name = "continuous-gradient",
    color_var = var,
    scale = scale_gradient(
      data = data,
      vars =  var,
      low = low,
      mid = NULL,
      high = high,
      range = range
    )
  )
}



#' Update a legend in Shiny
#'
#' @param proxy A \code{d3_map_proxy} object.
#' @param title Title for the legend.
#' @param prefix A prefix of legend labels.
#' @param suffix A suffix of legend labels.
#' @param d3_format A string passed to \code{d3.format},
#'  see \url{https://github.com/d3/d3-format}.
#'  If used \code{prefix} and \code{suffix} are ignored.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' if (interactive()) {
#'
#' library(r2d3maps)
#' library(shiny)
#'
#' # data about Paris
#' data("paris")
#'
#'
#' # app
#' ui <- fluidPage(
#'   fluidRow(
#'     column(
#'       width = 8, offset = 2,
#'       tags$h2("Proxy for continuous breaks scale"),
#'       d3Output(outputId = "mymap"),
#'       selectInput(
#'         inputId = "var", label = "Variable:",
#'         choices = grep(pattern = "AGE", x = names(paris), value = TRUE)
#'       )
#'     )
#'   )
#' )
#'
#' server <- function(input, output, session) {
#'
#'   output$mymap <- renderD3({
#'     d3_map(shape = paris) %>%
#'       add_continuous_gradient(var = "AGE_00", low = "#FEE0D2", high = "#CB181D") %>%
#'       add_legend(d3_format = ".2s")
#'   })
#'
#'   observeEvent(input$var, {
#'     d3_map_proxy(shinyId = "mymap", data = paris) %>%
#'       update_continuous_gradient(var = input$var) %>%
#'       update_legend(title = tolower(gsub(
#'         patter = "_", replacement = " ", x = input$var
#'       )), d3_format = ".1s")
#'   }, ignoreInit = TRUE)
#'
#' }
#'
#' shinyApp(ui, server)
#'
#' }
#'
#' }
update_legend <- function(proxy, title = "", prefix = "", suffix = "", d3_format = NULL) {
  if (!"d3_map_proxy" %in% class(proxy))
    stop("This function must be used with a d3_map_proxy object", call. = FALSE)
  .r2d3maps_proxy(
    proxy = proxy,
    name = "legend",
    title = title,
    prefix = prefix,
    suffix = suffix,
    d3_format = d3_format
  )
}
