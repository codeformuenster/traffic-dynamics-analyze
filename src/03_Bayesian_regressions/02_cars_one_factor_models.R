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

# TODO save more often

##### cars one factor models ######

cars_model_temperature = 
  brm(count ~ temperatureC,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

cars_model_wind = 
  brm(count ~ windspeedC,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

save(cars_model_temperature,
     cars_model_wind,
     file = "results/cars_one_factor_models1.RData")

cars_model_weather = 
  brm(count ~ weather,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

cars_model_rain = 
  brm(count ~ rain,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

save(cars_model_weather,
     cars_model_rain,
     file = "results/cars_one_factor_models2.RData")

cars_model_weekday = 
  brm(count ~ weekday,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

cars_model_month = 
  brm(count ~ month,
      family = mixture(negbinomial, negbinomial),
      data = cars_neutor
  )

save(cars_model_month,
     cars_model_weekday,
     file = "results/cars_one_factor_models3.RData")