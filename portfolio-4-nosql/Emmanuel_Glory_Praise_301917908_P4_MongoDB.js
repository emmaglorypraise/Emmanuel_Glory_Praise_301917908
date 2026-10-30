// 1. Select the database and collection

const database = db.getSiblingDB("ride_hailing_activity");
const events = database.getCollection("trip_events");

// 2. Check whether the collection already contains documents

const existingCount = events.countDocuments({});
print("Documents before insert: " + existingCount);

// 3. Insert the four sample event documents only if collection is empty

if (existingCount === 0) {

    const result = events.insertMany([

        // Document 1: TripRequested
        {
            _id: "TRIP-EVENT-001",
            event_id: "EVT-001",
            event_type: "TripRequested",
            event_time: ISODate("2026-10-28T08:00:00Z"),

            customer: {
                customer_id: 1,
                full_name: "Ada James"
            },

            trip: {
                trip_id: 1,
                pickup_location: "Ikeja",
                destination: "Yaba"
            },

            details: {
                request_channel: "Mobile app"
            }
        },

        // Document 2: TripRequested
        {
            _id: "TRIP-EVENT-002",
            event_id: "EVT-002",
            event_type: "TripRequested",
            event_time: ISODate("2026-10-28T09:00:00Z"),

            customer: {
                customer_id: 1,
                full_name: "Ada James"
            },

            trip: {
                trip_id: 2,
                pickup_location: "Ikeja",
                destination: "Lekki"
            },

            details: {
                request_channel: "Mobile app"
            }
        },

        // Document 3: TripRequested
        {
            _id: "TRIP-EVENT-003",
            event_id: "EVT-003",
            event_type: "TripRequested",
            event_time: ISODate("2026-10-28T10:00:00Z"),

            customer: {
                customer_id: 2,
                full_name: "Ben Cole"
            },

            trip: {
                trip_id: 3,
                pickup_location: "Surulere",
                destination: "Yaba"
            },

            details: {
                request_channel: "Mobile app"
            }
        },

        // Document 4: TripCompleted
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

    ]);

    print("Inserted documents: " + result.insertedCount);

} else {

    print("Insert skipped: the collection is not empty.");

}


// 4. QUERY ONE: Count all activity events

print("Total activity events:");

print(events.countDocuments({}));


// 5. QUERY TWO: Retrieve Ada James's event history
// Sort events by time, oldest first.

print("Ada James event history:");

events.find(
    { "customer.customer_id": 1 }
).sort(
    { event_time: 1 }
).forEach(printjson);


// 6. QUERY THREE: Find events with Ikeja as pickup location
// This demonstrates filtering using a nested document field.

print("Events with Ikeja as the pickup location:");

events.find(
    { "trip.pickup_location": "Ikeja" }
).sort(
    { event_time: 1 }
).forEach(printjson);