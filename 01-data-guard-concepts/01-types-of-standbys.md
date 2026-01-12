# Types of Standby Databases

## 1. Physical Standby
- Maintains an exact, block-for-block copy of the primary database
- Redo data is applied using Redo Apply (MRP)
- Typically runs in **MOUNT** mode, but can be opened **READ ONLY** when using Active Data Guard
- Provides the highest level of data protection and is the most commonly used standby type

---

## 2. Snapshot Standby
- A physical standby that is temporarily converted to a snapshot standby
- Log apply services (MRP) are stopped during this mode
- Database is opened **READ WRITE**
- Allows testing and temporary changes without affecting the primary database
- When converted back to a physical standby, all local changes are discarded and redo apply resumes
- In production environments, it is recommended to have an additional standby available for failover while a snapshot standby is in use

---

## 3. Active Data Guard
- A physical standby opened **READ ONLY** while redo apply continues in real time
- Allows read-only workloads (reporting, queries, backups) to be offloaded from the primary database
- Reduces load on the primary database while maintaining synchronization
- Requires an **Active Data Guard option license** from Oracle

---

## 4. Logical Standby
- Redo data from the primary database is transformed into SQL statements
- SQL Apply is used to apply changes to the standby database
- Database remains **OPEN READ WRITE**
- The logical standby database does not need to be structurally identical to the primary
- Not all data types and database objects are supported
- More complex to configure and maintain compared to physical standbys
