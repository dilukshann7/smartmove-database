# SmartMove database coursework

Oracle SQL and PL/SQL for transport records, with MongoDB for feedback content and media links. Management and booking operations use short standalone PL/SQL procedures. Queries and reports read the results.

The populated `SMARTMOVE_DATABASE` schema in the local `XEPDB1` PDB contains the base coursework objects and sample data. Do not rerun the account, schema, or sample-data scripts there.

**Website integration update (2026-09-25):** Migrations `09_web_integration.sql`, `10_passenger_portal.sql`, and `11_admin_workspace.sql` are applied to `SMARTMOVE_DATABASE` in `XEPDB1`. The base schema and sample data were preserved. All schema objects compile as valid. `SMARTMOVE_DATABASE_APP` is the website login and `SMARTMOVE_DATABASE_REPORT` is reserved for reporting. Local passwords are held in ignored environment files.

**Passenger portal update:** Migration 10 adds locked whole-booking cancellation, full refund recording in the same Oracle transaction, profile updates, feedback eligibility and a unique review index. Rollback and concurrency tests are in `database/oracle/tests/`. MongoDB stores feedback content and the notification inbox. A recorded refund is not an external payout.

**Admin workspace update:** Migration 11 adds ADMIN sessions, sequences, scoped payment/refund and trip-cancellation procedures, and grants. Required management and trip operation procedures were compiled in the populated schema; the base tables and sample data were not rerun. Rollback tests exercise the workflows without retaining test records.

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
| `database/oracle/09_web_integration.sql` | One-time website integration migration; run after the base schema as SYSDBA |
| `database/oracle/10_passenger_portal.sql` | One-time passenger dashboard and feedback migration; apply after 09 |
| `database/oracle/11_admin_workspace.sql` | One-time ADMIN operations migration; apply after 10 |

Each procedure is defined once. Start with a single operation in file 07, then follow the booking example in file 08. Both practice files undo their changes at the end.

MongoDB files remain in `database/mongodb`: `setup.js` creates sample documents, `queries.js` demonstrates queries, and `sample-content.json` is a readable reference. These are mongosh examples, not Node.js programs.

## What became simpler

Short management procedures restore PL/SQL coverage across all nine operation areas listed in the coursework brief. They use ordinary INSERT, UPDATE, DELETE, IF, SELECT INTO and exceptions. The longer old drafts stay in the backup; there are no packages, dynamic SQL or duplicate procedure definitions.

The booking procedures still check trip times, occupied seats, capacity, payment totals and cancellation status. Table constraints handle duplicate IDs, missing required values, invalid references and repeated refunds. Validation errors print a message and raise an exception so the calling block stops.

The base coursework scripts are a single-session classroom example. Procedures check maintenance/trip conflicts and review eligibility, restrict rescheduling to unbooked future trips, and retain history. Whole-trip cancellation releases bookings, with refunds recorded separately. The later website migrations add passenger login, automatic hold expiry and locked passenger cancellation. The website coordinates Oracle feedback references with MongoDB content; it does not provide general cross-database transactions.

Coverage was mapped to the supplied DM2 coursework brief. This is authored database logic, not a completed application or a verified mark-band result. The ER diagram, application integration, runtime checks and presentation remain separate tasks.

## When you choose to run it later

Do not rerun setup or sample inserts in the populated local databases. This script set is for a fresh installation, not a migration. Use a separate empty test schema and distinct test accounts/role; adjust names in files 01 and 06 together before running.

1. Review the example passwords and run file 01 as an administrator in your PDB.
2. As the owner, run file 02, then `03_business_logic.sql`, `03_management_operations.sql`, `03_trip_operations.sql`, and file 04 using SQL Developer Run Script. Check compilation errors before continuing.
3. Run file 05 once. Stop on errors and roll back. Check the sample totals, then enter `COMMIT;` if correct.
4. Run file 06 after saving sample data; its DDL must not accidentally commit unfinished data changes.
5. Files 07 and 08 are optional practice. Run each in a separate session with no unrelated unsaved changes. They use IDs 90-92 and finish with `ROLLBACK;`.

Procedures do not commit. On failure, stop and roll back the pending workflow. Files 05, 07 and 08 include `WHENEVER SQLERROR` for script mode; if running selected statements instead, stop manually on errors. Creating tables/procedures/views is DDL and cannot be undone by rolling back the data.

For the already populated `SMARTMOVE_DATABASE` schema, do not rerun files 01, 02, or 05, or one-time migrations 09–11. A later base-logic update needs the three 03 files and file 06 only. Apply DDL in a session without pending changes and check compilation before examples.

No build or development server is needed.

## Backup

`backups/before-lecture-simplification-20260923-150530.zip` contains the earlier SQL and MongoDB source files. Documentation entries were removed from the archive. This is a source backup, not an export of live database data.
