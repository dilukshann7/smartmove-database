# SmartMove database coursework

Oracle SQL and PL/SQL for transport records, with MongoDB for feedback content and media links. Management and booking operations use short standalone PL/SQL procedures. Queries and reports read the results.

**The revised scripts have not been run or compiled in Oracle.** The local databases were not changed. `docs/execution-results.md` and the saved outputs describe the earlier version only.

## Read these files in order

| File | What to learn |
| --- | --- |
| `database/oracle/01_users.sql` | Database users, a role and privileges |
| `database/oracle/02_schema.sql` | 13 tables, keys, constraints and a history trigger |
| `database/oracle/03_business_logic.sql` | Seven procedures and one available-seat function |
| `database/oracle/03_management_operations.sql` | Vehicle, driver, route, user, passenger, maintenance and feedback procedures |
| `database/oracle/03_trip_operations.sql` | Reschedule, cancel, complete and delete trips; remove unpaid seats |
| `database/oracle/04_reports.sql` | Five reports using cursors, joins and totals |
| `database/oracle/05_sample_data.sql` | Small fictional dataset and procedure calls |
| `database/oracle/06_permissions.sql` | Trip/user views, procedure grants and application read access |
| `database/oracle/07_basic_operations.sql` | Optional management procedure walkthrough |
| `database/oracle/08_booking_example.sql` | Optional booking, payment, cancellation and refund walkthrough |

Each procedure is defined once. Start with a single operation in file 07, then follow the booking example in file 08. Both practice files undo their changes at the end.

MongoDB files remain in `database/mongodb`: `setup.js` creates sample documents, `queries.js` demonstrates queries, and `sample-content.json` is a readable reference. These are mongosh examples, not Node.js programs.

## What became simpler

Short management procedures restore PL/SQL coverage across all nine operation areas listed in the coursework brief. They use ordinary INSERT, UPDATE, DELETE, IF, SELECT INTO and exceptions. The longer old drafts stay in the backup; there are no packages, dynamic SQL or duplicate procedure definitions.

The booking procedures still check trip times, occupied seats, capacity, payment totals and cancellation status. Table constraints handle duplicate IDs, missing required values, invalid references and repeated refunds. Validation errors print a message and raise an exception so the calling block stops.

This is a single-session classroom example. Procedures check maintenance/trip conflicts and review eligibility, restrict rescheduling to unbooked future trips, and retain history. Whole-trip cancellation releases bookings, with refunds recorded separately. Login, automatic booking expiry and Oracle/MongoDB synchronization remain application work. See `docs/database-operations.md` for the coverage map and limits.

Coverage was mapped to the supplied DM2 coursework brief. This is authored database logic, not a completed application or a verified mark-band result. The ER diagram, application integration, runtime checks and presentation remain separate tasks.

## When you choose to run it later

Do not rerun setup or sample inserts in the populated local databases. This script set is for a fresh installation, not a migration. Use a separate empty test schema and distinct test accounts/role; adjust names in files 01 and 06 together before running.

1. Review the example passwords and run file 01 as an administrator in your PDB.
2. As the owner, run file 02, then `03_business_logic.sql`, `03_management_operations.sql`, `03_trip_operations.sql`, and file 04 using SQL Developer Run Script. Check compilation errors before continuing.
3. Run file 05 once. Stop on errors and roll back. Check the sample totals, then enter `COMMIT;` if correct.
4. Run file 06 after saving sample data; its DDL must not accidentally commit unfinished data changes.
5. Files 07 and 08 are optional practice. Run each in a separate session with no unrelated unsaved changes. They use IDs 90-92 and finish with `ROLLBACK;`.

Procedures do not commit. On failure, stop and roll back the pending workflow. Files 05, 07 and 08 include `WHENEVER SQLERROR` for script mode; if running selected statements instead, stop manually on errors. Creating tables/procedures/views is DDL and cannot be undone by rolling back the data.

For the already populated baseline, a later update needs the three 03 files and file 06 only; do not rerun account, table or sample setup. Apply DDL in a session without pending changes and check compilation before examples.

See `docs/verification.md` for checks to perform later. No build or development server is needed.

## Backup

`backups/before-lecture-simplification-20260923-150530.zip` contains all 30 project files before this change, including uncommitted work. Its contents were compared byte for byte with the originals before editing. Git internals and older backup archives are excluded. This is a source backup, not an export of live database data.
