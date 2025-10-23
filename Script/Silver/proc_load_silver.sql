
/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema table from the datawarehouse 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver layer.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		-- Loading silver.crm_cust_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: [silver].[yellow_tripdata_2024]';
		TRUNCATE TABLE [silver].[yellow_tripdata_2024];
		PRINT '>> Inserting Data Into: [silver].[yellow_tripdata_2024]';
		INSERT INTO [silver].[yellow_tripdata_2024](
			VendorID,
			tpep_pickup_datetime,
			tpep_dropoff_datetime,
			passenger_count,
			trip_distance,
			RatecodeID,
			store_and_fwd_flag,
			PULocationID,
			DOLocationID,
			payment_type,
			fare_amount,
			extra,
			mta_tax,
			tip_amount,
			tolls_amount,
			improvement_surcharge,
			total_amount,
			congestion_surcharge,
			Airport_fee
		)
		SELECT
			VendorID,
			tpep_pickup_datetime,
			tpep_dropoff_datetime,
			passenger_count,
			trip_distance,
			RatecodeID,
			CASE
				WHEN UPPER(TRIM(store_and_fwd_flag)) = 'Y' THEN 'Yes'
				WHEN UPPER(TRIM(store_and_fwd_flag)) = 'N' THEN 'No'
				ELSE 'n/a'
			END AS store_and_fwd_flag,
			PULocationID,
			DOLocationID,
			payment_type,
			fare_amount,
			extra,
			mta_tax,
			tip_amount,
			tolls_amount,
			improvement_surcharge,
			total_amount,
			congestion_surcharge,
			Airport_fee
		FROM [DataWareHouse].[bronze].[yellow_tripdata_2024]
		WHERE
			YEAR(tpep_pickup_datetime) = 2024
			AND tpep_dropoff_datetime > tpep_pickup_datetime
			AND trip_distance > 0
			AND passenger_count >= 1
			AND fare_amount >= 0
			AND total_amount >= 0;
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END;
GO

EXEC Silver.load_silver;
