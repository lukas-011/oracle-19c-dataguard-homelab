# Convert Snapshot Standby to Physical Standby

> This restores a snapshot standby back to a physical standby.
> All changes made during snapshot mode will be discarded.

---

## Prerequisites
- Standby must be in snapshot mode
- Flashback Database enabled
- Database in mount mode

## Shutdown and Startup the Database in Mount Mode
```SQL
SHUTDOWN IMMEDIATE;
EXIT;
```
```BASH
sqlplus / as sysdba
```
```SQL
STARTUP MOUNT;
```

## Convert the Snapshot Standby to a Physical Standby
```SQL
ALTER DATABASE CONVERT TO PHYSICAL STANDBY;
```
Validate restore point was dropped
```SQL
SELECT name, scn, database_incarnation#, guarantee_flashback_database, storage_size FROM v$restore_point;
```

## (Optional) Bounce the Database
Not required but done for clarity
```SQL
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
```

## Start the MRP Process
```SQL
alter database recover managed standby database using current logfile disconnect from session;
```

## Validate Data Guard Configuration
On Primary
```SQL
ARCHIVE LOG LIST;
```
On Standby
```SQL
SELECT name, open_mode FROM v$database;
SELECT process, status, sequence# FROM v$managed_standby;
```