# Data Source

## Dataset
`rapido_july2025_data.csv`

## Source
[RAPIDO_DATA_2025](https://www.kaggle.com/datasets/vengateshvengat/rapido-all-data) — Kaggle, uploaded by vengateshvengat

## Coverage
- 30,000 ride booking records
- Full month: July 1–31, 2025
- Single operating area, 5 pickup/drop zones (Bengaluru, Chennai, Delhi, Hyderabad, Pune)
- 8,676 unique customers, 900 unique drivers
- Vehicle types: Bike, Auto (Rapido's actual core service lines)

## Nature of the data
This is a **synthetic dataset created for analytics practice** — it is not official Rapido production data, and Rapido does not publicly release ride-level operational data. The dataset was selected after evaluating three candidate sources (see project history/README for the full comparison) because it was the only one that:
- Used genuinely Rapido-branded identifiers (`Booking_ID` format `RAP20250700001`, vehicle asset filenames like `rapido_bike.png`)
- Used Rapido's actual service categories (Bike/Auto) rather than a competitor's product lineup
- Included both customer-level and driver-level identifiers, enabling retention, segmentation, and driver-performance analysis that the other candidate datasets could not support

## Known limitations
- **Single month of data.** No month-over-month or quarterly trend analysis is included in this project — the dataset doesn't span multiple months, so those comparisons would be fabricated. Day-of-week and day-of-month patterns are used instead, which the data genuinely supports.
- **Fare does not correlate with distance.** Verified directly (`booking_value` vs `ride_distance`, r ≈ 0.006). This dashboard does not report "longer rides cost more" as a finding, since it isn't true in this data.
- **Only 5 pickup/drop zones.** Location analysis in this project is zone-level, not granular address/route-level.

## Processing
Raw data was cleaned and normalized into a star schema (1 fact table + 4 dimension tables) using Python/Pandas in Google Colab. See `data_dictionary.md` for the final schema and a full list of columns dropped or renamed during cleaning.
