app_footer <- function(id) {
  ns <- NS(id)
  div(
    class = "container myfooter",
    tags$small(
      class = "content",
      "Powered by ",
      tags$a(
        href = "https://trakt.tv/",
        target = "_blank",
        tags$img(
          src = "figures/trakt_logo.png",
          alt = "Trakt",
          style = "max-height: 1.5em; transform: translateY(0.4em);"
        )
      ),
      "and ",
      tags$a(
        href = "https://themoviedb.org",
        target = "_blank",
        "TMDb"
      ),
      "."
    )
  )
}
