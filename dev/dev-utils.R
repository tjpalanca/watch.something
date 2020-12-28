# Set Development Environment ---------------------------------------------

Sys.setenv("R_CONFIG_ACTIVE" = "dev")

# Development Packages ----------------------------------------------------

require(devtools)
require(usethis)
require(pkgdown)

# Development Utilities ---------------------------------------------------

d <- devtools::document
r <- devtools::load_all

dr <- function(reset = FALSE, export_all = TRUE) {
    if (reset) {
        rm(list = ls(envir = globalenv()), envir = globalenv())
        source("dev/dev-utils.R")
    }
    try(suppressWarnings(pkgload::load_all(export_all = export_all)))
    if (rstudioapi::isAvailable()) rstudioapi::documentSaveAll()
    devtools::document()
    pkgload::load_all(export_all = export_all)
}

drr <- function(reset = FALSE, export_all = TRUE, ...) {
  dr(reset = reset, export_all = export_all)
  watch.something::run_app(...)
}

rr <- function(...) {
  r()
  watch.something::run_app(...)
}
