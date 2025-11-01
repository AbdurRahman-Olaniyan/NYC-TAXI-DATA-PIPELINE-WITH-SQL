/*
===============================================================================
Stored Procedure: Load Yellow Taxi Incremental (File → Bronze)
===============================================================================
Script Purpose:
    Performs incremental file-by-file data loads from CSV files into the 
    [bronze].[yellow_tripdata_2024] table while updating centralized 
    [metadata].[watermarktable].

Key Logic:
    - Skips files already marked as 'Completed' in metadata.
    - Uses BULK INSERT to append data (no truncation).
    - Captures start/end time, rows processed, duration, and MaxPickupDate.
    - Updates metadata row for each file (new or existing).

Parameters:
    @FileName NVARCHAR(100)  → Example: 'yellow_tripdata_2024-01.csv'
    @FilePath NVARCHAR(255)  → Full path to CSV file.

Usage Example:
    EXEC bronze.load_bronze_incremental
        @FileName = 'yellow_tripdata_2024-01.csv',
        @FilePath = 'C:/nyc_tlc_2024/nyc_tlc_2024_csv/yellow_tripdata_2024-01.csv';
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze_incremental
    @FileName NVARCHAR(100),
    @FilePath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @EndTime DATETIME;
    DECLARE @MaxPickupDate DATETIME;
	DECLARE @MinPickupDate DATETIME;
    DECLARE @RowsLoaded INT = 0;
    DECLARE @Status NVARCHAR(20) = 'Started';
    DECLARE @DurationSec INT;
    DECLARE @SQL NVARCHAR(MAX);

    -- ===========================================================
    -- STEP 1: CHECK IF FILE WAS SUCCESSFULLY LOADED BEFORE
    -- ===========================================================
    IF EXISTS (
        SELECT 1
        FROM metadata.watermarktable
        WHERE FileName = @FileName
          AND BronzeStatus = 'Completed'
    )
    BEGIN
        PRINT 'Already loaded previously: ' + @FileName;
        RETURN;
    END

    BEGIN TRY
        PRINT 'Starting Bronze load for: ' + @FileName;

        -- ===========================================================
        -- STEP 2: BULK INSERT INTO BRONZE TABLE
        -- ===========================================================
        SET @SQL = '
            BULK INSERT bronze.yellow_tripdata_2024
            FROM ''' + @FilePath + '''
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = '','',
                ROWTERMINATOR = ''0x0a'',
                TABLOCK
            );';
        EXEC sp_executesql @SQL;

        SET @RowsLoaded = @@ROWCOUNT;

        -- ===========================================================
        -- STEP 3: CAPTURE LOAD METRICS
        -- ===========================================================
        SELECT @MaxPickupDate = MAX(tpep_pickup_datetime), @MinPickupDate = MIN(tpep_pickup_datetime)
        FROM bronze.yellow_tripdata_2024;

        SET @EndTime = GETDATE();
        SET @DurationSec = DATEDIFF(SECOND, @StartTime, @EndTime);
        SET @Status = 'Completed';

        PRINT 'Bronze Load Successful for: ' + @FileName;
        PRINT '   - Rows Loaded: ' + CAST(@RowsLoaded AS NVARCHAR);
        PRINT '   - Max Pickup Date: ' + CONVERT(VARCHAR, @MaxPickupDate, 120);
    END TRY
    BEGIN CATCH
        SET @EndTime = GETDATE();
        SET @DurationSec = DATEDIFF(SECOND, @StartTime, @EndTime);
        SET @Status = 'Failed';
        SET @RowsLoaded = 0;
        SET @MaxPickupDate = NULL;
		SET @MinPickupDate = NULL;

        PRINT 'Bronze Load Failed for: ' + @FileName + ' — ' + ERROR_MESSAGE();
    END CATCH;

    -- ===========================================================
    -- STEP 4: UPSERT METADATA ROW
    -- ===========================================================
    IF EXISTS (SELECT 1 FROM metadata.watermarktable WHERE FileName = @FileName)
    BEGIN
        UPDATE metadata.watermarktable
        SET BronzeStartTime = @StartTime,
            BronzeEndTime = @EndTime,
            BronzeStatus = @Status,
            BronzeRowsProcessed = @RowsLoaded,
            BronzeLoadTimeSec = @DurationSec,
            MaxPickupDate = @MaxPickupDate,
			MinPickupDate = @MinPickupDate,
            LastUpdated = GETDATE()
        WHERE FileName = @FileName;
    END
    ELSE
    BEGIN
        INSERT INTO metadata.watermarktable (
            FileName, BronzeStartTime, BronzeEndTime, BronzeStatus,
            BronzeRowsProcessed, BronzeLoadTimeSec, MaxPickupDate, MinPickupDate
        )
        VALUES (
            @FileName, @StartTime, @EndTime, @Status,
            @RowsLoaded, @DurationSec, @MaxPickupDate, @MinPickupDate
        );
    END

    PRINT 'Metadata updated for file: ' + @FileName;
END;
GO


EXEC bronze.load_bronze_incremental
        @FileName = 'yellow_tripdata_2024-01.csv',
        @FilePath = 'C:/nyc_tlc_2024/nyc_tlc_2024_csv/yellow_tripdata_2024-01.csv';
