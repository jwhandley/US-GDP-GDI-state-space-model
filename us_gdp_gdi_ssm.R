library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

df <- read_csv("gdp_gdi.csv") %>%
  mutate(across(c(GDI,GDP),~400*(log(.x) - lag(log(.x))))) %>%
  filter(!is.na(GDP))

df$t <- row(df)[,1]

data <- list(N = nrow(df),
             y1 = df$GDP,
             y2 = df$GDI)

fit <- stan("gdp_ssm.stan",
            data = data,
            chains = 4,
            iter = 4000)
print(fit)


posterior_samples <- extract(fit, permuted = TRUE)
mu_samples <- posterior_samples$mu

mu_CI <- apply(mu_samples, 2, quantile, probs = c(0.025, 0.5, 0.975))
rownames(mu_CI) <- c("lower2.5","median","upper97.5")

mu_CI %>%
  t() %>%
  as_tibble() %>%
  bind_cols(df) %>%
  ggplot(aes(x = date)) +
  geom_hline(yintercept = 0) +
  geom_line(aes(y = GDI, color = "GDI")) +
  geom_line(aes(y = GDP, color = "GDP")) +
  geom_line(aes(y = median, color = "Estimate")) +
  geom_ribbon(aes(ymin = lower2.5, ymax = upper97.5), alpha = 0.3) +
  scale_color_manual(values = c("GDI" = "#E69F00", "GDP" = "#56B4E9", "Estimate" = "black"),
                     name = NULL) +
  labs(x = NULL,
       y = "Continuously compounded annual rate of change",
       title = "State space approach to reconciling GDP and GDI",
       caption = "@jwhandley17")
ggsave("gdp_gdi_growth.png",width=8,height=5)
