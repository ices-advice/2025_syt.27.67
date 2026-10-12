### ------------------------------------------------------------------------ ###
### Apply rfb rule ####
### ------------------------------------------------------------------------ ###

## Before: data/syt.27.67_All_Survey_Indices_{assessment_year}.csv
##         data/syt_27_67_landings_length.csv
## After:  model/advice.rds

###--------------------------- Load packages -------------------------------------------
library ("tidyverse")
library("here")
library("glue")
library("icesVocab")
library("icesTAF")
library("cat3advice")

###--------------------------- Create folder -------------------------------------------
mkdir("model")

###--------------------------- set years -------------------------------------------
##DataYear: last year with data
DataYear <- 2024 

##assessment_year: year of the working group
assessment_year <- 2025 


###--------------------------- Biomass index trend (ratio) r --------------------------------
## Calculate biomass trend
r <- r(biomass_index)
r
## To replace 2020 by NA into the advice table since 2020 is not used for the assessment
#N.B. According to the WGEF decision, 2020 was ignored since indices values were missing in 2020 due to
#disruption of sampling plans.
r@n2_yrs[r@n2_yrs == 2020] <- NA


###--------------------------- Biomass safeguard b --------------------------------------------
## Use previous dataset with data of combined biomass index.
## Itrigger should only be defined once in the first year of the application of the rfb rule. (in 2023)
## In the following years, the same value should be used.
## Except when biomass index changes over time which is the case in 2025 because the whole-time series was recalculated because of errors detection.
b<-b(biomass_index, yr_ref= 2000) ##2000 is the year with the lowest value defined also during the first application of the rfb-rule (2023)


###--------------------------- Fishing pressure proxy F ----------------------------------------
## Catch length data are used to approximate the fishing pressure. 
## The mean length of fish in the catch compared to a reference length is used as the indicator.

###---------------------------
############## Length at first capture Lc  
## Only length data above the length at first capture Lc are used to avoid noisy data from fish that are not fully selected. Lc is defined as the first length class
## where the abundance is at or above 50% of the mode of the length distribution and can be calculated with the function Lc().
# Lc can change from year to year. Therefore, it is recommended to pool data from several (e.g. 5) years. 

#A lc of 60 cm was accepted in 2023 corresponding to a bin of 2cm ##NEED UPDATE
#Different scenarios were tested in 2025 by adding the 2023 and 2024 data // this didn't have an impact on Lc. See 4-syt.27.67_Length_Distribution_Formatted_Years_pooled.r
lc <-Lc(60)

###---------------------------
############## Mean length 
#After defining Lc , the mean (annual) catch length Lmean above Lc can be calculated.
lmean_syt<-Lmean(data = syt_27_67_length, Lc =lc, units ="cm", include_Lc=FALSE) #include_Lc=FALSE is a recommendation of WGEF
lmean_syt

###---------------------------
############## Reference length
## The reference length follows the concepts of Beverton and Holt (1957) and is calculated as derived by Jardim, Azevedo, and Brites (2015).
## This simple equation assumes that fishing at F=M can be used as a proxy for MSY and that M/k=1.5 (where M is the natural mortality and k the von Bertalanffy individual growth rate).
#The reference LF=M (MSY reference length) length should only be defined once in the first year of the application of the rfb rule.In the following years, the same value 
#should be used.

#In 2023, WGEF decided "No realistic estimate of L∞ from growth study. Lmax=121 cm taken from Heesen and al. (2015). 
#Lestimated as Lmax/0.95=127.3684"

#Once defined, lref should be kept constant and the same value used for all data years. 
lref <- Lref(76.84211) #Defined in 2023 as 0.75*Lc+0.25*L∞
lref

###---------------------------
############## Indicator ##############

##---------
##Fishing pressure
f <- f(Lmean = lmean_syt, Lref = lref, units = "cm")
f


###--------------------------- multiplier m -------------------------------------------
## The multiplier is a tuning parameter and ensures that the catch advice is precautionary in the long term.
## The value of m is set depending on the von Bertalanffy parameter k (individual growth rate)
## Here k= 0.95, so m= 0.95

#Keep multiplier from previous year
m <-m(0.95) ## Set in 0.95
m


###--------------------------- Application of the rfb rule -----------------------------
advice <-rfb(A = A, r = r, f = f, b = b, m = m)
advice@r@n2_yrs[advice@r@n2_yrs == 2020] <- NA
advice(advice)

### ------------------------------------------------------------------------ ###
### save output ####
### ------------------------------------------------------------------------ ###
saveRDS(advice, file = "model/advice.rds")