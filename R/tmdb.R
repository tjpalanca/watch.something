#' @include watch.something-package.R

tmdb_call <- function(path, query = list(), ...,
                      verb = "GET",
                      api_key = Sys.getenv("TMDB_API_KEY")) {
  RETRY(
    verb = verb,
    url  = "https://api.themoviedb.org",
    path = glue("3/{path}"),
    content_type_json(),
    query = modifyList(query, list(api_key = api_key)),
    ...
  ) %>%
    stop_for_status() %>%
    content(as = "parsed")
}

tmdb_configuration <- memoise(function(current = timeout(86400)) {
  tmdb_call("configuration")
}, cache = pkg_cache())

tmdb_image_secure_base_url <- memoise(function(current = timeout(86400)) {
  tmdb_configuration() %$%
    images %$%
    secure_base_url
}, cache = pkg_cache())

tmdb_info <- memoise(function(type, tmdb_id, current = timeout(86400)) {
  if (type == "movie") {
    tmdb_call(glue("movie/{tmdb_id}"))
  } else if (type == "show") {
    tmdb_call(glue("tv/{tmdb_id}"))
  } else {
    stop("Type must be either movie or show")
  }
}, cache = pkg_cache())

tmdb_image_poster_url <- memoise(function(type, tmdb_id,
                                          size = "w780",
                                          current = timeout(86400)) {
  poster_path <- tmdb_info(type, tmdb_id)$poster_path
  if (!is.null(poster_path)) {
    paste0(
      tmdb_image_secure_base_url(),
      size,
      poster_path
    )
  } else {
    NULL
  }
})

tmdb_image_backdrop_url <- memoise(function(type, tmdb_id,
                                            size = "w780",
                                            current = timeout(86400)) {
  backdrop_path <- tmdb_info(type, tmdb_id)$backdrop_path
  if (!is.null(backdrop_path)) {
    paste0(
      tmdb_image_secure_base_url(),
      size,
      backdrop_path
    )
  } else {
    NULL
  }
})
