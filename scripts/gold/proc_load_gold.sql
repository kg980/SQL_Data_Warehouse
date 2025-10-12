/*
========================================================================================
Stored Procedure: gold.load_gold
========================================================================================

Purpose:
    - Drops and recreates all Gold Layer views (dim_customers, dim_products, fact_sales)
    - Based on data from the Silver Layer

Notes:
    - Uses dynamic SQL for CREATE VIEW statements
    - Includes timing and error logging
    - No GO statements (fully executable in one batch)
========================================================================================
*/

CREATE OR ALTER PROCEDURE gold.load_gold AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    DECLARE @sql NVARCHAR(MAX);

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '========================================================================================';
        PRINT 'Starting Gold Layer View Creation';
        PRINT '========================================================================================';

        ----------------------------------------------------------------------------------------
        -- DIM_CUSTOMERS
        ----------------------------------------------------------------------------------------
        PRINT '------------';
        SET @start_time = GETDATE();
        PRINT '>> Dropping View gold.dim_customers (if exists)';

        IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
            DROP VIEW gold.dim_customers;

        PRINT '>> Creating View gold.dim_customers';

        SET @sql = N'
        CREATE VIEW gold.dim_customers AS
        SELECT
            ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
            ci.cst_id AS customer_id,
            ci.cst_key AS customer_number,
            ci.cst_firstname AS first_name,
            ci.cst_lastname AS last_name,
            la.cntry AS country,
            ci.cst_marital_status AS marital_status,
            CASE 
                WHEN ci.cst_gndr != ''N/A'' THEN ci.cst_gndr
                ELSE COALESCE(ca.gen, ''N/A'')
            END AS gender,
            ca.bdate AS birthdate,
            ci.cst_create_date AS create_date
        FROM silver.crm_cust_info ci
        LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
        LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid;
        ';
        EXEC sp_executesql @sql;

        SET @end_time = GETDATE();
        PRINT '>> gold.dim_customers created in ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds.';


        ----------------------------------------------------------------------------------------
        -- DIM_PRODUCTS
        ----------------------------------------------------------------------------------------
        PRINT '------------';
        SET @start_time = GETDATE();
        PRINT '>> Dropping View gold.dim_products (if exists)';

        IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
            DROP VIEW gold.dim_products;

        PRINT '>> Creating View gold.dim_products';

        SET @sql = N'
        CREATE VIEW gold.dim_products AS
        SELECT
            ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
            pn.prd_id AS product_id,
            pn.prd_key AS product_number,
            pn.prd_nm AS product_name,
            pn.cat_id AS category_id,
            pc.cat AS category,
            pc.subcat AS subcategory,
            pc.maintenance,
            pn.prd_cost AS cost,
            pn.prd_line AS product_line,
            pn.prd_start_dt AS start_date
        FROM silver.crm_prd_info pn
        LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
        WHERE pn.prd_end_dt IS NULL;
        ';
        EXEC sp_executesql @sql;

        SET @end_time = GETDATE();
        PRINT '>> gold.dim_products created in ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds.';


        ----------------------------------------------------------------------------------------
        -- FACT_SALES
        ----------------------------------------------------------------------------------------
        PRINT '------------';
        SET @start_time = GETDATE();
        PRINT '>> Dropping View gold.fact_sales (if exists)';

        IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
            DROP VIEW gold.fact_sales;

        PRINT '>> Creating View gold.fact_sales';

        SET @sql = N'
        CREATE VIEW gold.fact_sales AS
        SELECT 
            sd.sls_ord_num AS order_number,
            pr.product_key,
            cu.customer_id,
            sd.sls_order_dt AS order_date,
            sd.sls_ship_dt AS shipping_date,
            sd.sls_due_dt AS due_date,
            sd.sls_sales AS sales_amount,
            sd.sls_quantity AS quantity,
            sd.sls_price AS price
        FROM silver.crm_sales_details sd
        LEFT JOIN gold.dim_products pr ON sd.sls_prd_key = pr.product_number
        LEFT JOIN gold.dim_customers cu ON sd.sls_cust_id = cu.customer_id;
        ';
        EXEC sp_executesql @sql;

        SET @end_time = GETDATE();
        PRINT '>> gold.fact_sales created in ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds.';


        ----------------------------------------------------------------------------------------
        -- Summary
        ----------------------------------------------------------------------------------------
        SET @batch_end_time = GETDATE();
        PRINT '========================================================================================';
        PRINT 'Gold Layer View Creation Completed Successfully';
        PRINT 'Total Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds.';
        PRINT '========================================================================================';

    END TRY
    BEGIN CATCH
        PRINT '========================================================================================';
        PRINT 'ERROR LOADING GOLD LAYER:';
        PRINT 'Error msg: ' + ERROR_MESSAGE();
        PRINT 'Error num: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error state: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '========================================================================================';
    END CATCH;
END;
GO


-- EXEC gold.load_gold;
