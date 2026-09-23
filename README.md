# SmartMove database coursework

A simple Oracle and MongoDB database example based on the topics in your supplied `skill.md`. The Oracle scripts and MongoDB examples were run locally on 23 September 2026. Compilation, sample reports and the recorded validation checks passed. See `docs/execution-results.md` for results and connection details.

## What to read first

1. `database/oracle/02_schema.sql` - tables and a status-history trigger.
2. `database/oracle/03_business_logic.sql` - separate procedures for trips, bookings, seats, payments, cancellations, refunds and maintenance; one function counts available seats.
3. `database/oracle/04_reports.sql` - five reports using cursors and `DBMS_OUTPUT`.
4. `database/oracle/05_sample_data.sql` - small, numbered examples showing how the procedures work.
5. `database/mongodb/setup.js` and `queries.js` - simple documents, inserts, searches, averages and optional CRUD practice.

## When you are ready to run it manually

Use a fresh Oracle schema. These files replace the earlier design; they do not upgrade an existing database.

Your local setup is already loaded. Do not rerun the user, schema or sample-data setup files in the existing databases. The steps below are for a new installation.

1. Edit the example passwords in `01_users.sql`, then run it as an administrator connected to your PDB, such as XEPDB1.
2. Connect as `SMARTMOVE_OWNER` and run `02_schema.sql`, `03_business_logic.sql`, `04_reports.sql`, then `05_sample_data.sql` using Run Script in SQL Developer.
3. Read the output and inspect the rows. If successful, enter `COMMIT;`. If an error occurs, stop and enter `ROLLBACK;` before fixing and retrying the data changes. Table and procedure definitions are not undone by this rollback.
4. Run `06_permissions.sql` to create the view and grant permissions.
5. Open mongosh, enter `use smartmove`, then paste the commands from `setup.js` once. Try the commands in `queries.js`. These are mongosh examples, not Node.js files.

The procedures print expected validation failures. Read their messages before moving to the next step. They do not save or undo the whole workflow for you. An unexpected Oracle error also means you should stop and roll back the pending changes.

## Simple booking flow

Create a booking, reserve one or more seats, then record the full payment. All IDs are entered manually. For example, after loading the sample data, these unused IDs book seat 3 on trip 2:

```sql
SET SERVEROUTPUT ON;
BEGIN
    create_booking(4, 1, 2);
    reserve_seat(5, 4, 3);
    record_payment(4, 4, 800, 'CASH');
END;
/
```

Read the output before entering `COMMIT;` or `ROLLBACK;`. This example changes the report totals, so check the original sample results in `docs/verification.md` first.

## What was simplified

Packages became standalone procedures. Reports now print text. Dates use `DATE`, seats use numbers, and sample rows have manual IDs. MongoDB uses plain documents instead of schema validators and index setup.

This version is for a classroom demonstration using one database session at a time. It keeps multiple seats per booking, but uses one full payment and one full refund. Automatic booking expiry, partial refunds, simultaneous-booking protection and automatic Oracle/MongoDB synchronization are not included. Pending seats remain reserved until the booking is paid or cancelled. Tagged keyword matching replaces full-text search.

The Next.js application and login system are not included. `.env.example` is only a future application template. The original files are preserved in `backups/before-simplification-*.zip`.

See `docs/database-design.md` for the table relationships, `docs/verification.md` for expected examples, and `docs/backup-restore.md` for a short backup guide.
