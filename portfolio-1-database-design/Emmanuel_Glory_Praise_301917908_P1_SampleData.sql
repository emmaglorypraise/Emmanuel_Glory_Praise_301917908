BEGIN;

INSERT INTO public.customer (full_name, email) VALUES
('Ada James', 'ada@example.com'),
('Ben Cole', 'ben@example.com');

INSERT INTO public.driver (full_name, licence_number, availability_status) VALUES
('Daniel Okafor', 'LIC-100', 'Available'),
('Mary Bello', 'LIC-101', 'Available');

-- Find generated driver IDs by unique licence numbers.
INSERT INTO public.vehicle (registration_number, driver_id)
SELECT 'LAG-101AA', driver_id FROM public.driver WHERE licence_number = 'LIC-100';
INSERT INTO public.vehicle (registration_number, driver_id)
SELECT 'LAG-202BB', driver_id FROM public.driver WHERE licence_number = 'LIC-101';

-- Requested trip, not yet assigned.
INSERT INTO public.trip
(customer_id, pickup_location, destination, requested_at, trip_status)
SELECT customer_id, 'Ikeja', 'Yaba', '2026-10-28 09:00:00+01', 'Requested'
FROM public.customer WHERE email = 'ada@example.com';

-- Accepted trip.
INSERT INTO public.trip
(customer_id, driver_id, pickup_location, destination, requested_at, trip_status)
SELECT c.customer_id, d.driver_id, 'Ikeja', 'Lekki',
       '2026-10-28 10:00:00+01', 'Accepted'
FROM public.customer c CROSS JOIN public.driver d
WHERE c.email = 'ada@example.com' AND d.licence_number = 'LIC-100';

-- Trip in progress.
INSERT INTO public.trip
(customer_id, driver_id, pickup_location, destination, requested_at, trip_status)
SELECT c.customer_id, d.driver_id, 'Surulere', 'Yaba',
       '2026-10-28 11:00:00+01', 'In Progress'
FROM public.customer c CROSS JOIN public.driver d
WHERE c.email = 'ben@example.com' AND d.licence_number = 'LIC-101';

-- Completed trip.
INSERT INTO public.trip
(customer_id, driver_id, pickup_location, destination, requested_at, trip_status, fare, completed_at)
SELECT c.customer_id, d.driver_id, 'Yaba', 'Ikeja',
       '2026-10-28 12:00:00+01', 'Completed', 4500.00, '2026-10-28 12:35:00+01'
FROM public.customer c CROSS JOIN public.driver d
WHERE c.email = 'ada@example.com' AND d.licence_number = 'LIC-100';

-- Cancelled trip, before driver assignment.
INSERT INTO public.trip
(customer_id, pickup_location, destination, requested_at, trip_status)
SELECT customer_id, 'Surulere', 'Victoria Island',
       '2026-10-28 13:00:00+01', 'Cancelled'
FROM public.customer WHERE email = 'ben@example.com';

-- Status history uses trip/customer details to find generated trip IDs.
INSERT INTO public.trip_status_history (trip_id, status, changed_at)
SELECT t.trip_id, v.status, v.changed_at
FROM (VALUES
 ('ada@example.com', TIMESTAMPTZ '2026-10-28 09:00:00+01', 'Requested', TIMESTAMPTZ '2026-10-28 09:00:00+01'),
 ('ada@example.com', TIMESTAMPTZ '2026-10-28 10:00:00+01', 'Requested', TIMESTAMPTZ '2026-10-28 10:00:00+01'),
 ('ada@example.com', TIMESTAMPTZ '2026-10-28 10:00:00+01', 'Accepted', TIMESTAMPTZ '2026-10-28 10:05:00+01'),
 ('ben@example.com', TIMESTAMPTZ '2026-10-28 11:00:00+01', 'Requested', TIMESTAMPTZ '2026-10-28 11:00:00+01'),
 ('ben@example.com', TIMESTAMPTZ '2026-10-28 11:00:00+01', 'Accepted', TIMESTAMPTZ '2026-10-28 11:02:00+01'),
 ('ben@example.com', TIMESTAMPTZ '2026-10-28 11:00:00+01', 'In Progress', TIMESTAMPTZ '2026-10-28 11:10:00+01'),
 ('ada@example.com', TIMESTAMPTZ '2026-10-28 12:00:00+01', 'Requested', TIMESTAMPTZ '2026-10-28 12:00:00+01'),
 ('ada@example.com', TIMESTAMPTZ '2026-10-28 12:00:00+01', 'Accepted', TIMESTAMPTZ '2026-10-28 12:02:00+01'),
 ('ada@example.com', TIMESTAMPTZ '2026-10-28 12:00:00+01', 'In Progress', TIMESTAMPTZ '2026-10-28 12:10:00+01'),
 ('ada@example.com', TIMESTAMPTZ '2026-10-28 12:00:00+01', 'Completed', TIMESTAMPTZ '2026-10-28 12:35:00+01'),
 ('ben@example.com', TIMESTAMPTZ '2026-10-28 13:00:00+01', 'Requested', TIMESTAMPTZ '2026-10-28 13:00:00+01'),
 ('ben@example.com', TIMESTAMPTZ '2026-10-28 13:00:00+01', 'Cancelled', TIMESTAMPTZ '2026-10-28 13:04:00+01')
) AS v(email, requested_at, status, changed_at)
JOIN public.customer c ON c.email = v.email
JOIN public.trip t ON t.customer_id = c.customer_id AND t.requested_at = v.requested_at;

COMMIT;

-- Expected valid counts: customer 2, driver 2, vehicle 2, trip 5, history 12.
