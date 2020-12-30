#' @title
#' Watch Something Shiny App
#'
#' @description
#' Shiny app for deciding what to watch
#'
#' @name app
NULL

#' @describeIn app Application User Interface
#' @param request Internal parameter for `{shiny}`.
#' @import shiny
app_ui <- function(request) {
    tagList(
        app_resources(),
        app_page()
    )
}

#' @describeIn app Application Server Logic
#' @param input,output,session Internal parameters for {shiny}.
#' @import shiny
app_server <- function(input, output, session) {
    # List the first level callModules here
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
        tags$title("Watch Something"),
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
        htmlDependency(
            name       = read.dcf("DESCRIPTION", "Package"),
            version    = read.dcf("DESCRIPTION", "Version"),
            src        = dev_pkg_inst("app/www/"),
            meta       = list(
                viewport = "width=device-width, initial-scale=1"
            ),
            stylesheet = c("custom.css", "bulma.min.css"),
            script     = ""
        )
    )
}

#' @describeIn app Run the Application
#' @param ... A series of options to be used inside the app.
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(...) {
    with_golem_options(
        app = shinyApp(
            ui = app_ui,
            server = app_server
        ),
        golem_opts = list(...)
    )
}
