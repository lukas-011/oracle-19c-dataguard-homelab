-- ⚠️ Ensure you have a recent backup before performing a switchover

---------------------------------------------------------------------------
-- 1. Check the primary and standby for log gaps
---------------------------------------------------------------------------

-- Primary: check destination 2 (typically the standby)
SELECT status, gap_status FROM v$archive_dest_status WHERE dest_id = 2;

-- Standby: check Data Guard statistics
SELECT name, value, datum_time FROM v$dataguard_stats;

---------------------------------------------------------------------------
-- 2. Convert primary to standby
---------------------------------------------------------------------------

-- Check switchover status on primary
SELECT switchover_status FROM v$database;

-- Commit switchover to standby
ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;

-- Shutdown primary (optional, but ensures role change)
SHUTDOWN IMMEDIATE;

-- Mount database as standby
STARTUP MOUNT;

---------------------------------------------------------------------------
-- 3. Convert standby to primary
---------------------------------------------------------------------------

-- Check switchover status on standby
SELECT switchover_status FROM v$database;

-- Commit switchover to primary
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;

-- Open the new primary
ALTER DATABASE OPEN;

---------------------------------------------------------------------------
-- 4. Start MRP on new standby
---------------------------------------------------------------------------

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

---------------------------------------------------------------------------
-- 5. Validate
---------------------------------------------------------------------------

-- Confirm MRP is online on standby
SELECT process, status FROM v$managed_standby WHERE process LIKE 'MRP%';

-- Confirm flashback is enabled on both primary and standby
SELECT flashback_on FROM v$database;

-- Verify log sequence gap
SELECT MAX(sequence#) AS last_applied FROM v$archived_log WHERE applied='YES';