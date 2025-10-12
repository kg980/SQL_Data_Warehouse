
TRUNCATE TABLE bronze.crm_cust_info;

BULK INSERT bronze.crm_cust_info
FROM 'E:\CodeProjects\SQL-Data-Warehouse\SQL_Data_Warehouse\datasets\source_crm\cust_info.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);

SELECT * FROM bronze.crm_cust_info
SELECT COUNT(*) FROM bronze.crm_cust_info



TRUNCATE TABLE bronze.crm_prd_info;

BULK INSERT bronze.crm_prd_info
FROM 'E:\CodeProjects\SQL-Data-Warehouse\SQL_Data_Warehouse\datasets\source_crm\prd_info.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);

SELECT * FROM bronze.crm_prd_info
SELECT COUNT(*) FROM bronze.crm_prd_info



TRUNCATE TABLE bronze.crm_sales_details;

BULK INSERT bronze.crm_sales_details
FROM 'E:\CodeProjects\SQL-Data-Warehouse\SQL_Data_Warehouse\datasets\source_crm\sales_details.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


SELECT * FROM bronze.crm_sales_details
SELECT COUNT(*) FROM bronze.crm_sales_details



TRUNCATE TABLE bronze.erp_cust_az12;

BULK INSERT bronze.erp_cust_az12
FROM 'E:\CodeProjects\SQL-Data-Warehouse\SQL_Data_Warehouse\datasets\source_erp\cust_az12.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


SELECT * FROM bronze.erp_cust_az12
SELECT COUNT(*) FROM bronze.erp_cust_az12



TRUNCATE TABLE bronze.erp_loc_a101;

BULK INSERT bronze.erp_loc_a101
FROM 'E:\CodeProjects\SQL-Data-Warehouse\SQL_Data_Warehouse\datasets\source_erp\loc_a101.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


SELECT * FROM bronze.erp_loc_a101
SELECT COUNT(*) FROM bronze.erp_loc_a101



TRUNCATE TABLE bronze.erp_px_cat_g1v2;

BULK INSERT bronze.erp_px_cat_g1v2
FROM 'E:\CodeProjects\SQL-Data-Warehouse\SQL_Data_Warehouse\datasets\source_erp\px_cat_g1v2.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


SELECT * FROM bronze.erp_px_cat_g1v2
SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2