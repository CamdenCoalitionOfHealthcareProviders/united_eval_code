
# Add No Spending Cap and Spending Cap Scenarios --------------------------
# Based on results of clean_files.R

# Load Libraries ----------------------------------------------------------

library(tidyverse)

# See united_evaluation.Rmd file for binding each indivdiual file
m <- read_csv("y:/united_evaluation/united_members.csv")
c <- read_csv("y:/united_evaluation/united_claims.csv")


# Member Months and Risk Score Counts -------------------------------------
mm_risk_counts <- m %>% 
  filter((product_bin != "HCR Expansion" | PRODUCT_DESC != "MEDICAID - NON-AFDC"),
         year_eval != 'PY4') %>% 
  group_by(year_eval, product_bin, camden_cchp) %>% 
  summarise(member_months = n(),
            risk_score_orig = sum(risk_score, na.rm = T),
            risk_score_update = sum(risk_score_update))


# No Spending Cap ---------------------------------------------------------

# Claim cost by product_bin and year
claim_by_member <- c %>% 
  filter(product_bin != "HCR Expansion" | year_eval != "PY4" | PRODUCT_DESC != "MEDICAID - NON-AFDC") %>%
  group_by(memb_id, year_eval, product_bin) %>% 
  summarise(claim_cost = sum(claim_cost))

claim_cost_sum_no_cap <- claim_by_member %>% 
  left_join(select(m, memb_id, year_eval, camden_cchp), by = c("memb_id", "year_eval")) %>% 
  distinct() %>% 
  group_by(year_eval, product_bin, camden_cchp) %>% 
  summarise(claim_cost = sum(claim_cost)) %>% 
  mutate(baseline_max = "no max")
  

# $63K Spending Cap -------------------------------------------------------

year_eval_month_count <- data.frame(
  year_eval = c('BY1', 'BY2', 'BY3', 'PY1', 'PY2', 'PY3', '2017'),
  month_count = c(12, 12, 11, 12, 13, 12, 12))

memb_risk_score_by_year_eval <- m %>%
  group_by(memb_id, year_eval) %>%
  summarise(risk_sum = sum(risk_score_update))

risk_score_by_year_eval <- memb_risk_score_by_year_eval %>%
  group_by(year_eval) %>%
  summarise(risk_sum_year_eval = sum(risk_sum))

# Set spending cap
baseline_max <- c(63000)
baseline_max_month <- baseline_max/12

df <- data.frame(baseline_max = rep(baseline_max, 7),
                 baseline_max_month = rep(baseline_max_month, 7),
                 year_eval = rep(year_eval_month_count$year_eval, 4),
                 year_eval_month_count = rep(year_eval_month_count$month_count, 4))

df2 <- df %>% mutate(baseline_max_annual = baseline_max_month*year_eval_month_count)


# Annualize Spending ------------------------------------------------------

# Number of member months per person per evaluation year
memb_month_count_year_eval <- m %>%
  filter(PRODUCT_DESC != "MEDICAID - NON-AFDC") %>% 
  group_by(memb_id, product_bin, year_eval, `camden_cchp`) %>%
  count()

# Adding the baseline annual and baseline monthly max to the member list based on evaluation year (Members only)
memb_set_up_baseline_max <- memb_month_count_year_eval %>%
  left_join(df2, by = as.character("year_eval")) %>% distinct()

# Group claims by member ID, year_eval, and then sum claim costs (Claims only)
memb_claim_cost_by_year_eval <-  c %>%
  filter(PRODUCT_DESC != "MEDICAID - NON-AFDC") %>% 
  group_by(memb_id, year_eval) %>%
  summarise(cost_by_year_eval = sum(claim_cost)) %>%
  left_join(memb_set_up_baseline_max, by = c("memb_id", "year_eval"))

# Add adjusted max monthly cost and risk scores (Members and Claims)
memb_claim_cost_by_year_eval_adj <- memb_claim_cost_by_year_eval %>%
  mutate(cost_per_month_year_eval = cost_by_year_eval/n,
         adjusted_cost_per_month_year_eval =
           case_when(
             cost_per_month_year_eval > baseline_max_month ~ baseline_max_month,
             cost_per_month_year_eval <= baseline_max_month ~ cost_per_month_year_eval
           ),
         cost_difference_truncated = cost_per_month_year_eval - adjusted_cost_per_month_year_eval) %>%
  left_join(memb_risk_score_by_year_eval, by = c("memb_id", "year_eval"))

# Calculate adjusted spending
cost_by_year_eval_adj <- memb_claim_cost_by_year_eval_adj %>%
  group_by(year_eval, product_bin, camden_cchp, baseline_max) %>%
  summarise(claim_cost = sum(adjusted_cost_per_month_year_eval),
            memb_month_count = sum(n, na.rm = T),
            risk_score = sum(risk_sum, na.rm = T)) %>% 
  mutate(baseline_max = "63000") %>% 
  select(everything(), -memb_month_count, -risk_score)


# Bind spending cap and no spending cap together --------------------------

spending_combined <- rbind(claim_cost_sum_no_cap, cost_by_year_eval_adj)
spending_combined_filter <- spending_combined %>% 
  filter(product_bin != "HCR Expansion", year_eval != 'PY4')


# Export ------------------------------------------------------------------

write_csv(spending_combined_filter, "y:/united_evaluation/united_eval_claim_costs.csv")
write_csv(mm_risk_counts, "y:/united_evaluation/united_eval_mm_risk_counts.csv")

