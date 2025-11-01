IF OBJECT_ID('silver.yellow_tripdata_2024', 'U') IS NOT NULL
    DROP TABLE silver.yellow_tripdata_2024;
GO

CREATE TABLE silver.yellow_tripdata_2024 (
    VendorID INT,
    tpep_pickup_datetime DATETIME2,
    tpep_dropoff_datetime DATETIME2,
    passenger_count DECIMAL(12, 2),
    trip_distance DECIMAL(12, 2),
    RatecodeID DECIMAL(12, 2),
    store_and_fwd_flag NVARCHAR(10),
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
    Airport_fee DECIMAL(12,2),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
