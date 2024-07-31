
library(readr)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(poputils)
library(command)

cmd_assign(.births = "data/VSB355804_20240719_033528_19.csv.gz",
           .out = "out/birthsk.rds")

births <- read_csv(.births,
                   col_names = c("time", 13:47),
                   col_types = paste0(rep("i", times = 36), collapse = ""),
                   skip = 2,
                   n_max = 62) %>%
  pivot_longer(-time, names_to = "age", values_to = "births") %>%
  mutate(age = factor(age)) %>%
  filter(time >= 1992)

saveRDS(births, file = .out)
  



