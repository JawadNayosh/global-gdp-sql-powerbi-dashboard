## Global GDP Trends Dashboard
## End-to-End SQL Server & Power BI Analytics Project
### by Mohammad Jawad Nayosh

## Project Overview
This project shows how I take raw, messy data and turn it into a clean, interactive dashboard using SQL Server and Power BI — the way it’s done in real analytics environments.
The focus was not just on visuals, but on building a reliable data pipeline, handling real data issues, and separating raw data from reporting logic.

## What This Dashboard Show
- Global GDP trends over time
- Top global economies by GDP
- GDP vs GDP per capita comparison
- Country-level and year-level analysis
- Interactive KPIs and slicers

## Dashboard preview
<img width="1354" height="766" alt="Image" src="https://github.com/user-attachments/assets/8a297daa-0de1-4914-8cc1-deec08304f8e" />

## Data Pipeline Architecture
CSV → SQL Server → Power BI
Raw CSV file loaded into SQL Server
Data cleaned and validated in SQL (not in Power BI)
Reporting view created as a semantic layer
Stored procedure handles refresh logic
SQL Server Agent schedules refresh
Power BI connects only to the SQL view

This design keeps the dashboard stable and easy to maintain.

## Tools & Technologies
-SQL Server
-BULK INSERT
-Views
-Stored Procedures
-SQL Server Agent
-Power BI
-DAX measures
-KPI cards
-Interactive visuals & slicers
-Data Modeling & ETL Concepts

## Handling Real-World Data Issues
The raw CSV had common real-world problems:
Commas inside text fields, Large file size, Numeric values stored as text, Fields not ready for direct reporting

## To solve this, I:
Loaded raw lines into a staging table to debug parsing issues
Used proper CSV parsing with FORMAT = 'CSV' and FIELDQUOTE
Converted values safely using TRY_CONVERT
Separated raw data from reporting logic
Example (CSV-safe bulk insert):
BULK INSERT dbo.Raw_Data_GDP
FROM 'C:\Temp\global_gdp_data.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 1,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0d0a'
);

## Data Modeling (SQL View)
Instead of sending raw data to Power BI, I created a clean SQL view that reshapes the data into a reporting-ready format:
CREATE VIEW dbo.GDP_Excel_Input AS
SELECT
    a.Country,
    TRY_CONVERT(int, a.Year_No) AS Year_No,
    TRY_CONVERT(float, REPLACE(a.GDP_Value, ',', '')) AS GDP_Value,
    TRY_CONVERT(float, REPLACE(b.GDP_Per_Capita, ',', '')) AS GDP_Per_Capita
FROM ...
Power BI connects only to this view, not the raw table.

## Automation & Refresh Logic
A stored procedure reloads the data so refresh is repeatable and reliable:
CREATE PROCEDURE dbo.usp_Refresh_Global_GDP
AS
BEGIN
    TRUNCATE TABLE dbo.Raw_Data_GDP;
    BULK INSERT dbo.Raw_Data_GDP
    FROM 'C:\Temp\global_gdp_data.csv'
    WITH (FORMAT = 'CSV', FIELDQUOTE = '"');
END;
-Scheduled using SQL Server Agent
-Power BI refresh is designed to run after SQL refresh
-Gateway-ready for full automation

## Power BI Dashboard Features
KPIs
Total Countries
Latest Year
Global GDP (Latest Year)
Average GDP per Capita
Top GDP Country

## Visuals
GDP trend over time
Top economies by GDP
World map (GDP per capita)
Interactive tables for validation

## Key Insights
A small number of countries account for a large share of global GDP
High GDP does not always mean high GDP per capita
Economic growth patterns differ significantly across regions

## Skills Demonstrated
SQL-based ETL and data cleaning
Handling messy real-world CSV data
Building reporting layers with views
Stored procedures and scheduled jobs
Power BI modeling, DAX, and interactivity
Business-focused data storytelling

## Final Note
This project reflects how I approach analytics problems:
build a solid backend first, then create clear and useful insights on top of it.
