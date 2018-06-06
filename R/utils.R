

# helper to extract data
extract_data <- function(x) {
  UseMethod("extract_data")
}
extract_data.SpatialPolygonsDataFrame <- function(x) {
  return(x@data)
}
extract_data.data.frame <- function(x) {
  return(x)
}
extract_data.sf <- function(x) {
  x <- as.data.frame(x)
  colsf <- attr(x, "sf_column")
  x[[colsf]] <- NULL
  return(x)
}
extract_data.NULL <- function(x) {
  NULL
}



