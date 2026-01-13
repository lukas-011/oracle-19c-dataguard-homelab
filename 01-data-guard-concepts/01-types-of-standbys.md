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

**Why use a snapshot standby**
- A snapshot standby allows a physical standby to be opened read-write for testing or development using real production data. All changes are discarded when the database is converted back to a physical standby
- Consider maintaining at least two standby databases when converting one to a snapshot standby, since a snapshot standby cannot provide failover protection while in snapshot mode

*What happens when you convert a physical standby to a snapshot standby?*
- A **guaranteed restore point** is created at the time of conversion
- The standby database is **opened read-write**
- **Managed Recovery Process (MRP) stops**
- Redo is **still shipped from the primary**, but **not applied** while in snapshot mode
- The standby can be used for **testing or write operations**

*What happens when a snapshot standby is converted back to a physical standby?*
- The standby database is **flashed back to the guaranteed restore point**
- All changes made during snapshot mode are **discarded**
- Redo apply **resumes**
- Archived and standby redo logs are **applied until the standby is synchronized with the primary**

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
