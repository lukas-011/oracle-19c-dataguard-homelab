## Verify Standby Configuration
> This section covers post-build verification, redo apply modes,
> and ongoing standby health checks.

### On Both Primary and Standby
```SQL
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT;
-- When you use DISCONNECT, the SQL prompt continues in another session
-- otherwise your session becomes the recovery session for the MRP

-- On both primary and standby
set lines 500;
SELECT * FROM v$dataguard_status ORDER BY TIMESTAMP;
SELECT dest_id, status, destination, error FROM v$archive_dest WHERE dest_id<=2;

-- If you see any ORA error, do this on primary
ALTER SYSTEM SET log_archive_dest_state_2='DEFER';
ALTER SYSTEM SET log_archive_dest_state_2='ENABLE';
SELECT dest_id, status, destination, error FROM v$archive_dest WHERE dest_id<=2;
```
### On Primary
```SQL
SELECT sequence#, first_time, next_time, applied, archived FROM v$archived_log WHERE dest_id = 2 ORDER BY first_time;

ARCHIVE LOG LIST;

SELECT status, gap_status FROM v$archive_dest_status WHERE dest_id = 2;
```


### On Standby
```SQL

SELECT process, status, sequence# FROM v$managed_standby;

SELECT sequence#, applied, first_time, next_time, name, filename FROM v$archived_log ORDER BY sequence#;
```


## Specify How Redo Is Applied On Standby
```SQL
-- Archived redo apply: waits for a log switch before applying redo
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT;

--- This is for real time redo apply. The standby applies redo directly from the primary's current redo log. It doesn't wait for a log switch
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;
```





**Configure Archive Deletion Policy**
> Prevents RMAN from deleting archive logs on the primary
> until they are applied on all standby databases.

### On primary
```BASH
rman target /
```
```SQL
configure archivelog deletion policy to applied on all standby;
```

