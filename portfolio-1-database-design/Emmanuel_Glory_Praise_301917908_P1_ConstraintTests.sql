-- Run each statement separately after SampleData.sql.
-- Each INSERT is deliberately invalid and should produce an ERROR.
-- Use the normal PostgreSQL prompt, outside BEGIN/COMMIT.
-- These tests target constraints defined in the Ride-hailing System schema.

-- 1. A customer's full_name cannot be missing.
INSERT INTO public.customer (full_name, email)
VALUES (NULL, 'missing@example.com');

-- 2. Ada's email cannot be used for another customer.
INSERT INTO public.customer (full_name, email)
VALUES ('Another Customer', 'ada@example.com');

-- 3. A vehicle cannot reference a driver who does not exist.
INSERT INTO public.vehicle (registration_number, driver_id)
VALUES ('TEST-999', 999999);

-- 4. A trip cannot reference a customer who does not exist.
INSERT INTO public.trip
    (customer_id, pickup_location, destination, requested_at, trip_status)
VALUES
    (999999, 'Ikeja', 'Yaba', '2026-10-28 14:00:00+01', 'Requested');

-- 5. A driver's availability status must be an allowed value.
INSERT INTO public.driver (full_name, licence_number, availability_status)
VALUES ('Test Driver', 'LIC-999', 'On Break');

-- 6. A trip must use an allowed status.
INSERT INTO public.trip
    (customer_id, pickup_location, destination, requested_at, trip_status)
VALUES
    (
        (SELECT customer_id FROM public.customer WHERE email = 'ada@example.com'),
        'Ikeja', 'Yaba', '2026-10-28 14:10:00+01', 'Waiting'
    );

-- 7. A trip fare cannot be negative.
INSERT INTO public.trip
    (customer_id, pickup_location, destination, requested_at, trip_status, fare)
VALUES
    (
        (SELECT customer_id FROM public.customer WHERE email = 'ada@example.com'),
        'Ikeja', 'Yaba', '2026-10-28 14:20:00+01', 'Requested', -500.00
    );

-- 8. Pickup and destination must be different.
INSERT INTO public.trip
    (customer_id, pickup_location, destination, requested_at, trip_status)
VALUES
    (
        (SELECT customer_id FROM public.customer WHERE email = 'ada@example.com'),
        'Ikeja', 'Ikeja', '2026-10-28 14:30:00+01', 'Requested'
    );

-- 9. A completed trip must include a fare and completion timestamp.
INSERT INTO public.trip
    (customer_id, pickup_location, destination, requested_at, trip_status, completed_at)
VALUES
    (
        (SELECT customer_id FROM public.customer WHERE email = 'ada@example.com'),
        'Ikeja', 'Yaba', '2026-10-28 14:40:00+01', 'Completed',
        '2026-10-28 15:00:00+01'
    );

-- 10. A completed trip's completion time must be after its request time.
INSERT INTO public.trip
    (customer_id, pickup_location, destination, requested_at, trip_status, fare, completed_at)
VALUES
    (
        (SELECT customer_id FROM public.customer WHERE email = 'ada@example.com'),
        'Ikeja', 'Yaba', '2026-10-28 15:00:00+01', 'Completed', 2500.00,
        '2026-10-28 14:59:00+01'
    );

-- 11. A cancelled trip cannot have a completion timestamp.
INSERT INTO public.trip
    (customer_id, pickup_location, destination, requested_at, trip_status, completed_at)
VALUES
    (
        (SELECT customer_id FROM public.customer WHERE email = 'ada@example.com'),
        'Ikeja', 'Yaba', '2026-10-28 15:10:00+01', 'Cancelled',
        '2026-10-28 15:20:00+01'
    );

-- 12. Status history cannot reference a trip that does not exist.
INSERT INTO public.trip_status_history (trip_id, status, changed_at)
VALUES (999999, 'Requested', '2026-10-28 15:30:00+01');

-- 13. Status history must use an allowed status.
INSERT INTO public.trip_status_history (trip_id, status, changed_at)
VALUES (
    (SELECT trip_id FROM public.trip ORDER BY trip_id LIMIT 1),
    'Waiting',
    '2026-10-28 15:40:00+01'
);

-- Failed inserts must not change these counts:
-- customer 2, driver 2, vehicle 2, trip 5, trip_status_history 12.
SELECT 'customer' AS table_name, COUNT(*) AS row_count FROM public.customer
UNION ALL SELECT 'driver', COUNT(*) FROM public.driver
UNION ALL SELECT 'vehicle', COUNT(*) FROM public.vehicle
UNION ALL SELECT 'trip', COUNT(*) FROM public.trip
UNION ALL SELECT 'trip_status_history', COUNT(*) FROM public.trip_status_history;
