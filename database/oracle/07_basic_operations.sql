-- Optional CRUD practice as SMARTMOVE_OWNER after saving sample data.
-- Use a separate session with no unsaved work. IDs 90 must be unused.
-- Run Script stops and rolls back on error; successful practice also rolls back.
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
SET SERVEROUTPUT ON;

-- 1. Vehicles: CREATE a record, READ it, UPDATE it, DELETE it.
INSERT INTO vehicles VALUES (90, 'DEMO-090', 'VAN', 10, 'ACTIVE');
SELECT * FROM vehicles WHERE vehicle_id = 90;
UPDATE vehicles SET seat_count = 12 WHERE vehicle_id = 90;
DELETE FROM vehicles WHERE vehicle_id = 90;
-- Change capacity or delete a vehicle only while it has no trip/service history.
-- Foreign keys reject deletion of vehicles referenced by other tables.

-- 2. Drivers.
INSERT INTO drivers VALUES (90, 'Practice Driver', '0710000090', 'DEMO-LIC-90');
SELECT * FROM drivers WHERE driver_id = 90;
UPDATE drivers SET phone = '0710000091' WHERE driver_id = 90;
DELETE FROM drivers WHERE driver_id = 90;

-- 3. Routes. A changed base fare applies to newly scheduled trips only.
INSERT INTO routes VALUES (90, 'Kandy to Matale', 'Kandy', 'Matale', 300);
SELECT * FROM routes WHERE route_id = 90;
UPDATE routes SET base_fare = 350 WHERE route_id = 90;
DELETE FROM routes WHERE route_id = 90;

-- 4. Application users and passengers. This is sample data, not a login system.
INSERT INTO app_users VALUES (90, 'practice@example.test', 'DISABLED_DEMO_HASH', 'PASSENGER');
INSERT INTO passengers VALUES (90, 90, 'Practice Passenger', '0700000090');
SELECT p.full_name, p.phone, u.email
FROM passengers p JOIN app_users u ON p.user_id = u.user_id
WHERE p.passenger_id = 90;
UPDATE passengers SET phone = '0700000091' WHERE passenger_id = 90;
UPDATE app_users SET email = 'practice90@example.test' WHERE user_id = 90;
-- Delete the child first. Keep passengers with booking history.
DELETE FROM passengers WHERE passenger_id = 90;
DELETE FROM app_users WHERE user_id = 90;

-- 5. Maintenance. Check trip/service dates manually before scheduling work.
INSERT INTO maintenance_records (maintenance_id, vehicle_id, maintenance_type, scheduled_date)
VALUES (90, 3, 'Practice inspection', TRUNC(SYSDATE));
UPDATE maintenance_records SET maintenance_type = 'Practice brake inspection'
WHERE maintenance_id = 90;
BEGIN
    complete_maintenance(90, 1500);
END;
/
SELECT * FROM maintenance_records WHERE maintenance_id = 90;
-- Retain completed service records; remove unused future schedules only.

-- 6. Feedback reference. Booking 1 is a confirmed, completed sample journey.
-- Check review eligibility manually. Store text/ratings in MongoDB separately.
INSERT INTO feedback_records (feedback_id, booking_id, feedback_type)
VALUES (90, 1, 'REVIEW');
UPDATE feedback_records SET status = 'RESOLVED' WHERE feedback_id = 90;
SELECT * FROM feedback_records WHERE feedback_id = 90;

-- Undo every practice change, including the trigger/history effects.
ROLLBACK;
WHENEVER SQLERROR CONTINUE NONE
