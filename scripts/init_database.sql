/*
Purpose:
	Create Database and Schemas. 
	First, this script checks if the 'DataWarehouse' exists. If so, drop it and re-create it, otherwise just create it.
	Additionally, create bronze, silver, gold schemas.

WARNING:
	If the 'DataWarehouse' db already exists, it wil be dropped and all data will be lost.
*/

USE master;
GO

-- drop & recreate 'DataWarehouse' db
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

-- create fresh 'DataWarehouse' db
CREATE DATABASE DataWarehouse;
GO

Use DataWarehouse;
GO

-- schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;