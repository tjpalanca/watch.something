#' @import htmltools
#' @import dplyr
#' @importFrom rlang %||%
#' @importFrom httr
#'             RETRY
#'             stop_for_status
#'             content
#'             content_type_json
#'             add_headers
#'             with_verbose
#' @importFrom memoise timeout memoise cache_memory
#' @importFrom purrr map_dfr map_int map map_chr
#' @importFrom tidyr unnest_wider unnest_longer
#' @importFrom tibble tibble
#' @import tjutils
#' @importFrom magrittr %>% %$% %T>%
#' @importFrom glue glue
#' @import lubridate
#' @keywords internal
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL

pkg_cache <- function(dir = "~/.cache/watch.something") {
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  memoise::cache_filesystem(dir)
}

