# Portfolio 2 Query Processing and Optimisation

## Queries and results

Three PostgreSQL queries were executed against the ride-hailing database:

- **Q1 – Trip details:** Returned 5 trips requested on 28 October 2026, showing customer, pickup, destination, status, driver and fare details.
- **Q2 – Available drivers:** Returned Daniel Okafor (`LIC-100`) as the only driver marked Available without a trip currently in progress.
- **Q3 – Completed trips per customer:** Returned Ada James with 1 completed trip and Ben Cole with 0.

[View query results screenshot](screenshots/Emmanuel_Glory_Praise_301917908_P2_QueryResults.png)

## Index comparison

The benchmark used 100,000 synthetic records in `p2_benchmark.synthetic_trip_history_v2`. The same seven-day date-range query returned 1,918 rows before and after adding a B-tree index on `requested_at`.

| Measurement | Before index | After index |
|---|---:|---:|
| Scan type | Sequential scan | Index-only scan |
| Execution time, run 1 (ms) | 7.027 | 0.350 |
| Execution time, run 2 (ms) | 5.940 | 0.260 |
| Execution time, run 3 (ms) | 7.339 | 0.239 |
| Median time (ms) | 7.027 | 0.260 |
| Top-level shared buffer hits, run 3 | 1,087 | 5 |

Before indexing, PostgreSQL scanned the table and removed 98,082 rows using the date filter. After indexing, it used `synthetic_trip_history_v2_requested_at_idx` for an index-only scan, with zero heap fetches. The median execution time decreased from 7.027 ms to 0.260 ms in these measurements. However, timings are environment-dependent and can vary with caching, system load and measurement conditions; three measured runs are a limited sample and do not establish a universal performance improvement. Indexes also consume storage and add overhead to inserts, updates and deletes because the index must be maintained. An index does not guarantee that every query will run faster.

## Performance analysis

The benchmark table and index are separate from the Portfolio 1 operational tables. The experiment compared the same query and date range before and after indexing, using `EXPLAIN (ANALYZE, BUFFERS)`. The observed plans and measurements indicate that the index was beneficial for this test, but results may differ for other workloads or data distributions.

## Files

- [SQL queries](Emmanuel_Glory_Praise_301917908_P2_Queries.sql)
- [Indexing optimisation SQL](Emmanuel_Glory_Praise_301917908_P2_Optimisation.sql)
- [Query results screenshot](screenshots/Emmanuel_Glory_Praise_301917908_P2_QueryResults.png)

**Before-index plans**
- [Run 1](screenshots/Emmanuel_Glory_Praise_301917908_P2_BeforeIndex_Run1.png)
- [Run 2](screenshots/Emmanuel_Glory_Praise_301917908_P2_BeforeIndex_Run2.png)
- [Run 3](screenshots/Emmanuel_Glory_Praise_301917908_P2_BeforeIndex_Run3.png)

**After-index plans**
- [Run 1](screenshots/Emmanuel_Glory_Praise_301917908_P2_AfterIndex_Run1.png)
- [Run 2](screenshots/Emmanuel_Glory_Praise_301917908_P2_AfterIndex_Run2.png)
- [Run 3](screenshots/Emmanuel_Glory_Praise_301917908_P2_AfterIndex_Run3.png)

## Reference

- [PostgreSQL 16 — Using EXPLAIN](https://www.postgresql.org/docs/16/using-explain.html)
