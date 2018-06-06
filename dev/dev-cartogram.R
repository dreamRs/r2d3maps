


# Dev cartogram -----------------------------------------------------------



# Ireland -----------------------------------------------------------------

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





# Paris -------------------------------------------------------------------

library(r2d3maps)
data("paris")

d3_cartogram(shape = paris) %>%
  add_continuous_breaks(var = "AGE_00", palette = "Blues")


d3_cartogram(shape = paris) %>%
  add_select_input(label = "Choose a var:", choices = grep(pattern = "AGE", x = names(paris), value = TRUE)) %>%
  add_continuous_breaks(var = "AGE_03", palette = "Blues")




