# This program is free software.
# You should have received a copy of the GNU General Public License
# along with this program (file COPYING). If not, see <http://www.gnu.org/licenses/>.

# set working directory to proper directory
# setwd("path/to/here")

# load libraries ####
# use 00_install_R_packages.R for installing missing packages
lapply(c("brms", "dplyr", "RSQLite", "lubridate"), require, character.only = TRUE)

noOfCores = parallel::detectCores()

# load data
# this assumes the script is called from the root directory of the repository
con <- dbConnect(SQLite(), dbname = "../data/database/traffic_data.sqlite")
# TODO path
bikes <- dbGetQuery(conn = con, 
					 "SELECT location, count, date, hour, weather, temperature, windspeed 
					 			 FROM bikes WHERE count != ''")

cars2 <- dbGetQuery(conn = con, 
					 "SELECT location, count, date, hour, weather
					 			 FROM cars WHERE count != ''")

dbDisconnect(con)

# filtering data ####
# filter data for valid observations
bikes_commuter_neutor <-
  bikes %>%
  # generate factors
  mutate(weather = as.factor(weather)) %>%
  mutate(rain = weather == "Regen") %>% 
	mutate(year = year(date)) %>% 
  mutate(month = as.factor(month(date))) %>%
	mutate(weekday = as.factor(wday(date, label = TRUE))) %>% 
  mutate(temperatureC = as.vector(scale(temperature, center = TRUE, scale = FALSE))) %>%
  mutate(windspeedC = as.vector(scale(windspeed, center = TRUE, scale = FALSE))) %>% 
	filter(!is.na(count),
	       location == 'Neutor',
         year == 2017,
         (hour == 7 | hour == 8),
				 (weekday != "Sa" & weekday != "So"))

bike_commuter_model_temperature = 
	brm(count ~ temperatureC,
			cores = noOfCores,
			family = mixture(negbinomial, negbinomial),
			data = bikes_commuter_neutor
	)

bike_commuter_model_temperature_wind = 
	brm(count ~ temperatureC * windspeedC,
			cores = noOfCores,
			family = mixture(negbinomial, negbinomial),
			data = bikes_commuter_neutor
	)

bike_commuter_model_temperature_wind_rain = 
	brm(count ~ temperatureC * windspeedC * rain,
			cores = noOfCores,
			family = mixture(negbinomial, negbinomial),
			data = bikes_commuter_neutor
	)

bike_commuter_model_temperature_wind_rain_weekday = 
	brm(count ~ temperatureC * windspeedC * rain * weekday,
			cores = noOfCores,
			family = mixture(negbinomial, negbinomial),
			data = bikes_commuter_neutor
	)

bike_commuter_model_temperature_wind_weather = 
	brm(count ~ temperatureC * windspeedC * weather,
			cores = noOfCores,
			family = mixture(negbinomial, negbinomial),
			data = bikes_commuter_neutor
	)

