
#' Wrapper of `r2d3` to create maps
#'
#' @param data An `sf` or `sp` object to convert to topojson.
#' @param script JavaScript file containing the D3 script.
#' @param css CSS file containing styles. The default value "auto" will use any CSS file
#'   located alongside the script file with the same stem (e.g. "barplot.css" would be
#'   used for "barplot.js") as well as any CSS file with the name "styles.css".
#' @param options Options to be passed to D3 script.
#' @param container The 'HTML' container of the D3 output.
#' @param elementId Use an explicit element ID for the widget (rather than an
#'   automatically generated one). Useful if you have other JavaScript that needs to
#'   explicitly discover and interact with a specific widget instance.
#' @param d3_version Major D3 version to use, the latest minor version is automatically
#'   picked.
#' @param dependencies Additional HTML dependencies. These can take the form of paths to
#'   JavaScript or CSS files, or alternatively can be fully specified dependencies created
#'   with [htmltools::htmlDependency].
#' @param width Desired width for output widget.
#' @param height Desired height for output widget.
#' @param sizing Widget sizing policy (see [htmlwidgets::sizingPolicy]).
#' @param viewer "internal" to use the RStudio internal viewer pane for output; "external"
#'   to display in an external RStudio window; "browser" to display in an external
#'   browser.
#'
#' @export
#' @importFrom r2d3 r2d3 default_sizing
#' @importFrom geojsonio geojson_json geo2topo
#' @importFrom htmltools htmlDependency
#'
#' @examples
#' # todo
r2d3map <- function(data, script, css = "auto", dependencies = NULL, options = NULL,
                    d3_version = c("5", "4", "3"), container = "svg", elementId = NULL,
                    width = NULL, height = NULL, sizing = default_sizing(),
                    viewer = c("internal", "external", "browser")) {
  # convert to geojson
  suppressWarnings({
    data <- geojson_json(input = data)
  })
  # convert to topojson
  data <- geo2topo(x = data, object_name = "states")
  # r2d3 call
  r2d3(
    data = data, script = script, css = css,
    dependencies = list(
      htmlDependency(
        name = "topojson", version = "3.0.2",
        src = system.file("js", package = "r2d3maps"),
        script = "topojson.min.js"
      ),
      dependencies
    ),
    options = options, d3_version = d3_version, container = container,
    elementId = elementId, width = width, height = height, sizing = sizing,
    viewer = viewer
  )
}


#' Use r2d3 template to create you D3 map
#'
#' @param path Path to a script R to create.
#'
#' @export
#'
#' @importFrom glue glue
#' @importFrom rstudioapi isAvailable navigateToFile
#'
#' @examples
#' \dontrun{
#'
#' # todo
#'
#' }
use_r2d3map <- function(path = "my_map.R") {
  dir_script <- dirname(path)
  path <- normalizePath(path, mustWork = FALSE)
  name <- basename(path)
  name <- gsub(pattern = "\\..+$", replacement = "", x = name)
  country <- c("Switzerland", "Cameroon", "Bolivia", "Denmark", "Madagascar", "Nigeria", "Nepal", "Togo", "Indonesia")
  country <- sample(country, 1)
  script <- readLines(con = system.file("template/map/map.R", package = "r2d3maps"))
  script <- paste(script, collapse = "\n")
  script <- glue::glue(script, country = country, name = paste(dir_script, name, sep = "/"))
  con <- file(path, encoding = "utf-8")
  on.exit(close(con), add = TRUE)
  cat(script, file = con, sep = "\n")
  file.copy(
    from = system.file("template/map/map.js", package = "r2d3maps"),
    to = file.path(dirname(path), paste0(name, ".js"))
  )
  file.copy(
    from = system.file("template/map/map.css", package = "r2d3maps"),
    to = file.path(dirname(path), paste0(name, ".css"))
  )
  if (rstudioapi::isAvailable()) {
    rstudioapi::navigateToFile(file = file.path(dirname(path), paste0(name, ".js")))
    rstudioapi::navigateToFile(file = path)
  }
  invisible(TRUE)
}

