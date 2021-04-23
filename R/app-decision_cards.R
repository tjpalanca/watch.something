#' @importFrom shinyjs html show hidden hide
#' @importFrom purrr map2

decision_cards <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      id = ns("cards_container"),
      class = "container cards-container"
    ),
    decision_buttons(
      id = ns("decision_buttons")
    )
  )
}

add_decision_card <- function(id, item, ns, hidden = TRUE, ...) {
  card <- decision_card(item = item, ns = ns)
  if (hidden) card <- hidden(card)
  html(
    id   = id,
    html = as.character(card),
    add  = TRUE
  )
}

decision_cards_server <- function(id, cards) {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      shown_cards   <- reactiveVal(tibble(trakt_id = integer(0)))
      decided_cards <- reactiveVal(tibble(trakt_id = integer(0)))
      observeEvent(cards(), {
        req(cards())
        cards() %>%
          anti_join(shown_cards(), by = "trakt_id") %>%
          anti_join(decided_cards(), by = "trakt_id") %>%
          mutate(
            add_card = map2(
              trakt_id, item,
              function(trakt_id, item) {
                add_decision_card(
                  id = "cards_container",
                  item = item,
                  hidden = TRUE,
                  ns = session$ns
                )
                shown_cards(union(
                  shown_cards(),
                  tibble(trakt_id = trakt_id)
                ))
              }
            )
          )
      })
      observeEvent(shown_cards(), {
        req(shown_cards())
        shown_cards() %>%
          # Show top of stack and hide all others
          mutate(
            show_card = map2(
              trakt_id, row_number(),
              ~if (.y == 1) {
                show(id = .x)
              } else {
                hide(id = .x)
              }
            )
          )
      })
      current_card <- reactive({
        req(shown_cards())
        shown_cards()$trakt_id[[1]]
      })
      decision <- decision_buttons_server("decision_buttons")
    }
  )
}

decision_card <- function(item, ns) {
  div(
    id = ns(item$ids$trakt),
    class = "card decision-card",
    decision_card_image(item),
    decision_card_content(item)
  )
}

decision_card_image <- function(item) {
  div(
    class = "card-image",
    tags$figure(
      class = "image cover-image",
      tags$img(
        src =
          tmdb_image_backdrop_url(item$type, item$ids$tmdb) %||%
          tmdb_image_poster_url(item$type, item$ids$tmdb) %||%
          "https://via.placeholder.com/600x300",
        alt = glue("{item$title} Image")
      )
    ),
    if (!is.na(item$trailer)) {
      div(
        class = "card-content is-overlay",
        tags$span(
          class = "tag is-primary",
          tags$a(
            href = item$trailer,
            style = "color: white;",
            target = "_blank",
            "Trailer"
          )
        )
      )
    }
  )
}

decision_card_content <- function(item) {
  div(
    class = "card-content",
    tags$p(
      class = "title is-4 card-title",
      item$title,
      tags$br(),
      tags$small(
        class = "content is-small watch-metadata",
        glue("{item$year} | {item$runtime} minutes "),
        if (item$type == "show") glue("| {item$episodes} episodes "),
        glue("| {item$status}")
      )
    ),
    tags$p(
      class = "content is-small truncate-overflow rating-text",
      if (!is.na(item$tagline)) {
        tags$em(
          paste0(coalesce(item$tagline %||% "", ""), ".")
        )
      },
      tags$strong(
        format(item$rating, scientific = FALSE, digits = 2),
        "/ 10. "
      ),
      item$overview
    ),
    tags$span(
      class = "content tags",
      tagList(map(item$genres, decision_card_genre_tag))
    )
  )
}

decision_card_genre_tag <- function(genre) {
  genre_title <-
    trakt_genres() %>%
    filter(slug == genre) %>%
    pull(name)
  genre_color <-
    trakt_genres() %>%
    arrange(name) %>%
    mutate(color = viridis::viridis_pal()(nrow(.))) %>%
    filter(slug == genre) %>%
    pull(color)
  tags$span(
    class = "tag is-small",
    style = glue(
      "background-color: {genre_color}; ",
      "color: white;"
    ),
    genre_title
  )
}

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
