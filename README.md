# Predicting Spatial Mismatch
![spatial mismatch cover image](/spatial_mismatch_banner.png)
_Spatial mismatch research project for Data and Society (DAT 4500) Spring 2022_  
_Authors: Haylie Turner [@turnerh1](https://github.com/turnerh1), Jobi Lo [@jobilo](https://github.com/jobilo), and Katie Honsinger [@katiehons](https://github.com/katiehons)_

Our primary dataset about job accessibility was originally published by the Urban Institute, and can be found [here](https://datacatalog.urban.org/dataset/unequal-commute-data).
The Urban Institute also published a [study](https://www.urban.org/features/unequal-commute) about unequal commutes that uses this data. Their study was a source of inspiration for our project.

## Goals and Research Motivation
Our goal was to identify social factors that can predict spatial mismatch in Seattle. [Wikipedia](https://en.wikipedia.org/wiki/Spatial_mismatch#:~:text=Spatial%20mismatch%20is%20the%20mismatch,reside%20and%20suitable%20job%20opportunities) defines spatial mismatch as “the mismatch between where low-income households reside and suitable job opportunities.” Such factors included marital status, language spoken at home, number of household earners, work status, household size, racial identity, population density (of a census block group), and median household income.

## Data Overview
All the data we referenced for this project can be found in the [`/data`](/data) directory, along with a more complete description of individual datasets. Additionally, our [glossary](https://github.com/turnerh1/unequal-commute/wiki/Glossary) contains definitions relevant to the study.
The Urban Institute data focuses on job availability and accessibility in Seattle, Nashville, Baltimore, and Lansing. The unit of measurement
is a census [block group](https://www.census.gov/programs-surveys/geography/about/glossary.html#par_textimage_4). The statistics
we are working with measure things like the ratio of available jobs to available workers; the number of low-wage workers;
and how many jobs are accessible by public transportation, as well as racial and ethnic data.
The data was collected prior to the COVID-19 pandemic.  
We also used data from the American Community Survey (ACS) and other population density data from the year 2019.


## Data Collection and Analyzation

## Data Visualization and Modeling
We created [`bar_charts`](/bar_charts) on our variables of interest to compare differences between high and low spatial mismatch areas. We then used correlograms to assess [`correlations`](/correlations) between the variables and spatial mismatch. Finally, we created
logistical and linear regression [`models`](/models) in an attempt to predict spatial mismatch in Seattle block groups.
## Project Outcomes and Impact
From our bar charts, we discovered that low spatial mismatch areas had a higher proportion of residents that were educated above an associate's degree, and higher spatial mismatch areas had a higher proportion of those that were not educated similarly. We also found that areas with high spatial mismatch had a higher proportion of residents who spoke spanish in their home. Further, we found that high spatial mismatch areas had a higher proportion of households size 3 or larger. Finally, we found that lower spatial mismatch areas have a higher proportion of single residents.

In analyzing correlograms, we decided to drop the variables marital status and hours worked from our predictor models as they did not correlate with spatial mismatch. Further, we discovered from our correlograms that the best standalone predictor of spatial mismatch was level of education.

INSERT CONCLUSIONS ABOUT MODELING
