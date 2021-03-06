
#' Create a map in D3
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
#' d3_map(shape = world)
#'
#' # Brazil!
#' brazil <- ne_states(country = "brazil", returnclass = "sf")
#' d3_map(shape = brazil)
#'
#' # Italy!
#' italy <- ne_states(country = "italy", returnclass = "sf")
#' d3_map(shape = italy)
#'
#' # Oceania!
#' oceania <- ne_countries(continent = "oceania", returnclass = "sf")
#' oceania <- sf::st_crop(oceania, xmin = 112, ymin = -56, xmax = 194, ymax = 12)
#' d3_map(shape = oceania) %>%
#'   add_tooltip()
#'
d3_map <- function(shape, projection = "Mercator", stroke_col = "#fff", stroke_width = 0.5, width = NULL, height = NULL) {

  projection <- match.arg(
    arg = projection,
    choices = c("Mercator", "Albers", "ConicEqualArea", "NaturalEarth")
  )

  # convert to geojson
  suppressWarnings({
    shape_json <- geojson_json(input = shape)
  })

  # keep data
  data <- extract_data(shape)

  # convert to topojson
  shape_topo <- geo2topo(x = shape_json, object_name = "states")

  map <- r2d3(
    data = shape_topo,
    d3_version = 5, container = "div",
    dependencies = c(
      system.file("js/topojson.min.js", package = "r2d3maps"),
      system.file("js/d3-legend.min.js", package = "r2d3maps"),
      system.file("js/r2d3maps-utils.js", package = "r2d3maps")
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
      tooltip = FALSE, legend = FALSE,
      zoom = FALSE, shiny = FALSE,
      stroke_col = stroke_col, stroke_width = stroke_width
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
#' library( r2d3maps )
#' library( rnaturalearth )
#'
#' ireland <- ne_states(country = "ireland", returnclass = "sf")
#' d3_map(shape = ireland) %>%
#'   add_labs(
#'     title = "Ireland",
#'     caption = "Data from NaturalEarth"
#'   )
#'
add_labs <- function(map, title = NULL, caption = NULL) {
  .r2d3map_opt(map, "labs", title = title, caption = caption)
}







#' Add a tooltip on a map
#'
#' @param map A \code{r2d3map} \code{htmlwidget} object.
#' @param value A \code{formula} or a \code{glue} string matching columns in \code{data}.
#' @param as_glue Use a \code{glue} string, if \code{FALSE}
#'  you can pass a character vector as tooltip.
#' @param .na Value to replace NA values with (if \code{value} is a \code{glue} string).
#'  Use \code{NULL} to don't display tooltip if there is NAs.
#'
#' @return A \code{r2d3map} \code{htmlwidget} object.
#' @export
#'
#' @importFrom glue glue glue_data
#' @importFrom stats model.frame
#'
#' @examples
#' library( r2d3maps )
#' library( rnaturalearth )
#'
#' belgium <- ne_states(country = "belgium", returnclass = "sf")
#'
#' # default
#' d3_map(shape = belgium) %>%
#'   add_tooltip()
#'
#' # glue
#' d3_map(shape = belgium) %>%
#'   add_tooltip(value = "{name} ({gn_name})")
#'
#' # formula
#' d3_map(shape = belgium) %>%
#'   add_tooltip(value = ~paste0(name, " (", gn_name, ")"))
add_tooltip <- function(map, value = "<b>{name}</b><<scale_var>>", as_glue = TRUE, .na = "no data") {
  if (is.null(map$x$options$data))
    stop("No data !", call. = FALSE)
  tooltip <- make_tooltip(
    data = map$x$options$data,
    value = value,
    var = map$x$options$colors$color_var,
    as_glue = as_glue,
    .na = .na
  )
  map$x$options$tooltip_value <- tooltip
  map$x$options$tooltip <- TRUE
  return(map)
}


make_tooltip <- function(data, value, var = NULL, as_glue = TRUE, .na = "no data") {
  if (inherits(x = value, what = "formula")) {
    tooltip <- model.frame(formula = value, data = data)[[1]]
  } else {
    if (as_glue) {
      if (is.null(var)) {
        var <- ""
      } else {
        var <- paste0(": {", var, "}")
      }
      tooltip <- glue(value, scale_var = var, .open = "<<", .close = ">>")
      tooltip <- glue_data(tooltip, .x = data, .na = .na)
    } else {
      tooltip <- value
    }
  }
  return(tooltip)
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
#' d3_map(shape = turkey)
#'
#' # zoom with click
#' d3_map(shape = turkey) %>% add_zoom()
#'
#' # zoom with mousewheel (open in browser)
#' d3_map(shape = turkey) %>% add_zoom(type = "wheel")
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
#' @param d3_locale Locale for \code{d3_format}, for exemple \code{"fr-FR"} for french,
#'  see possible values here \url{https://github.com/d3/d3-format/tree/master/locale}.
#'
#' @return A \code{r2d3map} \code{htmlwidget} object.
#' @export
#'
#' @importFrom jsonlite fromJSON
#'
#' @examples
#' \dontrun{
#'
#' # todo
#'
#' }
add_legend <- function(map, title = "", prefix = "", suffix = "", d3_format = NULL, d3_locale = NULL) {
  if (!is.null(d3_locale)) {
    path <- system.file(file.path("js/locale", paste0(d3_locale, ".json")), package = "r2d3maps")
    d3_locale <- jsonlite::fromJSON(txt = path)
  }
  map$x$options$legend <- TRUE
  .r2d3map_opt(
    map, "legend_opts",
    title = title, prefix = prefix, suffix = suffix,
    d3_format = d3_format, d3_locale = d3_locale
  )
}





#' Retrieve click in Shiny
#'
#' @param map A \code{r2d3map} \code{htmlwidget} object.
#' @param inputId The \code{input} slot that will be used to access the value.
#' @param layerId Name of a variable present in data to filter results returned,
#' if \code{NULL} (default) all columns are returned.
#' @param action What triggers input value server-side, \code{click} or \code{dblclick}.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library( r2d3maps )
#' library( r2d3 )
#' library( rnaturalearth )
#' library( shiny )
#'
#' france <- ne_states(country = "france", returnclass = "sf")
#' france <- france[france$type_en %in% "Metropolitan department", ]
#'
#' if (interactive()) {
#'   ui <- fluidPage(
#'
#'     fluidRow(
#'       column(
#'         offset = 2, width = 8,
#'         tags$h2("r2d3maps Shiny example"),
#'         fluidRow(
#'           column(
#'             width = 6,
#'             d3Output(outputId = "map")
#'           ),
#'           column(
#'             width = 6,
#'             verbatimTextOutput(outputId = "res_click")
#'           )
#'         )
#'       )
#'     )
#'
#'   )
#'
#'   server <- function(input, output, session) {
#'
#'     output$map <- renderD3({
#'       d3_map(shape = france) %>%
#'         add_tooltip() %>%
#'         add_click(
#'           inputId = "myclick",
#'           layerId = "name", # return only name,
#'           # NULL to get all data
#'           action = "dblclick" # on double click,
#'           # use "click" for simple click
#'         )
#'     })
#'
#'     output$res_click <- renderPrint({
#'       str(input$myclick, max.level = 2)
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
#' }
add_click <- function(map, inputId, layerId = NULL, action = "click") {
  action <- match.arg(action, c("click", "dblclick"))
  map$x$options$shiny <- TRUE
  .r2d3map_opt(
    map, "shiny_opts",
    inputId = inputId,
    layerId = layerId,
    action = action
  )
}


