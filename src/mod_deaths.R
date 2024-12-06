
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(poputils)
  library(command)
})

cmd_assign(deaths = "out/deaths.rds",
           popn = "out/popn.rds",
           .out = "out/mod_deaths.rds")

data <- inner_join(deaths, popn, by = c("age", "sex", "time")) |>
  mutate(age = combine_age(age, to = "five")) |>
  group_by(age, sex, time) |>
  summarise(deaths = sum(deaths), popn = sum(popn),
            .groups = "drop")

mod <- mod_pois(deaths ~ age:sex + age:time + sex:time + time,
                data = data,
                exposure = popn) |>
  set_prior(age:sex ~ RW2_Infant()) |>
  set_prior(age:time ~ SVD_RW2(HMD, zero_sum = TRUE)) |>
  set_prior(sex:time ~ RW2(zero_sum = TRUE)) |>
  set_prior(time ~ Lin_AR()) |>
  fit()


saveRDS(mod, file = .out)


  
