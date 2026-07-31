-- ============================================================
-- 03_business_queries.sql
-- Rapido Ride Analytics Dashboard — Foundational + Intermediate Queries
-- Schema: fact_bookings, dim_customers, dim_drivers, dim_date, dim_location
-- ============================================================


-- ================= FOUNDATIONAL =================

-- 1. Total rides & revenue by vehicle type
SELECT
    vehicle_type,
    COUNT(*) AS total_rides,
    SUM(booking_value) FILTER (WHERE booking_status = 'Completed') AS total_revenue,
    ROUND(AVG(booking_value), 2) AS avg_fare
FROM fact_bookings
GROUP BY vehicle_type
ORDER BY total_revenue DESC;


-- 2. Daily ride volume trend (no MoM — single month of data)
SELECT
    date,
    COUNT(*) AS total_rides,
    SUM(booking_value) FILTER (WHERE booking_status = 'Completed') AS daily_revenue
FROM fact_bookings
GROUP BY date
ORDER BY date;


-- 3. Cancellation rate by vehicle type
SELECT
    vehicle_type,
    COUNT(*) AS total_rides,
    COUNT(*) FILTER (WHERE booking_status = 'Cancelled') AS cancelled_rides,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE booking_status = 'Cancelled') / COUNT(*), 2
    ) AS cancellation_rate_pct
FROM fact_bookings
GROUP BY vehicle_type
ORDER BY cancellation_rate_pct DESC;


-- 4. Cancellation rate by zone (pickup location)
SELECT
    pickup_location,
    COUNT(*) AS total_rides,
    COUNT(*) FILTER (WHERE booking_status = 'Cancelled') AS cancelled_rides,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE booking_status = 'Cancelled') / COUNT(*), 2
    ) AS cancellation_rate_pct
FROM fact_bookings
GROUP BY pickup_location
ORDER BY cancellation_rate_pct DESC;


-- 5. Top 10 drivers by ride count and rating
SELECT
    driver_id,
    COUNT(*) AS total_rides,
    ROUND(AVG(driver_rating), 2) AS avg_rating
FROM fact_bookings
GROUP BY driver_id
ORDER BY total_rides DESC
LIMIT 10;


-- 6. Top 10 customers by ride count (repeat-customer check)
SELECT
    customer_id,
    COUNT(*) AS total_rides
FROM fact_bookings
GROUP BY customer_id
ORDER BY total_rides DESC
LIMIT 10;


-- 7. Revenue by payment method
SELECT
    payment_method,
    COUNT(*) AS total_rides,
    SUM(booking_value) FILTER (WHERE booking_status = 'Completed') AS total_revenue
FROM fact_bookings
GROUP BY payment_method
ORDER BY total_revenue DESC;


-- 8. Lost revenue from cancelled/incomplete rides
SELECT
    booking_status,
    COUNT(*) AS ride_count,
    SUM(booking_value) AS lost_revenue
FROM fact_bookings
WHERE booking_status IN ('Cancelled', 'Incomplete')
GROUP BY booking_status;


-- ================= INTERMEDIATE =================

-- 9. Rides & revenue % contribution by day-of-week (window function)
SELECT
    d.day_of_week,
    COUNT(*) AS total_rides,
    SUM(f.booking_value) FILTER (WHERE f.booking_status = 'Completed') AS revenue,
    ROUND(
        100.0 * SUM(f.booking_value) FILTER (WHERE f.booking_status = 'Completed')
        / SUM(SUM(f.booking_value) FILTER (WHERE f.booking_status = 'Completed')) OVER (), 2
    ) AS pct_of_total_revenue
FROM fact_bookings f
JOIN dim_date d ON f.date = d.date
GROUP BY d.day_of_week
ORDER BY revenue DESC;


-- 10. Rolling 7-day average cancellation rate
WITH daily_stats AS (
    SELECT
        date,
        COUNT(*) AS total_rides,
        COUNT(*) FILTER (WHERE booking_status = 'Cancelled') AS cancelled_rides
    FROM fact_bookings
    GROUP BY date
)
SELECT
    date,
    total_rides,
    cancelled_rides,
    ROUND(
        100.0 * AVG(cancelled_rides::numeric / total_rides) OVER (
            ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_7day_cancel_rate_pct
FROM daily_stats
ORDER BY date;


-- 11. Running total of daily revenue
SELECT
    date,
    SUM(booking_value) FILTER (WHERE booking_status = 'Completed') AS daily_revenue,
    SUM(SUM(booking_value) FILTER (WHERE booking_status = 'Completed')) OVER (
        ORDER BY date
    ) AS running_total_revenue
FROM fact_bookings
GROUP BY date
ORDER BY date;


-- 12. Customers with more than 5 rides
SELECT
    customer_id,
    COUNT(*) AS total_rides
FROM fact_bookings
GROUP BY customer_id
HAVING COUNT(*) > 5
ORDER BY total_rides DESC;


-- 13. Drivers with below-average rating AND above-average cancellation rate
WITH driver_stats AS (
    SELECT
        driver_id,
        ROUND(AVG(driver_rating), 2) AS avg_rating,
        ROUND(100.0 * COUNT(*) FILTER (WHERE cancel_side = 'Driver') / COUNT(*), 2) AS driver_cancel_rate
    FROM fact_bookings
    GROUP BY driver_id
),
overall_avg AS (
    SELECT AVG(avg_rating) AS overall_avg_rating, AVG(driver_cancel_rate) AS overall_avg_cancel_rate
    FROM driver_stats
)
SELECT ds.*
FROM driver_stats ds, overall_avg oa
WHERE ds.avg_rating < oa.overall_avg_rating
  AND ds.driver_cancel_rate > oa.overall_avg_cancel_rate
ORDER BY ds.driver_cancel_rate DESC;


-- 14. Zone-pair demand (top 10 pickup→drop combinations)
SELECT
    pickup_location,
    drop_location,
    COUNT(*) AS total_rides,
    SUM(booking_value) FILTER (WHERE booking_status = 'Completed') AS revenue
FROM fact_bookings
GROUP BY pickup_location, drop_location
ORDER BY total_rides DESC
LIMIT 10;


-- 15. Peak hour demand
SELECT
    hour,
    COUNT(*) AS total_rides
FROM fact_bookings
GROUP BY hour
ORDER BY total_rides DESC;
