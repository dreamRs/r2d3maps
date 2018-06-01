

# D3 map ------------------------------------------------------------------


# Packages ----
library(r2d3maps)
library(rnaturalearth)


# Data ----
{country} <- ne_states(country = "{country}", returnclass = "sf")


# Map ----
r2d3map(
  data = {country},
  script = "{name}.js"
)

