


# Packages ----------------------------------------------------------------

library(shiny)
library( r2d3maps )
library( r2d3 )
library( rnaturalearth )
library( magrittr )
library( dplyr )


# data --------------------------------------------------------------------

# shapes
africa <- ne_countries(continent = "Africa", returnclass = "sf")


# drinking water data
data("water_africa")
glimpse(water_africa)


# add data to shapes

africa <- left_join(
  x = africa %>% select(adm0_a3_is, name, geometry),
  y = water_africa %>% filter(year == 2015),
  by = c("adm0_a3_is" = "iso3")
)
africa$national_at_least_basic <- round(africa$national_at_least_basic)
africa$national_limited_more_than_30_mins <- round(africa$national_limited_more_than_30_mins)
africa$national_unimproved <- round(africa$national_unimproved)
africa$national_surface_water <- round(africa$national_surface_water)



# app ---------------------------------------------------------------------

ui <- fluidPage(
  fluidRow(
    column(
      width = 10, offset = 1,
      tags$h2("Example proxy"),
      d3Output(outputId = "mymap", width = "600px", height = "500px"),
      radioButtons(
        inputId = "var",
        label = "Indicator:",
        choices = list(
          "Basic" = "national_at_least_basic",
          "Limited" = "national_limited_more_than_30_mins",
          "Unimproved" = "national_unimproved",
          "Surface water" = "national_surface_water"
        ),
        inline = TRUE
      ),
      radioButtons(
        inputId = "palette",
        label = "Change color palette",
        choices = c("viridis", "magma", "plasma", "Blues", "Greens", "Reds"),
        inline = TRUE
      )
    )
  )
)

server <- function(input, output, session) {

  output$mymap <- renderD3({
    d3_map(shape = africa) %>%
      add_continuous_breaks(var = "national_at_least_basic") %>%
      # add_continuous_gradient(var = "national_at_least_basic") %>%
      add_tooltip(value = "<b>{name}</b>: {national_at_least_basic}%") %>%
      add_legend(title = "Population with at least basic access", suffix = "%") %>%
      add_labs(title = "Drinking water in Africa", caption = "Data: https://washdata.org/")
  })

  title_legend <- list(
    "national_at_least_basic" = "basic access",
    "national_limited_more_than_30_mins" = "limited access",
    "national_unimproved" = "unimproved water",
    "national_surface_water" = "surface water"
  )

  observeEvent(list(input$var, input$palette), {
    d3_map_proxy(shinyId = "mymap", data = africa) %>%
      update_continuous_breaks(var = input$var, palette = input$palette) %>%
      # update_continuous_gradient(var = input$var) %>%
      update_legend(title = sprintf(
        "Population with %s", title_legend[[input$var]]
      ), suffix = "%")
  }, ignoreInit = TRUE)

}

shinyApp(ui, server)




