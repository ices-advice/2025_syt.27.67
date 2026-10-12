### ------------------------------------------------------------------------ ###
### Create xlm file for Standard graph for advice sheet
### ------------------------------------------------------------------------ ###

## Before: data/syt.27.67_Landings_CATON_Year.csv
##         data/syt.27.67_All_Survey_Indices_{assessment_year}.csv
##         output/syt.27.67_df_inverse_f.rds
## After: report_sag/sag_syt.27.67.xml


###--------------------------- Load packages -------------------------------------------
library ("tidyverse")
library("icesSAG")
library("icesVocab")
library("here")
library("glue")
library("xml2")

###--------------------------- Create folder -------------------------------------------
mkdir("report_sag")

###--------------------------- set years -------------------------------------------
## Assessment_year: year of the working group
assessment_year<-2025  

###--------------------------- Set up stock info -------------------------------------------
## Create info and fishdata to be used for SAG upload using personal token
# https://datsu.ices.dk/web/selRep.aspx?Dataset=126 
info <- icesSAG::stockInfo(StockCode = "syt.27.67",
                           AssessmentYear = assessment_year,
                           ContactPerson = "noemie.deleys@ifremer.fr",
                           StockCategory = "3.9",
                           ModelType = "None",
                           ModelName = "None",
                           Purpose = "Advice",
                           CatchesLandingsUnits = "t",
                           StockSizeUnits = "t",
                           FishingPressureUnits = "ratio",
                           CustomLimitName1 = "I_{trigger}",
                           CustomLimitValue1 = 0.5412165,
                           CustomLimitName2 = "F_{MSYproxy}",
                           CustomLimitValue2 = 1,                          
                           ConfidenceIntervalDefinition = "95%")

##---------------------------- Load Landings data-------------------------------------------
syt_27_67_CATON_Year<-read.csv(file=glue("bootstrap/data/syt.27.67_Landings_CATON_Year.csv"),
                               header = TRUE, sep=",", dec = ",")

##---------------------------- Load stockSize data------------------------------------------
biomass_index<-read.csv(file=glue("bootstrap/data/syt.27.67_All_Survey_Indices_{assessment_year}.csv"),
                        header = TRUE, sep=",", dec = ".")

##---------------------------- Load Fishing pressure proxy (inverse f)----------------------
df_inverse_f <- readRDS(file=glue("output/syt.27.67_df_inverse_f.rds"))

##---------------------------- Prepare a df with all data ----------------------------------
#Create an empty df with same year than in biomass_index 
#fill all df with NA for years without data in order to realize fish data
empty_df <- biomass_index %>%
            select(Year)
df_syt_27_67_CATON_Year_sag <- left_join(empty_df, syt_27_67_CATON_Year)
df_inverse_f_sag <- left_join(empty_df, df_inverse_f)


##------------------------------- Set up fish data ------------------------------------------
fishdata <- stockFishdata(Year = biomass_index$Year,
                          Landings = df_syt_27_67_CATON_Year_sag$total_WEF_CATON,
                          StockSize = biomass_index$Standard_Index,
                          FishingPressure = df_inverse_f_sag$inverse_f)
print(fishdata)

##---------------------------------- Create xlm file ------------------------------------------
##create xlm file
xml <- createSAGxml(info, fishdata)
xml_convert <- read_xml(xml)
write_xml(xml_convert, file = glue("report_sag/sag_syt.27.67.xml"))