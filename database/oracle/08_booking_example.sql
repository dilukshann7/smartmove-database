-- Optional walkthrough as SMARTMOVE_OWNER after saving the original samples.
-- Use a separate session with no unsaved work. IDs 90 must be unused.
-- Trip 2 must still be in the future, and its seat 3 must be free.
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
SET SERVEROUTPUT ON;

-- 1. Book one seat and pay the fare recorded on trip 2.
DECLARE
    ticket_price NUMBER;
BEGIN
    SELECT fare INTO ticket_price FROM trips WHERE trip_id = 2;
    create_booking(90, 1, 2);
    reserve_seat(90, 90, 3);
    record_payment(90, 90, ticket_price, 'CASH');
END;
/
SELECT * FROM bookings WHERE booking_id = 90;
SELECT * FROM tickets WHERE booking_id = 90;
SELECT * FROM payments WHERE booking_id = 90;

-- 2. Cancel and refund. Cancellation also releases the seat.
BEGIN
    cancel_booking(90);
    process_refund(90, 90, 'Practice cancellation');
END;
/
SELECT * FROM refunds WHERE payment_id = 90;
SELECT * FROM booking_status_history WHERE booking_id = 90;

-- 3. Call the function and the five reports.
BEGIN
    DBMS_OUTPUT.PUT_LINE('Trip 2 free seats: ' || available_seats(2));
    popular_routes;
    revenue;
    passenger_history(1);
    maintenance_due(SYSDATE);
    trip_occupancy;
END;
/

-- Undo practice data. The original sample totals should remain unchanged.
ROLLBACK;
WHENEVER SQLERROR CONTINUE NONE
