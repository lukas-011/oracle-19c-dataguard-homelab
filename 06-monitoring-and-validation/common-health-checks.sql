set LINESIZE 500;
-- General database info
SELECT name, open_mode, protection_mode, database_role, switchover_status, fs_failover_status
FROM v$database;

-- Check if flashback is on
SELECT flashback_on 
FROM v$database;

-- Apply lag & Transport lag check
SELECT name, value, unit 
FROM v$dataguard_stats;

-- Check the status of data guard processes
SELECT process, status, sequence# 
FROM v$managed_standby;