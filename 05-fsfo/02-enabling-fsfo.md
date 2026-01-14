# Enabling Fast-Start Failover (FSFO)

> This section covers how to start Fast-Start Failover in your
> Data Guard configuration


## Enable Fast-Start Failover

### Define FSFO target
- Defines when primary fails, what database to failover to
```SQL
DGMGRL> EDIT DATABASE test SET PROPERTY FastStartFailoverTarget = 'test_s';
DGMGRL> EDIT DATABASE test_s SET PROPERTY FastStartFailoverTarget = 'test';

-- Validate
DGMGRL> show database verbose test;
DGMGRL> show database verbose test_s;
```
test_s - standby database

test - primary database

### Define FastStartFailoverThreshold
- This lets the broker know when to initiate automatic failover. What is the time (in seconds) that FSFO will wait before initiating failover
```SQL
DGMGRL> EDIT CONFIGURATION SET PROPERTY FastStartFailoverThreshold=30;
```

### Define FastStartFailoverLagLimit
- This defines how much time (in seconds) data we are ready to lose in case the Data Guard is in Max Performance
```SQL
DGMGRL> EDIT CONFIGURATION SET PROPERTY FastStartFailoverLagLimit=30;
```

### Enable FSFO. Never start observer on production database
```SQL
-- On standby server
DGMGRL> ENABLE FAST_START FAILOVER;
-- Validate
DGMGRL> show configuration;

OS> dgmgrl sys/<password>@<primary_db> "START OBSERVER" &
```