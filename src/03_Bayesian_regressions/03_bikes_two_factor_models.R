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
source("src/01_load_data.R")

##### bike models with two factors #####

# temperature * X

bikes_model_temperature_I_wind = 
  brm(count ~ temperatureC * windspeedC,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_temperature_I_weather = 
  brm(count ~ temperatureC * weather,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_temperature_I_rain = 
  brm(count ~ temperatureC * rain,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_temperature_I_weekday = 
  brm(count ~ temperatureC * weekday,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_temperature_I_month = 
  brm(count ~ temperatureC * month,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

save(bikes_model_temperature_I_month,
     bikes_model_temperature_I_weekday,
     bikes_model_temperature_I_rain,
     bikes_model_temperature_I_weather,
     bikes_model_temperature_I_wind,
     file = "results/bikes_two_factor_models_temperature.RData")

# wind * X

bikes_model_wind_I_weather = 
  brm(count ~ windspeedC * weather,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_wind_I_weekday = 
  brm(count ~ windspeedC * weekday,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_wind_I_month = 
  brm(count ~ windspeedC * month,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

save(bikes_model_wind_I_month,
     bikes_model_wind_I_weekday,
     bikes_model_wind_I_weather,
     file = "results/bikes_two_factor_models_wind.RData")

# weather * X

bikes_model_weather_I_weekday = 
  brm(count ~ weather * weekday,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_weather_I_month = 
  brm(count ~ weather * month,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

save(bikes_model_weather_I_weekday,
     bikes_model_weather_I_month,
     file = "results/bikes_two_factor_models_weather.RData"
)