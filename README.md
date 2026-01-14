# Oracle 19c Data Guard Homelab

> This repository documents an Oracle Database 19c Data Guard homelab with a focus on **observability**, **operational awareness**, and **real-world DBA/SRE workflows** rather than just automated setup scripts.

---

## Table of Contents

- [Project Overview](#project-overview)  
- [Requirements](#requirements)
- [Data Guard Concepts](#data-guard-concepts)
- [Manual Primary & Standby Setup](#manual-primary--standby-setup)
- [Manual Switchover & Failover](#manual-switchover--failover)
- [Data Guard Broker](#data-guard-broker)  
- [Fast-Start-Failover (FSFO)](#fast-start-failover-fsfo) 
- [Standby Conversions](#standby-conversions) 
- [Health Checks](#health-checks)  
- [License](#license)  

---

## Project Overview

This homelab is designed to simulate **real-world Oracle Data Guard environments**.  
The goal is to explore:

- Physical, Snapshot, Active Data Guard, and Logical Standby databases  
- Manual and automated failover / switchover workflows  
- Data Guard Broker configuration  
- Fast-Start-Failover (FSFO) with an observer  
- Health checks and operational verification  

It is **not intended for production automation**, but instead as a learning and observability exercise.

## Requirements

- Oracle Database 19c (Primary + Standby)
- Oracle Data Guard enabled
- Optional: Data Guard Broker license for FSFO
- Network connectivity between nodes
- Flashback Database enabled for certain operations  

> Note: Active Data Guard requires an additional license in production environments.

---

## Data Guard Concepts

Located in `01-data-guard-concepts/`:

- Types of standby databases:
  - Physical
  - Snapshot
  - Active Data Guard
  - Logical
- Redo transport and apply modes:
  - Archive transport
  - Redo log transport (LGWR SYNC/ASYNC)
  - Redo entry transport
- Data Guard roles and operational considerations
- A diagram made in draw.io of the Data Guard architecture

---

## Manual Primary & Standby Setup

- Manual primary and standby creation steps are located in `02-manual-build-and-setup/`.  
- Includes:
  - Enabling archive logs and force logging  
  - Configuring redo transport  
  - Creating password files
  - Configuring the listeners
  - RMAN duplication of the primary  
  - Starting/stopping MRP (Managed Recovery Process)  

---

## Manual Switchover & Failover

Located in `03-manual-failover-and-switchover/`:

- Manual switchover  
- Manual failover to standby in case of primary failure  
- Rebuilding the original primary:
  - RMAN duplicate
  - Flashback (if enabled)  

---

## Data Guard Broker

Located in `04-dg-broker/`:

- Listener configuration for primary and standby  
- Broker setup and registration  
- Enabling the configuration  
- Network and redo considerations  
- Failover and switchover using the DGMGRL

---

## Fast-Start-Failover (FSFO)

Located in `05-fsfo/`:

- Dedicated observer on a third host  
- Automatic failover and optional auto-reinstate  
- Requirements:
  - Data Guard Broker
  - Flashback Database for auto-reinstate  
- Considerations:
  - Network latency  
  - SYNC transport mode impact  

---

## Standby Conversions

Located in `standby_role_conversions/`:

- Physical ↔ Snapshot Standby
- Physical ↔ Active Data Guard

Includes **SQL commands, validation steps, and recommendations**.

---

## Health Checks

Located in `health_checks/`:

- **Primary**: redo generation, archive destinations, transport status  
- **Standby**: applied redo, MRP status, apply/transport lag, gaps  
- Scripts include **expected output guidelines**  
- Designed to be safe for production or lab environments  

---

## License

This project is for **educational purposes**.  
Feel free to fork and adapt for your own learning homelabs.  

