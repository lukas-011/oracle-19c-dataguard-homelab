-- General database info
SELECT name, open_mode, database_role
FROM v$database;

-- Is flashback on?
SELECT flashback_on FROM v$database;

-- Check the maximum sequence number applied on this database
SELECT MAX(sequence#) AS max_applied_sequence
FROM v$archived_log 
WHERE applied='YES';

-- Check the maximum sequence on this database
SELECT MAX(sequence#) AS max_sequence
FROM v$archived_log;

-- Check Data Guard process health
SELECT process, status, sequence#
FROM v$managed_standby;

-- Check redo gap
SELECT status, gap_status
FROM v$archive_dest_status
WHERE dest_id = 2;

-- Check apply lag
SELECT name, value, unit
FROM v$dataguard_stats
WHERE name IN ('transport lag', 'apply lag');