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
#' @importFrom purrr map_dfr
#' @importFrom tidyr unnest_wider
#' @importFrom tibble tibble
#' @importFrom tjutils dev_pkg_inst
#' @importFrom magrittr %>% %$% %T>%
#' @import lubridate
#' @keywords internal
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL
