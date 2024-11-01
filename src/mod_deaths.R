
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(poputils)
library(command)

cmd_assign(deaths = "out/deaths.rds",
           popn = "out/popn.rds",
           .out = "out/mod_deaths.rds")

data <- inner_join(deaths, popn, by = c("age", "sex", "time")) |>
  mutate(age = combine_age(age, to = "five"),
         age = set_age_open(age, lower = 60)) |>
  group_by(age, sex, time) |>
  summarise(deaths = sum(deaths), popn = sum(popn),
            .groups = "drop")


mod <- mod_pois(deaths ~ age * sex + age * time + sex * time,
                data = data,
                exposure = popn) |>
  set_prior(age ~ RW2()) |>
  set_prior(age:sex ~ RW()) |>
  set_prior(age:time ~ SVD_RW(HMD, zero_sum = TRUE)) |>
  set_prior(sex:time ~ RW(zero_sum = TRUE)) |>
  set_prior(time ~ Lin_AR()) |>
  fit()


saveRDS(mod, file = .out)


  
