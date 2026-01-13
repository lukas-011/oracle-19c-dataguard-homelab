# Data Guard Protection Modes

## 1. Maximum Performance (Default)
- Prioritizes primary database performance over data protection
- Redo is transported asynchronously (ASYNC)
- Primary commits do not wait for acknowledgment from the standby
- Provides the best performance but allows for potential data loss if the primary fails
- Suitable for environments where performance is more critical than zero data loss

---

## 2. Maximum Availability
- Balances high data protection with minimal performance impact
- Redo is transported synchronously (SYNC)
- Primary commits wait for acknowledgment that redo has been received by the standby
- If the standby becomes unavailable, the primary automatically falls back to Maximum Performance mode
- Under normal conditions, provides zero data loss

---

## 3. Maximum Protection
- Guarantees zero data loss
- Redo is transported synchronously (SYNC) with AFFIRM enabled
- Primary commits wait until redo is written to disk on the standby before completing
- If redo cannot be successfully transmitted to the standby, the primary database will automatically shut down
- Requires at least one synchronous standby database to be available at all times
