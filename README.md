# SQL_Data_Warehouse

Welcome to the SQL Data Warehouse repository! This project showcases the implementation of a modern data warehouse using SQL Server, adhering to the Medallion Architecture (Bronze, Silver, Gold layers). It's designed to transform raw business data into structured, analytics-ready datasets.

### Project Overview

This repository demonstrates the end-to-end process of building a data warehouse:
- **Data Ingestion:** Extracting raw data from source systems.
- **Data Transformation:** Cleaning, enriching, and structuring data.
- **Data Modeling:** Designing fact and dimension tables optimized for analytical queries.
- **Analytics & Reporting:** Creating SQL-based reports and dashboards for actionable insights.

### Technologies Used
- SQL Server: Relational database management system.
- SQL Server Management Studio (SSMS): Integrated environment for managing SQL infrastructure.

### Repository Structure
- bronze/: Raw data ingestion scripts.
- silver/: Data transformation scripts.
- gold/: Data modeling and reporting scripts.
- README.md: Project documentation (you are here, hello!).

### Specifications
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: focus on latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics


### Project Architecture
The data warehouse follows a Medallion Architecture with three distinct layers:
- Bronze Layer: Raw, unprocessed data ingested directly from source systems.
- Silver Layer: Cleaned and transformed data, ready for analysis.
- Gold Layer: Aggregated and business-ready datasets for reporting and analytics.

<img width="932" height="609" alt="Architecture Diagram drawio" src="https://github.com/user-attachments/assets/e7f19b90-531f-4222-bc3c-8bf599eca851" />


Data Flow Diagram

<img width="661" height="403" alt="Data Flow Diagram drawio" src="https://github.com/user-attachments/assets/325976d2-75fe-4b1c-aebd-7a8b90a9d963" />

Integration Model Diagram

<img width="701" height="531" alt="Integration Model Diagram drawio" src="https://github.com/user-attachments/assets/56fbe2b4-9a10-4d9d-bcd5-f06cd925fcfa" />

Star Diagram

<img width="721" height="442" alt="Star Diagram - Gold drawio" src="https://github.com/user-attachments/assets/d5823d28-3637-4010-bd2f-65dc29e4d3b4" />
