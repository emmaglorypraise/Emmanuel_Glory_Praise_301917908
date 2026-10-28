# Ride-hailing System Normalisation

Normalisation separates information into related tables to reduce repeated details and prevent inconsistent updates. This example follows three fictional ride records through First Normal Form (1NF), Second Normal Form (2NF), and Third Normal Form (3NF). Only selected fields appear in the example tables; the final design retains the other fields from the agreed database design.

The example uses fictional customers Ada James and Ben Cole, drivers Daniel Okafor and Mary Bello, and their ride requests. Dates and times are shortened for readability.

## Starting ride list

Suppose the system initially stores ride requests in one list, with customer, driver, and trip information grouped together.

| customer_id | Customer details | Ride requests |
|---|---|---|
| 1 | Ada James, ada@example.com | Trip 101: driver 10, Daniel Okafor, pickup Ikeja, destination Yaba, Requested, 2026-10-20 09:00; Trip 102: driver 10, Daniel Okafor, pickup Ikeja, destination Lekki, Completed, ₦5,000, 2026-10-20 11:00 |
| 2 | Ben Cole, ben@example.com | Trip 103: driver 11, Mary Bello, pickup Surulere, destination Yaba, Completed, ₦3,500, 2026-10-20 12:00 |

The `Ride requests` field contains multiple trips in one cell. This makes it difficult to find or update one trip independently. Customer and driver details also repeat across trips, creating unnecessary duplication.

## 1NF: One value per cell

First Normal Form (1NF) means each cell contains one value, and each row represents one record. The repeated trip lists are separated into individual rows.

| trip_id | customer_id | customer_name | email | driver_id | driver_name | pickup_location | destination | trip_status | fare |
|---|---|---|---|---|---|---|---|---|---:|
| 101 | 1 | Ada James | ada@example.com | 10 | Daniel Okafor | Ikeja | Yaba | Requested | — |
| 102 | 1 | Ada James | ada@example.com | 10 | Daniel Okafor | Ikeja | Lekki | Completed | 5000 |
| 103 | 2 | Ben Cole | ben@example.com | 11 | Mary Bello | Surulere | Yaba | Completed | 3500 |

**Key:** `trip_id`, assuming each trip has a unique ID.

Each row now represents one trip, and each cell holds a single value. The repeated list is removed. However, customer and driver names and emails still repeat across trip records. If Ada changes her email address, every row containing her email would need to be updated.

The dash in the fare column means the fare is not yet applicable or recorded for Trip 101. In the agreed design, `fare` can be empty when it is not yet applicable.

## 2NF: Details depend on the whole key

Second Normal Form (2NF) includes 1NF. Every non-key field must depend on the whole primary key, not just part of a combined key.

In this example, `trip_id` is a single-field primary key, rather than a combined key. Since `trip_id` identifies one complete trip, there is no partial dependency on part of the key. Therefore, the 1NF table is already in 2NF.

**Key:** `trip_id`.

| trip_id | customer_id | customer_name | email | driver_id | driver_name | pickup_location | destination | trip_status | fare |
|---|---|---|---|---|---|---|---|---|---:|
| 101 | 1 | Ada James | ada@example.com | 10 | Daniel Okafor | Ikeja | Yaba | Completed | 4500 |
| 102 | 1 | Ada James | ada@example.com | 10 | Daniel Okafor | Ikeja | Lekki | Completed | 5000 |
| 103 | 2 | Ben Cole | ben@example.com | 11 | Mary Bello | Surulere | Yaba | Completed | 3500 |

The table remains unchanged at this stage because its primary key contains only one field. However, customer details still depend on `customer_id`, and driver details depend on `driver_id`, rather than directly describing the trip. These dependencies are addressed in 3NF.

## 3NF: Keep details with the thing they describe

Third Normal Form (3NF) includes 2NF. Non-key fields must depend on the key, the whole key, and nothing but the key. In simple words, each table stores details about one main thing.

Two dependencies explain the changes:

- `customer_id` determines the customer's name and email.
- `driver_id` determines the driver's name, licence number, and availability.

