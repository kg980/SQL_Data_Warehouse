/*
========================================================================================
Stored Procedure: Load Bronze Layer (Souce -> Bronze)
========================================================================================

Script Purpose:
	Load data into 'bronze' schema from external CSV files.
	- Truncates bronze tables before loading data.
	- uses `BULK INSERT` to load data from csv to bronze tables.

Usage Example:
	EXEC bronze.load_bronze;
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '========================================================================================'
		PRINT 'Loading Bronze Layer'
		PRINT '========================================================================================'
		
		PRINT '----------------------------------------------------------------------------------------'
		PRINT 'Loading CRM Tables'
		PRINT '----------------------------------------------------------------------------------------'


		PRINT '------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.crm_cust_info'
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>> Inserting crm_cust_info.csv'
		BULK INSERT bronze.crm_cust_info
		FROM 'E:\CodeProjects\SQL-Data-Warehouse\SQL_Data_Warehouse\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		--SELECT * FROM bronze.crm_cust_info
		--SELECT COUNT(*) FROM bronze.crm_cust_info
		PRINT '------------'


		PRINT '------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.crm_prd_info'
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>> Inserting crm_prd_info.csv'
		BULK INSERT bronze.crm_prd_info
		FROM 'E:\CodeProjects\SQL-Data-Warehouse\SQL_Data_Warehouse\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		--SELECT * FROM bronze.crm_prd_info
		--SELECT COUNT(*) FROM bronze.crm_prd_info
		PRINT '------------'


		PRINT '------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.crm_sales_details'
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Inserting crm_sales_details.csv'
		BULK INSERT bronze.crm_sales_details
		FROM 'E:\CodeProjects\SQL-Data-Warehouse\SQL_Data_Warehouse\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		--SELECT * FROM bronze.crm_sales_details
		--SELECT COUNT(*) FROM bronze.crm_sales_details
		PRINT '------------'

		
		PRINT '----------------------------------------------------------------------------------------'
		PRINT 'Loading ERP Tables'
		PRINT '----------------------------------------------------------------------------------------'

		PRINT '------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.erp_cust_az12'
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>> Inserting erp_cust_az12.csv'
		BULK INSERT bronze.erp_cust_az12
		FROM 'E:\CodeProjects\SQL-Data-Warehouse\SQL_Data_Warehouse\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		--SELECT * FROM bronze.erp_cust_az12
		--SELECT COUNT(*) FROM bronze.erp_cust_az12
		PRINT '------------'


		PRINT '------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.erp_loc_a101'
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>> Inserting loc_a101.csv'
		BULK INSERT bronze.erp_loc_a101
		FROM 'E:\CodeProjects\SQL-Data-Warehouse\SQL_Data_Warehouse\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		--SELECT * FROM bronze.erp_loc_a101
		--SELECT COUNT(*) FROM bronze.erp_loc_a101
		PRINT '------------'


		PRINT '------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		PRINT '>> Inserting px_cat_g1v2.csv'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'E:\CodeProjects\SQL-Data-Warehouse\SQL_Data_Warehouse\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		--SELECT * FROM bronze.erp_px_cat_g1v2
		--SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2
		PRINT '------------'

	END TRY
	BEGIN CATCH
		PRINT '========================================================================================'
		PRINT 'ERROR LOADING BRONZE LAYER: '
		PRINT 'Error msg: ' + ERROR_MESSAGE();
		PRINT 'Error num: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error STATE: ' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '========================================================================================'		
	END CATCH
	
	SET @batch_end_time = GETDATE();

	PRINT '>> BATCH DURATION: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
END