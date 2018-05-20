
#  ------------------------------------------------------------------------
#
# Title : Shiny example
#    By : Victor
#  Date : 2018-05-20
#
#  ------------------------------------------------------------------------



# Packages ----------------------------------------------------------------

library( r2d3maps )
library( r2d3 )
library( rnaturalearth )
library( shiny )


# Data --------------------------------------------------------------------

france <- ne_states(country = "france", returnclass = "sf")
france <- france[france$type_en %in% "Metropolitan department", ]



# App ---------------------------------------------------------------------

if (interactive()) {
  ui <- fluidPage(

    fluidRow(
      column(
        offset = 2, width = 8,
        tags$h2("r2d3maps Shiny example"),
        fluidRow(
          column(
            width = 6,
            d3Output(outputId = "map")
          ),
          column(
            width = 6,
            verbatimTextOutput(outputId = "res_click")
          )
        )
      )
    )

  )

  server <- function(input, output, session) {

    output$map <- renderD3({
      r2d3map(shape = france) %>%
        add_tooltip() %>%
        add_click(
          inputId = "myclick",
          layerId = "name", # return only name,
          # NULL to get all data
          action = "dblclick" # on double click,
          # use "click" for simple click
        )
    })

    output$res_click <- renderPrint({
      str(input$myclick, max.level = 2)
    })
  }

  shinyApp(ui, server)
}
