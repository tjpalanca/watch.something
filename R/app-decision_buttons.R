decision_buttons <- function(id) {
  ns <- NS(id)
  div(
    class = "container decision-buttons",
    div(
      class = "columns is-mobile is-centered",
      div(
        class = "column is-narrow",
        decision_button(ns("reject"), "thumbs-down", "danger")
      ),
      div(
        class = "column is-narrow",
        decision_button(ns("seen"), "eye", "warning")
      ),
      div(
        class = "column is-narrow",
        decision_button(ns("accept"), "thumbs-up", "success")
      )
    )
  )
}

decision_button <- function(input_id, icon, color) {
  tags$button(
    id = input_id,
    type = "button",
    class = glue("button is-rounded is-{color} action-button"),
    tags$span(
      class = "icon",
      tags$i(class = glue("fas fa-{icon}"))
    )
  )
}

decision_buttons_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      decision <- reactiveVal()
      observeEvent(
        input$reject,
        decision(list(decision = "reject", times = input$reject))
      )
      observeEvent(
        input$accept,
        decision(list(decision = "accept", times = input$accept))
      )
      observeEvent(
        input$seen,
        decision(list(decision = "seen", times = input$seen))
      )
      return(decision)
    }
  )
}
