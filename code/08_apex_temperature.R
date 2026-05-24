# =============================================================================
# Purpose: Parse Neptune Apex XML datalogs into a per-tank temperature time
#          series and visualize the heat ramp + steady-state period.
#          Apex logs are large (one <record> per probe poll); we stream-parse
#          file-by-file, aggregate to hourly means inside each file, and
#          discard raw records before moving on. This keeps memory bounded.
# Input:   data/raw/apex/datalog*.xml
# Output:  data/processed/apex_temperature.rds  (hourly per probe)
#          data/processed/apex_temperature_daily.rds (daily per probe)
#          figures/08_apex_temperature.{pdf,png}
# =============================================================================

source(here::here("code", "00_setup.R"))
suppressPackageStartupMessages(library(xml2))

xml_files <- list.files(file.path(DATA_RAW, "apex"),
                        pattern = "\\.xml$", full.names = TRUE)
stopifnot(length(xml_files) > 0)

# Stream-parse one Apex file → hourly mean per probe.
# Returns tibble(datetime [hour], probe, value_mean, value_sd, n).
parse_apex_hourly <- function(path) {
  message("Parsing ", basename(path), " (", round(file.size(path) / 1e6, 1), " MB)")
  doc <- tryCatch(
    read_xml(path, options = c("RECOVER", "NOWARNING", "NOERROR")),
    error = function(e) NULL
  )
  if (is.null(doc)) return(tibble())

  records <- xml_find_all(doc, "//record")
  if (length(records) == 0) return(tibble())

  # Extract record dates en masse
  dates_text <- xml_text(xml_find_first(records, "./date"))
  dates <- suppressWarnings(mdy_hms(dates_text, tz = "Pacific/Tahiti"))

  # For each record extract probe name+value vectors; collapse to one row per
  # (record, probe).
  out_list <- vector("list", length(records))
  for (i in seq_along(records)) {
    if (is.na(dates[i])) next
    probes <- xml_find_all(records[[i]], "./probe")
    if (length(probes) == 0) next
    nms <- xml_text(xml_find_first(probes, "./name"))
    vals <- suppressWarnings(as.numeric(xml_text(xml_find_first(probes, "./value"))))
    out_list[[i]] <- tibble(datetime = dates[i], probe = nms, value = vals)
  }

  records <- NULL; doc <- NULL; gc()

  bind_rows(out_list) |>
    filter(!is.na(value)) |>
    mutate(hour = lubridate::floor_date(datetime, "hour")) |>
    group_by(hour, probe) |>
    summarise(value_mean = mean(value, na.rm = TRUE),
              value_sd   = sd(value, na.rm = TRUE),
              n          = n(),
              .groups = "drop") |>
    rename(datetime = hour)
}

hourly <- map_dfr(xml_files, parse_apex_hourly)
saveRDS(hourly, file.path(DATA_PROC, "apex_temperature.rds"))

# ---- Daily aggregation for plotting ---------------------------------------
daily <- hourly |>
  mutate(date = as_date(datetime),
         probe = str_squish(probe)) |>
  group_by(date, probe) |>
  summarise(value_mean = mean(value_mean, na.rm = TRUE),
            value_sd   = mean(value_sd, na.rm = TRUE),
            .groups = "drop")
saveRDS(daily, file.path(DATA_PROC, "apex_temperature_daily.rds"))

# ---- Filter to temperature-like probes ------------------------------------
# Apex names tank temperatures as `Temp1`–`Temp12` (one per outlet/tank).
# Values are in degrees F (Apex US default) when > 60; convert to C.
temp_daily <- daily |>
  filter(str_detect(probe, "^Temp\\d+$"),
         is.finite(value_mean), value_mean > 0) |>
  mutate(
    tank = as.integer(str_extract(probe, "\\d+")),
    # Convert F to C if reading looks Fahrenheit (Apex US firmware)
    value_c = if_else(value_mean > 60, (value_mean - 32) * 5 / 9, value_mean),
    treatment = case_when(
      tank %in% c(3, 6, 9, 12)  ~ "28C",
      tank %in% c(4, 5, 10, 11) ~ "31C",
      TRUE ~ NA_character_
    )
  ) |>
  filter(!is.na(treatment), value_c > 15, value_c < 40)

# ---- Plot ------------------------------------------------------------------
# Restrict to the experimental window for cleanest display
exp_window <- as_date(c("2025-05-25", "2025-06-25"))
d_plot <- temp_daily |>
  filter(between(date, exp_window[1], exp_window[2]))

p_apex <- ggplot(d_plot, aes(date, value_c, group = tank,
                              colour = treatment)) +
  geom_hline(yintercept = c(28, 31), linetype = "dashed",
             colour = "grey60", linewidth = 0.3) +
  geom_line(linewidth = 0.4, alpha = 0.85) +
  geom_point(size = 1.0, alpha = 0.75) +
  geom_text(data = data.frame(date = exp_window[2], y = c(28, 31),
                              lab = c("28 °C target", "31 °C target")),
            aes(x = date, y = y, label = lab),
            inherit.aes = FALSE, hjust = 1.1, vjust = -0.4,
            size = 2.6, colour = "grey40") +
  scale_colour_manual(values = c(`28C` = "#56B4E9", `31C` = "#D55E00"),
                      name = "Treatment") +
  scale_x_date(date_breaks = "5 days", date_labels = "%b %d") +
  labs(x = NULL, y = "Daily mean tank T (°C)",
       title = "Apex tank temperatures across the experimental window",
       subtitle = "One line per tank; heat ramp begins late May, sustained 31 °C through experiment") +
  theme_pub(10)

save_fig(p_apex, "08_apex_temperature", width = 170, height = 100)

# Companion: full-period view including ramps and cooldowns
p_full <- ggplot(temp_daily, aes(date, value_c, group = tank,
                                  colour = treatment)) +
  geom_hline(yintercept = c(28, 31), linetype = "dashed",
             colour = "grey60", linewidth = 0.3) +
  geom_line(linewidth = 0.3, alpha = 0.75) +
  scale_colour_manual(values = c(`28C` = "#56B4E9", `31C` = "#D55E00"),
                      name = "Treatment") +
  labs(x = NULL, y = "Daily mean tank T (°C)",
       title = "Apex tank temperatures — full datalog period",
       subtitle = "Tanks 3, 6, 9, 12 = 28 °C; tanks 4, 5, 10, 11 = 31 °C") +
  theme_pub(10)
save_fig(p_full, "08b_apex_temperature_full", width = 200, height = 100)

cat("\nProbes detected (top 20 by record count):\n")
hourly |> count(probe, sort = TRUE) |> head(20) |> print()

cat("\nWrote apex_temperature.rds (", nrow(hourly), " hourly records),",
    " apex_temperature_daily.rds (", nrow(daily), "),",
    " 08_apex_temperature.{pdf,png}\n", sep = "")
