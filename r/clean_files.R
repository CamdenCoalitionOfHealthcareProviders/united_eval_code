# Script to clean members, claims, and risk scores for United MCO evaluation
# Output is: 1) One member file; 2) One claim file

# This file:
# 1. Bind members and claims files into their own tables
# 2. Rename different identifying variables to for members in members and claims files
# 3. Set Baseline and Performance Years
# 4. Add in # of months are in Baseline and Performance Years
# "Bin" Medicaid Product Lines
# 5. Update risk scores

# Load library
library(tidyverse)
library(lubridate)

# Bind members and claims files into their own tables ---------------------

# UHC Claims, 2011-2017
c11 <- read_delim("Y:/united_evaluation/data/2011 Claims.txt", "\t")
c12 <- read_delim("Y:/united_evaluation/data/2012 Claims.txt", "\t")
c13a <- read_delim("Y:/united_evaluation/data/2013 Claims_a.txt", "\t")
c13b <- read_delim("Y:/united_evaluation/data/2013 Claims Data_b.txt", "\t")
c14 <- read_delim("Y:/united_evaluation/data/2014 Claims Data.txt", "\t")
c15 <- read_delim("Y:/united_evaluation/data/2015 Claims Data.txt", "\t")
c16 <- read_delim("Y:/united_evaluation/data/2016 Claims Data.txt", "\t")
c17 <- read_delim("Y:/united_evaluation/data/2017 Claims Data.txt", "\t")

# UHC Members, 2011-2017
m11 <- read_delim("Y:/united_evaluation/data/2011 Members.txt", "\t")
m12 <- read_delim("Y:/united_evaluation/data/2012 Members.txt", "\t")
m13a <- read_delim("Y:/united_evaluation/data/2013 Members_a.txt", "\t")
m13b <- read_delim("Y:/united_evaluation/data/2013 Members Data_b.txt", "\t")
m14 <- read_delim("Y:/united_evaluation/data/2014 Members Data.txt", "\t")
m15 <- read_delim("Y:/united_evaluation/data/2015 Members Data.txt", "\t")
m16 <- read_delim("Y:/united_evaluation/data/2016 Members Data.txt", "\t")
m17 <- read_delim("Y:/united_evaluation/data/2017 Members Data.txt", "\t")


# Rename different identifying variables to for members in members --------

# Rename `Unique Number` and `Unique Identifier` column in members files
m11$memb_id  <- m11$`Unique Number`
m12$memb_id  <- m12$`Unique Number`
m13a$memb_id  <- m13a$`Unique Number`
m13b$memb_id  <- m13b$`Unique Identifier`
m14$memb_id  <- m14$`Unique Indentifier`
m15$memb_id  <- m15$`Unique Identifier`
m16$memb_id  <- m16$`Unique Identifier`
m17$memb_id  <- m17$`Unique Identifier`

m11$`Unique Number` <- NULL
m12$`Unique Number` <- NULL
m13a$`Unique Number` <- NULL
m13b$`Unique Identifier` <- NULL
m14$`Unique Indentifier` <- NULL
m15$`Unique Identifier` <- NULL
m16$`Unique Identifier` <- NULL
m17$`Unique Identifier` <- NULL

# Rename `Unique Number` and `Unique Identifier` column in claims files
c11$memb_id  <- c11$`Unique Number`
c12$memb_id  <- c12$`Unique Number`
c13a$memb_id  <- c13a$`Unique Number`
c13b$memb_id  <- c13b$`Unique Identifier`
c14$memb_id  <- c14$`Unique Identifier`
c15$memb_id  <- c15$`Unique Identifier`
c16$memb_id  <- c16$`Unique Identifier`
c17$memb_id  <- c17$`Unique Identifier`

c11$`Unique Number` <- NULL
c12$`Unique Number` <- NULL
c13a$`Unique Number` <- NULL
c13b$`Unique Identifier` <- NULL
c14$`Unique Identifier` <- NULL
c15$`Unique Identifier` <- NULL
c16$`Unique Identifier` <- NULL
c17$`Unique Identifier` <- NULL


# Claims: Rename 'Net Amt' and 'Calc..' columns ---------------------------
c11$claim_cost  <- c11$`Net Amt`
c12$claim_cost  <- c12$`Net Amt`
c13a$claim_cost  <- c13a$`Net Amt`
c13b$claim_cost  <- c13b$Calc_Allo_Paid_Net_Amt
c14$claim_cost  <- c14$Calc_Allo_Paid_Net_Amt
c15$claim_cost  <- c15$Calc_Allo_Paid_Net_Amt
c16$claim_cost  <- c16$Calc_Allo_Paid_Net_Amt
c17$claim_cost  <- c17$Calc_Allo_Paid_Net_Amt

