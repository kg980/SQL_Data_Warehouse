
-- Quality Checks
-- Run these checks on the Bronze Data to identify problems to transform.
-- Run the same checks again on the transformed silver data (replace 'bronze' with 'silver' in all queries should work fine). Should get no errors.


/* 
============================================
CRM
============================================
*/


-- Check for Nulls/Duplicates in Primary Key
-- Expectation: None

SELECT cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL



-- Spot check known bad record 
-- Expecting no dupliate:

SELECT 
* 
FROM silver.crm_cust_info
WHERE cst_id = 29466



-- Check for unwanted spaces
-- Expectation: None

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- Standardization & Consistency (for columns with low cardinality, e.g. Gender, Marital Status)

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info




-- Check for Null or Negative numbers

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL


-- Check for invalid dates. 
-- Expectation: There should not be overlap in start/end dates over multiple records for a single product, as it can only have one price set at a time.
-- Start date cannot be after End date.
-- Start date cannot be NULL (but End can be NULL if it is current)
-- Solution Option: replace end date with the start date of the NEXT Record (-1 day) so terms are always handed over and can never overlap. NULL if no next record.
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt


--- Invalid dates in YYYYMMDD format
SELECT
NULLIF(sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 OR sls_order_dt > 20500101 OR sls_order_dt < 19000101


--- Data consistency: Sales, Quantity, Price
-- >> Sales === Quantity * Price
-- >> Values must != NULL, 0 or -ve

SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,

CASE WHEN sls_sales IS NULL OR sls_sales < = 0 OR sls_sales != sls_quantity * ABS(sls_price)
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <= 0
	THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price
END AS sls_price

FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 or sls_quantity <= 0 OR sls_price <= 0
order by sls_sales, sls_quantity, sls_price








/* 
============================================
ERP
============================================
*/

-- Want to remove NAS prefix from cid. Other tables dont use.

SELECT 
cid,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END cid,
bdate,
gen 
FROM bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%'



--- out of range dates

SELECT DISTINCT
bdate,
CASE WHEN bdate > GETDATE() THEN NULL
	ELSE bdate
END bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Standardization & Consistency
SELECT DISTINCT 
gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	ELSE 'N/A'
END AS gen
FROM bronze.erp_cust_az12





SELECT
REPLACE(cid, '-', '') cid,
cntry
FROM bronze.erp_loc_a101 

-- standardize
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
ORDER BY cntry

/*
WHERE REPLACE(cid, '-', '') NOT IN 
(SELECT cst_key FROM silver.crm_cust_info)
*/