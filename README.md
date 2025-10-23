# NYC TAXI DATA PIPELINE

This project demonstrate the design and implementation of a simple, SQL based data pipeline that ingests, transforms, and aggregates NYC Taxi data for the year 2024. The pipelines compare both full refresh and incremental loading strategies.

----
# Data Architecture
----
The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers for both **Full Load** and **Incremental Load** Scenarios:
![Data Pipeline Architecture](Data-Architecture.png)
