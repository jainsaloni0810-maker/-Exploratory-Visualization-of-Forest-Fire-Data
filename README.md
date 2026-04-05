🌲 Forest Fires Data Analysis in R
An exploratory data analysis (EDA) and regression study of the UCI Forest Fires dataset, which records wildfire incidents in the Montesinho Natural Park, Portugal.

📁 Dataset

517 fire incidents with 13 variables
Source: UCI Machine Learning Repository
Key variables:

X, Y — spatial grid coordinates of the fire (1–9)
month, day — when the fire occurred
FFMC, DMC, DC, ISI — Fire Weather Index (FWI) system components
temp, RH, wind, rain — meteorological conditions
area — burned area in hectares (target variable)




📊 Analysis Sections
SectionDescriptionData Loading & CleaningType casting, log-transform of skewed area variableTemporal PatternsFire frequency and severity by month and day of weekSpatial DistributionHeatmap of fire counts across the park gridDistributionsHistograms of all numeric variablesCorrelation AnalysisPearson correlation matrix across all variablesScatter PlotsBurned area vs. each weather and FWI predictorBoxplotsBurned area broken down by month and dayRegression ModellingLinear regression with diagnostic plotsSeasonal ComparisonPeak (Aug–Sep) vs. off-peak season t-test

🔍 Key Findings

August and September account for the highest number of fires and largest burned areas
247 out of 517 fires (47.8%) had zero recorded burned area
The area variable is heavily right-skewed — log(area + 1) transformation is applied throughout
Weather variables like temp and RH show moderate correlation with burned area
The linear regression model confirms limited predictability from weather/FWI variables alone
