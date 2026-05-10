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

rd <- function(f) {
  readr::read_csv(
    file.path("data", f),
    show_col_types = FALSE,
    locale         = locale(encoding = "UTF-8")
  )
}

monthly_data <- rd("raw_monthly_kfe_cpi_usdtry.csv")
cat("  OK monthly_data  :", nrow(monthly_data), "rows\n")

annual_macro <- rd("raw_annual_macro.csv") |>
  mutate(
    kfe_nominal_yoy = (kfe_nominal_2010base / lag(kfe_nominal_2010base) - 1) * 100,
    kfe_real_yoy    = (kfe_real_2010base    / lag(kfe_real_2010base)    - 1) * 100
  )
cat("  OK annual_macro  :", nrow(annual_macro), "rows\n")

regional_nuts2 <- rd("raw_regional_nuts2.csv") |>
  mutate(
    cum_2020_2024_pct =
      ((1 + kfe_2020_yoy_pct/100) *
       (1 + kfe_2021_yoy_pct/100) *
       (1 + kfe_2022_yoy_pct/100) *
       (1 + kfe_2023_yoy_pct/100) *
       (1 + kfe_2024_yoy_pct/100) - 1) * 100
  )
cat("  OK regional_nuts2:", nrow(regional_nuts2), "rows\n")

city_monthly  <- rd("raw_city_kfe_monthly.csv")
affordability <- rd("raw_affordability_annual.csv")
quarterly_fx  <- rd("raw_quarterly_kfe_fx.csv")
housing_sales <- rd("raw_housing_sales_annual.csv")
permits       <- rd("raw_building_permits_annual.csv")
minwage       <- rd("raw_minimum_wage_history.csv")
kfe_new_exist <- rd("raw_kfe_new_vs_existing.csv")

cat("  OK city_monthly  :", nrow(city_monthly), "rows\n")
cat("  OK affordability :", nrow(affordability), "rows\n")
cat("  OK quarterly_fx  :", nrow(quarterly_fx), "rows\n")
cat("  OK housing_sales :", nrow(housing_sales), "rows\n")
cat("  OK permits       :", nrow(permits), "rows\n")
cat("  OK minwage       :", nrow(minwage), "rows\n")
cat("  OK kfe_new_exist :", nrow(kfe_new_exist), "rows\n")

save(monthly_data, annual_macro, regional_nuts2, city_monthly,
     affordability, quarterly_fx, housing_sales, permits,
     minwage, kfe_new_exist,
     file = "data/housing_market_tr.RData")

cat("\nSaved: data/housing_market_tr.RData (10 objects)\n")
