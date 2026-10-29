-- Q1: List trips with customer and driver details for the sample date.
SELECT c.full_name AS customer_name, t.pickup_location, t.destination,
       t.trip_status, d.full_name AS driver_name, t.fare
FROM public.trip t
JOIN public.customer c USING (customer_id)
LEFT JOIN public.driver d USING (driver_id)
WHERE t.requested_at >= TIMESTAMPTZ '2026-10-28 00:00:00+01'
  AND t.requested_at < TIMESTAMPTZ '2026-10-29 00:00:00+01'
ORDER BY t.requested_at, t.trip_id;

-- Q2: A driver is available for matching when marked Available
-- and has no trip currently in progress.
SELECT d.full_name, d.licence_number
FROM public.driver d
WHERE d.availability_status = 'Available'
  AND NOT EXISTS (
      SELECT 1 FROM public.trip t
      WHERE t.driver_id = d.driver_id
        AND t.trip_status = 'In Progress'
  )
ORDER BY d.full_name;

-- Q3: Count each customer's completed trips, including customers
-- who have no completed trips.
SELECT c.full_name, count(t.trip_id) AS completed_trips
FROM public.customer c
LEFT JOIN public.trip t
    ON t.customer_id = c.customer_id
   AND t.trip_status = 'Completed'
GROUP BY c.customer_id, c.full_name
ORDER BY c.full_name;