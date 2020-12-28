# Create the hex sticker for this package

# Library
library(hexSticker)
library(magrittr)

# Define logo location
logo_location <- dev_pkg_inst("figures/logo.png")
assertthat::assert_that(logo_location != "")
hex_location  <- "inst/figures/watch.something_hex.png"

# Render sticker
sticker(
    subplot  = logo_location %>%
        png::readPNG() %>%
        grid::rasterGrob(interpolate = TRUE),
    package  = "Watch Something",
    filename = hex_location,
    p_size   = 14,
    s_width  = 10,
    s_height = 0.9,
    s_x      = 1,
    s_y      = 0.85,
    p_color  = "#FFFFFF",
    h_color  = "#4f78bd",
    h_fill   = "#34558B"
)

# Use the logo
usethis::use_logo(hex_location)
