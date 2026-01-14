-- What is the last generated sequence?
SELECT thread#, MAX(sequence#) AS last_generated
FROM v$log_history
GROUP BY thread#;

-- Check standby archive log destination
SELECT dest_id, status, error
FROM v$archive_dest_status
WHERE target = 'STANDBY';

-- Check transport health
SELECT dest_id, destination, status, error
FROM v$archive_dest;

-- When was the last log switched
SELECT TO_CHAR(MAX(first_time), 'YYYY-MM-DD HH24:MI:SS') AS last_log_switch
FROM v$archived_log;

-- 3. Check the status of data guard processes
SELECT process, status, sequence# 
FROM v$managed_standby;