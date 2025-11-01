/*
===============================================================================
DDL Script: Create Gold Table
===============================================================================
Script Purpose:
    This script creates the 'Gold' layer table that holds aggregated and 
    analytics-ready trip metrics derived from the 'Silver' layer.
===============================================================================
*/

IF OBJECT_ID('gold.yellow_tripdata_2024', 'U') IS NOT NULL
    DROP TABLE gold.yellow_tripdata_2024;
GO

CREATE TABLE gold.yellow_tripdata_2024 (
	TripDate DATE,
	VendorID INT,
	VendorName NVARCHAR(100),
	RatecodeID INT,
	RateCode NVARCHAR(50),
	payment_type INT,
	PaymentType NVARCHAR(50),
	TotalTrips INT,
	TotalPassengers INT,
	TotalDistance DECIMAL(18,2),
	TotalDurationMins DECIMAL(18,2),
	TotalFare DECIMAL(18,2),
	TotalTip DECIMAL(18,2),
	TotalTolls DECIMAL(18,2),
	TotalAmount DECIMAL(18,2),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
	);
GO
