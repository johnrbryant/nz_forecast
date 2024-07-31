
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(poputils)
library(ggplot2)
library(rvec, warn.conflicts = FALSE)
library(command)

cmd_assign(mod_deaths = "out/mod_deaths.rds",
           year_max = 2050,
           .out = "out/fig_lifeexp.pdf")

labels <- seq(from = max(mod_deaths$data$time) + 1L,
              to = year_max)

aug <- forecast(mod_deaths,
                labels = labels,
                include_estimates = TRUE)

lifeexp <- aug %>%
  lifeexp(mx = .fitted,
          sex = sex,
          by = time) %>%
  mutate(draws_ci(ex))

p_life <- lifeexp %>%
  ggplot(aes(x = time)) +
  facet_wrap(vars(sex)) +
  geom_ribbon(aes(ymin = ex.lower,
                  ymax = ex.upper),
              fill = "steelblue1") + 
  geom_line(aes(y = ex.mid),
            color = "darkblue") +
  xlab("Time") +
  ylab("") +
  ggtitle("Time trends in life expectancy at birth")


graphics.off()
pdf(file = .out,
    width = 10,
    height = 10)
plot(p_life)
dev.off()
