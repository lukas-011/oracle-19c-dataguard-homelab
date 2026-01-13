# Standby Database Build

This section prepares the standby host for RMAN duplication
by creating a standby-specific initialization file and SPFILE.

---

## Create Standby PFILE from Primary

On the **primary database**, create a PFILE from the SPFILE
and copy it to the standby host.

```SQL
CREATE PFILE='/tmp/initproddb_st.ora' FROM SPFILE;
```
```BASH
scp /tmp/initproddb_st.ora oracle@<standby_ip>:/tmp
```

## Modify PFILE on Standby Host
On the standby server, edit the copied PFILE
```BASH
vi /tmp/initproddb_st.ora
```
Update the following parameters:
- Set DB_UNIQUE_NAME to the standby database name:
```ini
db_unique_name=proddb_st
```
- Update FAL_SERVER to point to the primary database:
```ini
fal_server=proddb
```
- Update LOG_ARCHIVE_DEST_2:
    - Change SERVICE to the primary
    - Change DB_UNIQUE_NAME to the primary
    - Ensure VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE)
- Verify or update audit_file_dest
    - Create the directory at the OS level if it does not exist
    - Ensure correct ownership and permissions
```BASH
mkdir -p /u01/app/oracle/admin/proddb_st/adump
chown oracle:oinstall /u01/app/oracle/admin/proddb_st/adump
```

## Create SPFILE on Standby
Start the standby instance in NOMOUNT mode using the PFILE
and create a standby-specific SPFILE.
```SQL
STARTUP NOMOUNT PFILE='/tmp/initproddb_st.ora';
CREATE SPFILE='+DATA/proddb_st/spfileproddb_st.ora' FROM PFILE='/tmp/initproddb_st.ora';
```

## Restart Using SPFILE
Restart the standby instance using the SPFILE to confirm
it is being read correctly.
```SQL
STARTUP NOMOUNT;
SHOW PARAMETER spfile;
EXIT;
```
**Note:** You **MUST** exit SQL*Plus before running RMAN duplication.
If the auxiliary instance remains connected, RMAN duplicate
will fail.