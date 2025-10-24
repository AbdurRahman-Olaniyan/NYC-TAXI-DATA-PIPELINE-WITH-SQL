# NYC TAXI DATA PIPELINE

This project demonstrate the design and implementation of a simple, SQL based data pipeline that ingests, transforms, and aggregates NYC Taxi data for the year 2024. The pipelines compare both full refresh and incremental loading strategies.

----
# Data Architecture
----
The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers for both **Full Load** and **Incremental Load** Scenarios:
![Data Pipeline Architecture](Data-Architecture.png)

# Design Rationale
The pipeline flow across three layers and was designed to handle the NYC Yellow Taxi trip data for 2024. Due to the size and structure of the source data, the implementation uses two seperate data warehouses:
 * DataWareHouse1: stores the raw data and act as bronze layer
 * DataWareHouse2: contain two schema that stores the transformed data in silver layer and aggregated data in gold layer

 This seperation allows for better resource management and avoids perfomance and disk size issues when processinf large volumes of data.

* Data flow between layers
    * The **bronze layer** ingests raw data directly from source files, preserving its schema as-is
    * The **silver layer** applies data quality filters to clean and transform the data. for example, trips must occur in 2024, have positive distance value, a valid passenger count, and a logical timestamps where drop-off time is after the pickup time.
    * The **gold layer** aggregates the transformed data into business-ready data table. which incude metrics such as total trips, total distance, duration, and total amounts, and grouped by other descriptive columns for analytics reporting

# Full vs. incremental load logic
* Full Refresh
**Bronze layer** load raw data from a single csv file containing all 12 months of NYC yellow taxi data. The layer table is truncated before loading using a stored procedure that performs a `BULK INSERT`.

**Silver layer** cleanses and filters data from the bronze layer. A stored procedure truncates the silver table and inserts only valid record from 2024.

**Gold layer** A view is created from the silver layer to produce aggregated and analytics ready metrics grouped by vendor and date,

Each layer is rebuilt from scratch to ensure consistency and data integrity across the pipeline.

# Metadata management for dynamic loading
During a full refresh, a metadata column is added to the silver layer to record the ModifiedDate for each ingested record. This timestamp reflects when the data was loaded into the system, enabling clear visibily into when each record entered the pipeline and to distinguish between historical and newly refreshed data.
![alt text](<Full Refresh/Script/Silver/metadatacolumninsilver.png>)

# Example queries
#### Which vendor had the highest total revenue on the top 5 days in Q1 2024?
```sql
SELECT 
   TOP 5 TripDate,
    VendorName,
	COUNT(*) AS TotalTrips,
    SUM(TotalAmount) AS TotalRevenue
FROM Gold.nyc_tripdata_2024
WHERE TripDate BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY TripDate, VendorName
ORDER BY TotalRevenue DESC;
```

#### What is the average trip distance and duration per payment type in Q1 2024?
```sql
SELECT 
    PaymentType,
    ROUND(AVG(AvgDistance), 2) AS AvgTripDistance,
    ROUND(AVG(AvgDurationMins), 2) AS AvgTripDuration
FROM Gold.nyc_tripdata_2024
WHERE TripDate BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY PaymentType;
```
