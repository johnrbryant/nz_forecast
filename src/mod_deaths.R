
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)

cmd_assign(deaths = "out/deaths.rds",
           popn = "out/popn.rds",
           .out = "out/mod_deaths.rds")

data <- inner_join(deaths, popn, by = c("age", "sex", "time")) %>%
  filter(time <= 2015)

mod <- mod_pois(deaths ~ age:sex + age:sex:time + time,
                data = data,
                exposure = popn) %>%
  set_prior(age:sex ~ RW2()) %>%
  set_prior(age:sex:time ~ SVDS_RW2(HMD, n = 2)) %>%
  set_prior(time ~ Lin_AR()) %>%
  fit()

saveRDS(mod, file = .out)


  
