# Primary Database Configuration

After creating the primary database, the following configuration
steps are required to prepare it for Data Guard.

---

## Enable ARCHIVELOG Mode

The primary database must run in ARCHIVELOG mode to support redo
shipping to the standby database.
``` SQL
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ARCHIVE LOG LIST;
```

## Enable Force Logging
Force logging ensures that all database changes generate redo,
even if users attempt to use NOLOGGING operations.
```SQL
ALTER DATABASE FORCE LOGGING;
SELECT name, force_logging FROM v$database;
```

## Configure Standby File Management
This ensures that datafile additions and removals on the primary
are automatically reflected on the standby database.
```SQL
ALTER SYSTEM SET standby_file_management='AUTO';
```

## Add Standby Redo Logs on Primary
Standby redo logs are required for redo transport and real-time
apply. It is recommended to configure one more standby redo log
group than online redo log groups.
```SQL
ALTER DATABASE ADD STANDBY LOGFILE GROUP 11
'/u02/oradata/TEST/redo11.log' SIZE 50M;
```

## Configure Password File for Standby
A password file is required for RMAN duplication and redo transport
authentication.
```SQL
ALTER SYSTEM SET remote_login_passwordfile=EXCLUSIVE SCOPE=SPFILE;
EXIT;
```
```BASH
cd $ORACLE_HOME/dbs
# Create a copy of the primary and name it the standby
orapwd file=orapwproddb_st password=<sys_password>
# Copy the standby over to the standby host
scp orapwproddb_st oracle@<standby_ip>:$ORACLE_HOME/dbs
```

## Verify DB_UNIQUE_NAME
Each database in a Data Guard configuration must have a unique
DB_UNIQUE_NAME.
```SQL
SHOW PARAMETER db_unique_name;
```

## Enable Flashback Database
Flashback enables fast reinstatement of the former primary database
after a failover.
```SQL
ALTER SYSTEM SET db_recovery_file_dest_size=45G;
ALTER DATABASE FLASHBACK ON;
SELECT flashback_on FROM v$database;
```
Note:
Without Flashback Database, reinstating a failed primary
requires a full RMAN rebuild.

## Configure Network Connectivity
Configure TNS entries on both primary and standby hosts.

test = primary

test_s = standby
```BASH
vi $ORACLE_HOME/network/admin/tnsname.ora
```
```ini
proddb = 
	(DESCRIPTION = 
		(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.111)(PORT = 1521))
		(CONNECT_DATA = 
			(SERVER = DEDICATED)
			(SERVICE_NAME = test)
		)
	)
	
test_s = 
	(DESCRIPTION = 
		(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.112)(PORT = 1521))
		(CONNECT_DATA = 
			(SERVER = DEDICATED)
			(SERVICE_NAME = test_s)
		)
	)
```

## Configure the Listener on Primary and Standby
EXTPROC1521 is for Data Guard

test = primary

test_s = standby
```BASH
cd $ORACLE_HOME/network/admin
vi listener.ora
```
```ini
LISTENER = 
	(DESCRIPTION_LIST =
		(DESCRIPTION =
			(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.112) (PORT = 1521))
			(ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
		)
	)
	
SID_LIST_LISTENER = 
	(SID_LIST = 
		(SID_DESC = 
			(GLOBAL_DBNAME = test_s)
			(SID_NAME = test_s)
			(ORACLE_HOME = /u02)
		)
		(SID_DESC = 
			(GLOBAL_DBNAME = test_s_DGMGRL)
			(SID_NAME = test_s)
			(ORACLE_HOME = /u02)
		)
	)
```

## Configure Redo Transport
Redo transport is configured using LOG_ARCHIVE_DEST_n. This
destination is valid only when the database is in the PRIMARY role.
```SQL
ALTER SYSTEM SET log_archive_dest_2 =
'SERVICE=test_s ASYNC
 VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE)
 DB_UNIQUE_NAME=test_s';
```
Redo Transport Modes

**LGWR SYNC** – Synchronous redo transport (Maximum Availability / Protection)

**LGWR ASYNC** – Asynchronous redo transport (Maximum Performance)

**ARCH** – Archived redo log transport

## Specify How Redo is Shipped
**How to tell if we are in** Archive transport, Redo log file transport, or redo entry transport?
- We can specify
- **LGWR SYNC** - redo entry transport. LNS reads directly from the redo log buffer to get redo log entries and is not dependent on LGWR. (**Max Performance**)
- **LGWR ASYNC** - redo log file transport. Which means LNS will read from ORLFs and send them to the RFS (preferred in most DBs). LNS needs to wait for LGWR to write redo log files to OLRFs to then send
- **If you don't specify** then the archive logs are being transferred causing a gap which is archive transport. An archiver process, instead of archiving it will send archive files to the RFS




**valid_for** means which types of files we are sending to our log_archive_dest_n
- We can define if we want to copy our online_logfiles or archive_logfiles

We have 30 log destinations we can use
- Log dest 1 is to the archive logs on the primary
- Log dest 2 is to the archive logs on the standby

We need to keep dest2 disabled on standby because we don't want standby shipping logs
- This is why we have to put **primary_role** in the **valid_for** statement so we know it's only valid to ship if it is a primary database

This parameter is what starts the LNS service when a failover occurs

## Setup FAL (Fetch Archive Log) server
This parameter tells the RFS as to where it will get archives from (FAL Server=proddb_st) in case there is a gap
```SQL
-- Primary
ALTER SYSTEM SET fal_server='test_s';

-- Standby
ALTER SYSTEM SET fal_server='test';
```

## Configure Data Guard Configuration
Setup Data Guard configuration on primary: This parameter will let primary database know which databases are in data guard configuration
```SQL
ALTER SYSTEM SET log_archive_config='dg_config=(test,test_s)';
```
