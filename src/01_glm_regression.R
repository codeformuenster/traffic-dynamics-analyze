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
con <- dbConnect(SQLite(), dbname = "../data/database/traffic_data.sqlite")
bikes <- dbGetQuery(conn = con, 
                    "SELECT 
                      location, count, date, hour, weather,
                      temperature, windspeed 
				 			      FROM bikes WHERE count != ''")
dbDisconnect(con)


# filtering data ####
# filter data for valid observations
bikes_commuter_neutor <-
  bikes %>%
  # generate factors
  mutate(regen = weather == "Regen") %>% 
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
         (weekday != "Sa" & weekday != "So"))

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
  glm(count ~ temperatureC + log(windspeed + 0.001) + regen + month,
     data = bikes_commuter_neutor)
fit %>% summary
fit %>% summary

# analyze residuals ####
fit %>%
  resid() %>%
  ad.test() # not perfect, yet
plot(fit)


