# Tests a payment waiting on a concurrent cancellation of the same booking.
# The booking exists only for this test and is removed in finally.
$ErrorActionPreference = 'Stop'
$dir = Join-Path ([IO.Path]::GetTempPath()) ('smartmove-lock-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $dir | Out-Null
$setup = Join-Path $dir 'setup.sql'
$cancel = Join-Path $dir 'cancel.sql'
$payment = Join-Path $dir 'payment.sql'
$cleanup = Join-Path $dir 'cleanup.sql'
@'
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET CONTAINER=XEPDB1;
BEGIN
  smartmove_database.create_booking(990010, 1, 2);
  smartmove_database.reserve_seat(990010, 990010, 8);
  COMMIT;
END;
/
'@ | Set-Content -LiteralPath $setup
@'
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET CONTAINER=XEPDB1;
SET SERVEROUTPUT ON
DECLARE v_changed NUMBER; v_refund NUMBER;
BEGIN
  smartmove_database.web_cancel_booking(990010, 1, v_changed, v_refund);
  DBMS_OUTPUT.PUT_LINE('CANCEL_LOCKED');
  DBMS_LOCK.SLEEP(4);
  ROLLBACK;
END;
/
'@ | Set-Content -LiteralPath $cancel
@'
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET CONTAINER=XEPDB1;
SET SERVEROUTPUT ON
SET TIMING ON
BEGIN
  smartmove_database.record_payment(990010, 990010, 800, 'CASH');
  DBMS_OUTPUT.PUT_LINE('PAYMENT_AFTER_LOCK');
  ROLLBACK;
END;
/
'@ | Set-Content -LiteralPath $payment
@'
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET CONTAINER=XEPDB1;
DELETE FROM smartmove_database.payments WHERE booking_id=990010;
DELETE FROM smartmove_database.booking_status_history WHERE booking_id=990010;
DELETE FROM smartmove_database.tickets WHERE booking_id=990010;
DELETE FROM smartmove_database.bookings WHERE booking_id=990010;
COMMIT;
'@ | Set-Content -LiteralPath $cleanup
try {
  $setupOutput = & sqlplus -S '/ as sysdba' "@$setup" 2>&1
  if ($LASTEXITCODE -ne 0) { throw "Setup failed: $setupOutput" }
  $cancelJob = Start-Job -ScriptBlock { param($file) & sqlplus -S '/ as sysdba' "@$file" 2>&1 } -ArgumentList $cancel
  Start-Sleep -Milliseconds 900
  $paymentJob = Start-Job -ScriptBlock { param($file) & sqlplus -S '/ as sysdba' "@$file" 2>&1 } -ArgumentList $payment
  $jobs = @($cancelJob, $paymentJob)
  $null = $jobs | Wait-Job -Timeout 20
  $cancelOutput = Receive-Job $cancelJob
  $paymentOutput = Receive-Job $paymentJob
  Write-Output $cancelOutput
  Write-Output $paymentOutput
  if (($cancelOutput -join ' ') -notmatch 'CANCEL_LOCKED' -or ($paymentOutput -join ' ') -notmatch 'PAYMENT_AFTER_LOCK') {
    throw 'Concurrent cancellation/payment did not both complete.'
  }
  Write-Output 'PASS payment waited for cancellation lock, then proceeded after rollback'
} finally {
  if ($jobs) { $jobs | Stop-Job -ErrorAction SilentlyContinue; $jobs | Remove-Job -Force -ErrorAction SilentlyContinue }
  $cleanupOutput = & sqlplus -S '/ as sysdba' "@$cleanup" 2>&1
  Write-Output $cleanupOutput
  Remove-Item -LiteralPath $setup, $cancel, $payment, $cleanup -Force
  Remove-Item -LiteralPath $dir -Force
}
