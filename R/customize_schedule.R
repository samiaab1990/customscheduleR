#' Customize cronR and taskscheduleR run dates
#'
#' \code{custom_schedule} returns an error if the current system date is not in the specifications defined in the vector and halts execution of the script.
#'
#' Wrapper for cronR or taskscheduleR that provides more flexibility and convenience in customizing run dates. Version 0.1.0 requires cronR or taskscheduleR to be installed and a job or task scheduled for daily at the desired time and daily frequency-minutely, hourly, or once daily with the custom_schedule function defined at the beginning of the automated script.
#'
#' @param start_date A string date value of Y-m-d format. Default is 01-01 of the year.
#' @param specific_dates A string date or vector of dates in Y-m-d format.
#' @param days_of_week A string name of day or vector of days in week. Valid arguments are "Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday".
#' @param biweekly Includes every other week dates if TRUE.
#' @param skip_weekends Skips Saturday and Sunday if TRUE.
#' @param dates_to_skip A string date or vector of dates in Y-m-d format to skip.
#' @param run_next_day Runs the following day after dates to skip if TRUE.
#' @param days_of_month An integer or vector of integers of specific days in month.
#' @param select_min Selects the first day of days_of_month for every month if TRUE.
#' @param select_last Selects the last day of the month the job should run based on other criteria.
#' @param get_dataset Returns dataset of dates in Global Environment if TRUE.
#' @return Returns a print statement of successful run if system date is among specified conditions, otherwise returns an error that halts task execution when running cronR or taskscheduleR. Returns a data frame of run dates if get_dataset is TRUE.
#' @importFrom lubridate year month
#' @importFrom dplyr %>% mutate bind_cols rename filter group_by ungroup slice add_row
#' @export

customize_schedule <- function(
  start_date = NULL,
  specific_dates = NULL,
  days_of_week = NULL,
  biweekly = FALSE,
  skip_weekends = FALSE,
  dates_to_skip = NULL,
  run_next_day = FALSE,
  days_of_month = NULL,
  select_min = FALSE,
  select_last = FALSE,
  get_dataset = FALSE
  ) {

  valid_days<-c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")
  valid_date_format<-"%Y-%m-%d"
  year<-lubridate::year(Sys.Date())

  if(!is.null(start_date)  && !is.na(as.Date(start_date,valid_date_format))){
    start_date = as.Date(start_date)

 } else if(!is.null(start_date) && is.na(as.Date(start_date,valid_date_format))){

    stop("start_date must be of %Y-%m-%d format")

  } else {

    start_date = as.Date(paste0(year,"-01-01"))
    message(paste0("start_date set to ", year,"-01-01"))
  }

  if((!is.null(days_of_week) && days_of_week %in% valid_days)){

      days_of_week = days_of_week

  }

  if(!is.null(days_of_week) && !(days_of_week %in% valid_days)){

    stop("days_of_week must supply valid string name")
  }


  if(!is.null(specific_dates) && !is.na(as.Date(specific_dates,valid_date_format))){

    specific_dates = as.Date(specific_dates)

}
  if(!is.null(specific_dates) && is.na(as.Date(specific_dates,valid_date_format))){

    stop("specific_dates must be of %Y-%m-%d format")
  }

  if(isTRUE(biweekly)){

    if(is.null(days_of_week)){

      stop("biweekly requires non-empty days_of_week argument")
    }
  }


  if(!is.null(dates_to_skip) && !is.na(as.Date(dates_to_skip,valid_date_format))){
    dates_to_skip = as.Date(dates_to_skip)
  }

  if(!is.null(dates_to_skip) && is.na(as.Date(dates_to_skip,valid_date_format))){
    stop("dates_to_skip must be of %Y-%m-%d format")
  }

  if(is.null(dates_to_skip) && isTRUE(run_next_day)){
    stop("run_next_day requires specifying dates_to_skip")
  }

  if(!is.null(days_of_month) && is.numeric(days_of_month) && days_of_month>=1 && days_of_month<=31){
    days_of_month = days_of_month
  }

if(!is.null(days_of_month) && (!is.numeric(days_of_month) | days_of_month<1 | days_of_month>31)){
    stop("days_of_month must be one or more integer value between 1-31")
  }

if(is.null(days_of_month) && isTRUE(select_min)){
   stop("select_min requires specifying days_of_month")
}


  end_date<-as.Date(paste0(year,"-12-31"))

  dates<-seq(start_date, end_date, "day")

  suppressMessages(dates<-dates %>% bind_cols(weekdays(dates)) %>%
          rename(date=`...1`, weekday=`...2`) %>%
          mutate(month=lubridate::month(date),
          day=lubridate::day(date)))

if(!is.null(specific_dates)){

  dates <- dates %>% filter(date %in% specific_dates)
}

  if(!is.null(dates_to_skip))

    {

    dates <- dates %>% filter(!(date %in% dates_to_skip))

    if(isTRUE(run_next_day))

      {

        if(!((dates_to_skip+1) %in% dates$date))

          {

        for(i in (dates_to_skip+1))
          {
          dates <- dates %>% add_row(
            date = i,
            weekday = weekday(i),
            month = lubridate::month(i),
            day = lubridate::day(i),
            complete = ifelse(i < Sys.Date(),"complete","")
          )
        }


      }
    }
  }

if(!is.null(days_of_week)){

  dates <- dates %>% filter(weekday %in% days_of_week)
}

if(skip_weekends){

  dates <- dates %>% filter(!(weekday %in% c("Saturday","Sunday")))
}


if(!is.null(days_of_month)){
  dates <- dates %>% filter(day %in% days_of_month)

  if(isTRUE(select_min)){
    dates <- dates %>% group_by(month) %>% filter(day==min(day)) %>% ungroup()
  }
}

if(isTRUE(select_last)){

  dates<-dates %>% group_by(month) %>% filter(day==max(day)) %>% ungroup()
}


if(isTRUE(biweekly)){

    if(length(days_of_week)>1){

    dates <-dates %>% group_by(weekday) %>% slice(seq(1,nrow(dates),2)) %>% ungroup()
    }else{
    dates <-dates %>% slice(seq(1,nrow(dates),2))
    }
  }

if(isTRUE(get_dataset)){
  dates<<-dates %>% mutate(complete = ifelse(Sys.Date()>=date, 'complete',""))
}

if (Sys.Date() %in% dates$date){

  print(paste0("Custom schedule successful run on ", Sys.Date()))

} else {
  stop("Date not in valid dates to run")
}

}




