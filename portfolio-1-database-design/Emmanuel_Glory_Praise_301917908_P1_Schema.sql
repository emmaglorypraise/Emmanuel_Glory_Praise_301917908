BEGIN;

-- Store customers who request rides.
CREATE TABLE public.customer (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE
);

-- Store drivers and their availability.
CREATE TABLE public.driver (
    driver_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    licence_number VARCHAR(50) NOT NULL UNIQUE,
    availability_status VARCHAR(20) NOT NULL
        CHECK (availability_status IN ('Available', 'Unavailable'))
);

-- Store vehicles and their assigned drivers.
CREATE TABLE public.vehicle (
    vehicle_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    registration_number VARCHAR(30) NOT NULL UNIQUE,
    driver_id BIGINT NOT NULL
        REFERENCES public.driver (driver_id)
);

-- Store ride requests and trip details.
CREATE TABLE public.trip (
    trip_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL
        REFERENCES public.customer (customer_id),
    driver_id BIGINT
        REFERENCES public.driver (driver_id),
    pickup_location VARCHAR(200) NOT NULL,
    destination VARCHAR(200) NOT NULL,
    requested_at TIMESTAMPTZ NOT NULL,
    trip_status VARCHAR(20) NOT NULL
        CHECK (trip_status IN (
            'Requested',
            'Accepted',
            'In Progress',
            'Completed',
            'Cancelled'
        )),
    fare NUMERIC(12,2)
        CHECK (fare IS NULL OR fare >= 0),
    completed_at TIMESTAMPTZ,
    CHECK (pickup_location <> destination),
    CHECK (
        trip_status <> 'Completed'
        OR (
            fare IS NOT NULL
            AND completed_at IS NOT NULL
            AND completed_at > requested_at
        )
    ),
    CHECK (
        trip_status <> 'Cancelled'
        OR completed_at IS NULL
    )
);

-- Keep a record of each trip status change.
CREATE TABLE public.trip_status_history (
    history_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    trip_id BIGINT NOT NULL
        REFERENCES public.trip (trip_id),
    status VARCHAR(20) NOT NULL
        CHECK (status IN (
            'Requested',
            'Accepted',
            'In Progress',
            'Completed',
            'Cancelled'
        )),
    changed_at TIMESTAMPTZ NOT NULL
);

-- Assignment and status-transition rules need transaction logic.
-- Prevent concurrent assignments from giving one driver multiple
-- trips in progress; the application or controlled database
-- operations must enforce this rule.
-- Status history must be maintained when trip_status changes.
-- Vehicle reassignment must use controlled updates.

COMMIT;