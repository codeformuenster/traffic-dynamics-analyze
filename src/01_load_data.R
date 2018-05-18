# This program is free software.
# You should have received a copy of the GNU General Public License
# along with this program (file COPYING). If not, see <http://www.gnu.org/licenses/>.

# set working directory to proper directory
# setwd("path/to/here")

# load libraries ####
# use 00_install_R_packages.R for installing missing packages
lapply(c("dplyr", "RSQLite", "lubridate"), require, character.only = TRUE)

# this assumes the script is called from the root directory of the repository
con <- dbConnect(SQLite(), dbname = "data/database/traffic_data.sqlite")

bikes <- dbGetQuery(conn = con, 
                    "SELECT location, count, date, hour, weather, temperature, windspeed 
                    FROM bikes WHERE count != ''")

# TODO: cars table does not have the weather in it in the latest release of traffic-dynamics;
# there should be one table that contains the weather instead of appending it to cars/bikes tables
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
