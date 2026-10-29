# Portfolio 1 Database Design and Modelling

## Case study
A ride-hailing system manages customers, drivers, vehicles, trip requests and trip records. Customers request rides, and available drivers accept requests and transport customers to their destinations. The system records trip details, statuses and fares to support trip tracking and operational reporting.

## Users
Customers request rides, provide pickup and destination locations, and view their trip history. Drivers manage their availability, accept ride requests and update trip statuses. Administrators register customers and drivers, maintain vehicle records, monitor trips and review operational reports.

## Main operations
Register a customer; register a driver and vehicle; submit a ride request; assign an available driver to a requested trip; update a trip's status; record the completed trip's fare and completion time; view customer trip history, driver trip records and trip summaries.

## Business rules
1. Each customer has a unique customer ID and email address. Each driver has a unique driver ID and licence number.
2. Each vehicle has a unique vehicle ID and registration number. Each vehicle is assigned to one registered driver at a time.
3. Each trip has a unique trip ID and belongs to one customer. A customer can request multiple trips.
4. Each trip must have a valid pickup location, destination and request timestamp. The destination must differ from the pickup location.
5. Each trip is assigned to at most one driver, and a driver must be registered and available before accepting a trip.
6. A driver cannot accept a new trip while another assigned trip is in progress.
7. A trip status must be one of Requested, Accepted, In Progress, Completed or Cancelled. Status changes must follow a valid sequence, and a completed or cancelled trip cannot be reopened.
8. A completed trip must have a non-negative fare and a completion timestamp later than its request timestamp. Cancelled trips cannot be recorded as completed.

## Scope
The system covers a single-city ride-hailing service using fictional customers, drivers, vehicles and trip records. It includes ride requests, driver assignments, trip status tracking, fare recording and basic trip reporting. Real-time GPS tracking, payment processing, surge pricing, driver ratings, notifications, multiple cities and external map services are excluded.

## Design and implementation files

| File | Contents |
|---|---|
| `Emmanuel_Glory_Praise_301917908_P1_Design.md` | Database design, entities, relationships and business rules. |
| `Emmanuel_Glory_Praise_301917908_P1_ERDiagram.md` | Entity-relationship diagram and relationship explanations. |
| `Emmanuel_Glory_Praise_301917908_P1_Normalisation.md` | Normalisation through First, Second and Third Normal Forms (1NF, 2NF and 3NF). |
| `Emmanuel_Glory_Praise_301917908_P1_Schema.sql` | PostgreSQL table definitions, primary keys, foreign keys and integrity constraints. |
| `Emmanuel_Glory_Praise_301917908_P1_SampleData.sql` | Fictional sample records used to test the database. |
| `Emmanuel_Glory_Praise_301917908_P1_ConstraintTests.sql` | Deliberately invalid INSERT statements used to test database constraints. |
| `screenshots/` | Screenshots showing database creation, table structures, sample-data insertion, constraint tests and final row counts. |

## Implementation

The database was implemented using PostgreSQL 16.15 in a terminal environment. The database is named `ride_hailing_portfolio`. It contains five tables: `customer`, `driver`, `vehicle`, `trip` and `trip_status_history`. Primary keys identify records, foreign keys maintain relationships, and `NOT NULL`, `UNIQUE` and `CHECK` constraints enforce the defined data-integrity rules.

The schema was created before inserting the fictional sample data. The constraint tests were executed individually to check whether PostgreSQL rejected records that violated the defined constraints. Screenshots of the implementation and test results were saved in the `screenshots/` folder.

## Test results

The sample-data insertion completed, and the final row-count query returned the expected results: **2 customers, 2 drivers, 2 vehicles, 5 trips and 12 trip-status history records**. The counts remained consistent after the constraint tests.

All executed invalid `INSERT` statements were rejected as expected. The tests covered required fields, duplicate customer emails, invalid foreign-key references, invalid driver availability, invalid trip and history statuses, negative fares, identical pickup and destination locations, and invalid completion details. Screenshots of the tests were saved in the `screenshots/` folder.

Some business rules require additional logic beyond the tested table constraints. These include valid status-transition sequences, preventing a driver from having multiple trips in progress, checking driver availability during assignment, and automatically recording status changes in the history table. These rules were documented but were not verified by the constraint tests described above.
