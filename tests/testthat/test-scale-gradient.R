
context("Gradient scale")


test_that("Scale gradient - one var", {

  var <- "Petal.Length"
  sclgdt <- r2d3maps:::scale_gradient(data = iris, vars = var)

  expect_length(object = sclgdt, n = length(var))
  expect_identical(object = names(sclgdt), expected = var)

  sclgdtvar <- sclgdt[[var]]

  expect_length(object = sclgdtvar, n = 5)
  expect_named(object = sclgdtvar, expected = c("range_var", "scale_var", "colors", "colors_legend", "legend_label"))

})


test_that("Scale gradient - several vars", {

  var <- c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")
  sclgdt <- r2d3maps:::scale_gradient(data = iris, vars = var)

  expect_length(object = sclgdt, n = length(var))
  expect_identical(object = names(sclgdt), expected = var)

  lapply(
    X = var,
    FUN = function(x) {
      sclgdtvar <- sclgdt[[x]]
      expect_length(object = sclgdtvar, n = 5)
      expect_named(object = sclgdtvar, expected = c("range_var", "scale_var", "colors", "colors_legend", "legend_label"))
    }
  )

})


test_that("Add scale gradient", {
  map <- list(
    x = list(
      options = list(
        data = iris
      )
    )
  )
  class(map) <- "r2d3"

  resgdt <- add_continuous_gradient(map = map, var = "Petal.Width")
  resgdt <- resgdt$x$options$colors

  expect_false(object = is.null(resgdt))
  expect_length(object = resgdt, n = 5)
  expect_identical(object = resgdt$color_type, expected = "continuous-gradient")

})



