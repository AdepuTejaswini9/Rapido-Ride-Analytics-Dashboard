-- ============================================================
-- 02_data_cleaning.sql
-- Rapido Ride Analytics Dashboard — SQL-side Data Validation
--
-- NOTE: The primary cleaning pass (renaming columns, dropping the
-- pre-aggregated daily columns, standardizing categories, feature
-- engineering) was done in Python/Pandas in Google Colab before
-- these CSVs were exported. This file contains SQL-side validation
-- checks run AFTER loading into Postgres, to confirm the loaded
-- data is consistent and catch anything the Python pass missed.
-- ============================================================

-- 1. Check for duplicate booking_id (should return 0 rows)
SELECT booking_id, COUNT(*) 
FROM fact_bookings
GROUP BY booking_id
HAVING COUNT(*) > 1;


-- 2. Null audit — confirm nulls only exist where expected
-- (incomplete_rides_reason should be the only column with meaningful nulls,
--  and only for rows where booking_status = 'Incomplete')
SELECT
    COUNT(*) FILTER (WHERE booking_id IS NULL) AS null_booking_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE driver_id IS NULL) AS null_driver_id,
    COUNT(*) FILTER (WHERE booking_value IS NULL) AS null_booking_value,
    COUNT(*) FILTER (WHERE incomplete_rides_reason IS NULL AND booking_status = 'Incomplete') AS unexpected_null_reason
FROM fact_bookings;


-- 3. Business rule check — cancel_side should only be set when
--    booking_status = 'Cancelled', and should be null/None otherwise
SELECT booking_status, cancel_side, COUNT(*) AS row_count
FROM fact_bookings
GROUP BY booking_status, cancel_side
ORDER BY booking_status;


-- 4. Range validation — ride_distance and ride_time should never be negative
SELECT COUNT(*) AS invalid_distance_or_time
FROM fact_bookings
WHERE ride_distance < 0 OR ride_time < 0;


-- 5. Rating range validation — ratings should fall within 1-5
SELECT COUNT(*) AS out_of_range_ratings
FROM fact_bookings
WHERE (driver_rating IS NOT NULL AND (driver_rating < 1 OR driver_rating > 5))
   OR (customer_rating IS NOT NULL AND (customer_rating < 1 OR customer_rating > 5));


-- 6. Referential integrity check — every customer_id/driver_id in
--    fact_bookings should exist in its dimension table (should return 0 rows)
SELECT DISTINCT f.customer_id
FROM fact_bookings f
LEFT JOIN dim_customers c ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT DISTINCT f.driver_id
FROM fact_bookings f
LEFT JOIN dim_drivers d ON f.driver_id = d.driver_id
WHERE d.driver_id IS NULL;


-- 7. Row count reconciliation — confirm dim_customers/dim_drivers
--    total_rides columns match actual counts in fact_bookings
SELECT 
    c.customer_id, 
    c.total_rides AS dim_total, 
    COUNT(f.booking_id) AS actual_total
FROM dim_customers c
JOIN fact_bookings f ON c.customer_id = f.customer_id
GROUP BY c.customer_id, c.total_rides
HAVING c.total_rides <> COUNT(f.booking_id)
LIMIT 20;   -- any rows returned here indicate a mismatch worth investigating


-- 8. Fare-distance correlation check — documented known limitation,
--    re-verify directly in SQL (expect a value close to 0)
SELECT CORR(booking_value, ride_distance) AS fare_distance_correlation
FROM fact_bookings
WHERE booking_status = 'Completed';