These details describe customers and drivers, not individual trips. They move into separate tables. Trip records keep the IDs that link to those tables.

### Customer

**Key:** `customer_id`.

| customer_id | full_name | email |
|---|---|---|
| 1 | Ada James | ada@example.com |
| 2 | Ben Cole | ben@example.com |

Customer information is stored once. If Ada changes her email, the system updates her customer record instead of every trip she takes.

### Driver

**Key:** `driver_id`.

| driver_id | full_name | licence_number | availability_status |
|---|---|---|---|
| 10 | Daniel Okafor | LIC-100 | Available |
| 11 | Mary Bello | LIC-101 | Available |

Driver details are stored once, and `licence_number` remains unique. Trips refer to the driver using `driver_id`.

### Vehicle

**Key:** `vehicle_id`. `driver_id` is a foreign key referencing `driver.driver_id`.

| vehicle_id | registration_number | driver_id |
|---|---|---|
| 201 | LAG-101AA | 10 |
| 202 | LAG-202BB | 11 |

Vehicle registration details are stored separately from driver details. Each vehicle references its assigned driver.

### Trip

**Key:** `trip_id`. `customer_id` and `driver_id` are foreign keys.

| trip_id | customer_id | driver_id | pickup_location | destination | trip_status | fare |
|---|---|---|---|---|---|---:|
| 101 | 1 | 10 | Ikeja | Yaba | Completed | 4500 |
| 102 | 1 | 10 | Ikeja | Lekki | Completed | 5000 |
| 103 | 2 | 11 | Surulere | Yaba | Completed | 3500 |

The trip table stores information specific to each ride. The IDs link each trip to the customer and assigned driver, without repeating their names and other details.

### Trip status history

**Key:** `history_id`. `trip_id` is a foreign key referencing `trip.trip_id`.

| history_id | trip_id | status | changed_at |
|---|---|---|---|
| 1001 | 101 | Requested | 2026-10-20 09:00 |
| 1002 | 101 | Accepted | 2026-10-20 09:02 |
| 1003 | 101 | Completed | 2026-10-20 09:35 |

The history table stores separate status changes for a trip. This preserves the sequence of changes rather than keeping only the current status in the trip table.

## How the final tables stay linked

A **primary key (PK)** uniquely identifies a record. A **foreign key (FK)** refers to a primary key in another table, linking related information.

For example, Trip 101 has `customer_id = 1` and `driver_id = 10`. The customer table identifies customer 1 as Ada James, while the driver table identifies driver 10 as Daniel Okafor. The trip status history links to Trip 101 through `trip_id`.

The final design also includes unique constraints on customer email, driver licence number, and vehicle registration number. These prevent duplicate values in those fields.

The final schema uses `trip_id` as the primary key, so it does not need a combined key such as `(customer_id, requested_at)` to identify a trip. Using an ID is a design choice; an ID alone does not prove that a table is in 3NF. The dependencies between the fields determine normalisation.

## Fields not shown in full

The tables above show selected fields to make the normalisation process easier to follow. The complete agreed design retains all attributes:

- `trip`: `requested_at TIMESTAMPTZ` and `completed_at TIMESTAMPTZ`, in addition to the fields shown.
- `trip_status_history`: `history_id`, `trip_id`, `status`, and `changed_at`.
- `customer`, `driver`, and `vehicle`: all attributes shown in their respective tables.

The complete design also retains the agreed data types, primary keys, foreign keys, and unique constraints.

## Rules that normalisation does not enforce by itself

Normalisation reduces repeated information, but it does not automatically enforce every business rule. The database and its transaction logic must also ensure that:

- Pickup and destination differ.
- A driver is available before accepting a trip and cannot have another trip in progress.
- Trip statuses follow the valid sequence, and completed or cancelled trips cannot be reopened.
- A fare is non-negative, and a completed trip has a fare and a completion timestamp later than its request timestamp.
- Concurrent requests cannot assign conflicting trips to the same driver.

These checks require appropriate constraints and transaction logic in addition to the normalised table structure.
