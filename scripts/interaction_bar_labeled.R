library(tidyverse)
library(scales)

country_tier_predictions <- read_csv(
  "output/tables/final_model_predicted_salary_by_country_tier.csv"
) %>%
  mutate(
    college_tier = factor(college_tier, levels = c("Tier 1", "Tier 2", "Tier 3")),
    country      = factor(country, levels = c("India", "Germany", "UK", "Canada", "USA"))
  )

# Calculate midpoints and gaps between adjacent tiers for each country
# gap_labels <- country_tier_predictions %>%
#   arrange(country, college_tier) %>%
#   group_by(country) %>%
#   mutate(
#     next_salary = lead(predicted_salary),
#     next_tier   = lead(college_tier),
#     midpoint    = (predicted_salary + next_salary) / 2,
#     gap_label   = ifelse(!is.na(next_salary),
#                          paste0("-", dollar(predicted_salary - next_salary, accuracy = 1000)),
#                          NA)
#   ) %>%
#   filter(!is.na(gap_label))

# Compute dodge positions manually so gap arrows sit between correct bars
# dodge_positions <- tibble(
#   college_tier = factor(c("Tier 1", "Tier 2", "Tier 3"),
#                         levels = c("Tier 1", "Tier 2", "Tier 3")),
#   x_offset     = c(-0.233, 0, 0.233)   # matches position_dodge(width = 0.7)
# )
# 
# gap_labels <- gap_labels %>%
#   left_join(dodge_positions, by = "college_tier") %>%
#   mutate(
#     next_x_offset = x_offset + 0.233,
#     label_x       = as.numeric(country) + (x_offset + next_x_offset) / 2
#   )

ggplot(country_tier_predictions,
       aes(x = country, y = predicted_salary, fill = college_tier)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.7), width = 0.7) +
  
  # Salary labels on top of each bar
  geom_text(
    aes(label = dollar(predicted_salary, accuracy = 1000)),
    position = position_dodge(width = 0.7),
    vjust = -0.5, size = 2.8, fontface = "bold"
  ) +
  
  # Gap labels between adjacent tiers
  # geom_label(
  #   data = gap_labels,
  #   aes(x = label_x, y = midpoint, label = gap_label),
  #   inherit.aes = FALSE,
  #   size = 2.8, fill = "white", color = "firebrick",
  #   fontface = "bold", label.size = 0.3
  # ) +
  
  scale_y_continuous(
    labels = dollar_format(),
    limits = c(40000, max(country_tier_predictions$predicted_salary) * 1.12),
    oob    = scales::squish   # clips bars cleanly at $40k floor
  ) +
  scale_fill_brewer(palette = "Blues") +
  coord_cartesian(ylim = c(40000, max(country_tier_predictions$predicted_salary) * 1.12)) +
  labs(
    title    = "Predicted Salary by College Tier and Country",
    subtitle = "Labels show salary drop from one tier to the next. Baseline: median CGPA, modal ranking band and industry.",
    x        = "Country",
    y        = "Predicted Salary",
    fill     = "College Tier",
    caption  = "Based on final OLS model with college_tier * country interaction"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold"),
    plot.subtitle = element_text(color = "grey40", size = 9),
    legend.position = "top"
  )

ggsave("output/figures/predicted_salary_tier_country_gaps.png", width = 13, height = 7, dpi = 150)


country_specialization_predictions <- read_csv(
  "output/tables/final_model_predicted_salary_by_country_specialization.csv"
) %>%
  mutate(
    specialization = factor(specialization,
                            levels = c("AI/ML", "Cloud", "Core CS", 
                                       "Cybersecurity", "Data Science")),
    country        = factor(country, 
                            levels = c("India", "Germany", "UK", "Canada", "USA"))
  )

# Calculate gaps between adjacent specializations within each country
# gap_labels <- country_specialization_predictions %>%
#   arrange(country, specialization) %>%
#   group_by(country) %>%
#   mutate(
#     next_salary = lead(predicted_salary),
#     next_spec   = lead(specialization),
#     midpoint    = (predicted_salary + next_salary) / 2,
#     gap_label   = ifelse(!is.na(next_salary),
#                          paste0(ifelse(predicted_salary - next_salary >= 0, "-", "+"),
#                                 dollar(abs(predicted_salary - next_salary), accuracy = 1000)),
#                          NA)
#   ) %>%
#   filter(!is.na(gap_label))
# 
# # Dodge positions for 5 specializations
# n_specs    <- 5
# bar_width  <- 0.7
# spec_offsets <- seq(-bar_width/2 + bar_width/(2*n_specs),
#                     bar_width/2 - bar_width/(2*n_specs),
#                     length.out = n_specs)
# 
# dodge_positions <- tibble(
#   specialization = factor(c("AI/ML", "Cloud", "Core CS", "Cybersecurity", "Data Science"),
#                           levels = c("AI/ML", "Cloud", "Core CS", 
#                                      "Cybersecurity", "Data Science")),
#   x_offset = spec_offsets
# )
# 
# gap_labels <- gap_labels %>%
#   left_join(dodge_positions, by = "specialization") %>%
#   mutate(
#     next_x_offset = x_offset + diff(spec_offsets)[1],
#     label_x       = as.numeric(country) + (x_offset + next_x_offset) / 2
#   )

ggplot(country_specialization_predictions,
       aes(x = country, y = predicted_salary, fill = specialization)) +
  geom_bar(stat = "identity", position = position_dodge(width = bar_width), 
           width = bar_width) +
  
  # Salary labels on top of each bar
  geom_text(
    aes(label = dollar(predicted_salary, accuracy = 1000)),
    position = position_dodge(width = bar_width),
    vjust = -0.5, size = 2.4, fontface = "bold"
  ) +
  
  # Gap labels between adjacent specializations
  # geom_label(
  #   data = gap_labels,
  #   aes(x = label_x, y = midpoint, label = gap_label),
  #   inherit.aes = FALSE,
  #   size = 2.2, fill = "white", color = "firebrick",
  #   fontface = "bold", label.size = 0.3
  # ) +
 
  scale_y_continuous(
    labels = dollar_format(),
    limits = c(40000, max(country_specialization_predictions$predicted_salary) * 1.12),
    oob    = scales::squish
  ) +
  scale_fill_brewer(palette = "Blues") +
  coord_cartesian(
    ylim = c(40000, max(country_specialization_predictions$predicted_salary) * 1.12)
  ) +
  labs(
    title    = "Predicted Salary by Specialization and Country",
    subtitle = "Labels show salary difference between adjacent specializations. Baseline: Tier 1, median CGPA, modal ranking band and industry.",
    x        = "Country",
    y        = "Predicted Salary",
    fill     = "Specialization",
    caption  = "Based on final OLS model with country * specialization interaction"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold"),
    plot.subtitle = element_text(color = "grey40", size = 9),
    legend.position = "top"
  )

ggsave("output/figures/predicted_salary_specialization_country_gaps.png", 
       width = 15, height = 7, dpi = 150)