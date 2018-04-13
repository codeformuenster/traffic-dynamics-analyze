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

### car models with three factors ####

cars_model_temperature_wind_weather = 
  brm(count ~ temperatureC * windspeedC * weather,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

cars_model_temperature_wind_rain = 
  brm(count ~ temperatureC * windspeedC * rain,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

save(cars_model_temperature_wind_rain,
     casr_model_temperature_wind_weather,
     file = "results/cars_three_factor_models.RData")