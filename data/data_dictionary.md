# Data Dictionary — Rapido Ride Analytics Dashboard

Documents the **cleaned, final schema** used across SQL, Excel, and Power BI. This reflects the data *after* cleaning and star-schema normalization in Colab — not the original raw source file (see `SOURCE.md` for that).

---

## fact_bookings
One row per ride booking.

| Column | Type | Description |
|---|---|---|
| booking_id | string, PK | Unique ride identifier (format `RAP20250700001`) |
| customer_id | string, FK | Links to `dim_customers` |
| driver_id | string, FK | Links to `dim_drivers` |
| vehicle_type | string | Bike / Auto (Rapido's actual core services) |
| pickup_location | string | One of 5 zones |
| drop_location | string | One of 5 zones |
| payment_method | string | UPI / Wallet / Cash / Card |
| date | date | Links to `dim_date`. Full month, July 1–31, 2025 |
| booking_status | string | Completed / Cancelled / Incomplete |
| booking_value | float | Fare charged (₹30–₹250 range) — note: not distance-correlated (r ≈ 0.006), a known dataset limitation, not a real business insight |
| ride_distance | float | Distance covered (km) |
| ride_time | float | Trip duration (minutes) |
| customer_rating | float | Driver's rating of the customer |
| driver_rating | float | Customer's rating of the driver |
| v_tat | int | Vehicle turnaround time (minutes) — time for driver to reach pickup |
| c_tat | int | Customer turnaround time (minutes) — ride duration once picked up |
| cancel_side | string | `Customer` / `Driver` / `None` — derived column indicating who cancelled, replacing the raw source's two separate binary flags |
| incomplete_rides_reason | string | Network issue / Customer cancelled early / Driver delayed / Customer not found / Weather issue — null when status ≠ Incomplete |

**Dropped from the original source file during cleaning:** `Total_Bookings`, `Canceled_Bookings`, `Canceled_Percentage` (were daily aggregates repeated per row, not true row-level facts — removed to keep the fact table properly normalized) and `Vehicle_Image` (cosmetic asset filename, not needed for analysis).

## dim_customers
One row per unique customer (8,676 rows).

| Column | Type | Description |
|---|---|---|
| customer_id | string, PK | Unique customer identifier |
| total_rides | int | Total rides taken by this customer — genuine repeat-ride signal, avg ~3.5 rides/customer |
| avg_rating_given | float | Average rating this customer gave to drivers |

## dim_drivers
One row per unique driver (900 rows).

| Column | Type | Description |
|---|---|---|
| driver_id | string, PK | Unique driver identifier |
| total_rides | int | Total rides completed by this driver — up to 55 for the busiest driver, supports real utilization analysis |
| avg_rating | float | Average rating this driver received from customers |
| cancel_rate | float | Share of this driver's rides that were driver-cancelled |

## dim_date
One row per calendar date in the dataset (31 rows).

| Column | Type | Description |
|---|---|---|
| date | date, PK | Calendar date |
| day_of_week | string | Monday–Sunday |
| is_weekend | boolean | True for Saturday/Sunday |
| week_of_month | int | Which week of July (1–5) |

## dim_location
Unique pickup/drop zone reference (26 rows).

| Column | Type | Description |
|---|---|---|
| pickup_location | string | Zone name |
| drop_location | string | Zone name |
| zone_pair | string | Combined "pickup → drop" label |

*Note: `dim_location` is not formally joined to `fact_bookings` in the data model — pickup/drop are used directly from `fact_bookings` for zone analysis instead, since `dim_location` holds pairs rather than a clean single join key.*

---

## Scope notes
- Full month, single-city-tier dataset (no `city` column — all 5 zones are within one operating area)
- No monthly/quarterly trend analysis is reported — only 31 days of data exists
- `booking_value` does not correlate with `ride_distance` in this dataset (verified, r ≈ 0.006) — treated as a known synthetic-data limitation, not a business finding
