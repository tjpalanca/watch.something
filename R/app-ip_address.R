#' @include watch.something-package.R

ip_address_input <- function(req, input_id = "ip_address") {
  forwarder <- if_else(
    !is.null(req[["HTTP_X_FORWARDED_FOR"]]),
    req[["HTTP_X_FORWARDED_FOR"]],
    req[["REMOTE_ADDR"]]
  )
  div(
    style = "display: none;",
    textInput(
      inputId = input_id,
      label   = "IP Address",
      value   = stringr::str_split(forwarder, ", ")[[1]][[1]]
    )
  )
}

#' @importFrom rgeolocate ip_api ip_info
ip_address_country <- memoise(function(ip_address) {
  country <- try(
    ip_api(
      ip_addresses = ip_address,
      as_data_frame = TRUE
    )$country_code
  )
  if (inherits(country, "try-error")) {
    country <- ip_info(ip_address)$country
  }
  stringr::str_to_lower(country)
}, cache = pkg_cache())
