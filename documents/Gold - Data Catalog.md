========================================================================================
                               GOLD LAYER DATA CATALOG
========================================================================================

Purpose:
The Gold Layer provides business-ready analytical views built on top of the Silver Layer,
which standardizes and cleans data from the Bronze Layer.

- Bronze: Raw CSV files loaded as-is from source systems
- Silver: Cleansed and standardized tables
- Gold: Curated, joined, and business-focused analytical views

========================================================================================
TABLE: gold.dim_customers
========================================================================================
Description:
Customer dimension containing enriched CRM and ERP data. Combines customer info,
demographics, and location data into a single standardized dimension.

Source Lineage:
- bronze.crm_cust_info.csv   → silver.crm_cust_info
- bronze.erp_cust_az12.csv   → silver.erp_cust_az12
- bronze.erp_loc_a101.csv    → silver.erp_loc_a101

Join Logic:
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid

----------------------------------------------------------------------------------------
| COLUMN NAME       | DATA TYPE | DESCRIPTION                                    | NOTES                              |
|--------------------|-----------|------------------------------------------------|------------------------------------|
| customer_key       | INT       | Surrogate key for BI joins                    | Generated via ROW_NUMBER()         |
| customer_id        | INT       | Source CRM customer ID                        | From CRM                           |
| customer_number    | NVARCHAR  | Unique CRM customer key                       | From CRM                           |
| first_name         | NVARCHAR  | Customer’s first name                         | Trimmed and standardized           |
| last_name          | NVARCHAR  | Customer’s last name                          | Trimmed and standardized           |
| country            | NVARCHAR  | Customer’s country                            | From ERP location data             |
| marital_status     | NVARCHAR  | Marital status (Married/Single/N/A)           | Normalized                         |
| gender             | NVARCHAR  | Gender (CRM preferred, ERP fallback)          | CASE + COALESCE logic              |
| birthdate          | DATE      | Date of birth                                 | Null if invalid/future date        |
| create_date        | DATETIME  | Customer record creation date                 | From CRM                           |
----------------------------------------------------------------------------------------


========================================================================================
TABLE: gold.dim_products
========================================================================================
Description:
Product dimension joining CRM product data with ERP category metadata.
Contains descriptive, categorical, and financial attributes for each product.

Source Lineage:
- bronze.crm_prd_info.csv   → silver.crm_prd_info
- bronze.erp_px_cat_g1v2.csv → silver.erp_px_cat_g1v2

Join Logic:
LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id

Filter:
WHERE pn.prd_end_dt IS NULL  -- only active products retained

----------------------------------------------------------------------------------------
| COLUMN NAME     | DATA TYPE | DESCRIPTION                               | NOTES                                |
|------------------|-----------|-------------------------------------------|--------------------------------------|
| product_key      | INT       | Surrogate key for BI joins                | Generated via ROW_NUMBER()           |
| product_id       | INT       | Product ID from CRM                       | Source field                         |
| product_number   | NVARCHAR  | Unique CRM product number                 | From CRM                             |
| product_name     | NVARCHAR  | Product name                              | Trimmed and cleaned                  |
| category_id      | NVARCHAR  | Category ID prefix                        | Derived from prd_key                 |
| category         | NVARCHAR  | Product category                          | From ERP lookup                      |
| subcategory      | NVARCHAR  | Product subcategory                       | From ERP lookup                      |
| maintenance      | NVARCHAR  | Maintenance flag                          | From ERP                             |
| cost             | DECIMAL   | Product cost                              | Nulls replaced with 0                |
| product_line     | NVARCHAR  | Product line (Mountain, Road, etc.)       | Normalized from CRM codes            |
| start_date       | DATE      | Product effective start date              | From CRM                             |
----------------------------------------------------------------------------------------


========================================================================================
TABLE: gold.fact_sales
========================================================================================
Description:
Central fact table containing all sales transactions linked to customer and product
dimensions. Derived from CRM transactional data, cleaned in the Silver layer.

