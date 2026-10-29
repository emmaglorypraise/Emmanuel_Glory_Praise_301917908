-- Start from the Portfolio 1 ride-hailing sample data.
-- Run the sections in order, once, in ride_hailing_portfolio.

-- Commit a change to Daniel Okafor.
-- The condition only changes a driver currently marked Available.
BEGIN;
UPDATE public.driver
SET availability_status = 'Unavailable'
WHERE driver_id = 1
  AND availability_status = 'Available';
COMMIT;

-- Try the same update again. Expected: UPDATE 0.
UPDATE public.driver
SET availability_status = 'Unavailable'
WHERE driver_id = 1
  AND availability_status = 'Available';

-- Begin another transaction and make a valid temporary change for Mary Bello.
BEGIN;
UPDATE public.driver
SET availability_status = 'Unavailable'
WHERE driver_id = 2
  AND availability_status = 'Available';

-- This deliberate mistake reuses Ada James's unique email address.
-- Expected: unique-constraint error on customer.email. Run ROLLBACK next.
INSERT INTO public.customer (full_name, email)
VALUES ('Test Customer', 'ada@example.com');

ROLLBACK;

-- Daniel's committed change remains; Mary's temporary change is rolled back.
SELECT driver_id, full_name, availability_status
FROM public.driver
WHERE driver_id IN (1, 2)
ORDER BY driver_id;

-- The failed insert did not create a second customer with Ada's email.
SELECT customer_id, full_name, email
FROM public.customer
WHERE email = 'ada@example.com';
