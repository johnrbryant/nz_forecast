
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(ggplot2)
library(command)

cmd_assign(births = "out/births.rds",
           popn = "out/popn.rds",
           .out = "out/fig_direct_births.pdf")

popn <- popn %>%
  filter(sex == "Female") %>%
  select(-sex)

data <- inner_join(births, popn, by = c("age", "time")) %>%
  mutate(rate = births / popn)

p <- ggplot(data, aes(x = time, y = rate)) +
  facet_wrap(vars(age), nrow = 1) +
  geom_line(linewidth = 0.4)



graphics.off()
pdf(file = .out,
    width = 10,
    height = 2)
plot(p)
dev.off()



  
         