c11$`Net Amt` <- NULL
c12$`Net Amt` <- NULL
c13a$`Net Amt` <- NULL
c13b$Calc_Allo_Paid_Net_Amt <- NULL
c14$Calc_Allo_Paid_Net_Amt <- NULL
c15$Calc_Allo_Paid_Net_Amt <- NULL
c16$Calc_Allo_Paid_Net_Amt <- NULL
c17$Calc_Allo_Paid_Net_Amt <- NULL

# Clean column name for c13a
colnames(c13a)[14] <- "Quantity"

# Bind claims, members in single data frames
# For 2013 members, m13a and m13b both contain the same July 2013 member list.
# Remove the member list for July 2013 from one of the two 2013 data frames
c <- rbind(c11, c12, c13a, c13b, c14, c15, c16, c17)

m13a_no7 <- m13a %>% filter(Month != 7)
m <- rbind(m11, m12, m13a_no7, m13b, m14, m15, m16, m17)

# In members data frame, add date column based on Year and Month
m <- m %>%
  mutate(month_pad = str_pad(Month, pad = "0", side = c("left"), width = 2),
         memb_date = mdy(paste0(month_pad, "-01-", Year)))

# In claims data frame, add date column based on Year and Month
c <- c %>%
  mutate(month_pad = str_pad(Month, pad = "0", side = c("left"), width = 2),
         memb_date = mdy(paste0(month_pad, "-01-", Year)))


# Members: Add Age at Membership Month ------------------------------------
m$age_at_memb_date <- time_length(interval(mdy(m$DOB), ymd(m$memb_date)), "year")


# Set Baseline and Performance Years --------------------------------------

# Baseline Years:
# BY1 - Jan 2011 - Dec 2011
# BY2 - Jan 2012 - Dec 2012
# BY3 - Jan 2013 - Nov 2013

# Performance Years:
# PY1 - Dec 2013 - Nov 2014
# PY2 - Dec 2014 - Dec 2015
# PY3 - Jan 2016 - Dec 2016

# Claims: Add Evaluation Year
c <- c %>% mutate(
  year_eval = case_when(
    Year == "2011" ~ "BY1",
    Year == "2012" ~ "BY2",
    Year == "2013" & (Month >= 1 & Month <= 11) ~ "BY3",
    (Year == "2013" & Month == 12) | Year == "2014" & (Month >= 1 & Month <= 11)~ "PY1",
    (Year == "2014" & Month == 12) | Year == "2015" ~ "PY2",
    Year == "2016" ~ "PY3",
    Year == "2017" ~ "PY4"))

# Members: Add Evaluation Year
m <- m %>% mutate(
  year_eval = case_when(
    Year == "2011" ~ "BY1",
    Year == "2012" ~ "BY2",
    Year == "2013" & (Month >= 1 & Month <= 11) ~ "BY3",
    (Year == "2013" & Month == 12)| Year == "2014" & (Month >= 1 & Month <= 11)~ "PY1",
    (Year == "2014" & Month == 12) | Year == "2015" ~ "PY2",
    Year == "2016" ~ "PY3",
    Year == "2017" ~ "PY4"))


# Add in # of months are in Baseline and Performance Years ----------------
c <- c %>% mutate(
  year_eval_mo_count = case_when(
    year_eval == 'BY1' ~ 12,
    year_eval == 'BY2' ~ 12,
    year_eval == 'BY3' ~ 11,
    year_eval == 'PY1' ~ 12,
    year_eval == 'PY2' ~ 13,
    year_eval == 'PY3' ~ 12,
    year_eval == 'PY4' ~ 12
  ))

m <- m %>% mutate(
  year_eval_mo_count = case_when(
    year_eval == 'BY1' ~ 12,
    year_eval == 'BY2' ~ 12,
    year_eval == 'BY3' ~ 11,
    year_eval == 'PY1' ~ 12,
    year_eval == 'PY2' ~ 13,
    year_eval == 'PY3' ~ 12,
    year_eval == 'PY4' ~ 12
  ))


# "Bin" Medicaid Product Lines --------------------------------------------

m_bin <- m %>% mutate(product_bin =
                        case_when(
                          PRODUCT_DESC == "CHP (Kids Care)" ~ "TANF/AFDC/CHP/FHP",
                          PRODUCT_DESC == "FHP" ~ "TANF/AFDC/CHP/FHP",
                          PRODUCT_DESC == "HCR Expansion" ~ "HCR Expansion",
                          PRODUCT_DESC == "MCR Dual" ~ "SSI w MCR",
                          PRODUCT_DESC == "MEDICAID - NON-AFDC" ~ "TANF/AFDC/CHP/FHP",
                          PRODUCT_DESC == "SSI w MCR" ~ "SSI w MCR",
                          PRODUCT_DESC == "SSI w/o MCR" ~ "SSI w/o MCR",
                          PRODUCT_DESC == "TANF/AFDC" ~ "TANF/AFDC/CHP/FHP"
                        ))

