#PREPROCESSING SCRIPT:
rm(list = ls())

# Load all the necessary packages
library(countrycode)
library(dplyr)
library(ggplot2)
library(magrittr)
library(readr)
library(rmarkdown)
library(tidyr)
library(tidyverse)
library(tinytex)
library(knitr)
library(shiny)
library(leaflet)
library(sf)
library(dplyr)
library(scales)
library("GGally")
library(contrast)
library(effects)
library(MCMCglmm)
library(languageR) 
library(lmerTest)
library(coefplot)
library(stats)
library(curl)
library(data.table)
library(car)
library(phia)
library(MuMIn)
library(spData)
library(gt)
library(countrycode)

#Table 1, Suiciderates

#Read the Data: 
setwd("C:\\Users\\irmak\\Desktop\\datascience\\Rbootcamp")
suicide <- read.csv("sucide-processed.csv") 



#Remove Missing Values (NAs):
suicide <- na.omit(suicide) 


#Filter Specific Years (2000 til 2019):
suicide <- suicide %>% 
  filter(!Year %in% c(2021)) 


colnames(suicide)
#Rename Column for Simplicity:
suicide <- suicide %>%
  rename(
    suiciderates = "Age.standardized.death.rate.from.self.harm.among.both.sexes","Country.Name"="Entity"
  )




#Save the Modified Table as an Output File:
write.csv(suicide, "suicide_processed.csv",row.names = FALSE)



#Table 2, Unemployment-rates:**

#Read the Data:
unemployment <- read.csv("unemployment-processd.csv") 


#Remove Missing Values (NAs):
unemployment <- na.omit(unemployment) 


#Filter Specific Years (2000 til 2019):
unemployment <- unemployment %>% 
  filter(!Year %in% c(1991,1992,1993,1994,1995,1996,1997,1998,1999,2020,2021,2022)) 

colnames(unemployment)
#Rename columns:
unemployment <- unemployment %>%
  rename(
    "unemployment"="Unemployment..total....of.total.labor.force...modeled.ILO.estimate.","Country.Name"="Entity"
  )




#Save the Modified Table as an Output File:
write.csv(unemployment, "unemployment_processed.csv",row.names = FALSE)


#Table 3, Mental Health Rates:**

#Read the Data:
MH<-read.csv("C:/Users/Barbara Maier/Desktop/1- mental-illnesses-prevalence.csv")



#Rename Columns for Simplicity:
MH<-MH %>%
  rename("SchizophreniaRates"="Schizophrenia.disorders..share.of.population....Sex..Both...Age..Age.standardized","Depressive_DisorderRates"="Depressive.disorders..share.of.population....Sex..Both...Age..Age.standardized","Anxiety_DisorderRates"="Anxiety.disorders..share.of.population....Sex..Both...Age..Age.standardized","Bipolar_DisorderRates"="Bipolar.disorders..share.of.population....Sex..Both...Age..Age.standardized","Eating_DisorderRates"="Eating.disorders..share.of.population....Sex..Both...Age..Age.standardized","Country.Name"="Entity")




#Clean NA Values and Keep Relevant Years:
if (sum(is.na(MH)) > 0) {
  MH <- MH %>% drop_na()
  print("Cleaned the dataset of NA values")
} else {
  print("No NA values found.")
}
keptY=c(2000:2019)
mh_new <- MH %>% filter(Year %in% keptY)
mh_new<-droplevels(mh_new)
#Save the file
write.csv(mh_new, "MH_new.csv")




#Table 4, Drug-Death-Rates:**

#Read the Data:
drugdeaths <- read.csv("drugdeaths.csv")


#Preparing percentages by dividing drug overdose rates to country population by country.

#Read R data countrypops from "gt" package:
countrypops<-countrypops
#Year into numeric:
countrypops$Year<-as.integer(countrypops$year)
drugdeaths$Year<-as.integer(drugdeaths$year)

#Prepare Country, Year column for merging
countrypops<- countrypops %>%
  rename("Country.Name"="country_name")
drugdeaths<- drugdeaths %>%
  rename("Country.Name"="Country")
write.csv(drugdeaths,"drugdeats_processed1.csv")
#Merge drug deaths with country population:
drugdeaths<-left_join(
  drugdeaths,
  countrypops,
  by = c("Year","Country.Name"))


#Calculate Percentages:
drugdeaths<-drugdeaths%>%
  mutate(opioiddeathp=Deaths...Opioid.use.disorders...Sex..Both...Age..All.Ages..Number./population)%>%
  mutate(cocainedeath=Deaths...Cocaine.use.disorders...Sex..Both...Age..All.Ages..Number./population)%>%
  mutate(otherdrugd=Deaths...Other.drug.use.disorders...Sex..Both...Age..All.Ages..Number./population)%>%
  mutate(amphdeathp=Deaths...Amphetamine.use.disorders...Sex..Both...Age..All.Ages..Number./population)



dropspop <- c("Deaths...Amphetamine.use.disorders...Sex..Both...Age..All.Ages..Number.","Deaths...Other.drug.use.disorders...Sex..Both...Age..All.Ages..Number.","Deaths...Cocaine.use.disorders...Sex..Both...Age..All.Ages..Number.","Deaths...Opioid.use.disorders...Sex..Both...Age..All.Ages..Number.","country_code_2","country_code_3")
drops1y<-c("X.1","X")
drugdeaths<-drugdeaths[ , !(names(drugdeaths) %in% drops1y)]

#Only keep columns we want:
drugdeaths<-drugdeaths[ , !(names(drugdeaths) %in% dropspop)]


#Merging and refining all 4 tables


# Make sure Year is numeric:
suicide$Year<-as.integer(suicide$Year)
unemployment$Year<-as.integer(unemployment$Year)
drugdeaths$Year<-as.integer(drugdeaths$Year)
MH_new$Year<-as.integer(MH_new$Year)

#Merge the 4 tables:

new_table <- MH_new %>%  
  full_join(suicide, by = c("Country.Name","Year")) %>%  
  full_join(unemployment, by = c("Country.Name","Year")) %>%  
  full_join(drugdeaths, by = c("Country.Name","Year")) 

#Drop unnecessary column Code:
drops<- c("Code")
new_table <- new_table[, !(names(new_table) %in% drops)]




#Create a new Column "Continent" using package "countrycode":
new_table$Continent <- countrycode(new_table$Country.Name, 
                                   origin = "country.name", 
                                   destination = "continent")




#Remove Missing Values (NAs and 0 values):

if (sum(is.na(new_table)) > 0) {
  new_table <- new_table %>% drop_na()
  print("Cleaned the dataset of NA values")
} else {
  print("No NA values found.")
}


#Save the Modified Table as an Output File:
write.csv(new_table, "C:/Users/Barbara Maier/Desktop/merged_data_last.csv", row.names = FALSE)


