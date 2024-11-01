
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(command)
library(poputils)
library(ggplot2)
library(rvec, warn.conflicts = FALSE)

cmd_assign(mod_deaths = "out/mod_deaths.rds",
           year_max = 2050,
           .out = "out/fig_hyper_deaths.rds")

labels <- seq(from = max(mod_deaths$data$time) + 1L,
              to = year_max)

comp <- forecast(mod_deaths,
                 labels = labels,
                 output = "components",
                 include_estimates = TRUE)


p_time <- comp %>%
  filter(term == "time",
         component %in% c("effect", "trend", "cyclical")) %>%
  mutate(draws_ci(.fitted)) %>%
  rename(time = level) %>%
  mutate(time = as.integer(time)) %>%
  mutate(component = factor(component,
                            levels = c("effect", "trend", "cyclical"),
                            labels = c("Effect", "Trend", "Cyclical"))) %>%
  ggplot(aes(x = time)) +
  facet_wrap(vars(component), ncol = 1) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = "steelblue1") +
  geom_line(aes(y = .fitted.mid),
            color = "darkblue") +
  xlab("Time") +
  ylab("") +
  ggtitle("Time effect and underlying components")


p_agetime <- comp %>%
  filter(term == "age:time",
         component == "effect") %>%
  select(-term, -component) %>%
  separate_wider_delim(level, delim = ".", names = c("age", "time")) %>%
  mutate(time = as.integer(time)) %>%
  mutate(draws_ci(.fitted)) %>%
  ggplot(aes(x = time)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = "steelblue1",
              alpha = 0.4) +
  geom_line(aes(y = .fitted.mid),
            color = "darkblue") +
  xlab("Time") +
  ylab("") +
  ggtitle("Age:time interaction")


p_sextime <- comp %>%
  filter(term == "sex:time",
         component == "effect") %>%
  select(-term, -component) %>%
  separate_wider_delim(level, delim = ".", names = c("sex", "time")) %>%
  mutate(time = as.integer(time)) %>%
  mutate(draws_ci(.fitted)) %>%
  ggplot(aes(x = time)) +
  facet_wrap(vars(sex)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = "steelblue1",
              alpha = 0.4) +
  geom_line(aes(y = .fitted.mid),
            color = "darkblue") +
  xlab("Time") +
  ylab("") +
  ggtitle("Sex:time interaction")


p_svd <- comp %>%
  filter(term == "age:time" & component == "svd") %>%
  select(-term, -component) %>%
  separate_wider_delim(level, delim = ".", names = c("component", "time")) %>%
  mutate(component = sub("comp", "Component ", component),
         time = as.integer(time)) %>%
  mutate(draws_ci(.fitted)) %>%
  ggplot(aes(x = time)) +
  facet_wrap(vars(component)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = "steelblue1") +
  geom_line(aes(y = .fitted.mid),
            color = "darkblue") +
  xlab("Time") +
  ylab("") +
  ggtitle("Time trends in SVD components")
  

graphics.off()
pdf(file = .out,
    width = 10,
    height = 10,
    onefile = TRUE)
plot(p_time)
plot(p_agetime)
plot(p_sextime)
plot(p_svd)
dev.off()  
  
