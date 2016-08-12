
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
  
  # render location map
  # first create location map popup
  location$popup <- paste0("<strong>",location$waterBody,"</strong>",
                                 "<br><i>vatn_lnr: </i>",location$waterBodyID,
                                 "<br><i>Prøvefisket dato:</i>",location$dato)
  
  output$locationmap <- renderLeaflet({
    loc<-location
    leaflet(loc) %>% addTiles() %>% addMarkers(lng = ~decimalLongitude, lat = ~decimalLatitude, popup = loc$popup)
  })
  
  
  
  
  # render species map
  # first create species map popup
  location_arter$popup <- paste0("<strong>",location_arter$waterBody,"- ",location_arter$art,"</strong>",
                                 "<br><i>CPUE: </i>",location_arter$CPUE,
                                 "<br><i>WPUE: </i>",location_arter$WPUE,
                                 "<br><i>gj.lengde_mm:</i>",location_arter$gj_lengde_mm,
                                 "<br><i>gj.vekt_g:</i>",location_arter$gj_vekt_g,
                                 "<br><i>Max.vekt_g:</i>",location_arter$max_vekt_g,
                                 "<br><i>Max.lengde_mm:</i>",location_arter$max_lengde_mm
                                 )
  
  # Resultat_provefiske_map
  output$resultat_provefiske_map <- renderLeaflet({
    
    # select species 
    loc_arter <- location_arter[loc_arter$art==input$Resultat_provefiske_velgArt,]
   
     # select variable to display as colour palette on map
    if (input$Resultat_provefiske_velgVariabel=="CPUE") loc_arter$displayVar <- loc_arter$CPUE
    if (input$Resultat_provefiske_velgVariabel=="WPUE") loc_arter$displayVar <- loc_arter$WPUE
    if (input$Resultat_provefiske_velgVariabel=="gj_lengde_mm") loc_arter$displayVar <- loc_arter$gj_lengde_mm
    if (input$Resultat_provefiske_velgVariabel=="gj_vekt_g") loc_arter$displayVar <- loc_arter$gj_vekt_g
    if (input$Resultat_provefiske_velgVariabel=="max_lengde_mm") loc_arter$displayVar <- loc_arter$max_lengde_mm
    if (input$Resultat_provefiske_velgVariabel=="max_vekt_g") loc_arter$displayVar <- loc_arter$max_vekt_g

    # create colour palett 
    pal <- colorNumeric(
      palette = c("blue", "red"),
      domain = loc_arter$displayVar
    )
    
    leaflet(loc_arter) %>% 
      addTiles() %>% 
      addCircleMarkers(lng = ~decimalLongitude, lat = ~decimalLatitude, popup = loc_arter$popup, 
                       color = ~pal(displayVar),stroke = FALSE, fillOpacity = 0.9
                       ) %>%
      addLegend("bottomright", pal = pal, values = ~displayVar,title = input$Resultat_provefiske_velgVariabel,labFormat = labelFormat(prefix = ""),
                opacity = 1
      )
    
     })

})



