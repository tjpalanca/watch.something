#' @title
#' Watch Something Shiny App
#'
#' @description
#' Shiny app for deciding what to watch
#'
#' @name app
#' @include app-ip_address.R
NULL

#' @describeIn app Application User Interface
#' @param request Internal parameter for `{shiny}`.
#' @import shiny
app_ui <- function(request) {
    tagList(
        app_resources(),
        app_meta(request),
        app_page("app"),
        getwd()
    )
}

#' @describeIn app Application Meta Interface
app_meta <- function(request) {
    tagList(
        ip_address_input(request),
        app_pwa_meta()
    )
}

#' @describeIn app Application Server Logic
#' @param input,output,session Internal parameters for {shiny}.
#' @import shiny
app_server <- function(input, output, session) {
    app_page_server("app")
}

#' @describeIn app Application Configuration
#' @param value Value to retrieve from the config file.
#' @param config R_CONFIG_ACTIVE value.
#' @param use_parent Logical, scan the parent directory for config file.
app_config <- function(value,
                       config = Sys.getenv("R_CONFIG_ACTIVE", "default"),
                       use_parent = TRUE) {
    config::get(
        value = value,
        config = config,
        file = dev_pkg_inst("golem-config.yml"),
        use_parent = use_parent
    )
}

#' @describeIn app Application Resources
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
app_resources <- function() {
    add_resource_path("www", dev_pkg_inst("app/www"))
    add_resource_path("figures", dev_pkg_inst("figures"))

    tags$head(
        tags$title(app_config("title")),
        tags$link(
            rel  = "shortcut icon",
            href = "figures/watch.something_hex.png"
        ),
        suppressDependencies("bootstrap"),
        shinyjs::useShinyjs(),
        tags$script(
            src = "https://kit.fontawesome.com/b7c62b184e.js",
            crossorigin = "anonymous"
        ),
        tags$link(rel = "stylesheet", href = "www/custom.css"),
        tags$link(rel = "stylesheet", href = "www/bulma.min.css"),
        tags$script(src = "www/jquery.touchSwipe.min.js"),
        tags$meta(
            name    = "viewport",
            content = "width=device-width, initial-scale=1"
        )
    )
}

#' @describeIn app Run the Application
#' @param port the port to be used
#' @param host the host address to be served
#' @param ... A series of options to be used inside the app.
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(...) {
    options("shiny.port" = app_config("port"),
            "shiny.host" = app_config("host"))
    with_golem_options(
        app = shinyApp(
            ui = app_ui,
            server = app_server
        ),
        golem_opts = list(...)
    )
}
