app_pwa_generate_manifest <- function(output_dir = dev_pkg_inst("app/www")) {
  jsonlite::toJSON(
    list(
      name        = app_config("title"),
      theme_color = app_config(c("pwa", "theme_color")),
      background_color = app_config(c("pwa", "background_color")),
      display     = app_config(c("pwa", "display")),
      orientation = app_config(c("pwa", "orientation")),
      start_url   = app_config(c("pwa", "start_url")),
      scope       = app_config(c("pwa", "scope")),
      icons       = app_config(c("pwa", "icons"))
    ),
    pretty = TRUE,
    auto_unbox = TRUE
  ) %>%
    as.character() %>%
    writeLines(file.path(output_dir, "manifest.json"))
}

app_pwa_meta <- function(output_dir = dev_pkg_inst("app/pwa")) {
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  add_resource_path("pwa", output_dir)
  app_pwa_generate_manifest(output_dir)
  tagList(
    tags$head(
      tags$link(
        rel         = "manifest",
        href        = "pwa/manifest.json",
        crossorigin = "use-credentials"
      ),
      tags$script(
        async       = NA,
        src         = "https://cdn.jsdelivr.net/npm/pwacompat",
        crossorigin = "anonymous"
      )
    )
  )
}
