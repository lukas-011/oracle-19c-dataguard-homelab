# About Fast-Start Failover (FSFO)

> This section covers considerations when configuring the
> Fast-Start Failover (FSFO) observer for your Data Guard configuration,
> along with definitions of key FSFO concepts.

## Observer

- FSFO requires an **observer process**
- The observer:
  - Monitors the health of the primary database
  - Communicates through Data Guard Broker
  - Should run on a **separate third host**, not on the primary or standby
- If the primary database becomes unavailable and failover conditions are met,
  the observer initiates an automatic failover to the standby database

## Failover and Reinstate

- FSFO provides:
  - Automatic failover
  - Automatic reinstatement of the former primary (if Flashback Database is enabled)
- Automatic reinstatement is conditional and may require manual intervention
  if Flashback Database or other requirements are not met

## Benefits

- Eliminates manual intervention during primary database outages
- Reduces downtime and human error
- Provides fast, predictable, and consistent failover behavior

## Considerations and Disadvantages

- Requires Data Guard Broker
- Requires Flashback Database for automatic reinstatement
- Requires careful configuration to avoid split-brain scenarios
- SYNC transport modes may impact performance, though FSFO itself has minimal overhead
- Network issues can trigger a failover if the observer cannot confirm primary health

## Best Practices

- Run the observer on a dedicated third server
- Never run the observer on the primary or standby database
- Regularly monitor observer health and Data Guard Broker status
