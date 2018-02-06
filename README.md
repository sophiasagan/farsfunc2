[![Build Status](https://travis-ci.org/sophiasagan/farsfuncs.svg?branch=master)](https://travis-ci.org/sophiasagan/farsfuncs)

The functions provided by this package use data from the [US National Highway Traffic Safety Administration's](https://www.nhtsa.gov/) [Fatality Analysis Reporting System](https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars). This is a US nationwide census providing the American public yearly data regarding fatal injuries suffered in motor vehicle traffic crashes.


## Required set-up for this package

Currently, this package exists in a development version on GitHub. To use the package, you need to install it directly from GitHub using the `install_github` function from `devtools`. 

You can use the following code to install the development version of `farsfuncs`: 

```R
library(devtools)
install_github("sophiasagan/farsfunc2")
library(farsfuncs)
```
## Sample data included with package

Users may access some sample data by running the following codes.

```R
f13path<-system.file("extdata", "accident_2013.csv.bz2", package = "farsfuncs")
f14path<-system.file("extdata", "accident_2014.csv.bz2", package = "farsfuncs")
f15path<-system.file("extdata", "accident_2015.csv.bz2", package = "farsfuncs")
file.copy(from=c(f13path,f14path,f15path),to=getwd())
```
## farsfuncs

The user has access to two functions to help summarise and visualise the data. These are the `fars_summarize_years` and `fars_map_state` functions.

Use of these functions are shown below.

### fars_summarize_years

The `fars_summarize_years` function summarises by month and year the total number of accidents.

Enter years as a vector or integer years in YYYY format (eg 2013).

```R
library(dplyr)
library(readr)
library(tidyr)
fars_summarize_years(c(2013,2014,2015))
```
### fars_map_state

The `fars_map_state` function generates of map of the location of accidents within the specified US state during the specified year.

Enter the State number (eg 1) and the year to be analysed in YYYY format eg 2011.

```R
library(dplyr)
library(readr)
library(tidyr)
library(maps)
library(graphics)
fars_map_state(1,2014)
```
