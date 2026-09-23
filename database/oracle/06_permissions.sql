-- Run as SMARTMOVE_OWNER after saving the sample data.
-- A simple view shows scheduled trips and their remaining seats.
CREATE OR REPLACE VIEW public_trip_details AS
SELECT t.trip_id, r.route_name, t.departure_at, t.fare,
       available_seats(t.trip_id) AS remaining_seats
FROM trips t JOIN routes r ON t.route_id = r.route_id
WHERE t.status = 'SCHEDULED';

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
-- Classroom inserts and table edits are done through SMARTMOVE_OWNER.
