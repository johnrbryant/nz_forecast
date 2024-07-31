
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(command)
library(poputils)
library(ggplot2)
library(rvec, warn.conflicts = FALSE)

cmd_assign(mod_deaths = "out/mod_deaths.rds",
           .out = "out/fig_esthyper_deaths.pdf")


comp <- components(mod_deaths, standardize = T)


p_trend <- comp %>%
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


p_agesextime <- comp %>%
  filter(term == "age:sex:time",
         component == "effect") %>%
  select(-term, -component) %>%
  separate_wider_delim(level, delim = ".", names = c("age", "sex", "time")) %>%
  mutate(time = as.integer(time)) %>%
  mutate(draws_ci(.fitted)) %>%
  filter(age %in% seq(0, 90, 10)) %>%
  ggplot(aes(x = time)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper,
                  fill = sex),
              alpha = 0.4) +
  geom_line(aes(y = .fitted.mid,
                color = sex)) +
  xlab("Time") +
  ylab("") +
  ggtitle("Time effect and underlying components")


p_svd <- comp %>%
  filter(term == "age:sex:time" & component == "svd") %>%
  select(-term, -component) %>%
  separate_wider_delim(level, delim = ".", names = c("sex", "component", "time")) %>%
  mutate(component = sub("comp", "Component ", component),
         time = as.integer(time)) %>%
  mutate(draws_ci(.fitted)) %>%
  ggplot(aes(x = time)) +
  facet_grid(vars(sex), vars(component)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = "steelblue1") +
  geom_line(aes(y = .fitted.mid),
            color = "darkblue") +
  xlab("Time") +
  ylab("") +
  ggtitle("Time trends in SVD components, by sex")
  

graphics.off()
pdf(file = .out,
    width = 10,
    height = 10,
    onefile = TRUE)
plot(p_trend)
plot(p_svd)
dev.off()  
  
