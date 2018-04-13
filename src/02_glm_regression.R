# This program is free software.
# You should have received a copy of the GNU General Public License
# along with this program (file COPYING). If not, see <http://www.gnu.org/licenses/>.

# LINEAR GLM REGRESSION MODEL

# load libraries ####
# use 00_install_R_packages.R for installing missing packages
lapply(c("ggplot2", "dplyr", "RSQLite", "lubridate", "nortest",
         "fitdistrplus"), 
       require, character.only = TRUE)

# load data ####
source("src/01_load_data.R")

# data distributions
bikes_commuter_neutor %>% 
  # pull(count) %>% 
  pull(temperatureC) %>%
  # log() %>% 
  hist()

# distribution of target variable
ad.test(bikes_commuter_neutor$count)
pearson.test(bikes_commuter_neutor$count)
ks.test(bikes_commuter_neutor$count, "pnorm")

# fit model ####
# linear regression
fit <-
  glm(count ~ temperatureC + log(windspeed + 0.001) + rain + month,
     data = bikes_commuter_neutor)
fit %>% summary
fit %>% summary

# analyze residuals ####
fit %>%
  resid() %>%
  ad.test() # not perfect, yet
plot(fit)


