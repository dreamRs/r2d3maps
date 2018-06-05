


# Dev cartogram -----------------------------------------------------------



library( r2d3maps )
library( rnaturalearth )

ireland <- ne_states(country = "ireland", returnclass = "sf")

# dummy var
ireland$foo <- sample.int(100, nrow(ireland))
ireland$foo2 <- sample.int(1000, nrow(ireland))

# simplify shapes
ireland <- rmapshaper::ms_simplify(ireland, keep = 0.1)

# no change
d3_cartogram(shape = ireland)

# add continuous scale to modify shapes
d3_cartogram(shape = ireland) %>%
  add_continuous_breaks(var = "foo2", palette = "Blues")

