-- Run as SMARTMOVE_OWNER after all three 03_*.sql files, reports and saved sample data.
-- A simple view shows scheduled trips and their remaining seats.
CREATE OR REPLACE VIEW public_trip_details AS
SELECT t.trip_id, r.route_name, t.departure_at, t.fare,
       available_seats(t.trip_id) AS remaining_seats
FROM trips t JOIN routes r ON t.route_id = r.route_id
WHERE t.status = 'SCHEDULED' AND t.departure_at > SYSDATE;

GRANT SELECT ON public_trip_details TO smartmove_app;
GRANT SELECT ON public_trip_details TO smartmove_reporting;

GRANT EXECUTE ON schedule_trip TO smartmove_app;
GRANT EXECUTE ON create_booking TO smartmove_app;
GRANT EXECUTE ON reserve_seat TO smartmove_app;
GRANT EXECUTE ON record_payment TO smartmove_app;
GRANT EXECUTE ON cancel_booking TO smartmove_app;
GRANT EXECUTE ON process_refund TO smartmove_app;
GRANT EXECUTE ON complete_maintenance TO smartmove_app;
GRANT EXECUTE ON available_seats TO smartmove_app;

GRANT EXECUTE ON popular_routes TO smartmove_reporting;
GRANT EXECUTE ON revenue TO smartmove_reporting;
GRANT EXECUTE ON passenger_history TO smartmove_reporting;
GRANT EXECUTE ON maintenance_due TO smartmove_reporting;
GRANT EXECUTE ON trip_occupancy TO smartmove_reporting;

-- Another user calls an owner's procedure as SMARTMOVE_OWNER.procedure_name(...).
-- The trusted application server calls procedures for writes; it checks user roles/ownership.

-- Management operations for the trusted application server.
GRANT EXECUTE ON add_vehicle TO smartmove_app;
GRANT EXECUTE ON update_vehicle TO smartmove_app;
GRANT EXECUTE ON add_driver TO smartmove_app;
GRANT EXECUTE ON update_driver TO smartmove_app;
GRANT EXECUTE ON add_route TO smartmove_app;
GRANT EXECUTE ON update_route TO smartmove_app;
GRANT EXECUTE ON add_app_user TO smartmove_app;
GRANT EXECUTE ON update_app_user TO smartmove_app;
GRANT EXECUTE ON change_password_hash TO smartmove_app;
GRANT EXECUTE ON add_passenger TO smartmove_app;
GRANT EXECUTE ON update_passenger TO smartmove_app;
GRANT EXECUTE ON delete_vehicle TO smartmove_app;
GRANT EXECUTE ON delete_driver TO smartmove_app;
GRANT EXECUTE ON delete_route TO smartmove_app;
GRANT EXECUTE ON delete_passenger TO smartmove_app;
GRANT EXECUTE ON delete_app_user TO smartmove_app;
GRANT EXECUTE ON schedule_maintenance TO smartmove_app;
GRANT EXECUTE ON update_maintenance TO smartmove_app;
GRANT EXECUTE ON delete_maintenance TO smartmove_app;
GRANT EXECUTE ON add_feedback TO smartmove_app;
GRANT EXECUTE ON update_feedback_status TO smartmove_app;
GRANT EXECUTE ON reschedule_trip TO smartmove_app;
GRANT EXECUTE ON cancel_trip TO smartmove_app;
GRANT EXECUTE ON complete_trip TO smartmove_app;
GRANT EXECUTE ON delete_trip TO smartmove_app;
GRANT EXECUTE ON remove_reserved_ticket TO smartmove_app;

-- Read access for application screens, without exposing password hashes.
CREATE OR REPLACE VIEW user_details AS
SELECT user_id, email, role FROM app_users;
GRANT SELECT ON user_details TO smartmove_app;
GRANT SELECT ON vehicles TO smartmove_app;
GRANT SELECT ON drivers TO smartmove_app;
GRANT SELECT ON routes TO smartmove_app;
GRANT SELECT ON passengers TO smartmove_app;
GRANT SELECT ON trips TO smartmove_app;
GRANT SELECT ON bookings TO smartmove_app;
GRANT SELECT ON tickets TO smartmove_app;
GRANT SELECT ON payments TO smartmove_app;
GRANT SELECT ON refunds TO smartmove_app;
GRANT SELECT ON maintenance_records TO smartmove_app;
GRANT SELECT ON feedback_records TO smartmove_app;
GRANT SELECT ON booking_status_history TO smartmove_app;
