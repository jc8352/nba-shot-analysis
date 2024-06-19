#deployed at https://jc8352.shinyapps.io/nba_shot_analysis/
library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(tidyr)

source("nba_shots.R")
shots_22_23 <- read.csv("data/shotdetail_2022.csv")
player_vs_league <- vs_average(shots_22_23)

ui <- fluidPage(
  theme = bs_theme(version = 4, bootswatch = "flatly"),
  tags$head(
    tags$style(HTML("
      .small-select-input .selectize-control.single .selectize-input {
        height: 20px;
        padding-top: 2px;
        padding-bottom: 2px;
        font-size: 10px;
      }
      .small-select-input .selectize-dropdown {
        font-size: 10px;
      }
      .small-select-input .control-label {
        font-size: 10px;
      }
      .small-select-input {
        margin-top: 200px;
      }
    "))
  ),
    mainPanel(
      width = 12,
      fluidRow(
        column(
          width = 10,
          h5("Player vs League Averages"),
          plotOutput("selectedPlayer", height = "400px")
        ),
        column(
          width=2,
          class = "small-select-input",
          selectInput(
            "playerSelect",
            label = "Select a player",
            choices = unique(shots_22_23$PLAYER_NAME),
            selected = unique(shots_22_23$PLAYER_NAME)[1]
          )
        )
      ),
      hr(),
      fluidRow(
        column(
          width = 5,
          h5("Player Shot Distance Frequencies"),
          plotOutput("selectedPlayerPie", height = "400px")
        ),
        column(
          width = 7,
          h5("Player vs League Frequencies"),
          plotOutput("selectedPlayerFreq", height = "400px")
        )
      )
    )

)


server <- function(input, output) {
  #z-scores
  output$selectedPlayer <- renderPlot({
    plot_player_vs_avg(player_vs_league, input$playerSelect)
    
  })
  
  #shot distribution
  output$selectedPlayerPie <- renderPlot({
    plot_player_distance_frequencies(shots_22_23, input$playerSelect)
    
  })
  
  #shot distribution vs league average
  output$selectedPlayerFreq <- renderPlot({
    plot_player_vs_league_frequencies(shots_22_23, input$playerSelect)
    
  })
  
  
}

shinyApp(ui = ui, server = server)