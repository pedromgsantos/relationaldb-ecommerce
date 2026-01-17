# Storing and Retrieving Data – Final Project

Project for the Storing and Retrieving Data course, Masters in Data Science and Advanced Analytics, NOVA IMS


---

## Project Authors

Pedro Santos – 20250399 – [20250399@novaims.unl.pt](mailto:20250399@novaims.unl.pt)  
Miguel Correia – 20250381 – [20250381@novaims.unl.pt](mailto:20250381@novaims.unl.pt)  
Pedro Fernandes – 20250418 – [20250418@novaims.unl.pt](mailto:20250418@novaims.unl.pt)  
Tiago Duarte – 20250360 – [20250360@novaims.unl.pt](mailto:20250360@novaims.unl.pt)

---

## Project Overview

This project implements a complete relational database system for a fictitious business. The database supports core business operations including transactions, inventory management, customer ratings, and automated invoice generation.

---

## Repository Contents

- **ProjectSRD.sql** – Complete database creation script with schema, triggers, sample data, and queries
- **EER_Diagram.png** – Entity-Relationship Diagram showing database structure
  
---

## Database Features
### Entity-Relationship Design
- **8+ normalized tables** following 3NF principles
- Customer rating system integrated
- Comprehensive relationship mapping
- Clear naming conventions for entities and attributes

### Triggers
1. **Update Trigger** – Automatically updates inventory stock levels on product sales
2. **Audit Log Trigger** – Records all critical operations in log table for compliance

### Business Queries
Contains five analytical queries addressing CEO-level business questions that queries span multiple years of transaction data and which results support strategic decision-making.

### Invoice Generation
Two MySQL views working together:
- **Invoice Header View** – Customer details, invoice number, date, totals
- **Invoice Details View** – Line items with descriptions, quantities, prices
- Dynamically generated from transactional tables
---
