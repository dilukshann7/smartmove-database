-- Optional procedure practice as SMARTMOVE_DATABASE after installing all objects.
-- Use a separate session with no unsaved work and saved original sample data.
-- IDs 90 and 91 must be unused. Nothing is committed.
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
SET SERVEROUTPUT ON;

-- 1. Vehicles, drivers and routes: create, update, read, delete unused records.
BEGIN
    add_vehicle(90, 'DEMO-090', 'VAN', 10);
    update_vehicle(90, 'DEMO-090', 'VAN', 12, 'ACTIVE');
    add_driver(90, 'Practice Driver', '0710000090', 'DEMO-LIC-90');
    update_driver(90, 'Practice Driver', '0710000091', 'DEMO-LIC-90');
    add_route(90, 'Kandy to Matale', 'Kandy', 'Matale', 300);
    update_route(90, 'Kandy to Matale', 350);
END;
/
SELECT * FROM vehicles WHERE vehicle_id = 90;
SELECT * FROM drivers WHERE driver_id = 90;
SELECT * FROM routes WHERE route_id = 90;
BEGIN
    delete_vehicle(90);
    delete_driver(90);
    delete_route(90);
END;
/

-- 2. User/passenger management. These hashes deliberately cannot authenticate.
BEGIN
    add_app_user(90, 'practice@example.test', 'DISABLED_DEMO_HASH', 'PASSENGER');
    add_passenger(90, 90, 'Practice Passenger', '0700000090');
    update_app_user(90, 'practice90@example.test', 'PASSENGER');
    change_password_hash(90, 'DISABLED_DEMO_HASH_CHANGED');
    update_passenger(90, 'Practice Passenger', '0700000091');
END;
/
SELECT * FROM user_details WHERE user_id = 90;
SELECT * FROM passengers WHERE passenger_id = 90;
BEGIN
    delete_passenger(90);
    delete_app_user(90);
END;
/

-- 3. Complete one service and remove a second unused schedule.
BEGIN
    schedule_maintenance(90, 3, 'Practice inspection', SYSDATE);
    update_maintenance(90, 'Practice brake inspection', SYSDATE);
    complete_maintenance(90, 1500);
    schedule_maintenance(91, 3, 'Practice future service', SYSDATE + 1);
    delete_maintenance(91);
END;
/
SELECT * FROM maintenance_records WHERE maintenance_id = 90;

-- 4. Review a confirmed, completed sample journey, then update its status.
BEGIN
    add_feedback(90, 1, 'REVIEW');
    update_feedback_status(90, 'RESOLVED');
END;
/
SELECT * FROM feedback_records WHERE feedback_id = 90;

ROLLBACK;
WHENEVER SQLERROR CONTINUE NONE
