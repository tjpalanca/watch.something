#' @include app-header.R
#'          app-watch_item_card.R
#'          app-decision_buttons.R
#'          app-footer.R
#'          app-decision_cards.R

app_page <- function(id) {
  ns <- NS(id)
  div(
    id = ns("app"),
    class = "container app",
    app_header(ns("header")),
    decision_cards(ns("decision_cards")),
    app_footer(ns("footer"))
  )
}

app_page_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      decision_cards_server("decision_cards")
    }
  )
}
