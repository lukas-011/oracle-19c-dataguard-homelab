# Steps to Convert Physical Standby to Snapshot Standby

> Snapshot Standby allows temporary read-write access for testing
> while preserving the ability to revert back to a physical standby
> using Flashback Database.
---
## Prerequisites
- Flashback Database must be enabled on the standby
- Standby must be in **MOUNT** mode
- Managed Recovery Process (MRP) must be stopped

## Stop the MRP process
```SQL
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
```

## Convert Physical Standby to Snapshot Standby
```SQL
ALTER DATABASE CONVERT TO SNAPSHOT STANDBY;
```
Validate
```SQL
SELECT name, open_mode, database_role FROM v$database;

SELECT name, scn, database_incarnation#, guarantee_flashback_database, storage_size FROM v$restore_point;
```

## Open The Snapshot Standby
```SQL
ALTER DATABASE OPEN;
```

## Perform Testing
Snapshot Standby allows full read-write operations such as:
- Schema changes
- Patching
- Data manipulation
- Performance Testing