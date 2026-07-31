-- ============================================================
-- 01_create_tables.sql
-- Rapido Ride Analytics Dashboard — Schema Definition
-- Star schema: fact_bookings + 4 dimension tables
-- Run this first, before loading any data.
-- ============================================================

-- Dimension tables first (referenced by foreign keys in fact_bookings)

CREATE TABLE dim_date (
    date DATE PRIMARY KEY,
    day_of_week VARCHAR(10),
    is_weekend BOOLEAN,
    week_of_month INT
);

CREATE TABLE dim_customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    total_rides INT,
    avg_rating_given NUMERIC(3,2)
);

CREATE TABLE dim_drivers (
    driver_id VARCHAR(20) PRIMARY KEY,
    total_rides INT,
    avg_rating NUMERIC(3,2),
    cancel_rate NUMERIC(5,4)
);

CREATE TABLE dim_location (
    pickup_location VARCHAR(50),
    drop_location VARCHAR(50),
    zone_pair VARCHAR(120)
);

-- Fact table — one row per ride booking

CREATE TABLE fact_bookings (
    booking_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) REFERENCES dim_customers(customer_id),
    driver_id VARCHAR(20) REFERENCES dim_drivers(driver_id),
    vehicle_type VARCHAR(10),
    pickup_location VARCHAR(50),
    drop_location VARCHAR(50),
    payment_method VARCHAR(10),
    date DATE REFERENCES dim_date(date),
    hour INT,
    booking_status VARCHAR(15),
    booking_value NUMERIC(8,2),
    ride_distance NUMERIC(6,2),
    ride_time NUMERIC(6,2),
    customer_rating NUMERIC(3,2),
    driver_rating NUMERIC(3,2),
    v_tat INT,
    c_tat INT,
    cancel_side VARCHAR(10),
    incomplete_rides_reason VARCHAR(50)
);

-- ============================================================
-- Load order once tables exist (via Supabase Table Editor CSV import,
-- or psql \copy):
--   1. dim_customers
--   2. dim_drivers
--   3. dim_date
--   4. dim_location
--   5. fact_bookings   (must be last — references the other 4 via FK)
-- ============================================================

-- Post-load verification
-- SELECT COUNT(*) FROM fact_bookings;     -- expect 30000
-- SELECT COUNT(*) FROM dim_customers;     -- expect 8676
-- SELECT COUNT(*) FROM dim_drivers;       -- expect 900
-- SELECT COUNT(*) FROM dim_date;          -- expect 31
-- SELECT COUNT(*) FROM dim_location;      -- expect 26
