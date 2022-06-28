# customscheduleR

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/customscheduleR)](https://CRAN.R-project.org/package=customscheduleR)
![GitHub all releases](https://img.shields.io/github/downloads/samiaab1990/customscheduleR/total)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
![GitHub tag(latest by date)](https://img.shields.io/github/v/tag/samiaab1990/customscheduleR)

<!-- badges: end -->

customscheduleR provides greater flexibility to customize run dates when using cronR or taskscheduleR through the `customize_schedule()` wrapper function. While standard job scheduling packages allow for running on specific days of the week or days of the month, creating more specific schedules is not feasible. The customscheduleR package allows:

1. Running jobs on specific dates only 

2. Skipping runs on specific dates (such as holidays) and providing the option to run the next day

3. Running jobs biweekly

4. Running jobs on specific days of the month and providing the option to select the first out of the specific days, accounting for the option to not run on weekends or holidays  

5. Running jobs on the last day of the month accounting for the option to not run on weekends or holidays 

6. Getting a data frame of dates in the year the script will run.

The current version requires separate installation of cronR or taskscheduleR and a daily job at the desired time and daily frequency (minute, hourly or daily). The customscheduleR package then provides the option defining criteria for the specific days in the current year the script should/should not run. The start date refreshes to January 1st at the beginning of every year. 

## Installation

You can install the development version of customscheduleR from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("samiaab1990/customscheduleR")
```

The `customize_schedule()` function should be placed at the beginning of the script. 

## Example


``` r
library(customscheduleR)

```

```
# At the beginning of the desired script

customize_schedule(

# A specific start date if desired in YYYY-mm-dd format. If none is specified, default to January 1st of the year

start_date = "2022-01-01",

# Allows filtering specific date(s) the script should run in YYYY-mm-dd format

specific dates = c("2022-02-01", "2022-02-02"),

# Allows specifying specific days of the week the script should run 

days_of_week = c("Monday","Tuesday"),

# Runs every other week if true 

biweekly = TRUE,

# Skips Saturday and Sunday if TRUE. A simplified argument alternative to specifying Monday-Friday in days_of_week

skip_weekends = TRUE,

# Allows the option to skip specific dates (ie: holiday dates)

dates_to_skip = "2022-07-04",

# If date or date vector is provided in dates_to_skip, asks if the script should be run the next day. Note this accounts for if options are set to run on specific days of the week or skip weekdays.

run_next_day = TRUE,

# Integer between 1-31 specifying the day or days of month the script should run

days_of_month= c(1:7),

# If days are provided in days_of_month, selects the first (minimum day) out of the days_of_month 
select_min = TRUE,


# Selects the last day of the month accounting for other criteria (weekends, holidays, specific days of week, etc.)

select_last = TRUE,

# Returns a data frame with specific run dates when the function is run for the year


get_dataset = TRUE

)

```
If the current date is not in the customized schedule, then the function returns an error and halts the job from running. Otherwise, it returns a statement of successful job run.
