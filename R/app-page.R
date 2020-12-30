app_page <- function(id) {
  ns <- NS(id)
  div(
    id = ns("app"),
    class = "container app",
    app_header(),
    div(
      class = "container cards-container",
      watch_item_card(sample_n(trakt_trending(), 1)$item[[1]])
    ),
    decision_buttons(ns("decision_buttons"))
  )
}

app_page_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      decision <- decision_buttons_server("decision_buttons")
      observeEvent(
        decision(),
        shinyjs::alert(decision())
      )
    }
  )

}

app_header <- function() {
  div(
    class = "container header-image",
    tags$img(src = "figures/watch.something_hex.png")
  )
}

watch_item_card <- function(item) {
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
      )
    ),
    div(
      class = "card-content",
      tags$p(
        class = "title is-4",
        item$title,
        tags$br(class = "is-hidden-desktop"),
        tags$small(
          class = "content is-small watch-metadata",
          glue("{item$year} | {item$runtime} minutes "),
          if (item$type == "show") glue("| {item$episodes} episodes "),
          glue("| {item$status}")
        )
      ),
      if (!is.na(item$tagline)) {
        tags$p(
          class = "subtitle is-6",
          item$tagline
        )
      },
      tags$p(
        class = "content is-small truncate-overflow rating-text",
        tags$strong(
          format(item$rating, scientific = FALSE, digits = 2),
          "/10. "
        ),
        item$overview
      ),
      tags$span(
        class = "content tags",
        tagList(map(item$genres, watch_item_card_genre_tag))
      )
    )
  )
}

watch_item_card_genre_tag <- function(genre) {
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
