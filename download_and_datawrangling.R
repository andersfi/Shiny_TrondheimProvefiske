library(dplyr)
library(knitr)
library(DT) #install.packages('DT')
library(tidyr)
library(curl)

#########################################################################################################
# access the files for the analyses stored as a Occurrence core DwC-A 
# on NTNU-VM's ITP instalation - using the curl library (https://cran.r-project.org/web/packages/curl/vignettes/intro.html)
#########################################################################################################

# download occurrences
tmp <- tempfile()
curl_download("http://gbif.vm.ntnu.no/ipt/archive.do?r=freshwater_survey_occurrences_trondheim_municipality&v=1.1", tmp)
#unzip(tmp, files = "NULL", list = T) view the files in the zip archive
unzip(tmp, files = c("occurrence.txt","measurementorfact.txt"), list = F)
occurrence <- read.table("occurrence.txt",sep="\t",header = T)
measurementorfact <- read.table("measurementorfact.txt",sep="\t",header = T)

mof_temp <- spread(data=measurementorfact,key=measurementType,value=measurementValue) %>% rename(occurrenceID=id)




# download events
tmp2 <- tempfile()
curl_download("http://gbif.vm.ntnu.no/ipt/archive.do?r=freshwater_survey_events_trondheim_municipality&v=1.0", tmp2)
#unzip(tmp2, files = "NULL", list = T) #view the files in the zip archive
unzip(tmp2, files = c("event.txt"), list = F)
event <- read.table("event.txt",sep="\t",header = T)


#########################################################################################################
#
# merge the event, occurrences and measurments and facts, and create location dataframe.
# Rename DwC-terms to Norwegian
#
####################################################################################################
fisk_temp <- left_join(occurrence[c("eventID","occurrenceID","year","month","day","taxonID","scientificName",
                                    "vernacularName","individualCount","organismQuantity","organismQuantityType",
                                    "recordNumber")],
                       event,by="eventID")
fisk_no <- left_join(fisk_temp,mof_temp) %>% select(waterBody=waterBody,aar=year,dato=eventDate,
                                                    latinskNamn=scientificName,art=vernacularName,
                                                    antall=individualCount,vekt_g=organismQuantity,lengde_mm=fork_length)
# preseed separator with a double backslash when a "metacharacter"...? http://biostat.mc.vanderbilt.edu/wiki/pub/Main/SvetlanaEdenRFiles/regExprTalk.pdf
fisk_no <- separate(data=fisk_no,col=waterBody,into=c("vatn","vatn_lnr"),sep="\\[") 
fisk_no <- select(fisk_no,-vatn_lnr)


location <- unique(fisk_temp[c("decimalLatitude","decimalLongitude","waterBody","locationID")])
location_arter <- unique(fisk_temp[c("decimalLatitude","decimalLongitude",
                                     "waterBody","locationID","vernacularName")])  %>% rename(art=vernacularName) 
