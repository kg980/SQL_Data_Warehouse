-- ========================================================================================
-- Quality Checks – GOLD Layer
-- Run these checks after creating the Gold Views using: EXEC gold.load_gold;
-- Purpose: Validate transformation logic, joins, and data consistency in business-ready data.
-- ========================================================================================


/* 
============================================
DIM_CUSTOMERS
============================================
*/

-- Check for Duplicates in Surrogate Key
-- Expectation: Each customer_key should be unique.
SELECT customer_key, COUNT(*) 
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- Check for Nulls in Primary Identifiers
-- Expectation: customer_id and customer_number should never be NULL.
SELECT *
FROM gold.dim_customers
WHERE customer_id IS NULL OR customer_number IS NULL;


-- Check Gender Standardization
-- Expectation: Gender should only contain standardized values ('Male', 'Female', 'N/A')
SELECT DISTINCT gender
FROM gold.dim_customers;


-- Check for Missing Country Information
-- Expectation: Most customers should have a country populated (from ERP)
SELECT COUNT(*) AS missing_country_count
FROM gold.dim_customers
WHERE country IS NULL OR TRIM(country) = '';


-- Check for Unrealistic Birthdates
-- Expectation: Birthdate should be between 1920 and current date.
SELECT *
FROM gold.dim_customers
WHERE birthdate < '1920-01-01' OR birthdate > GETDATE();


-- Check for Null or Invalid Create Dates
-- Expectation: create_date should not be NULL.
SELECT *
FROM gold.dim_customers
WHERE create_date IS NULL;


/* 
============================================
DIM_PRODUCTS
============================================
*/

-- Check for Duplicates in Product Key
-- Expectation: product_key should be unique.
SELECT product_key, COUNT(*)
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- Check for Nulls in Product Identifiers
-- Expectation: product_id and product_number should not be NULL.
SELECT *
FROM gold.dim_products
WHERE product_id IS NULL OR product_number IS NULL;


-- Check for Missing or Negative Costs
-- Expectation: cost must be >= 0.
SELECT *
FROM gold.dim_products
WHERE cost IS NULL OR cost < 0;


-- Check Category and Subcategory Mapping
-- Expectation: category_id should always map to a valid category/subcategory.
SELECT *
FROM gold.dim_products
WHERE category_id IS NULL OR category IS NULL OR subcategory IS NULL;


-- Check for Historical Products (should be excluded)
-- Expectation: Only active products (prd_end_dt IS NULL in silver) should appear.
SELECT *
FROM gold.dim_products
WHERE start_date IS NULL;


/* 
============================================
FACT_SALES
============================================
*/

-- Check for Null Joins (Integrity)
-- Expectation: Every sales record should join successfully to a product and customer.
SELECT *
FROM gold.fact_sales
WHERE product_key IS NULL OR customer_id IS NULL;


-- Validate Dates
-- Expectation: order_date <= shipping_date <= due_date (if present)
SELECT *
FROM gold.fact_sales
WHERE (shipping_date < order_date)
   OR (due_date < order_date)
   OR (due_date < shipping_date);


-- Check for Negative or Null Values in Sales Metrics
-- Expectation: sales_amount, quantity, and price must be > 0.
SELECT *
FROM gold.fact_sales
WHERE sales_amount <= 0 OR quantity <= 0 OR price <= 0
OR sales_amount IS NULL OR quantity IS NULL OR price IS NULL;


-- Consistency Check: Sales = Quantity * Price
-- Expectation: The derived measure should match.
SELECT *
FROM gold.fact_sales
WHERE ABS(sales_amount - (quantity * price)) > 0.01;


-- Check for Orphaned Orders (Duplicate Order Numbers)
-- Expectation: order_number should be unique per line.
SELECT order_number, COUNT(*)
FROM gold.fact_sales
GROUP BY order_number
HAVING COUNT(*) > 1;


/*
============================================
SUMMARY COUNTS
============================================
*/

-- Compare Record Counts for Sanity
-- Expectation: Fact table should have <= CRM Sales Detail count from Silver
SELECT
    (SELECT COUNT(*) FROM silver.crm_sales_details) AS silver_sales_count,
    (SELECT COUNT(*) FROM gold.fact_sales) AS gold_sales_count,
    (SELECT COUNT(*) FROM gold.dim_customers) AS gold_customer_count,
    (SELECT COUNT(*) FROM gold.dim_products) AS gold_product_count;


-- Check that joins reduced data as expected (no inflation)
-- Expectation: gold.fact_sales count should not exceed silver.crm_sales_details
SELECT
    CASE 
        WHEN (SELECT COUNT(*) FROM gold.fact_sales) <= (SELECT COUNT(*) FROM silver.crm_sales_details)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS join_integrity_check;
