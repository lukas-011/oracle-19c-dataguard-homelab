## Configure Data Guard Broker
> This section covers configuring Data Guard Broker (DGMGRL),
> enabling centralized management, monitoring, and role transitions
> for primary and standby databases.

### Configure the Listener on the Primary Database

Data Guard Broker requires a **statically registered service**
so it can connect to the database even when it is in **MOUNT** mode.

The `_DGMGRL` service must be defined in `listener.ora`
on both the **primary** and **standby** databases.

#### listener.ora (Primary)
```ini
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.111)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = test)
      (SID_NAME = test)
      (ORACLE_HOME = /u02)
    )
    (SID_DESC =
      (GLOBAL_DBNAME = test_DGMGRL)
      (SID_NAME = test)
      (ORACLE_HOME = /u02)
    )
  )
```
## Configure Data Guard Broker

> Data Guard Broker centrally manages redo transport, apply services,
> monitoring, and role transitions. Once enabled on the primary,
> the configuration is automatically replicated to the standby.

> These steps are executed primarily from the **primary database**.

---

### Stop Managed Recovery on Standby
```sql
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
```

Clear Manual Redo Transport Configuration

Data Guard Broker manages redo transport destinations automatically.
Any manually configured LOG_ARCHIVE_DEST_n parameters must be cleared
on both the primary and standby.

```sql
-- Primary
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='' SCOPE=BOTH SID='*';

-- Standby
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='' SCOPE=BOTH SID='*';
```

### Enable Data Guard Broker

Enable the broker on both the primary and standby databases.
```sql
-- Primary
ALTER SYSTEM SET dg_broker_start=TRUE;
SHOW PARAMETER dg_broker_start;

-- Standby
ALTER SYSTEM SET dg_broker_start=TRUE;
SHOW PARAMETER dg_broker_start;
```


### Register the Primary Database with Broker

From the primary host, connect to DGMGRL and create the broker configuration.

```bash
dgmgrl sys/sys@proddb
```

```sql
CREATE CONFIGURATION my_dg AS PRIMARY DATABASE IS test CONNECT IDENTIFIER IS test;

SHOW CONFIGURATION;
```

Configuration parameters:

my_dg — Name of the Data Guard configuration

test — Primary database SID / db_unique_name

test (connect identifier) — TNS alias for the primary database

### Register the Standby Database

Add the standby database to the broker configuration from the primary.
```sql
ADD DATABASE test_s AS CONNECT IDENTIFIER IS test_s;

SHOW CONFIGURATION;
```

### Enable the Broker Configuration
```sql
ENABLE CONFIGURATION;
```

You may see ORA-16809 after enabling the configuration.
This indicates a transient transport lag or network latency warning
and does not prevent normal Data Guard operation.