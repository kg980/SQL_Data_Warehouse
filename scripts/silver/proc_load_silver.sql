--- Silver Data Transformations
/*
========================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
========================================================================================

Script Purpose:
	Performs quality checks for data consistency, dtandardization and accuracy for the 'silver' schema.
	Checks include:
	- Null/duplicate pkeys
	- unexpected spaces in strings
	- data normaliation and standardization
	- invalid date ranges
	- consistency between related pkey/fkey fields

WARNING:
- Truncates silver tables before loading data. Existing data will be lost.
- transforms data from bronze tables to corresponding silver tables.

Usage Example:
	EXEC silver.load_silver;
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY

		SET @batch_start_time = GETDATE();
		PRINT '========================================================================================'
		PRINT 'Loading Silver Layer'
		PRINT '========================================================================================'
		
		PRINT '----------------------------------------------------------------------------------------'
		PRINT 'Loading CRM Tables'
		PRINT '----------------------------------------------------------------------------------------'


		/* 
		============================================
		CRM
		============================================
		*/


		--- crm_cust_info
		PRINT '------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table silver.crm_cust_info'
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting crm_cust_info.csv'
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN UPPER(trim(cst_marital_status)) = 'M' THEN 'Married' -- trim spaces and make upper before testing
			WHEN UPPER(trim(cst_marital_status)) = 'S' THEN 'Single'
			ELSE 'N/A' -- replacing null values
		END,
		CASE WHEN UPPER(trim(cst_gndr)) = 'F' THEN 'Female' -- trim spaces and make upper before testing
			WHEN UPPER(trim(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'N/A' -- replacing null values
		END,
		cst_create_date
		FROM (
			SELECT 
			*,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
			FROM bronze.crm_cust_info
		)t WHERE flag_last = 1

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------'




		-- crm_prd_info
		PRINT '------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table silver.crm_prd_info'
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserting crm_prd_info.csv'
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- must add new column to Silver DDL in order for INSERT cols to match SELECT cols
		SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
		prd_nm,
		ISNULL(prd_cost, 0), --replace null with 0
		CASE UPPER(trim(prd_line)) 
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'N/A'
		END AS prd_line,
		prd_start_dt,
		-- dropping time from DATETIME, as in this data it's not provided so always 00:00:00
		-- LEAD: access value from next row in window. Using prd key to create partitions, only use LEAD(prd_start_dt) for the same product.
		CAST(DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE) AS prd_end_dt
		FROM bronze.crm_prd_info

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------'




		--- crm_sales_details
		--- need to convert date to the same format
		PRINT '------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table silver.crm_sales_details'
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting crm_sales_details.csv'
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) -- cannot go directly from in to date in sql srv
		END AS sls_order_dt, -- Update INT -> DATE in DDL
		CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt, -- Update INT -> DATE in DDL
		CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt, -- Update INT -> DATE in DDL
		CASE WHEN sls_sales IS NULL OR sls_sales < = 0 OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END AS sls_sales,
		sls_quantity,
		CASE WHEN sls_price IS NULL OR sls_price <= 0
			THEN sls_sales / NULLIF(sls_quantity, 0)
			ELSE sls_price
		END AS sls_price
		FROM bronze.crm_sales_details

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------'


		/* 
		============================================
		ERP
		============================================
		*/
		PRINT '----------------------------------------------------------------------------------------'
		PRINT 'Loading ERP Tables'
		PRINT '----------------------------------------------------------------------------------------'


		--- erp_cust_az12
		PRINT '------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table silver.erp_cust_az12'
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Inserting erp_cust_az12.csv'
		INSERT INTO silver.erp_cust_az12(cid, bdate, gen)
		SELECT
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
			ELSE cid
		END AS cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
		END AS bdate,
		CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
			ELSE 'N/A'
		END AS gen
		FROM bronze.erp_cust_az12
		
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------'


		---erp_loc_a101
		PRINT '------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table silver.erp_loc_a101'
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting loc_a101.csv'
		INSERT INTO silver.erp_loc_a101
		(cid, cntry)
		SELECT
		REPLACE(cid, '-', '') cid,
		CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
			WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
			ELSE TRIM(cntry)
		END AS cntry
		FROM bronze.erp_loc_a101 
		
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------'



		--- erp_px_cat_g1v2
		-- no changes needed
		PRINT '------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table silver.erp_px_cat_g1v2'
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Inserting px_cat_g1v2.csv'
		INSERT INTO silver.erp_px_cat_g1v2
		(id, cat, subcat, maintenance)
		SELECT
		id,
		cat,
		subcat,
		maintenance
		FROM bronze.erp_px_cat_g1v2

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------'
	
	END TRY
	BEGIN CATCH
		PRINT '========================================================================================'
		PRINT 'ERROR LOADING SILVER LAYER: '
		PRINT 'Error msg: ' + ERROR_MESSAGE();
		PRINT 'Error num: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error STATE: ' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '========================================================================================'		
	END CATCH
	
	SET @batch_end_time = GETDATE();

	PRINT '>> BATCH DURATION: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';

END