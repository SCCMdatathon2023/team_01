library(tidyverse)
library(arrow)

dat <- read_parquet("data/data_clean.parquet")


fig <- dat |>
  filter(between(core_glucose, 30, 600), between(delta_offset, -15, 15)) |>
  ggplot(aes(delta_glucose)) +
    geom_density() +
    coord_cartesian(expand=FALSE, ylim = c(0, 0.035)) + 
    scale_y_continuous(breaks = NULL) + 
    labs(x = "POC Glucose Error", y = "") + 
    theme_bw(base_size = 16)

ggsave("figure_density_dist.png", fig, width = 9, height = 6)


fig <- dat |>
  filter(between(core_glucose, 30, 600), between(delta_offset, -15, 15)) |>
  ggplot(aes(core_glucose, poc_glucose)) +
    geom_bin_2d() +
    scale_fill_continuous(trans = "log10", guide = NULL) + 
    coord_cartesian(expand=FALSE) +
    labs(x = "Core Lab Glucose (mg/dL)", y = "POC Glucose (mg/dL)", fill = "Count") + 
    theme_bw(base_size = 16)


ggsave("figure_poc_core_agreement.png", fig, width = 9, height = 6)


dat |>
  filter(between(core_glucose, 30, 600), between(delta_offset, -15, 15), !is.na(hemoglobin)) |>
  mutate(hgb_group = cut_interval(hemoglobin, 5)) |>
  ggplot(aes(delta_glucose, color = hgb_group)) + 
    geom_density()

dat |>
  filter(between(core_glucose, 30, 600), between(delta_offset, -15, 15), !is.na(hemoglobin)) |>
  mutate(hgb_group = cut_interval(hemoglobin, 5)) |>
  group_by(hgb_group) |>
  summarise(mean = mean(delta_glucose), sd = sd(delta_glucose))

dat |>
  filter(between(core_glucose, 30, 600), between(delta_offset, -15, 15), !is.na(hemoglobin)) |>
  group_by(ethnicity) |>
  summarise(mean = mean(delta_glucose), sd = sd(delta_glucose))
