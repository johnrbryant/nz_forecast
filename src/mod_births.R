
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(command)

cmd_assign(births = "out/births.rds",
           popn = "out/popn.rds")


popn <- popn %>%
  filter(sex == "Female") %>%
  select(-sex)

data <- inner_join(births, popn, by = c("age", "time"))

mod <- mod_pois(births ~ age:time,
                data = data,
                exposure = popn) %>%
  set_prior(age:time ~ SVD_RW2(HFD))


mod <- fit(mod)

comp <- components(mod)



library(ggplot2)
library(rvec, warn.conflicts = FALSE)

svd <- comp %>%
  filter(term == "age:time" & component == "svd") %>%
  select(-term, -component) %>%
  separate_wider_delim(level, delim = ".", names = c("component", "time")) %>%
  mutate(component = sub("comp", "Component ", component),
         time = as.integer(time)) %>%
  mutate(draws_ci(.fitted))

p <- ggplot(svd, aes(x = time)) +
  facet_wrap(vars(component)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = "steelblue1") +
  geom_line(aes(y = .fitted.mid),
            color = "darkblue")
