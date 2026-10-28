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