# This program is free software.
# You should have received a copy of the GNU General Public License
# along with this program (file COPYING). If not, see <http://www.gnu.org/licenses/>.

# set working directory to proper directory
# setwd("path/to/here")

# load libraries ####
# use 00_install_R_packages.R for installing missing packages
lapply(c("brms", "dplyr", "RSQLite", "lubridate"), require, character.only = TRUE)

options(mc.cores = parallel::detectCores())

# load data
# this assumes the script is called from the root directory of the repository
con <- dbConnect(SQLite(), dbname = "data/database/traffic_data.sqlite")

bikes <- dbGetQuery(conn = con, 
					 "SELECT location, count, date, hour, weather, temperature, windspeed 
					 			 FROM bikes WHERE count != ''")

cars <- dbGetQuery(conn = con, 
					 "SELECT location, count, date, hour, weather, temperature, windspeed
					 			 FROM cars WHERE count != '' AND location like '%01080%'")

dbDisconnect(con)

# filter data for valid observations
bikes_neutor <-
  bikes %>%
  # generate factors
  mutate(rain = weather == "Regen") %>% 
  mutate(weather = as.factor(weather)) %>%
	mutate(year = year(date)) %>% 
  mutate(month = as.factor(month(date))) %>%
	mutate(weekday = as.factor(wday(date, label = TRUE))) %>% 
  mutate(temperatureC = as.vector(scale(temperature, center = TRUE, scale = FALSE))) %>%
  mutate(windspeedC = as.vector(scale(windspeed, center = TRUE, scale = FALSE))) %>% 
	filter(!is.na(count),
	       !is.na(temperature),
	       !is.na(weather),
	       !is.na(windspeed),
	       location == 'Neutor',
         year == 2017,
         (hour == 7 | hour == 8),
				 (weekday != "Sat" & weekday != "Sun"))

if(nrow(bikes_neutor) != 513) {
  error <- "wrong amount of data"
  write.csv(error, file = "results/error.txt")
  stop("wrong amount of data")
  quit(save = "no")
}

cars_neutor <-
  cars %>%
  # generate factors
  mutate(rain = weather == "Regen") %>% 
  mutate(weather = as.factor(weather)) %>%
  mutate(year = year(date)) %>% 
  mutate(month = as.factor(month(date))) %>%
  mutate(weekday = as.factor(wday(date, label = TRUE))) %>% 
  mutate(temperatureC = as.vector(scale(temperature, center = TRUE, scale = FALSE))) %>%
  mutate(windspeedC = as.vector(scale(windspeed, center = TRUE, scale = FALSE))) %>% 
  filter(!is.na(count),
         !is.na(temperature),
         !is.na(weather),
         !is.na(windspeed),
         year == 2017,
         (hour == 7 | hour == 8),
         (weekday != "Sat" & weekday != "Sun"))

# compute the same model as in 01_glm_regression.R

bike_model_like_NHST = 
  brm(count ~ temperatureC + log(windspeed + 0.001) + rain + month,
      family = gaussian,
      data = bikes_neutor)

##### simple bike models ######
# first to get quicker first results 

bike_model_temperature = 
	brm(count ~ temperatureC,
			family = mixture(negbinomial, negbinomial),
			data = bikes_neutor
	)

bike_model_wind = 
  brm(count ~ windspeedC,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bike_model_weather = 
  brm(count ~ weather,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bike_model_rain = 
  brm(count ~ rain,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bike_model_weekday = 
  brm(count ~ weekday,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bike_model_month = 
  brm(count ~ month,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

save(bike_model_like_NHST,
     bike_model_temperature,
     bike_model_wind,
     bike_model_weather,
     bike_model_rain,
     bike_model_month,
     bike_model_weekday,
     file = "results/simpleBikeModels.RData")

##### simple car models ######

car_model_temperature = 
  brm(count ~ temperatureC,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_wind = 
  brm(count ~ windspeedC,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_weather = 
  brm(count ~ weather,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_rain = 
  brm(count ~ rain,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_weekday = 
  brm(count ~ weekday,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_month = 
  brm(count ~ month,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

save(car_model_like_NHST,
     car_model_temperature,
     car_model_wind,
     car_model_weather,
     car_model_rain,
     car_model_month,
     car_model_weekday,
     file = "results/simpleCarModels.RData")

##### bike models with single interaction #####

# temperature * X

bike_model_temperature_I_wind = 
	brm(count ~ temperatureC * windspeedC,
			family = mixture(negbinomial, negbinomial),
			data = bikes_neutor
	)

bike_model_temperature_I_weather = 
  brm(count ~ temperatureC * weather,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bike_model_temperature_I_rain = 
  brm(count ~ temperatureC * rain,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bike_model_temperature_I_weekday = 
  brm(count ~ temperatureC * weekday,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bike_model_temperature_I_month = 
  brm(count ~ temperatureC * weather,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

save(bike_model_temperature_I_month,
     bike_model_temperature_I_weekday,
     bike_model_temperature_I_rain,
     bike_model_temperature_I_weather,
     bike_model_temperature_I_wind,
     file = "results/twoFactorsTemperatureBike.RData")

# wind * X

bike_model_wind_I_weather = 
  brm(count ~ windspeedC * weather,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bike_model_wind_I_weekday = 
  brm(count ~ windspeedC * weekday,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bike_model_wind_I_month = 
  brm(count ~ windspeedC * month,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

save(bike_model_wind_I_month,
     bike_model_wind_I_weekday,
     bike_model_wind_I_weather,
     file = "results/twoFactorsWindBike.RData")

# weather * X

bike_model_weather_I_weekday = 
  brm(count ~ weather * weekday,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bike_model_weather_I_month = 
  brm(count ~ weather * month,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

save(bike_model_weather_I_weekday,
     bike_model_weather_I_month,
     file = "results/twoFactorsWeatherBike.RData"
    )

#### car models with single interaction ####

# temperature * X

car_model_temperature_I_wind = 
  brm(count ~ temperatureC * windspeedC,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_temperature_I_weather = 
  brm(count ~ temperatureC * weather,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_temperature_I_rain = 
  brm(count ~ temperatureC * rain,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_temperature_I_weekday = 
  brm(count ~ temperatureC * weekday,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_temperature_I_month = 
  brm(count ~ temperatureC * weather,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

save(car_model_temperature_I_month,
     car_model_temperature_I_weekday,
     car_model_temperature_I_rain,
     car_model_temperature_I_weather,
     car_model_temperature_I_wind,
     file = "results/twoFactorsTemperatureCar.RData")

# wind * X

car_model_wind_I_weather = 
  brm(count ~ windspeedC * weather,
      family = mixture(negbinomial, negbinomial),
      data = car_neutor
  )

car_model_wind_I_weekday = 
  brm(count ~ windspeedC * weekday,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

car_model_wind_I_month = 
  brm(count ~ windspeedC * month,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

save(car_model_wind_I_month,
     car_model_wind_I_weekday,
     car_model_wind_I_weather,
     file = "results/twoFactorsWindCar.RData")

# weather * X

car_model_weather_I_weekday = 
  brm(count ~ weather * weekday,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_weather_I_month = 
  brm(count ~ weather * month,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

save(car_model_weather_I_weekday,
     car_model_weather_I_month,
     file = "results/twoFactorsWeatherCar.RData"
)

### bike models with three factors ####

bike_model_temperature_wind_weather = 
	brm(count ~ temperatureC * windspeedC * weather,
			family = mixture(negbinomial, negbinomial),
			data = bikes_neutor
	)

bike_model_temperature_wind_rain = 
  brm(count ~ temperatureC * windspeedC * rain,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

save(bike_model_temperature_wind_rain,
     bike_model_temperature_wind_weather,
     file = "resluts/threeFactorsBike.RData")

### car models with three factors ####

car_model_temperature_wind_weather = 
  brm(count ~ temperatureC * windspeedC * weather,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_temperature_wind_rain = 
  brm(count ~ temperatureC * windspeedC * rain,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

save(car_model_temperature_wind_rain,
     car_model_temperature_wind_weather,
     file = "resluts/threeFactorsCar.RData")

### bike models with four factors #####

bike_model_temperature_wind_rain_weekday = 
	brm(count ~ temperatureC * windspeedC * rain * weekday,
			family = mixture(negbinomial, negbinomial),
			data = bikes_neutor
	)

bike_model_temperature_wind_rain_month = 
  brm(count ~ temperatureC * windspeedC * rain * month,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bike_model_temperature_wind_weather_weekday = 
  brm(count ~ temperatureC * windspeedC * weather * weekday,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bike_model_temperature_wind_weather_month = 
  brm(count ~ temperatureC * windspeedC * weather * month,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

save(bike_model_temperature_wind_weather_month,
     bike_model_temperature_wind_weather_weekday,
     bike_model_temperature_wind_rain_month,
     bike_model_temperature_wind_rain_weekday,
     file = "results/fourFactorsBike.RData")

## car models with four factors #####

car_model_temperature_wind_rain_weekday = 
  brm(count ~ temperatureC * windspeedC * rain * weekday,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_temperature_wind_rain_month = 
  brm(count ~ temperatureC * windspeedC * rain * month,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_temperature_wind_weather_weekday = 
  brm(count ~ temperatureC * windspeedC * weather * weekday,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

car_model_temperature_wind_weather_month = 
  brm(count ~ temperatureC * windspeedC * weather * month,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

save(car_model_temperature_wind_weather_month,
     car_model_temperature_wind_weather_weekday,
     car_model_temperature_wind_rain_month,
     car_model_temperature_wind_rain_weekday,
     file = "results/fourFactorsCar.RData")

### full bike & car models ####

bike_model_temperature_wind_weather_weekday_month = 
  brm(count ~ temperatureC * windspeedC * weather * weekday * month,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

car_model_temperature_wind_weather_weekday_month = 
  brm(count ~ temperatureC * windspeedC * weather * weekday * month,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

save(bike_model_temperature_wind_weather_weekday_month,
     car_model_temperature_wind_weather_weekday_month,
     file = "results/fullModels.RData")

