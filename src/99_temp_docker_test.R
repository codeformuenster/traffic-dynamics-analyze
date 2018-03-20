# set working directory to proper directory
# setwd("path/to/here")

# temporary file to test docker deployment

library(envDocument)

# two times dirname() to go to project root
setwd(dirname(dirname(getScriptPath())))

# load libraries ####
# use 00_install_R_packages.R for installing missing packages
lapply(c("brms", "dplyr", "RSQLite", "lubridate"), require, character.only = TRUE)

noOfCores = parallel::detectCores()

# load data
# this assumes the script is called from the root directory of the repository
con <- dbConnect(SQLite(), dbname = "data/database/traffic_data.sqlite")
bikes <- dbGetQuery(conn = con, 
					 paste0("SELECT location, count, date, hour, weather, temperature, windspeed 
					 			 FROM bikes WHERE count != ''"))
dbDisconnect(con)

# filtering data ####
# filter data for valid observations
bikes_commuter_neutor <-
  bikes %>%
  # generate factors
  mutate(weather = as.factor(weather)) %>%
	mutate(year = year(date)) %>% 
  mutate(month = as.factor(month(date))) %>%
	mutate(weekday = as.factor(wday(date, label = TRUE))) %>% 
                          #levels = c("Mon", "Tues", "Wed", "Thurs", "Fri"))) %>%
  mutate(temperatureC = as.vector(scale(temperature, center = TRUE, scale = FALSE))) %>%
  mutate(windspeedC = as.vector(scale(windspeed, center = TRUE, scale = FALSE))) %>% 
	filter(location == 'Neutor',
         year == 2017,
         (hour == 7 | hour == 8),
				 (weekday != "Saturday" & weekday != "Sunday"))

write.csv(bikes_commuter_neutor,
          file = "results/bikesCommuterNeutor.csv",
          row.names = FALSE)

quit(save = "no")
