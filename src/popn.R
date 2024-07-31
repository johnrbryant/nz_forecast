
library(readr)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(poputils)
library(command)

cmd_assign(.popn = "data/DPE403905_20240719_034147_54.csv.gz",
           .out = "out/popn.rds")

popn <- read_csv(.popn,
                 col_names = c("time", "sex", "age", "popn"),
                 col_types = "icci",
                 skip = 2,
                 n_max = 6336,
                 na = c("", "..")) %>%
  fill(time, sex) %>%
  mutate(age = reformat_age(age)) %>%
  filter(time >= 1992)

saveRDS(popn, file = .out)
  



