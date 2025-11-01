USE master;
GO

-- Drop and recreate the 'DataWarehouse2' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWareHouse2')
BEGIN
	ALTER DATABASE DataWareHouse2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWareHouse2;
END;
GO

-- Create the 'DataWareHouse2' database
CREATE DATABASE DataWareHouse2;
GO

USE DataWareHouse2;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA Gold;