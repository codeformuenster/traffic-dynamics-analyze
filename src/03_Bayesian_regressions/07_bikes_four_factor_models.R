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

### bike models with four factors #####

bikes_model_temperature_wind_rain_weekday = 
  brm(count ~ temperatureC * windspeedC * rain * weekday,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_temperature_wind_rain_month = 
  brm(count ~ temperatureC * windspeedC * rain * month,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

save(bikes_model_temperature_wind_rain_month,
     bikes_model_temperature_wind_rain_weekday,
     file = "results/bikes_four_factor_models1.RData")

bikes_model_temperature_wind_weather_weekday = 
  brm(count ~ temperatureC * windspeedC * weather * weekday,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_temperature_wind_weather_month = 
  brm(count ~ temperatureC * windspeedC * weather * month,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

save(bikes_model_temperature_wind_weather_month,
     bikes_model_temperature_wind_weather_weekday,
     file = "results/bikes_four_factor_models2.RData")