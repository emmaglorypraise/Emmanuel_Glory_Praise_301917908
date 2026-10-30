# Portfolio 4 NoSQL and Advanced Data Models

## Document model

The `ride_hailing_activity` database contains a `trip_events` collection. Each document records one trip activity event. The shared fields are `_id`, `event_id`, `event_type` and `event_time`. Customer, driver and trip information are stored in small embedded documents. The `details` field varies by event type: `TripRequested` documents record the request channel, while `TripCompleted` documents record the fare and completion time.

| Field | Contents |
|---|---|
| `_id` | Unique string identifier for the MongoDB document |
| `event_id` | Event identifier |
| `event_type` | `TripRequested` or `TripCompleted` |
| `event_time` | Event date and time, stored as a BSON date |
| `customer` | Customer ID and name |
| `driver` | Driver ID and name, when relevant |
| `trip` | Trip ID, pickup location and destination |
| `details` | Request channel, or fare and completion time |

Example completed-trip document:

```javascript
{
  _id: "TRIP-EVENT-004",
  event_id: "EVT-004",
  event_type: "TripCompleted",
  event_time: ISODate("2026-10-28T11:35:00Z"),
  customer: {
    customer_id: 1,
    full_name: "Ada James"
  },
  driver: {
    driver_id: 1,
    full_name: "Daniel Okafor"
  },
  trip: {
    trip_id: 4,
    pickup_location: "Yaba",
    destination: "Ikeja"
  },
  details: {
    fare: 4500.00,
    completed_at: ISODate("2026-10-28T11:35:00Z")
  }
}
```

## Implementation and results

Four fictional event documents were inserted into the local MongoDB 8.0.34 server using `mongosh`. The collection count query returned `4`. The event-history query for Ada James returned three events in chronological order: EVT-001 (TripRequested), EVT-002 (TripRequested) and EVT-004 (TripCompleted). The nested-field query for `trip.pickup_location: "Ikeja"` returned two events, EVT-001 and EVT-002. The connection check also showed `db.version()` returning `8.0.34` and `db.runCommand({ ping: 1 })` returning `{ ok: 1 }`. These are separate fictional MongoDB examples based on identifiers from the ride-hailing PostgreSQL case; they were not automatically extracted from SQL, and the PostgreSQL database was not changed.

## Why MongoDB fits

MongoDB can store each trip activity as a separate document, keeping the event, customer and trip details together. The embedded `details` document can vary by event type, so a request event does not need completion fields that only apply to a completed trip. This makes the model useful for keeping a growing activity history. A limitation is that the embedded customer and driver names are snapshots: changes in PostgreSQL do not automatically update the MongoDB documents. This exercise does not synchronise the two databases or enforce PostgreSQL foreign-key rules in MongoDB.

## Files

- [MongoDB implementation and queries](Emmanuel_Glory_Praise_301917908_P4_MongoDB.js)
- [MongoDB setup and connection notes](Emmanuel_Glory_Praise_301917908_P4_Setup.md)
- [MongoDB connection screenshot](screenshots/Emmanuel_Glory_Praise_301917908_P4_MongoDBConnection.png)
- [MongoDB query results screenshot](screenshots/Emmanuel_Glory_Praise_301917908_P4_MongoDB_Queries.png)

The JavaScript file checks whether the collection is empty before inserting. If the collection already contains documents, it skips the insert and runs the queries. Do not delete existing data or rerun a separate insert manually.

## References

- [MongoDB — Data Modeling](https://www.mongodb.com/docs/manual/data-modeling/)
- [MongoDB — insertMany](https://www.mongodb.com/docs/manual/reference/method/db.collection.insertmany/)
- [MongoDB — Query Embedded Documents](https://www.mongodb.com/docs/manual/tutorial/query-embedded-documents/)
