-- Run with SQL*Plus as SYSDBA. All test data changes are rolled back.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET CONTAINER=XEPDB1;
SET SERVEROUTPUT ON
DECLARE
  v_payment NUMBER; v_amount NUMBER; v_changed NUMBER; v_refunds NUMBER; v_count NUMBER;
  PROCEDURE ensure(p_ok BOOLEAN, p_message VARCHAR2) IS
  BEGIN IF NOT p_ok THEN RAISE_APPLICATION_ERROR(-20991,p_message); END IF; END;
BEGIN
  INSERT INTO smartmove_database.app_users(user_id,email,password_hash,role)
  VALUES(990100,'admin-rollback@example.test','scrypt:test:test','ADMIN');
  INSERT INTO smartmove_database.web_admin_sessions(session_hash,user_id,expires_at)
  VALUES('test-admin-session',990100,SYSTIMESTAMP+INTERVAL '1' DAY);
  SELECT COUNT(*) INTO v_count FROM smartmove_database.web_admin_login WHERE user_id=990100;
  ensure(v_count=1,'Admin login view failed');
  SELECT COUNT(*) INTO v_count FROM smartmove_database.web_admin_login WHERE user_id=1;
  ensure(v_count=0,'Passenger entered admin login view');
  SELECT COUNT(*) INTO v_count FROM smartmove_database.web_passenger_login WHERE user_id=990100;
  ensure(v_count=0,'Admin entered passenger login view');
  DBMS_OUTPUT.PUT_LINE('PASS admin role and session');

  smartmove_database.add_route(990101,'Rollback Route','Test A','Test B',400);
  smartmove_database.update_route(990101,'Updated Route',450);
  smartmove_database.add_vehicle(990101,'TEST-ADMIN-11','VAN',10);
  smartmove_database.add_driver(990101,'Rollback Driver','0711111111','TEST-LIC-11');
  smartmove_database.schedule_trip(990101,990101,990101,990101,SYSDATE+3,SYSDATE+3+2/24);
  BEGIN
    smartmove_database.schedule_maintenance(990101,990101,'Conflict check',SYSDATE+3);
    RAISE_APPLICATION_ERROR(-20991,'Conflicting maintenance accepted');
  EXCEPTION WHEN OTHERS THEN IF SQLCODE != 1 THEN RAISE; END IF; END;
  smartmove_database.reschedule_trip(990101,990101,990101,SYSDATE+4,SYSDATE+4+2/24);
  smartmove_database.delete_trip(990101);
  smartmove_database.schedule_maintenance(990101,990101,'Routine',SYSDATE+4);
  smartmove_database.delete_maintenance(990101);
  smartmove_database.delete_driver(990101);
  smartmove_database.delete_vehicle(990101);
  smartmove_database.delete_route(990101);
  DBMS_OUTPUT.PUT_LINE('PASS guarded route, trip, fleet and maintenance edits');

  smartmove_database.create_booking(990100,1,2);
  smartmove_database.reserve_seat(990100,990100,4);
  smartmove_database.web_admin_record_payment(990100,'CASH',v_payment,v_amount);
  ensure(v_amount=800,'Payment must be full fare');
  SELECT COUNT(*) INTO v_count FROM smartmove_database.tickets
    WHERE booking_id=990100 AND status='ISSUED';
  ensure(v_count=1,'Ticket was not issued');
  smartmove_database.cancel_booking(990100);
  smartmove_database.web_admin_record_refund(990100,v_changed,v_amount);
  ensure(v_changed=1 AND v_amount=800,'Eligible refund missing');
  smartmove_database.web_admin_record_refund(990100,v_changed,v_amount);
  ensure(v_changed=0 AND v_amount=800,'Repeated refund must be idempotent');
  SELECT COUNT(*) INTO v_count FROM smartmove_database.refunds WHERE payment_id=v_payment;
  ensure(v_count=1,'Duplicate refund record');
  DBMS_OUTPUT.PUT_LINE('PASS payment, ticket issue and one full refund');

  smartmove_database.web_admin_cancel_trip(2,v_changed,v_refunds);
  ensure(v_changed=1 AND v_refunds=1,'Trip cancellation refund count');
  SELECT COUNT(*) INTO v_count FROM smartmove_database.tickets
    WHERE booking_id=2 AND status='CANCELLED';
  ensure(v_count=2,'Trip cancellation did not release every paid seat');
  SELECT COUNT(*) INTO v_count FROM smartmove_database.refunds
    WHERE payment_id=2 AND amount=1600;
  ensure(v_count=1,'Trip cancellation did not record full refund');
  smartmove_database.web_admin_cancel_trip(2,v_changed,v_refunds);
  ensure(v_changed=0 AND v_refunds=0,'Repeated trip cancellation');
  DBMS_OUTPUT.PUT_LINE('PASS atomic trip cancellation and repeat');

  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('ROLLBACK complete');
EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE;
END;
/
