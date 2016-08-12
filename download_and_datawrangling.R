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
fisk_temp <- left_join(fisk_temp,mof_temp[c("occurrenceID","fork_length")],by="occurrenceID")
# data coded with waterbody name and watebodyID in same column, waterBody... fix
# -- when using "separate" - preseed separator with a double backslash when a "metacharacter"...? 
# http://biostat.mc.vanderbilt.edu/wiki/pub/Main/SvetlanaEdenRFiles/regExprTalk.pdf
fisk_temp <- separate(data=fisk_temp,col=waterBody,into=c("waterBody","tempvar1"),sep="\\[",remove=T)
fisk_temp <- separate(data=fisk_temp,col=locationID,into=c("tempvar2","waterBodyID"),sep=":")


# translate variable names to be displayed in output tabel to Norwegian
fisk_no <- select(fisk_temp,vatn=waterBody,vatn_lnr=waterBodyID,aar=year,dato=eventDate,
                                                    latinskNamn=scientificName,art=vernacularName,
                                                    antall=individualCount,vekt_g=organismQuantity,
                                                    lengde_mm=fork_length)


# create table by locaiton, also include string with dates of testfishing 
location <- fisk_temp %>% group_by(waterBodyID,waterBody,decimalLatitude,decimalLongitude) %>% 
                      summarise(dato=paste(unique(eventDate),collapse=","))

# create table by location and species, also include dates, CPUE, max mass and length, mean mass and length
location_arter <- fisk_temp %>% group_by(waterBodyID,waterBody,decimalLatitude,decimalLongitude,vernacularName) %>% 
                          summarise(dato=paste(unique(eventDate),collapse=","),antall_fisk=sum(individualCount,na.rm=T),
                                    antall_fisk=sum(individualCount),innsats=mean(sampleSizeValue),
                                    gj_lengde_mm=round(mean(fork_length,na.rm=T),0),
                                    gj_vekt_g=round(mean(organismQuantity,na.rm=T)),
                                    sum_vekt_g=round(sum(organismQuantity)), # note: sum_vekt_g used to calculate WPUE below, want to return NA if NA exist in vector
                                    max_lengde_mm=round(max(fork_length,na.rm=T),0),
                                    max_vekt_g=round(max(organismQuantity,na.rm=T),0)
                                    ) %>% 
                          rename(art=vernacularName) 
# note sum returns 0 if only 
location_arter <- mutate(location_arter,CPUE=round(((antall_fisk/innsats)*100),1),
                         WPUE=round(((sum_vekt_g/innsats)*100),1))




