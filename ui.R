library(shiny)
library(leaflet)
source("download_and_datawrangling.R",local=FALSE)
# fisk_no <- read.csv("fisk_no.csv")
# location_arter <- read.csv("location_arter.csv")
# location <- read.csv("location.csv")

# Define UI for application 
shinyUI(navbarPage(title="Ferskvannsfisk i Trondheim",
                   
### First page                    
tabPanel("Lokaliteter",
    pageWithSidebar(
      
      # Application title
      headerPanel("Ferskvannsfisk i Trondheim"),
      
      # Sidebar with a slider input for number of observations
      sidebarPanel(
        includeMarkdown("text_TrondheimProvefiske_Lokaliteter.md"),
        img(src="ntnu-vm.png", width = 100)
        ),
      
      # Show map of locations 
      mainPanel(
        leafletOutput("locationmap"),
        p(),
        p("Kart viser lokaliteter for utført prøvefiske. Klikk på markøren for 
          å se navn på vatn.")
      )
    )), # End page

### second page: Resultat_provefiske                   
tabPanel("Resultat prøvefiske",
         pageWithSidebar(
           
           # Application title
           headerPanel("Fangst, lengde og vekt for ulike arter"),
           
           # Sidebar with a slider input for number of observations
           sidebarPanel(
             includeMarkdown("text_Resultat_provefiske.md"),
             selectInput("Resultat_provefiske_velgArt", 
                         label = "Velg art",
                         choices = unique(as.character(location_arter$art)),
                         selected = unique(as.character(location_arter$art))[1]),
             selectInput("Resultat_provefiske_velgVariabel", 
                         label = "Velg observasjonstype",
                         choices = c("Fangst per innssats"="CPUE",
                                     "Vekt per innsats"="WPUE",
                                     "Gjennomsnitt lengde"="gj_lengde_mm",
                                     "Gjennomsnitt vekt" = "gj_vekt_g",
                                     "Max lengde" = "max_lengde_mm",
                                     "Max vekt" = "max_vekt_g"),
                         selected = c("Fangst per innssats"="CPUE")
                         ),

             img(src="ntnu-vm.png", width = 100)
           ),
           
           
           # Show a plot of the generated distribution
           mainPanel(
             leafletOutput("resultat_provefiske_map"),
             p(),
             p("Kart viser observasjonsverdier per lokalitet for valgt art. 
               Merk at når art er observert på lokaliteten, men ønsket observasjonstype 
               ikke er tilgjengelig vises denne i grått (NA = No Attribute)")
           )
         )), # End page

### Third page                
tabPanel("Bestandstruktur",
  pageWithSidebar(
  
  # Application title
  headerPanel("Størrelsesfordeling fra prøvefiske Bymarka"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
    h3("Velg fiskeart og vatn"),
    p("Velg vilken lokalitet og art du vil se storrelsesfordeling for nedenfor.
      Du kan videre nedenfor selektere med hvilket intervall dataene vises."),


    selectInput("varII", 
                label = "Velg vatn",
                choices = unique(as.character(fisk_no$vatn)),
                selected = unique(as.character(fisk_no$vatn))[1]
                ),
    selectInput("var", 
                label = "Velg art",
                choices = unique(as.character(fisk_no$art)),
                selected = unique(as.character(fisk_no$art))[1]),
    sliderInput("n_bins", 
                "Intervall:", 
                value = 30,
                min = 5, 
                max = 50),
    
    img(src="bymarka.jpg", height = 250, width = 350)
   
  ), 
  
  # Show a plot of the generated distribution
  mainPanel(
    plotOutput("lengthHist", height=300),
    plotOutput("massHist", height=300)
  )
)), # End page

### forth page
tabPanel("Se data",
         fluidPage(
           titlePanel("Rådata - tabell"),

           # Create a new Row in the UI for selectInputs
           fluidRow(
             column(4,
                    selectInput("vatn",
                                "Vatn:",
                                c("alle",
                                  unique(as.character(fisk_no$vatn))))
             ),
             column(4,
                    selectInput("art",
                                "Art:",
                                c("alle",
                                  unique(as.character(fisk_no$art))))
             ),
             column(4,
                    selectInput("aar",
                                "År:",
                                c("alle",
                                  unique(as.character(fisk_no$aar))))
             )
           ),
           # Create a new row for the table.
           fluidRow(
             DT::dataTableOutput("table")
           )
         )
)

     )

) # end ShinyUI 








