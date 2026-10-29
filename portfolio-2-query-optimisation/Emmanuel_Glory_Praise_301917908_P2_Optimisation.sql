-- 1. Create a separate benchmark schema.
CREATE SCHEMA IF NOT EXISTS p2_benchmark;


-- 2. Create a new performance-test table without indexes.
CREATE TABLE p2_benchmark.synthetic_trip_history_v2 (
    benchmark_row_id BIGINT GENERATED ALWAYS AS IDENTITY,
    customer_id BIGINT NOT NULL,
    driver_id BIGINT NOT NULL,
    requested_at TIMESTAMPTZ NOT NULL,
    trip_status VARCHAR(20) NOT NULL,
    pickup_location VARCHAR(200) NOT NULL,
    destination VARCHAR(200) NOT NULL
);


-- 3. Generate 100,000 synthetic rows using existing customer and driver IDs.
-- These records are inserted only into the new benchmark table.
WITH customers AS (
    SELECT customer_id,
           ROW_NUMBER() OVER (ORDER BY customer_id) AS rn,
           COUNT(*) OVER () AS total
    FROM public.customer
),
drivers AS (
    SELECT driver_id,
           ROW_NUMBER() OVER (ORDER BY driver_id) AS rn,
           COUNT(*) OVER () AS total
    FROM public.driver
),
generated AS (
    SELECT g,
           TIMESTAMPTZ '2025-01-01 00:00:00+00'
             + ((g - 1) % 365) * INTERVAL '1 day'
             + ((g - 1) % 24) * INTERVAL '1 hour'
               AS requested_at,
           CASE g % 5
             WHEN 0 THEN 'Completed'
             WHEN 1 THEN 'Requested'
             WHEN 2 THEN 'Accepted'
             WHEN 3 THEN 'In Progress'
             ELSE 'Cancelled'
           END AS trip_status,
           CASE g % 4
             WHEN 0 THEN 'Ikeja'
             WHEN 1 THEN 'Yaba'
             WHEN 2 THEN 'Surulere'
             ELSE 'Lekki'
           END AS pickup_location,
           CASE g % 4
             WHEN 0 THEN 'Yaba'
             WHEN 1 THEN 'Lekki'
             WHEN 2 THEN 'Victoria Island'
             ELSE 'Ikeja'
           END AS destination
    FROM generate_series(1, 100000) AS series(g)
)
INSERT INTO p2_benchmark.synthetic_trip_history_v2
    (customer_id, driver_id, requested_at, trip_status,
     pickup_location, destination)
SELECT c.customer_id,
       d.driver_id,
       x.requested_at,
       x.trip_status,
       x.pickup_location,
       x.destination
FROM generated AS x
JOIN customers AS c
  ON c.rn = ((x.g - 1) % c.total) + 1
JOIN drivers AS d
  ON d.rn = ((x.g - 1) % d.total) + 1;


-- 4. Refresh PostgreSQL statistics.
ANALYZE p2_benchmark.synthetic_trip_history_v2;


-- 5. Verify the total number of generated rows.
SELECT COUNT(*) AS synthetic_history_rows
FROM p2_benchmark.synthetic_trip_history_v2;
-- Expected result: 100000


-- 6. Check the number of rows in the selected seven-day date range.
SELECT COUNT(*) AS trips_in_date_range
FROM p2_benchmark.synthetic_trip_history_v2
WHERE requested_at >= TIMESTAMPTZ '2025-02-01 00:00:00+00'
  AND requested_at <  TIMESTAMPTZ '2025-02-08 00:00:00+00';
-- Expected result: 1918


-- 7. Verify the new table has no indexes before the baseline test.
SELECT indexname
FROM pg_indexes
WHERE schemaname = 'p2_benchmark'
  AND tablename = 'synthetic_trip_history_v2';
-- Expected result: zero rows


-- 8. BEFORE INDEXING:
-- Run this query once as a warm-up, then three times for measurement.
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) AS trips_in_date_range
FROM p2_benchmark.synthetic_trip_history_v2
WHERE requested_at >= TIMESTAMPTZ '2025-02-01 00:00:00+00'
  AND requested_at <  TIMESTAMPTZ '2025-02-08 00:00:00+00';


-- 9. Create one B-tree index on the date/time column.
CREATE INDEX synthetic_trip_history_v2_requested_at_idx
    ON p2_benchmark.synthetic_trip_history_v2
    USING BTREE (requested_at);


-- 10. Refresh statistics after creating the index.
ANALYZE p2_benchmark.synthetic_trip_history_v2;


-- 11. AFTER INDEXING:
-- Run this identical query once as a warm-up, then three times for measurement.
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) AS trips_in_date_range
FROM p2_benchmark.synthetic_trip_history_v2
WHERE requested_at >= TIMESTAMPTZ '2025-02-01 00:00:00+00'
  AND requested_at <  TIMESTAMPTZ '2025-02-08 00:00:00+00';