Source Lineage:
- bronze.crm_sales_details.csv  → silver.crm_sales_details
- gold.dim_products             (joined)
- gold.dim_customers            (joined)

Join Logic:
LEFT JOIN gold.dim_products pr ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu ON sd.sls_cust_id = cu.customer_id

----------------------------------------------------------------------------------------
| COLUMN NAME    | DATA TYPE | DESCRIPTION                                | NOTES                                  |
|-----------------|-----------|--------------------------------------------|----------------------------------------|
| order_number    | NVARCHAR  | Unique sales order number                 | From CRM                               |
| product_key     | INT       | FK → gold.dim_products.product_key        | Surrogate join key                     |
| customer_id     | INT       | FK → gold.dim_customers.customer_id       | Surrogate join key                     |
| order_date      | DATE      | Order date                               | Converted from INT → DATE              |
| shipping_date   | DATE      | Shipment date                            | Converted from INT → DATE              |
| due_date        | DATE      | Delivery due date                        | Converted from INT → DATE              |
| sales_amount    | DECIMAL   | Total order amount                       | Recomputed if inconsistent             |
| quantity        | INT       | Quantity sold                            | From CRM                               |
| price           | DECIMAL   | Unit price                               | Derived if missing/invalid             |
----------------------------------------------------------------------------------------


========================================================================================
STAR SCHEMA RELATIONSHIPS
========================================================================================

                     +----------------------+
                     | gold.dim_customers   |
                     |----------------------|
                     | customer_key         |
                     | customer_id          |
                     | gender, country, etc |
                     +----------+-----------+
                                |
                                |
                                v
+---------------------+      +---------------------+      +----------------------+
| gold.dim_products   | ---> | gold.fact_sales     | <--- | gold.dim_customers   |
|---------------------|      |---------------------|      |----------------------|
| product_key         |      | order_number        |      | customer_id          |
| category, cost, etc |      | sales_amount, etc.  |      | country, gender, etc |
+---------------------+      +---------------------+      +----------------------+

========================================================================================
LINEAGE SUMMARY
========================================================================================

  BRONZE (Raw CSVs)  →  SILVER (Clean Tables)  →  GOLD (Analytical Views)

  crm_cust_info.csv     → silver.crm_cust_info     → gold.dim_customers
  erp_cust_az12.csv     → silver.erp_cust_az12     → gold.dim_customers
  erp_loc_a101.csv      → silver.erp_loc_a101      → gold.dim_customers

  crm_prd_info.csv      → silver.crm_prd_info      → gold.dim_products
  erp_px_cat_g1v2.csv   → silver.erp_px_cat_g1v2   → gold.dim_products

  crm_sales_details.csv → silver.crm_sales_details → gold.fact_sales

========================================================================================
DATA QUALITY & VALIDATION CHECKS
========================================================================================

| Check                          | Description                                    | Expected Result   |
|--------------------------------|------------------------------------------------|-------------------|
| Null customer_id in facts      | All facts linked to valid customers            | 0 nulls           |
| Null product_key in facts      | All facts linked to valid products             | 0 nulls           |
| Future birthdates              | Customer birthdates not beyond current date    | None              |
| Sales = quantity * price       | Sales validation consistency check             | Within tolerance  |
| Active products only           | Exclude inactive/end-dated products            | Verified          |

========================================================================================
SAMPLE QUERY
========================================================================================

SELECT
    c.country,
    p.category,
    SUM(f.sales_amount) AS total_sales,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_id = c.customer_id
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY c.country, p.category
ORDER BY total_sales DESC;

========================================================================================
Last Updated: 2025-10-12
Author: Data Engineering Team
Data Lineage: Bronze → Silver → Gold
Purpose: Business-ready layer for analytics, dashboards, and BI reporting.
========================================================================================
