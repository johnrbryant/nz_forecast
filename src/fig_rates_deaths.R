
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(poputils)
library(ggplot2)
library(rvec, warn.conflicts = FALSE)
library(command)

cmd_assign(mod_deaths = "out/mod_deaths.rds",
           year_max = 2050,
           .out = "out/fig_rates_deaths.rds")

labels <- seq(from = max(mod_deaths$data$time) + 1L,
              to = year_max)

aug <- forecast(mod_deaths,
                labels = labels,
                include_estimates = TRUE) %>%
  mutate(draws_ci(.fitted))

p_ageslices <- aug %>%
  filter(age %in% seq(0, 90, 10)) %>%
  ggplot(aes(x = time)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper,
                  fill = sex),
              alpha = 0.4) +
  geom_line(aes(y = .fitted.mid,
                color = sex)) +
  geom_point(aes(y = .observed,
                 color = sex),
             size = 0.2) +
  scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
  xlab("Time") +
  ylab("") +
  theme(legend.position = "top",
        legend.title = element_blank()) +
  ggtitle("Time trends in age-sex-specific rates, for selected ages")


p_timeslices <- aug %>%
  filter(time %in% seq(1990, year_max, 5)) %>%
  ggplot(aes(x = age_mid(age))) +
  facet_wrap(vars(time)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper,
                  fill = sex),
              alpha = 0.4) +
  geom_line(aes(y = .fitted.mid,
                color = sex)) +
  geom_point(aes(y = .observed,
                 color = sex),
             size = 0.2) +
  scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
  xlab("Age") +
  ylab("") +
  theme(legend.position = "top",
        legend.title = element_blank()) +
  ggtitle("Age-sex profiles, in selected years")


graphics.off()
pdf(file = .out,
    width = 10,
    height = 10,
    onefile = TRUE)
plot(p_ageslices)
plot(p_timeslices)
dev.off()
