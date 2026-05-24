# =============================================================================
# Purpose: Parse Neptune Apex XML datalogs into a per-tank temperature time
#          series and visualize the heat ramp + steady-state period.
#          Apex datalogs record one <record> per probe poll (~ every minute);
#          probes include `Tmp` (head temperature), `pH`, `ORP`, plus per-tank
#          Watts outlets. We extract Tmp by tank where tank identifiers are
#          encoded in probe names (`tnk3_T`, `tnk4_T`, etc.).
# Input:   data/raw/apex/datalog*.xml
# Output:  data/processed/apex_temperature.rds
#          figures/08_apex_temperature.{pdf,png}
# =============================================================================

source(here::here("code", "00_setup.R"))
suppressPackageStartupMessages(library(xml2))

xml_files <- list.files(file.path(DATA_RAW, "apex"),
                        pattern = "\\.xml$", full.names = TRUE)
stopifnot(length(xml_files) > 0)

# Parse one Apex file into a long tibble of (datetime, probe_name, value)
parse_apex <- function(path) {
  doc <- read_xml(path)
  records <- xml_find_all(doc, "//record")
  out <- map_dfr(records, function(rec) {
    dt_text <- xml_text(xml_find_first(rec, "./date"))
    dt <- suppressWarnings(mdy_hms(dt_text, tz = "Pacific/Tahiti"))
    probes <- xml_find_all(rec, "./probe")
    tibble(
      datetime = dt,
      probe    = xml_text(xml_find_first(probes, "./name")),
      value    = as.numeric(xml_text(xml_find_first(probes, "./value")))
    )
  })
  out |> filter(!is.na(datetime))
}

# This is slow on the big logs; only re-parse if processed cache is missing.
cache <- file.path(DATA_PROC, "apex_temperature.rds")
if (!file.exists(cache)) {
  message("Parsing ", length(xml_files), " Apex XML files (slow, one-time)…")
  all_records <- map_dfr(xml_files, parse_apex, .id = "file_idx")
  saveRDS(all_records, cache)
} else {
  all_records <- readRDS(cache)
  message("Loaded cached Apex parse from ", cache)
}

# Keep only temperature-like probes
temp_records <- all_records |>
  filter(str_detect(probe, regex("Tmp|Temp|_T$|tnk\\d_T", ignore_case = TRUE)),
         value > 15, value < 40) |>
  mutate(
    probe = str_squish(probe),
    # Encode tank from probe name where pattern is informative
    tank = case_when(
      str_detect(probe, regex("tnk(\\d+)", ignore_case = TRUE)) ~
        as.integer(str_match(probe, "tnk(\\d+)")[, 2]),
      probe == "Tmp" ~ NA_integer_,
      TRUE ~ NA_integer_
    ),
    treatment = case_when(
      tank %in% c(3, 6, 9, 12) ~ "28C",
      tank %in% c(4, 5, 10, 11) ~ "31C",
      TRUE ~ NA_character_
    )
  )

# Daily mean per tank (if tank info is available); else daily mean overall
if (any(!is.na(temp_records$tank))) {
  daily <- temp_records |>
    filter(!is.na(tank)) |>
    mutate(date = as_date(datetime)) |>
    group_by(date, tank, treatment) |>
    summarise(temp_mean = mean(value, na.rm = TRUE),
              temp_sd   = sd(value,   na.rm = TRUE),
              .groups = "drop")
  p_apex <- ggplot(daily, aes(date, temp_mean, group = tank,
                              colour = treatment)) +
    geom_line(linewidth = 0.4, alpha = 0.85) +
    geom_point(size = 0.9) +
    scale_colour_manual(values = c(`28C` = "#56B4E9", `31C` = "#D55E00"),
                        name = "Treatment") +
    labs(x = NULL, y = "Daily mean tank T (°C)",
         title = "Apex tank temperatures",
         subtitle = "One line per tank; ramp visible early June 2025") +
    theme_pub(10)
} else {
  # Fall back to head-of-system Tmp only
  daily <- temp_records |>
    mutate(date = as_date(datetime)) |>
    group_by(date) |>
    summarise(temp_mean = mean(value, na.rm = TRUE),
              temp_sd   = sd(value,   na.rm = TRUE),
              .groups = "drop")
  p_apex <- ggplot(daily, aes(date, temp_mean)) +
    geom_ribbon(aes(ymin = temp_mean - temp_sd, ymax = temp_mean + temp_sd),
                alpha = 0.2, fill = "#56B4E9") +
    geom_line(linewidth = 0.5, colour = "#0072B2") +
    geom_point(size = 1.2) +
    labs(x = NULL, y = "Daily mean head T (°C)",
         title = "Apex datalog (head temperature)",
         subtitle = "Per-tank probes not encoded in this datalog; head sensor only") +
    theme_pub(10)
}

save_fig(p_apex, "08_apex_temperature", width = 170, height = 95)

cat("Wrote apex_temperature.rds (n=", nrow(all_records),
    " records) and 08_apex_temperature.{pdf,png}\n", sep = "")
