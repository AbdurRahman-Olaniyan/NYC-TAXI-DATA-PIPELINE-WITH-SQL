
IF OBJECT_ID ('bronze.yellow_tripdata_2024', 'U') IS NOT NULL
	DROP TABLE bronze.yellow_tripdata_2024;
BEGIN
CREATE TABLE bronze.yellow_tripdata_2024(
	VendorID INT,
	tpep_pickup_datetime DATETIME2,
	tpep_dropoff_datetime DATETIME2,
	passenger_count DECIMAL(12, 2),
	trip_distance DECIMAL(12, 2),
	RatecodeID DECIMAL(12, 2),
	store_and_fwd_flag NVARCHAR(1),
	PULocationID INT,
	DOLocationID INT,
	payment_type INT,
	fare_amount DECIMAL(12,2),
	extra DECIMAL(12,2),
	mta_tax DECIMAL(12,2),
	tip_amount DECIMAL(12,2),
	tolls_amount DECIMAL(12,2),
	improvement_surcharge DECIMAL(12,2),
	total_amount DECIMAL(12,2),
	congestion_surcharge DECIMAL(12,2),
	Airport_fee DECIMAL(12,2)
);
END;
GO

-- Metadata Table for Load Tracking
IF OBJECT_ID('metadata.watermarktable', 'U') IS NOT NULL
	DROP TABLE metadata.watermarktable;
BEGIN
	CREATE TABLE metadata.watermarktable (
		FileName NVARCHAR(200) PRIMARY KEY,
		BronzeStartTime DATETIME NULL,
		BronzeEndTime DATETIME NULL,
		BronzeStatus NVARCHAR(20) NULL,
		BronzeRowsProcessed INT NULL,
		BronzeLoadTimeSec INT NULL,
		MaxPickupDate DATETIME NULL,
		MinPickupDate DATETIME NULL,
		SilverStartTime DATETIME NULL,
		SilverEndTime DATETIME NULL,
		SilverStatus NVARCHAR(20) NULL,
		SilverRowsProcessed INT NULL,
		SilverLoadTimeSec INT NULL,
		GoldStartTime DATETIME NULL,
		GoldEndTime DATETIME NULL,
		GoldStatus NVARCHAR(20) NULL,
		GoldRowsProcessed INT NULL,
		GoldLoadTimeSec INT NULL,
		LastUpdated DATETIME DEFAULT GETDATE()
	);
END;
GO
