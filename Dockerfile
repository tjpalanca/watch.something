FROM tjpalanca/apps:tjutils-v0.5.1
MAINTAINER TJ Palanca <mail@tjpalanca.com>

# Package Dependencies
RUN install2.r -s httr
RUN install2.r -s magrittr
RUN install2.r -s shinyjs
RUN install2.r -s golem
RUN install2.r -s htmltools
RUN install2.r -s sass
RUN install2.r -s hexSticker
RUN install2.r -s grid
RUN install2.r -s png
RUN install2.r -s tibble
RUN install2.r -s tidyr
RUN install2.r -s dplyr
RUN install2.r -s memoise
RUN install2.r -s lubridate
RUN install2.r -s rlang
RUN install2.r -s glue
RUN install2.r -s viridis
RUN install2.r -s stringr
RUN install2.r -s rgeolocate
RUN install2.r -s jsonlite

# Make package directory
RUN mkdir -p /watch.something
WORKDIR /watch.something

# Build assets
COPY DESCRIPTION DESCRIPTION
COPY NAMESPACE NAMESPACE
COPY .Rbuildignore .Rbuildignore
COPY inst inst
COPY man man
COPY R R

# Install package
RUN Rscript -e "devtools::install('.', dependencies = TRUE, upgrade = FALSE)"

# Post-build assets
COPY scripts scripts
COPY README.md README.md
COPY README.Rmd README.Rmd

# Golem Command
EXPOSE 3838
CMD Rscript -e "watch.something::run_app()"
