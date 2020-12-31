app_header <- function(id) {
  ns <- NS(id)
  div(
    id = ns("header"),
    class = "container header-image",
    tags$img(src = "figures/watch.something_hex.png")
  )
}
