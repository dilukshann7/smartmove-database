-- Run as SYSDBA in XEPDB1. Every data change in this test is rolled back.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET CONTAINER = XEPDB1;
SET SERVEROUTPUT ON

DECLARE
    v_before NUMBER;
    v_after NUMBER;
    v_changed NUMBER;
    v_refund NUMBER;
    v_count NUMBER;
    v_status VARCHAR2(100);
    PROCEDURE ensure(p_ok BOOLEAN, p_message VARCHAR2) IS
    BEGIN
        IF NOT p_ok THEN RAISE_APPLICATION_ERROR(-20990, p_message); END IF;
    END;
BEGIN
    -- Trip 2 has eight seats, two issued in the seed data.
    v_before := smartmove_database.available_seats(2);
    smartmove_database.create_booking(990001, 1, 2);
    smartmove_database.reserve_seat(990001, 990001, 4);
    smartmove_database.reserve_seat(990002, 990001, 5);
    ensure(smartmove_database.available_seats(2) = v_before - 2, 'Two seats were not held');
    smartmove_database.web_cancel_booking(990001, 1, v_changed, v_refund);
    ensure(v_changed = 1 AND v_refund = 0, 'Pending cancellation result');
    ensure(smartmove_database.available_seats(2) = v_before, 'Pending seats not released');
    SELECT COUNT(*) INTO v_count FROM smartmove_database.tickets
    WHERE booking_id = 990001 AND status = 'CANCELLED';
    ensure(v_count = 2, 'Pending cancellation did not release every seat');
    smartmove_database.web_cancel_booking(990001, 1, v_changed, v_refund);
    ensure(v_changed = 0 AND v_refund = 0, 'Pending repeat not idempotent');
    DBMS_OUTPUT.PUT_LINE('PASS pending multi-seat cancellation and repeat');

    -- Booking 2 is the seed data's paid, confirmed two-seat booking.
    smartmove_database.web_cancel_booking(2, 2, v_changed, v_refund);
    ensure(v_changed = 1 AND v_refund = 1600, 'Paid cancellation result');
    SELECT COUNT(*) INTO v_count FROM smartmove_database.tickets
    WHERE booking_id = 2 AND status = 'CANCELLED';
    ensure(v_count = 2, 'Paid cancellation did not release every seat');
    SELECT COUNT(*) INTO v_count FROM smartmove_database.refunds
    WHERE payment_id = 2 AND amount = 1600;
    ensure(v_count = 1, 'Full refund record missing');
    smartmove_database.web_cancel_booking(2, 2, v_changed, v_refund);
    ensure(v_changed = 0 AND v_refund = 1600, 'Paid repeat not idempotent');
    SELECT COUNT(*) INTO v_count FROM smartmove_database.refunds WHERE payment_id = 2;
    ensure(v_count = 1, 'Duplicate refund created');
    DBMS_OUTPUT.PUT_LINE('PASS paid multi-seat cancellation, full refund and repeat');

    BEGIN
        smartmove_database.web_cancel_booking(1, 1, v_changed, v_refund);
        RAISE_APPLICATION_ERROR(-20990, 'Past departure accepted');
    EXCEPTION WHEN OTHERS THEN
        IF SQLCODE != -20021 THEN RAISE; END IF;
    END;
    DBMS_OUTPUT.PUT_LINE('PASS departure cutoff');

    BEGIN
        smartmove_database.web_cancel_booking(2, 1, v_changed, v_refund);
        RAISE_APPLICATION_ERROR(-20990, 'Foreign cancellation accepted');
    EXCEPTION WHEN OTHERS THEN
        IF SQLCODE != 100 THEN RAISE; END IF;
    END;
    DBMS_OUTPUT.PUT_LINE('PASS cancellation ownership');

    -- Temporarily remove the seed review, then prove one review per booking.
    DELETE FROM smartmove_database.feedback_records WHERE feedback_id = 1;
    smartmove_database.web_submit_feedback(990001, 1, 1, 'REVIEW');
    BEGIN
        smartmove_database.web_submit_feedback(990002, 1, 1, 'REVIEW');
        RAISE_APPLICATION_ERROR(-20990, 'Duplicate review accepted');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL;
    END;
    BEGIN
        smartmove_database.web_submit_feedback(990003, 2, 2, 'REVIEW');
        RAISE_APPLICATION_ERROR(-20990, 'Uncompleted trip review accepted');
    EXCEPTION WHEN OTHERS THEN
        IF SQLCODE != -20024 THEN RAISE; END IF;
    END;
    smartmove_database.web_submit_feedback(990004, 3, 1, 'COMPLAINT');
    BEGIN
        smartmove_database.web_submit_feedback(990005, 3, 2, 'COMPLAINT');
        RAISE_APPLICATION_ERROR(-20990, 'Foreign complaint accepted');
    EXCEPTION WHEN OTHERS THEN
        IF SQLCODE != 100 THEN RAISE; END IF;
    END;
    DBMS_OUTPUT.PUT_LINE('PASS review eligibility, duplicate prevention and complaint ownership');

    smartmove_database.web_update_profile(1, 'Rollback Profile', '0771234567');
    SELECT full_name INTO v_status FROM smartmove_database.passengers WHERE passenger_id = 1;
    ensure(v_status = 'Rollback Profile', 'Profile update failed');
    DBMS_OUTPUT.PUT_LINE('PASS profile update');

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('ROLLBACK complete');
EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
