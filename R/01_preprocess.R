# =============================================================================
# Sansasyonel - EMU430 Data Analytics
# R/01_preprocess.R  --  Housing Market Project
#
# Usage:
#   setwd("sansasyonel/")
#   source("R/01_preprocess.R")
#
# Sources:
#   [1] TCMB KFE: https://www.tcmb.gov.tr
#   [2] TCMB EVDS (CPI, FX): https://evds2.tcmb.gov.tr
#   [3] TUIK: https://data.tuik.gov.tr/Kategori/GetKategori?p=insaat-ve-konut-116
# =============================================================================

library(readr)
library(dplyr)

cat("-- Preprocessing starting --\n")

read_raw <- function(f) {
  readr::read_csv(
    file.path("data", f),
    show_col_types = FALSE,
    locale         = locale(encoding = "UTF-8")
  )
}

# 1. Annual KFE + macro series 2010-2024
kfe_annual <- read_raw("raw_kfe_annual.csv") |>
  mutate(
    kfe_nominal_yoy = (kfe_nominal / lag(kfe_nominal) - 1) * 100,
    kfe_real_yoy    = (kfe_real    / lag(kfe_real)    - 1) * 100,
    cpi_yoy         = (cpi_index   / lag(cpi_index)   - 1) * 100,
    kfe_cumulative  = kfe_nominal / 100,
    kfe_real_norm   = kfe_real
  )
cat("  OK kfe_annual       :", nrow(kfe_annual), "rows\n")

# 2. Regional KFE (NUTS-1)
regional_kfe <- read_raw("raw_regional_kfe.csv") |>
  mutate(
    avg_annual_pct = (kfe_2020_pct + kfe_2021_pct + kfe_2022_pct +
                      kfe_2023_pct + kfe_2024_pct) / 5,
    cumulative_2020_2024 =
      (1 + kfe_2020_pct/100) *
      (1 + kfe_2021_pct/100) *
      (1 + kfe_2022_pct/100) *
      (1 + kfe_2023_pct/100) *
      (1 + kfe_2024_pct/100) - 1,
    cumulative_2020_2024_pct = cumulative_2020_2024 * 100
  )
cat("  OK regional_kfe     :", nrow(regional_kfe), "rows\n")

# 3. Affordability
affordability <- read_raw("raw_affordability.csv") |>
  mutate(
    months_100m2 = affordability_months,
    m2_usd       = avg_m2_price_usd
  )
cat("  OK affordability    :", nrow(affordability), "rows\n")

# 4. Exchange rate vs. housing (quarterly)
exchange_housing <- read_raw("raw_exchange_housing.csv") |>
  mutate(
    period       = paste0(year, " ", quarter),
    real_premium = kfe_yoy_pct - cpi_yoy_pct
  )
cat("  OK exchange_housing :", nrow(exchange_housing), "rows\n")

# 5. Sales and permits
sales_permits <- read_raw("raw_sales_permits.csv") |>
  mutate(
    second_hand_share = sales_second_hand / sales_total * 100,
    mortgage_share    = sales_mortgage    / sales_total * 100
  )
cat("  OK sales_permits    :", nrow(sales_permits), "rows\n")

# Save
save(kfe_annual, regional_kfe, affordability,
     exchange_housing, sales_permits,
     file = "data/housing_market_tr.RData")

cat("\nSaved: data/housing_market_tr.RData\n")
