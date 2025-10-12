# SQL_Data_Warehouse

Welcome to the SQL Data Warehouse repository! 
🥉🥈🥇
This project showcases the implementation of a modern data warehouse using SQL Server, adhering to the Medallion Architecture (Bronze, Silver, Gold layers). It's designed to transform raw business data into structured, analytics-ready datasets.
🥉🥈🥇

---

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
- 🥉 `bronze/`: Raw data ingestion scripts.
- 🥈 `silver/`: Data transformation scripts.
- 🥇 `gold/`: Data modeling and reporting scripts.
- `README.md`: Project documentation (you are here, hello!).

---

# Specifications
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

<img width="1010" height="658" alt="Architecture Diagram drawio" src="https://github.com/user-attachments/assets/50be1637-c3c0-4005-90ad-d547379ca767" />



### Data Lineage

<img width="741" height="471" alt="Data Flow Diagram drawio" src="https://github.com/user-attachments/assets/8fb262ad-3e87-47a8-9d1b-8d70cbc60bc4" />

### Integration Model Diagram

<img width="781" height="575" alt="Integration Model Diagram drawio" src="https://github.com/user-attachments/assets/a468b84c-fc86-44db-9cae-c6128648c312" />

### Star Diagram

<img width="781" height="481" alt="Star Diagram - Gold drawio" src="https://github.com/user-attachments/assets/e351abf9-bf50-4855-a912-045981f130fa" />


---

📊 Sample Queries

Here are some sample queries to get you started:

Top 10 Customers by Sales:

```
SELECT TOP 10 customer_id, SUM(sales_amount) AS total_sales
FROM gold.fact_sales
GROUP BY customer_id
ORDER BY total_sales DESC;
```

Product Sales Trends:

```
SELECT product_id, YEAR(order_date) AS year, SUM(sales_amount) AS annual_sales
FROM gold.fact_sales
GROUP BY product_id, YEAR(order_date)
ORDER BY year, product_id;
```
