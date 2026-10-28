# Ride-hailing System Database Design

## 1. Entities

The database contains five entities:

- **Customer:** Stores information about people who request rides.
- **Driver:** Stores driver details and availability.
- **Vehicle:** Stores vehicle registration details and the driver assigned to each vehicle.
- **Trip:** Stores ride requests, assignments, locations, status, fare, and completion details.
- **Trip Status History:** Records changes to a trip's status for tracking and reporting.

## 2. Attributes and Keys

| Entity | Attributes | Keys and constraints |
|---|---|---|
| `customer` | `customer_id BIGINT`, `full_name VARCHAR(120)`, `email VARCHAR(254)` | `customer_id` is the primary key. `email` is unique. All attributes are required. |
| `driver` | `driver_id BIGINT`, `full_name VARCHAR(120)`, `licence_number VARCHAR(50)`, `availability_status VARCHAR(20)` | `driver_id` is the primary key. `licence_number` is unique. All attributes are required. |
| `vehicle` | `vehicle_id BIGINT`, `registration_number VARCHAR(30)`, `driver_id BIGINT` | `vehicle_id` is the primary key. `registration_number` is unique. `driver_id` is a foreign key referencing `driver.driver_id`. All attributes are required. |
| `trip` | `trip_id BIGINT`, `customer_id BIGINT`, `driver_id BIGINT`, `pickup_location VARCHAR(200)`, `destination VARCHAR(200)`, `requested_at TIMESTAMPTZ`, `trip_status VARCHAR(20)`, `fare NUMERIC(12,2)`, `completed_at TIMESTAMPTZ` | `trip_id` is the primary key. `customer_id` references `customer.customer_id`; `driver_id` references `driver.driver_id`. `driver_id`, `fare`, and `completed_at` may be empty when not yet applicable. Other attributes are required. |
| `trip_status_history` | `history_id BIGINT`, `trip_id BIGINT`, `status VARCHAR(20)`, `changed_at TIMESTAMPTZ` | `history_id` is the primary key. `trip_id` is a foreign key referencing `trip.trip_id`. All attributes are required. |

A **primary key (PK)** uniquely identifies each record. A **foreign key (FK)** links a record to another table. `TIMESTAMPTZ` stores a date and time with time-zone information, while `NUMERIC(12,2)` stores a monetary value to two decimal places.

## 3. Relationships

- **Customer to Trip (one-to-many):** A customer can request zero or many trips. Each trip belongs to exactly one customer.
- **Driver to Vehicle (one-to-many):** A driver can be assigned zero or more vehicles over time. Each vehicle has one assigned driver at a time.
- **Driver to Trip (one-to-many):** A driver can have zero or many assigned trips. A trip can have no driver initially or one assigned driver.
- **Trip to Trip Status History (one-to-many):** A trip can have multiple status-history records. Each history record belongs to one trip.

For example, one customer can request three trips, and each trip has its own unique ID. A trip can remain unassigned until a driver accepts it.

## 4. Business Rules and Constraints

1. Primary keys uniquely identify records. Unique constraints prevent duplicate customer email addresses, driver licence numbers, vehicle registration numbers, and trip IDs.
2. A vehicle must reference an existing driver. Vehicle assignment changes are handled through controlled updates.
3. Each trip must reference an existing customer.
4. Each trip must have a pickup location, destination, and request timestamp. The pickup location and destination must differ.
5. A trip can be created without a driver. Before assigning a driver, the system checks that the driver is registered and available.
6. A driver cannot accept a new trip while another assigned trip is in progress. Assignment logic must also handle concurrent requests so that two requests cannot assign conflicting trips to the same driver.
7. A trip status must be `Requested`, `Accepted`, `In Progress`, `Completed`, or `Cancelled`. The system enforces valid status transitions and prevents completed or cancelled trips from being reopened.
8. A fare cannot be negative. A completed trip must have a fare and a completion timestamp later than its request timestamp. A cancelled trip cannot be recorded as completed.

Some rules, such as valid status transitions and checking driver availability during assignment, require transaction logic in addition to basic table constraints.

## 5. Design Assumptions

- Driver availability is recorded as `Available` or `Unavailable`. An active trip also prevents a driver from accepting another trip.
- The `trip` table stores the current status, while `trip_status_history` preserves the sequence of status changes.
- The system serves one city. Payment processing, real-time GPS tracking, surge pricing, ratings, notifications, multiple cities, and external map services are outside the scope.
- Vehicle reassignment is handled through controlled updates. A separate vehicle-assignment history table is not included in this design.
