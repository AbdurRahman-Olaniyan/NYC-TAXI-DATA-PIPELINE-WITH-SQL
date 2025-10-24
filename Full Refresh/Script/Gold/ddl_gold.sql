/*
===============================================================================
DDL Script: Create Gold View
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final table

    The view performs aggregation and transformations on the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/


IF OBJECT_ID('Gold.nyc_tripdata_2024', 'V') IS NOT NULL
	DROP VIEW Gold.nyc_tripdata_2024;
GO

CREATE VIEW Gold.nyc_tripdata_2024 AS

WITH AggregatedTrips AS (
	SELECT
		CAST(tpep_pickup_datetime AS DATE) AS TripDate,
		VendorID,
		CASE
			WHEN VendorID = 1 THEN 'Creative Mobile Technologies'
			WHEN VendorID = 2 THEN 'Curb Mobility'
			WHEN VendorID = 6 THEN 'Myle Technologies Inc'
			WHEN VendorID = 7 THEN 'Helix'
			ELSE 'Unknown'
		END AS VendorName,
		RatecodeID,
		CASE
			WHEN RatecodeID = 1 THEN 'Standard rate'
			WHEN RatecodeID = 2 THEN 'JFK'
			WHEN RatecodeID = 3 THEN 'Newark'
			WHEN RatecodeID = 4 THEN 'Nassau/Westchester'
			WHEN RatecodeID = 5 THEN 'Negotiated fare'
			WHEN RatecodeID = 6 THEN 'Group ride'
			ELSE 'Unknown'
		END AS RateCode,
		payment_type,
		CASE
			WHEN payment_type = 1 THEN 'Credit card'
			WHEN payment_type = 2 THEN 'Cash'
			WHEN payment_type = 3 THEN 'No charge'
			WHEN payment_type = 4 THEN 'Dispute'
			WHEN payment_type = 5 THEN 'Unknown'
			WHEN payment_type = 6 THEN 'Voided trip'
			ELSE 'Other'
		END AS PaymentType,
		COUNT(*) AS TotalTrips,
		SUM(COALESCE(passenger_count, 0)) AS TotalPassengers,
		SUM(COALESCE(trip_distance, 0)) AS TotalDistance,
		AVG(NULLIF(trip_distance,0)) AS AvgDistance,
		SUM(DATEDIFF(MINUTE, tpep_pickup_datetime, tpep_dropoff_datetime)) AS TotalDurationMins,
		AVG(DATEDIFF(MINUTE, tpep_pickup_datetime, tpep_dropoff_datetime)) AS AvgDurationMins,
		SUM(COALESCE(fare_amount, 0)) AS TotalFare,
		SUM(COALESCE(tip_amount, 0)) AS TotalTip,
		SUM(COALESCE(tolls_amount,0)) AS TotalTolls,
		SUM(COALESCE(total_amount,0)) AS TotalAmount
	FROM [DataWareHouse2].[silver].[yellow_tripdata_2024]
	WHERE trip_distance > 0
	GROUP BY
		CAST(tpep_pickup_datetime AS DATE),
		VendorID,
		RatecodeID,
		payment_type
	)
SELECT
	ROW_NUMBER() OVER (ORDER BY TripDate, VendorID, RatecodeID, PaymentType) AS TripID, --Surrogate key
	TripDate,
	VendorID,
	VendorName,
	RatecodeID,
	RateCode,
	PaymentType,
	TotalTrips,
	TotalPassengers,
	TotalDistance,
	AvgDistance,
	TotalDurationMins,
	AvgDurationMins,
	TotalFare,
	TotalTip,
	TotalTolls,
	TotalAmount
FROM AggregatedTrips;
GO
