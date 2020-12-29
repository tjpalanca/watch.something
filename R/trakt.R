trakt_call <- function(path, ..., verb = "GET",
                       api_key = Sys.getenv("TRAKT_CLIENT_ID")) {
  RETRY(
    verb = verb,
    url  = "https://api.trakt.tv",
    path = path,
    content_type_json(),
    add_headers(
      `trakt-api-version` = "2",
      `trakt-api-key` = api_key
    ),
    ...
  ) %>%
    stop_for_status() %>%
    content(as = "parsed")
}

trakt_countries <- memoise(function(current = timeout(86400)) {
  list(
    trakt_call("countries/shows"),
    trakt_call("countries/movies")
  ) %>%
    map_dfr(function(response) {
      response %>%
        tibble(country = .) %>%
        unnest_wider(country)
    }) %>%
    distinct(name, code)
})

trakt_genres <- memoise(function(current = timeout(86400)) {
  list(
    trakt_call("genres/shows"),
    trakt_call("genres/movies")
  ) %>%
    map_dfr(function(response) {
      response %>%
        tibble(genre = .) %>%
        unnest_wider(genre)
    }) %>%
    distinct(name, slug)
})

trakt_genres <- memoise(function(current = timeout(86400)) {
  list(
    trakt_call("genres/shows"),
    trakt_call("genres/movies")
  ) %>%
    map_dfr(function(response) {
      response %>%
        tibble(genre = .) %>%
        unnest_wider(genre)
    }) %>%
    distinct(name, slug)
})

trakt_languages <- memoise(function(current = timeout(86400)) {
  list(
    trakt_call("languages/shows"),
    trakt_call("languages/movies")
  ) %>%
    map_dfr(function(response) {
      response %>%
        tibble(genre = .) %>%
        unnest_wider(genre)
    }) %>%
    distinct(name, code)
})

trakt_params <- function(params        = list(),
                         query         = "",
                         year          = NULL,
                         year_range    = NULL,
                         genres        = NULL,
                         languages     = NULL,
                         countries     = NULL,
                         runtime       = NULL,
                         runtime_range = NULL,
                         rating        = NULL,
                         rating_range  = NULL,
                         page          = NULL,
                         limit         = NULL,
                         extended      = NULL) {
  current_year <- lubridate::year(Sys.Date())
  modifyList(
    params,
    list(
      query     = query,
      years     = if (!is.null(year)) {
        year <- pmin(pmax(year, 1900L), current_year)
        year_range <- year_range %||% 5L
        paste0(
          pmin(year - year_range, current_year), "-",
          pmin(year + year_range, current_year)
        )
      },
      genres    = paste0(genres, collapse = ","),
      languages = paste0(languages, collapse = ","),
      countries = paste0(countries, collapse = ","),
      runtimes  = if (!is.null(runtime)) {
        runtime <- pmin(pmax(runtime, 0), 300)
        runtime_range <- runtime_range %||% 30
        paste0(
          pmax(runtime - runtime_range, 0), "-",
          pmin(runtime + runtime_range, 300)
        )
      },
      ratings   = if (!is.null(rating)) {
        rating <- pmin(pmax(rating, 0), 100)
        rating_range <- rating_range %||% 10
        paste0(
          pmax(rating - rating_range, 0), "-",
          pmin(rating + rating_range, 100)
        )
      },
      extended = if (!is.null(extended)) if (extended) "full",
      page     = format(page, scientific = FALSE),
      limit    = format(limit, scientific = FALSE)
    )
  )
}

trakt_search <- memoise(function(...,
                                 type = "both",
                                 limit = 100L,
                                 extended = TRUE,
                                 current = timeout(86400)) {
  bind_rows(
    if (type %in% c("both", "movie")) {
      trakt_call(path  = "search/movie",
                 query = trakt_params(...,
                                      extended = extended,
                                      limit = limit)) %>%
        tibble(item = .) %>%
        unnest_wider(item) %>%
        unnest_wider(movie)
    },
    if (type %in% c("both", "show")) {
      trakt_call(path  = "search/show",
                 query = trakt_params(...,
                                      extended = extended,
                                      limit = limit))  %>%
        tibble(item = .) %>%
        unnest_wider(item) %>%
        unnest_wider(show)
    }
  ) %>%
    arrange(desc(score))
})

trakt_trending <- memoise(function(...,
                                   type = "both",
                                   limit = 100L,
                                   extended = TRUE,
                                   current = timeout(86400)) {
  bind_rows(
    if (type %in% c("both", "movie")) {
      trakt_call(path  = "movies/trending",
                 query = trakt_params(...,
                                      extended = extended,
                                      limit = limit)) %>%
        tibble(item = .) %>%
        mutate(type = "movie") %>%
        unnest_wider(item) %>%
        unnest_wider(movie)
    },
    if (type %in% c("both", "show")) {
      trakt_call(path  = "shows/trending",
                 query = trakt_params(...,
                                      extended = extended,
                                      limit = limit))  %>%
        tibble(item = .) %>%
        mutate(type = "show") %>%
        unnest_wider(item) %>%
        unnest_wider(show)
    }
  ) %>%
    arrange(desc(watchers))
})
