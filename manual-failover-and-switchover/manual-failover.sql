---------------------------------------------------------------------------
-- 1. Fail the primary
---------------------------------------------------------------------------
SHUTDWON ABORT;

---------------------------------------------------------------------------
-- 2. Stop the MRP process on the standby
---------------------------------------------------------------------------
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

---------------------------------------------------------------------------
-- 3. Finish the recovery process by applying all the redo logs using this command on the standby
---------------------------------------------------------------------------
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE FINISH;

---------------------------------------------------------------------------
-- 4. Check switchover status of the standby
---------------------------------------------------------------------------
SELECT switchover_status FROM v$database;

---------------------------------------------------------------------------
-- 5. Switchover the standby to a primary if switchover status is ok
---------------------------------------------------------------------------
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;

---------------------------------------------------------------------------
-- 6. Open the standby which has now become the new primary
---------------------------------------------------------------------------
ALTER DATABASE OPEN;




-- Part II, rebuilding the failed primary

---------------------------------------------------------------------------
-- 1. Find the SCN number when the standby was converted into primary
---------------------------------------------------------------------------
-- On new primary (use to_char since SCN can be too big for output)
SELECT to_char(standby_became_primary_scn) FROM v$database;

---------------------------------------------------------------------------
-- 2. Start listener on new standby (old primary)
---------------------------------------------------------------------------
OS> lsnrctl start

---------------------------------------------------------------------------
-- 3. Mount the new standby
---------------------------------------------------------------------------
STARTUP MOUNT;

---------------------------------------------------------------------------
-- 4. Flashback to the SCN number queried from the new primary
---------------------------------------------------------------------------
FLASHBACK DATABASE TO SCN 1234567;

---------------------------------------------------------------------------
-- 5. Convert new standby from "primary mode" to standby mode
---------------------------------------------------------------------------
ALTER DATABASE CONVERT TO PHYSICAL STANDBY;

---------------------------------------------------------------------------
-- 6. Shutdown new standby, mount database, start MRP
---------------------------------------------------------------------------
SHUT IMMEDIATE;

STARTUP MOUNT;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION USING CURRENT LOGFILE;

---------------------------------------------------------------------------
-- 6. Validate
---------------------------------------------------------------------------
-- Flashback is on for both primary and standby
SELECT flashback_on FROM v$database;

-- MRP process is online for the standby database
SELECT process, status FROM v$managed_standby WHERE process LIKE 'MRP%';

-- Confirm logfiles are in sync
-- primary
archive log list;
SELECT status, gap_status FROM v$archive_dest_status WHERE dest_id = 2;

-- Standby
SELECT process, status, sequence# FROM v$managed_standby;
SELECT sequence#, applied, first_time, next_time, name, filename FROM v$archived_log ORDER BY sequence#;