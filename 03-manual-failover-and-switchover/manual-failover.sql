-- Part I, failover the primary database to the standby
---------------------------------------------------------------------------
-- 1. Fail the primary database
---------------------------------------------------------------------------
SHUTDOWN ABORT;

---------------------------------------------------------------------------
-- 2. Stop the Managed Recovery Process (MRP) on the standby
---------------------------------------------------------------------------
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

---------------------------------------------------------------------------
-- 3. Finish applying all redo logs on the standby
---------------------------------------------------------------------------
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE FINISH;

---------------------------------------------------------------------------
-- 4. Check switchover status of the standby
---------------------------------------------------------------------------
SELECT switchover_status FROM v$database;

---------------------------------------------------------------------------
-- 5. Commit the standby to become primary if switchover_status = 'TO PRIMARY'
---------------------------------------------------------------------------
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;

---------------------------------------------------------------------------
-- 6. Open the new primary
---------------------------------------------------------------------------
ALTER DATABASE OPEN;




-- Part II, rebuilding the failed primary
---------------------------------------------------------------------------
-- 1. Find the SCN when standby became primary
---------------------------------------------------------------------------
-- Use TO_CHAR because SCN can be large
SELECT to_char(standby_became_primary_scn) FROM v$database;

---------------------------------------------------------------------------
-- 2. Start listener on the old primary server (now new standby)
---------------------------------------------------------------------------
-- OS> lsnrctl start

---------------------------------------------------------------------------
-- 3. Mount the database on the old primary
---------------------------------------------------------------------------
STARTUP MOUNT;

---------------------------------------------------------------------------
-- 4. Flashback the database to the SCN obtained from the new primary
---------------------------------------------------------------------------
FLASHBACK DATABASE TO SCN 1234567; -- replace with actual SCN

---------------------------------------------------------------------------
-- 5. Convert the flashed-back database to a physical standby
---------------------------------------------------------------------------
ALTER DATABASE CONVERT TO PHYSICAL STANDBY;

---------------------------------------------------------------------------
-- 6. Start Managed Recovery Process (MRP)
---------------------------------------------------------------------------
SHUTDOWN IMMEDIATE;

STARTUP MOUNT;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

---------------------------------------------------------------------------
-- 6. Validate
---------------------------------------------------------------------------
-- Confirm flashback is enabled
SELECT flashback_on FROM v$database;

-- Confirm MRP is online
SELECT process, status FROM v$managed_standby WHERE process LIKE 'MRP%';

-- Confirm log shipping and apply status

-- Primary
ARCHIVE LOG LIST; 
SELECT status, gap_status FROM v$archive_dest_status WHERE dest_id = 2;

-- Standby
SELECT process, status, sequence# FROM v$managed_standby;

SELECT sequence#, applied, first_time, next_time, name, filename FROM v$archived_log ORDER BY sequence#;