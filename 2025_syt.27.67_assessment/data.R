### ------------------------------------------------------------------------ ###
## Preprocess data, write TAF data tables
### ------------------------------------------------------------------------ ###


## Before: bootstrap/data/syt.27.67_Landings_CATON_Year.csv
##         bootstrap/data/syt.27.67_All_Survey_Indices_{assessment_year}.csv
##         bootstrap/data/syt_27_67_landings_length.csv
## Alter: data/syt.27.67_Landings_CATON_Year.csv
##         data/syt.27.67_All_Survey_Indices_{assessment_year}.csv
##         data/syt_27_67_landings_length.csv


###--------------------------- Load packages -------------------------------------------
library("icesTAF")
library("tidyr")
library("dplyr")
library("glue")
library("cat3advice")


###--------------------------- Run bootstrap -------------------------------------------
icesTAF::taf.bootstrap()


###--------------------------- create folder to store data -----------------------------
### create folder to store data
mkdir("data")


###--------------------------- set years -------------------------------------------
##DataYear: last year with data
DataYear <- 2024 

##assessment_year: year of the working group
assessment_year <- 2025 


###--------------------------- Landings table -------------------------------------------
#Load table
syt_27_67_CATON_Year<-read.csv(file=glue("bootstrap/data/syt.27.67_Landings_CATON_Year.csv"),
                               header = TRUE, sep=",", dec = ",")

#Arrange data
syt_27_67_CATON_Year<- syt_27_67_CATON_Year%>%
                       filter(! (Year %in% c("2004","2005","2006","2007","2008")))


###--------------------------- Reference catch Ay -------------------------------------------
## Define manually the value from previous advice
A <- A(682, units="tonnes") #!!Take landings values from 2023 advice sheet because not so much differences between advice and real landings (694 t in 2024)
A


###--------------------------- Biomass index trend (ratio) r --------------------------------
## Load combined biomass index from CGFS et UK-BTS
biomass_index<-read.csv(file=glue("bootstrap/data/syt.27.67_All_Survey_Indices_{assessment_year}.csv"),
                        header = TRUE, sep=",", dec = ".")

#Arrange data
biomass_index<-biomass_index %>%
                select("Year", "Standard_Index") %>%
                rename("year"="Year", "index"="Standard_Index")

###--------------------------- Length data  ---------------------------------------------------
## The fishing pressure proxy requires length data from the catch. Ideally, length data for several years are 
## provided in a data.frame with columns year, length and numbers. An additional column catch_category specifying 
## the catch category, such as discards and landings, is optional.

## Length table from ICES is available. This table is reviewed during the data prep meeting
## To avoid to load all the data, partly confidential, the data are arranged to select only interesting data for syt.27.67 
## and are available in the table below.
syt_27_67_length<-read.csv(file=glue("bootstrap/data/syt_27_67_landings_length.csv"), 
              header = TRUE, sep=";", dec = ".")

## Set column format
str(syt_27_67_length)
syt_27_67_length$year <- as.numeric(syt_27_67_length$year)
syt_27_67_length$catch_category <-as.factor(syt_27_67_length$catch_category)
syt_27_67_length$length <-as.numeric(syt_27_67_length$length)
syt_27_67_length$numbers<-as.numeric(syt_27_67_length$numbers)

head(syt_27_67_length)

## In 2025, the landings length composition data from commercial fisheries available for 2024 
## were considered not representative of the main fishery since the length-composition of the French landings were incomplete. 
## Therefore, in 2025, the 2024 length data were not included in the application of the rfb rule, and Lmean was defined with the 2023 data. 
syt_27_67_length<- syt_27_67_length %>%
                  filter( year >= 2019  & year <=2023) #NEED UPDATE 

head(syt_27_67_length)