# Performing Switchover and Failover in Oracle Data Guard

## Performing a Switchover

A switchover is a planned role reversal between the primary and standby databases.

```SQL
DGMGRL> SWITCHOVER TO <sid_name>;
```
<sid_name> is the SID of the target standby database that will become the new primary.

The operation is performed using Data Guard Broker and does not require manual recovery steps.

## Performing a Failover

A failover is an unplanned operation used when the primary database is no longer available.

### Kill the Primary Database

Simulate or handle a primary database failure by terminating the PMON process:
```BASH
ps -ef | grep pmon

kill -9 <pid_of_pmon>
```
This immediately crashes the primary database.

### Fail Over to the Standby

Connect to the standby database and initiate the failover using Data Guard Broker.
```sql
DGMGRL> show configuration;
DGMGRL> FAILOVER TO test_s;
DGMGRL> show configuration;
```
test_s is the standby database that will be promoted to primary.

Validate the configuration after the failover completes.

### Rebuild the Former Primary Database

After a failover, the old primary must be rebuilt before it can rejoin the configuration.

There are two supported methods:

**Rebuild from scratch**
- Use RMAN DUPLICATE to recreate the database as a standby.

**Flashback Database**
- Only possible if Flashback Database was enabled prior to the failure.

When using Data Guard Broker, the rebuild can be automated with a single command.
```sql
-- Start the failed primary in MOUNT mode

-- On the new primary database
DGMGRL> show configuration;

DGMGRL> reinstate database <failed_primary_name>;
```
The reinstate command automatically converts the failed primary into a standby.