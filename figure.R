library(tidyverse)
library(broom)
library(brms)

dat <- read_parquet("data/data_clean.parquet") |>
  mutate(ethnicity = fct_relevel(ethnicity, "Caucasian"))

dat2 <- 
  dat |>
  filter(between(delta_offset, -15, 15)) |>
  mutate(occulthypo = (poc_glucose > 70) & (core_glucose < 70))


fit_brm <- function(x) {
  brm(occulthypo ~ ethnicity,
      data = x,
      cores = 4,
      backend = 'cmdstanr',
      family = "bernoulli")
}
models <- 
  dat2 |>
    group_by(hospitalid) |>
    nest() |>
    mutate(model = map(data, fit_brm))

effects <- models |>
  mutate(p = map(model, \(x) tidy(x))) |>
  select(hospitalid, p) |>
  unnest(p) 

effects |>
  ggplot(aes(estimate)) + geom_histogram() + facet_wrap(~term)


post <- 
  models |>
  select(-data) |>
  mutate(d = map(model, \(x) as_draws_df(x))) |>
  select(-model) |>
  unnest(d)
write_rds(post, "post.rds")

la <- post |> group_by(hospitalid) |> summarise(h = mean(b_ethnicityAfricanAmerican > 0) > .975)

fig_df <- post |> left_join(la) %>%
  mutate(hospitalid = as_factor(hospitalid))

fig <- fig_df |>
ggplot(aes(b_ethnicityAfricanAmerican, group=hospitalid, color = h)) +
  geom_density() + 
  scale_color_manual(values = c("TRUE" = "red", "FALSE" = "#DDDDDDEE"), guide = NULL) + 
  scale_x_continuous(limits = c(-5, 5)) + 
  theme_bw() +
  labs(x = "Effect", y = "Density")

ggsave("model_effect.png", fig, width = 9, height = 6)
  