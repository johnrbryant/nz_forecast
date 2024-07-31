
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(ggplot2)
library(command)

cmd_assign(deaths = "out/deaths.rds",
           popn = "out/popn.rds",
           .out = "out/fig_direct_deaths.pdf")


data <- inner_join(deaths, popn, by = c("age", "sex", "time")) %>%
  mutate(rate = deaths / popn)

p <- ggplot(data, aes(x = time, y = rate, color = sex)) +
  facet_wrap(vars(age), nrow = 4) +
  geom_line(linewidth = 0.2) +
  scale_y_log10(labels = function(x) format(x, scientific = FALSE))


graphics.off()
pdf(file = .out,
    width = 10,
    height = 10)
plot(p)
dev.off()



  
         
