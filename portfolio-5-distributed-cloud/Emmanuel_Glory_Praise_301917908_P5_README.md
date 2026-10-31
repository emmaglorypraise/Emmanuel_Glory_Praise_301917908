# Portfolio 5 Distributed and Cloud Database Exercise

## Current setup

The ride-hailing system uses PostgreSQL for its relational records, including customers, drivers, vehicles and trips. Portfolio 4 added MongoDB Community Server 8.0.34 in the existing Ubuntu Codespace, with the `ride_hailing_activity` database and `trip_events` collection. MongoDB stores separate fictional trip activity documents, including `TripRequested` and `TripCompleted` events. The MongoDB server was accessed locally through `127.0.0.1:27017`. The actual MongoDB deployment topology has not been verified as a replica set or a multi-host deployment. No replication between MongoDB and PostgreSQL has been implemented.

## Proposed replication

I propose a MongoDB replica set with three voting members that each hold a copy of the data. Each member would run on a separate host and in a separate failure zone to reduce the risk of one infrastructure failure affecting all members.

| Member | Starting role | Location |
|---|---|---|
| Member 1 | Primary | Host A, Zone 1 |
| Member 2 | Secondary | Host B, Zone 2 |
| Member 3 | Secondary | Host C, Zone 3 |

For example, when a `TripRequested` event is written to the primary, the replica set replicates the operation to the secondary members. The primary handles writes, while eligible secondaries can be elected as primary if the current primary becomes unavailable. This is a proposed design, not an implemented deployment. [MongoDB replication](https://www.mongodb.com/docs/manual/replication/).

## Failure and consistency

If the primary host fails, the two remaining members can communicate and hold an election to choose a new primary. Writes may pause briefly during the election. MongoDB documentation explains that an election is required before normal write operations resume; actual recovery time depends on the deployment and network conditions. If a member cannot reach a majority of voting members, it cannot remain primary, and writes requiring a primary cannot proceed until a majority is available. [Replica set elections](https://www.mongodb.com/docs/v8.0/core/replica-set-elections/).

I would use `writeConcern: { w: "majority" }` for important event writes. This requests acknowledgement from a calculated majority of data-bearing voting members. With three voting members, that normally means the primary and at least one secondary. However, replication to secondaries is asynchronous, so a secondary may temporarily lag behind the primary. [MongoDB write concern](https://www.mongodb.com/docs/v8.0/reference/write-concern/). PostgreSQL should remain authoritative for relational trip records and business rules. MongoDB replication would protect only the MongoDB event data; it would not replicate PostgreSQL records or synchronise the two databases.

## Sharding and cloud deployment

Replication copies the same data across members for availability. Sharding divides a collection's records across multiple shards to distribute storage and workload. My four-document `trip_events` example is too small to need sharding. A single MongoDB server is sufficient for this exercise; a replica set would be a future availability improvement, not something already deployed. [MongoDB sharding](https://www.mongodb.com/docs/manual/sharding/).

For a future cloud deployment, MongoDB Atlas could host the proposed replica set. The deployment should use authentication, encrypted connections, restricted network access and regular backups. Backup and restore procedures should be tested so that records can be recovered after data loss. Atlas backup options and availability depend on the cluster tier, so the service cost must be considered alongside storage, compute and network costs. [Atlas backup and restore](https://www.mongodb.com/docs/atlas/backup-restore-cluster/).

A limitation is that replication does not replace backups, prevent incorrect data from being written, or synchronise MongoDB with PostgreSQL. The proposed design also adds hosting and operational costs compared with the current local practice setup.