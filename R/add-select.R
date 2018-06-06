

#' Add a select menu above a map
#'
#' Use this to update variable used in \code{d3_cartogram}.
#'
#' @param map A \code{d3_cartogram} \code{htmlwidget} object.
#' @param label Display label for the control, or \code{NULL} for no label.
#' @param choices List of values to select from. Can be a named list. Values must be variables names.
#'
#' @export
#'
#' @importFrom shiny selectInput
#' @importFrom htmltools doRenderTags
#'
#' @examples
#' # todo
add_select_input <- function(map, label = NULL, choices) {
  id <- paste0("select-", sample.int(1e9, 1))
  select_ <- selectInput(
    inputId = id,
    label = label,
    choices = choices,
    multiple = FALSE,
    selectize = FALSE
  )
  select_$children[[2]]$children[[1]]$attribs$class <- "form-control custom-select"
  select_html <- doRenderTags(select_)
  choices <- unlist(choices, use.names = FALSE)
  if (is.null(map$x$options$data))
    stop("No data !", call. = FALSE)
  data_ <- map$x$options$data
  if (!all(choices %in% names(data_)))
    stop("Choices are not all columns names !", call. = FALSE)
  map$x$options$select <- TRUE
  .r2d3map_opt(
    map, "select_opts",
    select_html = select_html,
    id = id, choices = choices
  )
}




