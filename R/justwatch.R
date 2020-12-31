#' @include watch.something-package.R

jw_call <- function(path, ..., verb = "GET") {
  RETRY(
    verb = verb,
    url  = "https://apis.justwatch.com/",
    path = glue("content/{path}"),
    content_type_json(),
    ...
  ) %>%
    stop_for_status() %>%
    content(as = "parsed")
}

jw_locales <- memoise(function(current = timeout(604800)) {
  jw_call("locales/state") %>%
    tibble(locale = .) %>%
    unnest_wider(locale)
}, cache = pkg_cache())

jw_providers <- memoise(function(locale, current = timeout(604800)) {
  jw_call(glue("providers/locale/{locale}")) %>%
    tibble(provider = .) %>%
    unnest_wider(provider)
}, cache = pkg_cache())

jw_find_locale <- memoise(function(ip_address, current = timeout(604800)) {
  locale <-
    jw_locales() %>%
    filter(exposed_url_part == !!ip_address_country(ip_address)) %>%
    pull(full_locale)
  if (length(locale) == 0) {
    locale <- "en_PH"
  }
  return(locale)
}, cache = pkg_cache())

jw_get_providers <- memoise(function(title, locale = "en_PH", profile = "s100") {
  jw_call(
    path = glue("titles/{locale}/popular"),
    body = list(query = title),
    verb = "POST",
    encode = "json"
  ) %$%
    items %>%
    tibble(item = .) %>%
    unnest_wider(item) %>%
    filter(tolower(title) == !!tolower(title)) %>%
    mutate(offers = map(
      offers,
      ~tibble(offer = .) %>%
        unnest_wider(offer)
    )) %>%
    unnest_longer(offers) %>%
    transmute(
      provider_id = offers$provider_id,
      watch_url = map_chr(offers$urls, 1)
    ) %>%
    inner_join(jw_providers(locale), by = c("provider_id" = "id")) %>%
    transmute(
      provider_id,
      provider_name = clear_name,
      watch_url,
      icon_url = map_chr(icon_url, ~glue("https://images.justwatch.com", .))
    ) %>%
    distinct()
})