c_bin <- c %>% mutate(product_bin =
                        case_when(
                          PRODUCT_DESC == "CHP (Kids Care)" ~ "TANF/AFDC/CHP/FHP",
                          PRODUCT_DESC == "FHP" ~ "TANF/AFDC/CHP/FHP",
                          PRODUCT_DESC == "HCR Expansion" ~ "HCR Expansion",
                          PRODUCT_DESC == "MCR Dual" ~ "SSI w MCR",
                          PRODUCT_DESC == "MEDICAID - NON-AFDC" ~ "TANF/AFDC/CHP/FHP",
                          PRODUCT_DESC == "SSI w MCR" ~ "SSI w MCR",
                          PRODUCT_DESC == "SSI w/o MCR" ~ "SSI w/o MCR",
                          PRODUCT_DESC == "TANF/AFDC" ~ "TANF/AFDC/CHP/FHP"
                        ))


# "Bin" Claims Cost -------------------------------------------------
c_bin2 <- c_bin %>% mutate(
  cost_bin = case_when(
    claim_cost < 0 ~ "Negative",
    claim_cost == 0 ~ "0",
    between(c$claim_cost, 0.01, 9.99) == TRUE ~ "1-9",
    between(c$claim_cost, 10, 24.99) == TRUE ~ "10-24",
    between(c$claim_cost, 25, 49.99) == TRUE ~ "25-49",
    between(c$claim_cost, 50, 99.99) == TRUE ~ "50-99",
    between(c$claim_cost, 100, 499.99) == TRUE ~ "100-499",
    between(c$claim_cost, 500, 999.99) == TRUE ~ "500-999",
    between(c$claim_cost, 1000, 2499.99) == TRUE ~ "1000-2499",
    between(c$claim_cost, 2500, 4999.99) == TRUE ~ "2500-4999",
    between(c$claim_cost, 5000, 7499.99) == TRUE ~ "5000-7499",
    between(c$claim_cost, 7500, 9999.99) == TRUE ~ "7500-9999",
    claim_cost > 10000 ~ "< 10000"
  )
)

# Update Risk Scores ------------------------------------------------------

# Read in updated risk scores
r <- read_delim("y:/united_evaluation/data/Member Risk Scores to send.txt", delim = "\t")

# Adjust updated risk scores to "long" form
r2 <- r %>% gather("memb_month","risk_score", -`Unique Indentifier`) %>% arrange(`Unique Indentifier`)

# Change Unique ID column
r2$memb_id  <- r2$`Unique Indentifier`
r2$`Unique Indentifier` <- NULL

# Member: Create field to match on risk score data frame
m2 <- m_bin %>% mutate(memb_month = paste0(m_bin$Year, str_pad(m_bin$Month, pad = "0", side = c("left"), width = 2)))

# Join member file with updated risk scores
m3_update_risk_score <-
  m2 %>%
  left_join(r2, by = c("memb_id", "memb_month")) %>%
  mutate(risk_diff = risk_score - IPRO_RISK_SCORE)

# Where member has an original risk score and no new risk score
no_new_risk_score <- m3_update_risk_score %>% filter(is.na(risk_score))

# Add updated risk scores to member file
m4_update_risk_score <- m3_update_risk_score %>% mutate(
  risk_score_update = case_when(
    is.na(risk_score) == TRUE ~ IPRO_RISK_SCORE,
    is.na(risk_score) == FALSE ~ risk_score
  )
)

# Add Member Zip Codes ----------------------------------------------------

# Read in file
z <- read_delim("Y:/united_evaluation/data/Member Zip Codes_send.txt", "\t")

# Create memb_id column
z$memb_id <- z$`Unique Number`
z2 <- z %>% 
  mutate(
    camden_cchp = if_else(
  ZIP_CODE == '08101' |ZIP_CODE == '08102' |ZIP_CODE == '08103' |ZIP_CODE == '08104' |ZIP_CODE == '08105', 'y', 'n'
  )) %>% 
  select(everything(), -`Unique Number`)

# Match on member list
m5_zip <- m4_update_risk_score %>% left_join(z2, by = "memb_id")

# Export Claims and Members Files -----------------------------------------

write_csv(c_bin2, "y:/united_evaluation/united_claims.csv", na = "")
write_csv(m5_zip, "y:/united_evaluation/united_members.csv", na = "")

