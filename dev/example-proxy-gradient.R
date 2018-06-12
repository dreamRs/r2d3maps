


# Packages ----------------------------------------------------------------

library(shiny)
library(shinyWidgets)
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

# d3_map(shape = africa) %>%
#   add_continuous_gradient(var = "national_at_least_basic", range = "auto") %>%
#   add_legend(title = "Population with at least basic access", suffix = "%")





# app ---------------------------------------------------------------------


get_brewer_name <- function(name) {
  pals <- RColorBrewer::brewer.pal.info[rownames(RColorBrewer::brewer.pal.info) %in% name, ]
  res <- lapply(
    X = seq_len(nrow(pals)),
    FUN = function(i) {
      RColorBrewer::brewer.pal(n = pals$maxcolors[i], name = rownames(pals)[i])
    }
  )
  unlist(res)
}
colors_choices <- get_brewer_name(c("Blues", "Greens", "Reds", "Oranges", "Purples"))


ui <- fluidPage(
  tags$h2("Example proxy with gradient scale"),
  fluidRow(
    column(
      width = 4,
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
      pickerInput(
        inputId = "col_lowest", label = "Lowest color",
        choices = colors_choices, selected = "#9ECAE1",
        options = list(`size` = 9, `show-tick` = TRUE),
        choicesOpt = list(
          style = "margin-left:-10px;",
          content = sprintf(
            "<div style='width:100%%;padding:5px;border-radius:4px;background:%s;color:%s'>%s</div>",
            colors_choices,
            ifelse(seq_along(colors_choices) %% 9 %in% c(6, 7, 8, 0), "white", "black"),
            colors_choices
          )
        )
      ),
      pickerInput(
        inputId = "col_highest", label = "Highest color",
        choices = colors_choices, selected = "#08306B",
        options = list(`size` = 9, `show-tick` = TRUE),
        choicesOpt = list(
          style = "margin-left:-10px;",
          content = sprintf(
            "<div style='width:100%%;padding:5px;border-radius:4px;background:%s;color:%s'>%s</div>",
            colors_choices,
            ifelse(seq_along(colors_choices) %% 9 %in% c(6, 7, 8, 0), "white", "black"),
            colors_choices
          )
        )
      )
    ),
    column(
      width = 7,
      d3Output(outputId = "mymap", width = "600px", height = "500px")
    )
  )
)

server <- function(input, output, session) {

  output$mymap <- renderD3({
    d3_map(shape = africa) %>%
      add_continuous_gradient(var = "national_at_least_basic", range = "auto") %>%
      add_legend(title = "Population with at least basic access", suffix = "%")
  })

  observeEvent(list(input$var, input$col_lowest, input$col_highest), {
    d3_map_proxy(shinyId = "mymap", data = africa) %>%
      update_continuous_gradient(var = input$var, low = input$col_lowest, high = input$col_highest, range = "auto")
  }, ignoreInit = TRUE)

}

shinyApp(ui, server)




