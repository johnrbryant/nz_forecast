
library(readr)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(poputils)
library(command)

cmd_assign(.deaths = "data/VSD349204_20240719_033016_10.csv.gz",
           .out = "out/deaths.rds")

deaths <- read_csv(.deaths,
                   col_names = c("time", "age", "Male", "Female"),
                   col_types = "icii",
                   skip = 2,
                   n_max = 7676) %>%
  fill(time) %>%
  mutate(age = reformat_age(age)) %>%
  pivot_longer(c(Male, Female), names_to = "sex", values_to = "deaths") %>%
  filter(time >= 1992) %>%
  mutate(age = set_age_open(age, lower = 95)) %>%
  count(age, sex, time, wt = deaths, name = "deaths")

saveRDS(deaths, file = .out)
  



