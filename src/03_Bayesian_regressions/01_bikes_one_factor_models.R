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

# compute the same model as in 01_glm_regression.R

bike_model_like_NHST = 
  brm(count ~ temperatureC + log(windspeed + 0.001) + rain + month,
      family = gaussian,
      data = bikes_neutor)

##### simple bikes models ######

bikes_model_temperature = 
  brm(count ~ temperatureC,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_wind = 
  brm(count ~ windspeedC,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_weather = 
  brm(count ~ weather,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_rain = 
  brm(count ~ rain,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_weekday = 
  brm(count ~ weekday,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

bikes_model_month = 
  brm(count ~ month,
      family = mixture(negbinomial, negbinomial),
      data = bikes_neutor
  )

save(bikes_model_like_NHST,
     bikes_model_temperature,
     bikes_model_wind,
     bikes_model_weather,
     bikes_model_rain,
     bikes_model_month,
     bikes_model_weekday,
     file = "results/bikes_one_factor_models.RData")