# =============================================================================
# Sansasyonel · EMU430 Data Analytics
# R/01_preprocess.R  —  Konut Piyasası Projesi
#
# Kullanım:
#   setwd("sansasyonel/")
#   source("R/01_preprocess.R")
#
# Kaynaklar:
#   [1] TCMB KFE: https://www.tcmb.gov.tr (Konut Fiyat Endeksi, aylık)
#   [2] TCMB EVDS (CPI, Kur): https://evds2.tcmb.gov.tr
#   [3] TÜİK Konut İstatistikleri: https://data.tuik.gov.tr/Kategori/GetKategori?p=insaat-ve-konut-116
# =============================================================================

library(readr)
library(dplyr)

cat("── Preprocessing başlıyor ──────────────────────────────\n")

read_raw <- function(f) {
  readr::read_csv(file.path("data", f),
                  show_col_types = FALSE,
                  locale = locale(encoding = "UTF-8"))
}

# ── 1. Yıllık KFE + makro seri 2010–2024 ─────────────────────────────────────
kfe_annual <- read_raw("raw_kfe_annual.csv") |>
  mutate(
    # Nominal KFE değişimi (yıllık %)
    kfe_nominal_yoy = (kfe_nominal / lag(kfe_nominal) - 1) * 100,
    # Reel KFE değişimi (yıllık %)
    kfe_real_yoy    = (kfe_real    / lag(kfe_real)    - 1) * 100,
    # CPI değişimi (yıllık %)
    cpi_yoy         = (cpi_index   / lag(cpi_index)   - 1) * 100,
    # Kümülatif kazanç 2010=1
    kfe_cumulative  = kfe_nominal / 100,
    # Reel endeksi normalize (2010=100)
    kfe_real_norm   = kfe_real
  )
cat("  ✓ kfe_annual       :", nrow(kfe_annual), "satır\n")

# ── 2. Bölgesel KFE (NUTS-1) ─────────────────────────────────────────────────
regional_kfe <- read_raw("raw_regional_kfe.csv") |>
  # Bölgeye göre ortalama yıllık değişim (2020-2024 ortalaması)
  mutate(
    avg_annual_pct = (kfe_2020_pct + kfe_2021_pct + kfe_2022_pct +
                      kfe_2023_pct + kfe_2024_pct) / 5,
    # 2021 kümülatif nominal (2020 bazlı yaklaşık)
    cumulative_2020_2024 = (1 + kfe_2020_pct/100) *
                           (1 + kfe_2021_pct/100) *
                           (1 + kfe_2022_pct/100) *
                           (1 + kfe_2023_pct/100) *
                           (1 + kfe_2024_pct/100) - 1
  ) |>
  mutate(cumulative_2020_2024_pct = cumulative_2020_2024 * 100)
cat("  ✓ regional_kfe     :", nrow(regional_kfe), "satır\n")

# ── 3. Konut erişilebilirliği ─────────────────────────────────────────────────
affordability <- read_raw("raw_affordability.csv") |>
  mutate(
    # Ortalama bir 100 m² konut almak için gereken asgari ücret miktarı (ay)
    months_100m2 = affordability_months,
    # USD cinsinden m² fiyatı
    m2_usd = avg_m2_price_usd
  )
cat("  ✓ affordability    :", nrow(affordability), "satır\n")

# ── 4. Kur–Konut ilişkisi (çeyreklik) ────────────────────────────────────────
exchange_housing <- read_raw("raw_exchange_housing.csv") |>
  mutate(
    period     = paste0(year, " ", quarter),
    real_premium = kfe_yoy_pct - cpi_yoy_pct   # reel fiyat değişimi
  )
cat("  ✓ exchange_housing :", nrow(exchange_housing), "satır\n")

# ── 5. Satışlar ve yapı ruhsatları ───────────────────────────────────────────
sales_permits <- read_raw("raw_sales_permits.csv") |>
  mutate(
    second_hand_share = sales_second_hand / sales_total * 100,
    mortgage_share    = sales_mortgage    / sales_total * 100
  )
cat("  ✓ sales_permits    :", nrow(sales_permits), "satır\n")

# ── Kaydet ───────────────────────────────────────────────────────────────────
save(kfe_annual, regional_kfe, affordability,
     exchange_housing, sales_permits,
     file = "data/housing_market_tr.RData")

cat("\n✅ Kaydedildi → data/housing_market_tr.RData\n")
cat("   Objeler: kfe_annual, regional_kfe, affordability,\n")
cat("            exchange_housing, sales_permits\n")
