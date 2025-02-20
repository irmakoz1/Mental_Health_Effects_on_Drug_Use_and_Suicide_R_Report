library(shiny)
library(leaflet)
library(sf)
library(dplyr)
library(scales)
library(spData)
library(tidyterra)


# UI for Shiny App
ui <- fluidPage(
  tags$style(HTML("
    .leaflet-control-legend .legend-title {
      font-size: 10px;
      font-weight: bold;
      white-space: normal;  /* Allows wrapping in the title */
    }
    .leaflet-control-legend .legend-label {
      font-size: 6px;  /* Adjust legend label font size */
      text-align: left;  /* Left-align legend labels */
    }
    .leaflet-control-legend {
      max-width: 300px; /* Adjust the max-width to fit longer legend titles and labels */
    }
  ")),
  titlePanel("Interactive Mental health and other factors in the world map"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("var", "Select a Variable:",
                  choices = c("Unemployment Rates"="unemployment",
                              "GDP"="gdpPercap",
                              "Life Expectancy"="lifeExp",
                              "Schizophrenia Rates"="SchizophreniaRates",
                              "Depression Rates"="Depressive_DisorderRates",
                              "Anxiety Rates"="Anxiety_DisorderRates",
                              "Bipolar Rates"="Bipolar_DisorderRates",
                              "Eating Disorder Rates"="Eating_DisorderRates",
                              "Suicide Rates"="suiciderates",
                              "Opioid Deaths" = "opioiddeathp",
                              "Cocaine Deaths" = "cocainedeath",
                              "Amphetamine Deaths" = "amphdeathp",
                              "Other Drug Deaths" = "otherdrugd",
                              "Total Drug Deaths"="drugtot"))
    ),
    mainPanel(
      leafletOutput("map", height = 800)
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  
  data<-read.csv("merged_data_last.csv")
  
  world<-world
  drops <- c("ID_Country_Year","X")
  data <- data[, !(names(data) %in% drops)]

  world$name_long[world$name_long=="Russian Federation"]<-"Russia"
  world$name_long[world$name_long=="Republic of Korea"]<-"South Korea"
  world$name_long[world$name_long=="Dem. Rep. Korea"]<-"North Korea"
  world$name_long[world$name_long=="Czech Republic"]<-"Czechia"
  world$name_long[world$name_long=="Democratic Republic of the Congo"]<-"Congo"
  

  wld_jn <- left_join(world,data, by = c("region_un"="Continent", "name_long" = 'Country.Name'))

  wld_jn<-wld_jn[!is.na(wld_jn$opioiddeathp),]
  

  ###Add year if there is country but no year:
  
  
  A<-which(wld_jn$name_long=="Greenland")
  B<-which(wld_jn$name_long=="Puerto Rico
")
  C<-which(wld_jn$name_long=="Palestine")
  t<-1999
  for (i in A) {
    wld_jn$Year[i]<-t+1
    t<-t+1
  } 
  
  for (i in B) {
    wld_jn$Year[i]<-t+1
    t<-t+1
  } 
  
  for (i in C) {
    wld_jn$Year[i]<-t+1
    t<-t+1
  } 
 
  # Summarize the data
  wld_jn <- wld_jn %>%
    mutate(drugtot = opioiddeathp + cocainedeath + amphdeathp + otherdrugd)

  # Define a function to create color palettes based on variable
  get_palette <- function(var) {
    colorNumeric(palette = "viridis", 
                 domain = wld_jn[[var]], 
                 na.color = "transparent")
  }
  
  # Render the map
  output$map <- renderLeaflet({
    req(input$var)  # Ensure the variable is selected before rendering map
    
    pal <- get_palette(input$var)  # Get the palette for the selected variable
    values <- wld_jn[[input$var]]  # Get the selected variable values
    legend_labels <- format(values, scientific = TRUE, digits = 10)
    
    leaflet(wld_jn) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~pal(get(input$var)),  # Use the selected variable for fill color
        weight = 1,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(weight = 3, color = "#666", fillOpacity = 0.9, bringToFront = TRUE),
        label = ~paste0(name_long, ": ", format(get(input$var), scientific = FALSE, trim = TRUE)),
        labelOptions = labelOptions(
          style = list("font-weight" = "bold"),
          textsize = "14px",
          direction = "auto"
        )
      ) %>%
      addLegend(pal = pal, values = values, 
                title = paste(input$var, "%"), 
                opacity = 1,
                labFormat = labelFormat(
                  suffix = "",
                  prefix = "",
                  between = " - "
                ),
                labels = legend_labels)    
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
