-- B1: START SESSION B WHILE SESSION A'S TRANSACTION IS OPEN
-- Run this section only AFTER Session A has updated Mary to
-- Unavailable but has NOT committed.

SET application_name = 'p3_session_b';

BEGIN ISOLATION LEVEL READ COMMITTED;

SHOW transaction_isolation;

-- Session B reads the last committed value.
-- Expected: Mary Bello | Available, because Session A has not
-- committed its change yet.

SELECT driver_id, full_name, availability_status
FROM public.driver
WHERE driver_id = 2;

-- Attempt the same conditional update as Session A.
-- This statement should WAIT while Session A holds the row lock.
-- Do not cancel it. Switch to Session A, check the wait, and COMMIT.
--
-- After Session A commits, this statement should complete with
-- UPDATE 0 because Mary is no longer Available.

UPDATE public.driver
SET availability_status = 'Unavailable'
WHERE driver_id = 2
  AND availability_status = 'Available';


-- B2: COMPLETE SESSION B AFTER ITS UPDATE RETURNS
-- Expected result from the waiting UPDATE above: UPDATE 0.

COMMIT;

-- Expected: COMMIT.


-- B3: FINAL VERIFICATION (run after both sessions have committed)

SELECT driver_id, full_name, availability_status
FROM public.driver
WHERE driver_id = 2;

-- Expected: Mary Bello | Unavailable.

SELECT trip_id, driver_id, trip_status
FROM public.trip
WHERE trip_id = 3;

-- Expected: trip_id 3 | driver_id 2 | In Progress.
