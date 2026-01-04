---------------------------------------------------------------------------
-- 1. Check the primary and standby for log gaps
---------------------------------------------------------------------------

-- Primary
SELECT status, gap_status FROM v$archive_dest_status WHERE dest_id = 2;

-- Standby
SELECT name, value, datum_time FROM v$dataguard_stats;

---------------------------------------------------------------------------
-- 2. Convert primary to standby
---------------------------------------------------------------------------

-- Primary
SELECT switchover_status FROM v$database;

ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;
-- Note, session shutdown is for your session not the users

SHUTDOWN IMMEDIATE;

STARTUP MOUNT;

---------------------------------------------------------------------------
-- 3. Convert standby to primary
---------------------------------------------------------------------------
SELECT switchover_status FROM v$database;

ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;

ALTER DATABASE OPEN;

---------------------------------------------------------------------------
-- 4. Start MRP on new standby
---------------------------------------------------------------------------

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION USING CURRENT LOGFILE;


---------------------------------------------------------------------------
-- 5. Validate
---------------------------------------------------------------------------

-- Confirm MRP is online

SELECT process, status FROM v$managed_standby WHERE process LIKE 'MRP%';

-- Confirm flashback is on for both standby and primary databases

SELECT flashback_on FROM v$database;