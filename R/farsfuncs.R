#' Read fars data
#'
#' This is a simple function that reads a csv data file into R.
#'
#' @details If the file does not exist it will generate an error message.
#'
#' @param filename string
#'
#' @return This function returns a table data frame.
#'
#' @examples
#' library(dplyr)
#' library(readr)
#' library(tidyr)
#' f13path<-system.file("extdata", "accident_2013.csv.bz2", package = "farsfuncs")
#' file.copy(from=c(f13path),to=getwd())
#' fars_read("accident_2013.csv.bz2")
#'
#' @importFrom readr read_csv
#' @importFrom dplyr tbl_df
#'
#' @export
fars_read <- function(filename) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}

#' Generates a fars file name for a given year
#'
#' Simple function to generate a character string that is in the standard form for a fars data file.
#'
#' @param year integer
#'
#' @return String that represents a fars file name for a given year.
#'
#' @examples
#' make_filename(2017)
#'
#' @export
make_filename <- function(year) {
        year <- as.integer(year)
        sprintf("accident_%d.csv.bz2", year)
}

#' Generates a table of months and years from fars data files
#'
#' Function to generate a table of months available for a list of years.
#'
#' @details Will produce errors if data file for a particular year is not available.
#'
#' @inheritParams fars_summarize_years
#'
#' @return A list of Months and Years.
#'
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#' @importFrom dplyr %>%
#'
#' @examples
#' library(dplyr)
#' library(readr)
#' library(tidyr)
#' f13path <- system.file("extdata", "accident_2013.csv.bz2", package = "farsfuncs")
#' f14path <- system.file("extdata", "accident_2014.csv.bz2", package = "farsfuncs")
#' f15path <- system.file("extdata", "accident_2015.csv.bz2", package = "farsfuncs")
#' file.copy(from=c(f13path,f14path,f15path),to=getwd())
#' fars_read_years(c(2013,2014,2015))
#'
#' @export
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate(dat, year = year) %>%
                                dplyr::select(MONTH, year)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}

#' Generates a table showing number of accidents by month and year
#'
#' Function to generate a table showing numbers of accidents for a list of years from fars data.
#'
#' @param years integer
#'
#' @return A table showing total number of accident by month and year.
#'
#' @examples
#' library(dplyr)
#' library(readr)
#' library(tidyr)
#' f13path <- system.file("extdata", "accident_2013.csv.bz2", package = "farsfuncs")
#' f14path <- system.file("extdata", "accident_2014.csv.bz2", package = "farsfuncs")
#' f15path <- system.file("extdata", "accident_2015.csv.bz2", package = "farsfuncs")
#' file.copy(from=c(f13path,f14path,f15path),to=getwd())
#' fars_summarize_years(c(2013,2014,2015))
#'
#' @importFrom dplyr bind_rows
#' @importFrom dplyr group_by
#' @importFrom dplyr summarize
#' @importFrom dplyr %>%
#' @importFrom tidyr spread
#'
#' @export
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>%
                dplyr::group_by(year, MONTH) %>%
                dplyr::summarize(n = n()) %>%
                tidyr::spread(year, n)
}

#' Generates a map displaying accidents for a given state and year
#'
#' This is a function that generates a map (using the maps package) that displays the location of
#' accidents (using the graphics package) for a given state and year.
#'
#' @details Will generate error if an invalid state number is input.
#'
#' @param state.num integer
#' @param year integer
#'
#' @return This function returns a graphical object.
#'
#' @examples
#' library(dplyr)
#' library(readr)
#' library(tidyr)
#' library(maps)
#' library(graphics)
#' f14path <- system.file("extdata", "accident_2014.csv.bz2", package = "farsfuncs")
#' file.copy(from=c(f14path),to=getwd())
#' fars_map_state(1,2014)
#'
#' @importFrom dplyr filter
#' @importFrom maps map
#' @importFrom graphics points
#'
#' @export
fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter(data, STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
