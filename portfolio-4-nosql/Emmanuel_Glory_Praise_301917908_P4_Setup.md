# MongoDB setup

## Environment

MongoDB Community Server 8.0.34 and Mongosh 2.14.1 run in the existing Ubuntu Codespace, alongside PostgreSQL. MongoDB's working files are stored in `/workspaces/mongodb-data`, outside the Git repository. The local server listens on `127.0.0.1:27017`.

## Installation

MongoDB's official Ubuntu 24.04 package repository was added using the MongoDB 8.0 signing key and a source list file. The MongoDB server and shell were installed with:

```bash
sudo apt-get update
sudo apt-get install -y gnupg curl
curl -fsSL --connect-timeout 10 --max-time 30 https://pgp.mongodb.com/server-8.0.asc -o /tmp/mongodb-server-8.0.asc
sudo gpg --dearmor --yes --output /usr/share/keyrings/mongodb-server-8.0.gpg /tmp/mongodb-server-8.0.asc
sudo install -m 644 portfolio-4-nosql/Emmanuel_Glory_Praise_301917908_P4_MongoDBSource.list /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org-server mongodb-mongosh
```

## Start and connect

The local data directory was created and the MongoDB server was started with:

```bash
mkdir -p /workspaces/mongodb-data
mongod --dbpath /workspaces/mongodb-data --logpath /workspaces/mongodb-data/mongod.log --logappend --bind_ip 127.0.0.1 --fork
mongosh "mongodb://127.0.0.1:27017"
```

The `mongosh` connection opened successfully and reported MongoDB version 8.0.34 and Mongosh version 2.14.1. The server is configured to listen only on the local loopback address. Do not forward port 27017 or make it public. This is a local practice setup without database authentication, not a production deployment.

## Connection check

Inside `mongosh`, `db.version()` returned `8.0.34`, and `db.runCommand({ ping: 1 })` completed successfully with `{ ok: 1 }`. This confirms that the local MongoDB server responded to the connection check.

The version and ping result are saved in [the MongoDB connection screenshot](screenshots/Emmanuel_Glory_Praise_301917908_P4_MongoDBConnection.png).

## References

- [MongoDB 8.0 — Install on Ubuntu](https://www.mongodb.com/docs/v8.0/tutorial/install-mongodb-on-ubuntu/)
- [MongoDB 8.0 — mongod startup options](https://www.mongodb.com/docs/v8.0/reference/program/mongod/)
