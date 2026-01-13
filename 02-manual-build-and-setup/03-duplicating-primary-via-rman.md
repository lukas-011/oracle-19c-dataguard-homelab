# RMAN Duplication (Primary → Physical Standby)

This section uses RMAN to duplicate the primary database
and create a physical standby using an active database copy.

---

## RMAN Duplication

You can run RMAN from either the primary or standby host.
In this example, RMAN is executed from the **primary server**.

> ⚠️ Prerequisites:
> - Standby instance is started in **NOMOUNT**
> - Password file exists on standby
> - Listener is running on standby
> - `db_unique_name` is different on primary and standby

---

### Connect to RMAN

```BASH
# NOTE:
# Using "rman target /" may fail depending on OS authentication.
# Use explicit SYS connection when duplicating.

rman target sys@proddb
```

```RMAN
CONNECT CATALOG rman_rc/rman_rc@rcat;
CONNECT AUXILIARY sys/<password>@proddb_st;
```

## Duplicate Database
```RMAN
DUPLICATE TARGET DATABASE FOR STANDBY FROM ACTIVE DATABASE NOFILENAMECHECK;
```
NOFILENAMECHECK is required when ASM disk group names
or file paths are the same between primary and standby.


## Managed Recovery Process (MRP)
After duplication completes, connect to the standby database
and control the Managed Recovery Process.

### Start MRP (Real-Time Apply)
```SQL
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;
```