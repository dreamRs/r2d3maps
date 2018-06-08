
context("Breaks scale")


test_that("Scale break - one var", {

  var <- "Petal.Length"
  sclbrk <- r2d3maps:::scale_breaks(data = iris, vars = var)

  expect_length(object = sclbrk, n = length(var))
  expect_identical(object = names(sclbrk), expected = var)

  sclbrkvar <- sclbrk[[var]]

  expect_length(object = sclbrkvar, n = 4)
  expect_named(object = sclbrkvar, expected = c("range_var", "breaks_var", "colors", "ticks"))

})


test_that("Scale break - several vars", {

  var <- c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")
  sclbrk <- r2d3maps:::scale_breaks(data = iris, vars = var)

  expect_length(object = sclbrk, n = length(var))
  expect_identical(object = names(sclbrk), expected = var)

  lapply(
    X = var,
    FUN = function(x) {
      sclbrkvar <- sclbrk[[x]]
      expect_length(object = sclbrkvar, n = 4)
      expect_named(object = sclbrkvar, expected = c("range_var", "breaks_var", "colors", "ticks"))
    }
  )

})



test_that("Add scale break", {
  map <- list(
    x = list(
      options = list(
        data = iris
      )
    )
  )
  class(map) <- "r2d3"

  resbrk <- add_continuous_breaks(map = map, var = "Petal.Width")
  resbrk <- resbrk$x$options$colors

  expect_false(object = is.null(resbrk))
  expect_length(object = resbrk, n = 4)
  expect_identical(object = resbrk$color_type, expected = "continuous-breaks")

})





