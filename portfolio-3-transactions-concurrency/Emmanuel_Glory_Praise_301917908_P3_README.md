# Portfolio 3 Transactions and Concurrency

## Commit and rollback
I used transactions to update driver availability and test rollback after an error. The first transaction changed Daniel Okafor's status from Available to Unavailable and was committed; repeating the conditional update returned UPDATE 0. In a second transaction, I temporarily changed Mary Bello's status to Unavailable, then attempted to insert a customer using Ada James's existing email address. PostgreSQL rejected the duplicate email with a unique-constraint error. I rolled back the transaction, and the final checks showed Daniel remained Unavailable, Mary returned to Available, and Ada's original email record remained unchanged.

## Isolation and concurrency control
I opened two PostgreSQL sessions and set both transactions to READ COMMITTED. Session A selected Mary Bello's driver row using FOR UPDATE and updated her availability while keeping the transaction open. The waiting-state screenshot shows Session B's update waiting while Session A held the row lock. However, the final terminal screenshot shows Session B's update returned UPDATE 1, rather than the expected UPDATE 0 if Session A's conditional update had committed first and Session B then rechecked the condition. The final check shows Mary as Unavailable and Trip 3 still assigned to Driver 2 with status In Progress. Because the recorded update count differs from the expected result, this evidence does not yet confirm the intended concurrent conditional-update outcome; the order of the commands and Session A's update/commit should be checked.

## Conclusion
The transaction exercise demonstrates that a committed driver update remains in place and that a transaction can be rolled back after a unique-constraint error. The concurrency screenshots show a row-lock wait under READ COMMITTED, but the final UPDATE 1 in Session B is unexpected for the planned test. The concurrency result should therefore be verified again before concluding that Session B correctly observed and respected Session A's committed change. The test also demonstrates row-level locking for this specific driver record; it does not enforce a general rule that a driver can have only one trip in progress.

## Files
- [Emmanuel_Glory_Praise_301917908_P3_Transactions.sql](Emmanuel_Glory_Praise_301917908_P3_Transactions.sql)
- [Emmanuel_Glory_Praise_301917908_P3_SessionA.sql](Emmanuel_Glory_Praise_301917908_P3_SessionA.sql)
- [Emmanuel_Glory_Praise_301917908_P3_SessionB.sql](Emmanuel_Glory_Praise_301917908_P3_SessionB.sql)
- [Commit and rollback screenshot](screenshots/Emmanuel_Glory_Praise_301917908_P3_CommitRollback.png)
- [Sessions waiting screenshot](screenshots/Emmanuel_Glory_Praise_301917908_P3_SessionsWaiting.png)
- [Concurrency result screenshot](screenshots/Emmanuel_Glory_Praise_301917908_P3_ConcurrencyResult.png)

## References
- [PostgreSQL 16 Documentation: Transactions](https://www.postgresql.org/docs/16/tutorial-transactions.html)
- [PostgreSQL 16 Documentation: Transaction Isolation](https://www.postgresql.org/docs/16/transaction-iso.html)
- [PostgreSQL 16 Documentation: Unique Indexes](https://www.postgresql.org/docs/16/indexes-unique.html)