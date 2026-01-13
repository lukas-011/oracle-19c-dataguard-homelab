# Convert Physical Standby to Active Data Guard

> Active Data Guard allows the standby database to remain open for read-only operations
> while continuously applying redo from the primary in real time.

---

## Prerequisites
- **Active Data Guard license** (required in production environments)
- Standby database must be a **physical standby**
- Managed Recovery Process (MRP) can be running (will be stopped in the steps below)
- Database must have **Flashback Database enabled** (recommended)

---

## Steps

### Stop Managed Recovery on Standby
```SQL
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
```
Stops redo apply so the standby can be opened for read-only operations.

## Open the Standby Database in Read-Only Mode
```sql
ALTER DATABASE OPEN;
```
Standby opens in READ ONLY mode by default.

## Start Read-Time Apply (MRP)
```SQL
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;
```

## Validadate Active Data Guard Configuration
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