decision_cards <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      id = ns("cards_container"),
      class = "container cards-container"
    ),
    decision_buttons(ns("decision_buttons"))
  )
}

decision_cards_add <- function(id, item, ...) {
  shinyjs::html(
    id   = id,
    html = as.character(decision_card(item = item))
  )
}

decision_cards_server <- function(id) {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      decision_cards_add(
        id = "cards_container",
        item = sample_n(trakt_trending(), 1)$item[[1]]
      )
      decision <- decision_buttons_server("decision_buttons")
      observeEvent(
        decision(),
        decision_cards_add(
          id = "cards_container",
          item = sample_n(trakt_trending(), 1)$item[[1]]
        )
      )
    }
  )
}

decision_card <- function(item) {
  div(
    class = "card",
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
    ),
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

