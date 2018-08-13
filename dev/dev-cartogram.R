


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
  add_continuous_breaks(var = "AGE_00", palette = "Blues") %>%
  add_tooltip(value = "{LIB}: {AGE_00}") %>%
  add_legend(title = "Population under 3") %>%
  add_labs(title = "Paris")

d3_map(shape = paris) %>%
  add_continuous_breaks(var = "AGE_00", palette = "Blues") %>%
  add_tooltip(value = "{LIB}: {AGE_00}") %>%
  add_legend(title = "Population under 3")



d3_cartogram(shape = paris) %>%
  add_select_input(label = "Choose a var:", choices = grep(pattern = "AGE", x = names(paris), value = TRUE)) %>%
  add_continuous_breaks(var = "AGE_03", palette = "Blues")







# App Paris ---------------------------------------------------------------


library(shiny)
library( r2d3maps )

ui <- fluidPage(
  fluidRow(
    column(
      width = 8, offset = 2,
      tags$h2("Cartogram in Shiny"),
      r2d3::d3Output(outputId = "my_cartogram"),
      selectInput(
        inputId = "var", label = "Variable:",
        choices = grep(pattern = "AGE", x = names(paris), value = TRUE)
      )
    )
  )
)

server <- function(input, output, session) {

  output$my_cartogram <- r2d3::renderD3({
    d3_cartogram(shape = paris) %>%
      add_continuous_breaks(var = "AGE_00", palette = "Blues") %>%
      add_legend(title = "")
  })

  observeEvent(input$var, {
    d3_cartogram_proxy(shinyId = "my_cartogram", data = paris) %>%
      update_continuous_breaks(var = input$var, palette = "Blues")
  }, ignoreInit = TRUE)

}

shinyApp(ui, server)







