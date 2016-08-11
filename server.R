
library(shiny)
library(dplyr)
library(knitr)
library(DT) #install.packages('DT')
library(leaflet)
library(tidyr)
library(curl)

shinyServer(function(input, output) {
  
  output$lengthHist <- renderPlot({
    # Expression that generates a histogram. The expression is
    # wraped in a call to renderPlot to indicate that:
    #  1) It is "reactive" and therefore should be automatically
    #     re-executed when inputs change
    #  2) Its output type is a plot
    x    <- fisk_no$lengde_mm[fisk_no$art==input$var & fisk_no$vatn==input$varII]  # lengdefordeling
    bins <- seq(min(x,na.rm=T),max(x,na.rm=T), length.out = input$n_bins)

    # draw the histogram with the specified number of bins
    hist(x, col = 'darkgray', border = 'white',xlab="Lengde (mm)",
         main="Lengdefordeling i provefiske",ylab="Antall",breaks=bins)
  })
  
  # Reactive histogram of mass
  output$massHist <- renderPlot({
    x    <- fisk_no$vekt_g[fisk_no$art==input$var & fisk_no$vatn==input$varII] 
    bins <- seq(min(x,na.rm=T),max(x,na.rm=T), length.out = input$n_bins)
    
    hist(x, col = 'darkgray', border = 'white',xlab="Vekt (g)",
         main="Vektfordeling i provefiske",ylab="Antall",breaks=bins)
  })
  
  output$table <- DT::renderDataTable(DT::datatable(
    {
    data <- fisk_no
    if (input$vatn != "alle") {
      data <- data[data$vatn == input$vatn,]
    }
    if (input$art != "alle") {
      data <- data[data$art == input$art,]
    }
    if (input$aar != "alle") {
      data <- data[data$aar == input$aar,]
    }
    data
  }
  ,rownames= FALSE))
  
  
  output$mymap <- renderLeaflet({
    loc<-location
    leaflet(loc) %>% addTiles() %>% addMarkers(lng = ~decimalLongitude, lat = ~decimalLatitude, popup = location$waterBody)
  })

  output$mymapII <- renderLeaflet({
    loc_arter <- location_arter
    leaflet(loc_arter[loc_arter$art==input$varIII,]) %>% addTiles() %>% addMarkers(lng = ~decimalLongitude, lat = ~decimalLatitude, popup = location$waterBody)
     })

})