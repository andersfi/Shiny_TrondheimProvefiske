## Shiny app for DwC-A. 

Small experimental Shiny app for displaying gill-net test-fishing data from DwC Archive. At the moment the app reads data directly from the IPT since the GBIF API don't throw back measurement and fact table's, which are needed to document various attributes. Note also that the dataset are published as two different DwC-A, since the start shaped format of a DWC-A does not enable possibilities for displaying both measurements and facts related to events or occurrences at the same time. 

Download and wrangeling of the data are in an own file "download_and_datawrangling.R". 

The app can be viewed live at [Ferskvannsfisk i Trondheim](https://shiny.vm.ntnu.no/users/andersfi/TrondheimProvefiske/). It is made as an example for disseminating information to local stakeholders and the general public, as such, the text is unfortunately only in Norwegian. 
