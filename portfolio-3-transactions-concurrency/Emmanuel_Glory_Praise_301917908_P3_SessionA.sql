-- A0: RESET THE TEST DATA (run once before starting the test)
-- The previous test may have left Mary Bello as Unavailable.
-- Reset her to Available so the concurrency test starts correctly.

UPDATE public.driver
SET availability_status = 'Available'
WHERE driver_id = 2;

-- Check the starting status. Expected: Mary Bello | Available.

SELECT driver_id, full_name, availability_status
FROM public.driver
WHERE driver_id = 2;


-- A1: START SESSION A'S TRANSACTION
-- Run these statements in Session A.
-- After the UPDATE returns UPDATE 1, STOP here.
-- Leave this transaction open and switch to Session B.

SET application_name = 'p3_session_a';

BEGIN ISOLATION LEVEL READ COMMITTED;

SHOW transaction_isolation;

-- Lock Mary Bello's driver row.

SELECT driver_id, full_name, availability_status
FROM public.driver
WHERE driver_id = 2
FOR UPDATE;

-- Change Mary from Available to Unavailable. Expected: UPDATE 1.

UPDATE public.driver
SET availability_status = 'Unavailable'
WHERE driver_id = 2
  AND availability_status = 'Available';

-- STOP. Do not COMMIT yet.
-- Switch to Session B and run its B1 section.
-- Session B's UPDATE should wait for this row lock.


-- A2: CHECK THAT SESSION B IS WAITING, THEN COMMIT
-- Run this section in Session A only AFTER Session B's UPDATE
-- is visibly waiting.

SELECT application_name, wait_event_type, wait_event
FROM pg_stat_activity
WHERE application_name = 'p3_session_b';

-- Expected while B is blocked: wait_event_type = Lock.
-- Take the waiting-state screenshot before committing.

COMMIT;

-- Expected: COMMIT.
-- This releases the row lock so Session B can continue.


-- A3: FINAL VERIFICATION (run after Session B has committed)

SELECT driver_id, full_name, availability_status
FROM public.driver
WHERE driver_id = 2;

-- Expected: Mary Bello | Unavailable.

SELECT trip_id, driver_id, trip_status
FROM public.trip
WHERE trip_id = 3;

-- Expected: trip_id 3 | driver_id 2 | In Progress.
