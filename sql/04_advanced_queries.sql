-- ============================================================
-- 04_advanced_queries.sql
-- Rapido Ride Analytics Dashboard — Advanced Queries
-- Schema: fact_bookings, dim_customers, dim_drivers, dim_date, dim_location
-- ============================================================


-- 16. Rank drivers by ride count WITHIN each vehicle type
WITH driver_vehicle_rides AS (
    SELECT
        driver_id,
        vehicle_type,
        COUNT(*) AS total_rides
    FROM fact_bookings
    GROUP BY driver_id, vehicle_type
)
SELECT
    driver_id,
    vehicle_type,
    total_rides,
    RANK() OVER (PARTITION BY vehicle_type ORDER BY total_rides DESC) AS rank_in_vehicle_type
FROM driver_vehicle_rides
ORDER BY vehicle_type, rank_in_vehicle_type
LIMIT 30;


-- 17. CTE-based chain: raw → cleaned → aggregated (cancellation attribution by zone)
WITH base AS (
    SELECT
        pickup_location,
        booking_status,
        cancel_side,
        booking_value
    FROM fact_bookings
),
zone_summary AS (
    SELECT
        pickup_location,
        COUNT(*) AS total_rides,
        COUNT(*) FILTER (WHERE cancel_side = 'Customer') AS customer_cancels,
        COUNT(*) FILTER (WHERE cancel_side = 'Driver') AS driver_cancels,
        SUM(booking_value) FILTER (WHERE booking_status = 'Cancelled') AS lost_revenue
    FROM base
    GROUP BY pickup_location
)
SELECT
    pickup_location,
    total_rides,
    customer_cancels,
    driver_cancels,
    ROUND(100.0 * customer_cancels / total_rides, 2) AS pct_customer_cancel,
    ROUND(100.0 * driver_cancels / total_rides, 2) AS pct_driver_cancel,
    lost_revenue
FROM zone_summary
ORDER BY lost_revenue DESC;


-- 18. Cancellation attribution: Customer-side vs Driver-side vs Incomplete-reason, overall
SELECT
    CASE
        WHEN booking_status = 'Cancelled' AND cancel_side = 'Customer' THEN 'Cancelled - Customer'
        WHEN booking_status = 'Cancelled' AND cancel_side = 'Driver' THEN 'Cancelled - Driver'
        WHEN booking_status = 'Incomplete' THEN COALESCE(incomplete_rides_reason, 'Incomplete - Unspecified')
        ELSE booking_status
    END AS outcome_category,
    COUNT(*) AS ride_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_all_rides
FROM fact_bookings
GROUP BY outcome_category
ORDER BY ride_count DESC;


-- 19. Data validation: does your own daily rollup make sense with dim_date?
-- (Original Total_Bookings/Canceled_Percentage columns were dropped as row-level fields;
--  this recomputes the same thing directly from fact_bookings + dim_date as the source of truth.)
SELECT
    d.date,
    d.day_of_week,
    COUNT(f.booking_id) AS total_bookings,
    COUNT(*) FILTER (WHERE f.booking_status = 'Cancelled') AS cancelled_bookings,
    ROUND(100.0 * COUNT(*) FILTER (WHERE f.booking_status = 'Cancelled') / COUNT(f.booking_id), 2) AS cancel_pct
FROM fact_bookings f
JOIN dim_date d ON f.date = d.date
GROUP BY d.date, d.day_of_week
ORDER BY d.date;


-- 20. Driver rating trend across the month (identify "at-risk" drivers whose rating is declining)
-- Requires window function comparing early-month vs late-month average per driver
WITH driver_period AS (
    SELECT
        driver_id,
        CASE WHEN date <= (SELECT MIN(date) + INTERVAL '15 days' FROM fact_bookings) THEN 'first_half' ELSE 'second_half' END AS period,
        driver_rating
    FROM fact_bookings
)
SELECT
    driver_id,
    ROUND(AVG(driver_rating) FILTER (WHERE period = 'first_half'), 2) AS avg_rating_first_half,
    ROUND(AVG(driver_rating) FILTER (WHERE period = 'second_half'), 2) AS avg_rating_second_half,
    ROUND(
        AVG(driver_rating) FILTER (WHERE period = 'second_half') -
        AVG(driver_rating) FILTER (WHERE period = 'first_half'), 2
    ) AS rating_change
FROM driver_period
GROUP BY driver_id
HAVING COUNT(*) > 4   -- only drivers with enough rides to trust the trend
ORDER BY rating_change ASC
LIMIT 15;


-- 21. Top 10 zone-pairs by cancellation rate (min 20 rides, to avoid tiny-sample noise)
SELECT
    pickup_location,
    drop_location,
    COUNT(*) AS total_rides,
    ROUND(100.0 * COUNT(*) FILTER (WHERE booking_status = 'Cancelled') / COUNT(*), 2) AS cancel_rate_pct
FROM fact_bookings
GROUP BY pickup_location, drop_location
HAVING COUNT(*) >= 20
ORDER BY cancel_rate_pct DESC
LIMIT 10;


-- 22. Underserved zones: high demand + high cancellation, low completion
WITH zone_perf AS (
    SELECT
        pickup_location,
        COUNT(*) AS total_rides,
        ROUND(100.0 * COUNT(*) FILTER (WHERE booking_status = 'Completed') / COUNT(*), 2) AS completion_pct,
        ROUND(100.0 * COUNT(*) FILTER (WHERE booking_status = 'Cancelled') / COUNT(*), 2) AS cancel_pct
    FROM fact_bookings
    GROUP BY pickup_location
)
SELECT *
FROM zone_perf
WHERE total_rides > (SELECT AVG(total_rides) FROM zone_perf)   -- above-average demand
  AND completion_pct < (SELECT AVG(completion_pct) FROM zone_perf)  -- below-average completion
ORDER BY cancel_pct DESC;


-- 23. Peak-hour demand ranking
SELECT
    hour,
    COUNT(*) AS total_rides,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS demand_rank
FROM fact_bookings
GROUP BY hour
ORDER BY hour;


-- 24. Peak-hour demand by zone (combines hour with pickup_location)
SELECT
    pickup_location,
    hour,
    COUNT(*) AS total_rides,
    RANK() OVER (PARTITION BY pickup_location ORDER BY COUNT(*) DESC) AS rank_in_zone
FROM fact_bookings
GROUP BY pickup_location, hour
ORDER BY pickup_location, rank_in_zone
LIMIT 25;
