test_that("customize schedule output is either a string or error", {
  expect_true(is.character(customize_schedule()) | class(try(log(customize_schedule()),silent = TRUE)) == "try_error")
})
