# Convert Active Data Guard to Physical Standby

> This procedure returns an Active Data Guard standby database back to a standard physical standby.
> The database will be in **MOUNT mode**, redo apply resumes, and read-only access is removed.

---

## Prerequisites
- Standby must currently be **Active Data Guard**  
- Managed Recovery Process (MRP) can be running (will be stopped in the steps below)  
- Flashback Database enabled (recommended)  

---

## Steps

## Stop Managed Recovery on Standby
```sql
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
```

## Shutdown the Standby Database
```SQL
SHUTDOWN IMMEDIATE;
```

## Startup Standby in Mount Mode
```SQL
STARTUP MOUNT;
```
The database is now mounted and ready for redo apply.

## Start Managed Recovery Process (MRP)
```SQL
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;
```

Redo transport and apply from the primary resumes, restoring standard physical standby operation.

## Validate Data Guard Configuration
On Primary
```SQL
ARCHIVE LOG LIST;
```
On Standby
```SQL
-- Confirm database role and open mode
SELECT name, open_mode FROM v$database;

-- Check all managed standby processes
SELECT process, status, sequence# FROM v$managed_standby;
```