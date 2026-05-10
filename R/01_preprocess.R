# =============================================================================
# Sansasyonel · EMU430 Data Analytics
# R/01_preprocess.R
#
# Kullanım:
#   1. RStudio'da proje kök klasörünü aç
#   2. Console'da: source("R/01_preprocess.R")
#
# Kaynaklar:
#   TÜİK 2024: https://data.tuik.gov.tr/Bulten/Index?p=Road-Traffic-Accident-Statistics-2024-54056
#   KGM  2024: https://www.kgm.gov.tr/SiteCollectionDocuments/KGMdocuments/Trafik/Trafik-kaza-ozetbilgi.pdf
#   EGM      : https://www.trafik.gov.tr/istatistikler37
# =============================================================================

library(readr)
library(dplyr)

cat("── Preprocessing başlıyor ──────────────────────────────\n")

read_raw <- function(f) {
  readr::read_csv(
    file.path("data", f),
    show_col_types = FALSE,
    locale         = locale(encoding = "UTF-8")
  )
}

# 1. Yıllık seri 2015–2024
annual <- read_raw("raw_annual_2015_2024.csv") |>
  mutate(
    fatal_injury_share  = fatal_injury_accidents / total_accidents,
    deaths_per_accident = deaths_total / fatal_injury_accidents
  )
cat("  ✓ annual          :", nrow(annual), "satır\n")

# 2. Kusur oranları 2015–2024
fault_pct <- read_raw("raw_fault_pct_2015_2024.csv")
cat("  ✓ fault_pct       :", nrow(fault_pct), "satır\n")

# 3. Araç türleri 2024
vehicles <- read_raw("raw_vehicle_type_2024.csv") |>
  mutate(deaths_per_1000_involved = 1000 * driver_deaths_total / vehicles_involved)
cat("  ✓ vehicles        :", nrow(vehicles), "satır\n")

# 4. Normalize edilmiş oranlar 2015–2024
rates <- read_raw("raw_rates_2015_2024.csv")
cat("  ✓ rates           :", nrow(rates), "satır\n")

# 5. Aylık dağılım 2024
monthly <- read_raw("raw_monthly_2024.csv") |>
  mutate(severity_index = deaths / accidents * 100)
cat("  ✓ monthly         :", nrow(monthly), "satır\n")

# 6. Haftanın günleri 2024
weekday <- read_raw("raw_dayofweek_2024.csv") |>
  mutate(severity_index = deaths / accidents * 100)
cat("  ✓ weekday         :", nrow(weekday), "satır\n")

# 7. Işık koşulları 2024
daylight <- read_raw("raw_daylight_2024.csv") |>
  mutate(severity_index = deaths / accidents * 100)
cat("  ✓ daylight        :", nrow(daylight), "satır\n")

# 8. Sürücü kusur türleri 2024
driver_faults <- read_raw("raw_driver_faults_2024.csv")
cat("  ✓ driver_faults   :", nrow(driver_faults), "satır\n")

# 9. Kaza oluşum türleri 2024
accident_types <- read_raw("raw_accident_type_2024.csv") |>
  mutate(
    fatality_rate_pct        = deaths  / accidents * 100,
    injury_rate_per_accident = injured / accidents
  )
cat("  ✓ accident_types  :", nrow(accident_types), "satır\n")

# 10. AB ülkeleri karşılaştırması 2024
eu_comparison <- read_raw("raw_eu_comparison_2024.csv")
cat("  ✓ eu_comparison   :", nrow(eu_comparison), "satır\n")

# 11. Yerleşim yeri / dışı 2024
settlement <- read_raw("raw_settlement_2024.csv") |>
  mutate(deaths_per_1000_accidents = 1000 * deaths_total / fatal_injury_accidents)
cat("  ✓ settlement      :", nrow(settlement), "satır\n")

# Kaydet
save(
  annual, fault_pct, vehicles, rates,
  monthly, weekday, daylight,
  driver_faults, accident_types, eu_comparison, settlement,
  file = "data/traffic_accidents_tr.RData"
)

cat("\n✅ Kaydedildi → data/traffic_accidents_tr.RData\n")
