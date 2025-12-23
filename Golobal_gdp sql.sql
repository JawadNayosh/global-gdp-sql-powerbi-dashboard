USE global_gdp;
GO

IF OBJECT_ID('dbo.Raw_Data_GDP','U') IS NOT NULL
    DROP TABLE dbo.Raw_Data_GDP;
GO

CREATE TABLE dbo.Raw_Data_GDP
(
    Demo_Ind   NVARCHAR(200),
    Indicator  NVARCHAR(200),
    [Location] NVARCHAR(200),
    Country    NVARCHAR(200),
    [Time]     NVARCHAR(50),
    [Value]    NVARCHAR(100)   -- <-- important change
);
GO
IF OBJECT_ID('dbo.Raw_Lines_GDP','U') IS NOT NULL DROP TABLE dbo.Raw_Lines_GDP;
GO
CREATE TABLE dbo.Raw_Lines_GDP (Line NVARCHAR(MAX));
GO

BULK INSERT dbo.Raw_Lines_GDP
FROM 'C:\Temp\global_gdp_data.csv'
WITH
(
    ROWTERMINATOR = '0x0d0a',
    CODEPAGE = '65001'
);
GO

SELECT *
FROM dbo.Raw_Lines_GDP
ORDER BY (SELECT NULL)
OFFSET 126130 ROWS FETCH NEXT 30 ROWS ONLY;
GO

SELECT TOP (50)
    (LEN(Line) - LEN(REPLACE(Line, ',', ''))) AS CommaCount,
    Line
FROM dbo.Raw_Lines_GDP
WHERE (LEN(Line) - LEN(REPLACE(Line, ',', ''))) <> 5
ORDER BY CommaCount DESC;

TRUNCATE TABLE dbo.Raw_Data_GDP;
GO

BULK INSERT dbo.Raw_Data_GDP
FROM 'C:\Temp\global_gdp_data.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 1,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0d0a'
);
GO

SELECT TOP (10) *
FROM dbo.Raw_Data_GDP;


SELECT COUNT(*) AS TotalRows
FROM dbo.Raw_Data_GDP;

SELECT DISTINCT Indicator
FROM dbo.Raw_Data_GDP
WHERE Indicator IN ('GDP (current US$)', 'GDP per capita (current US$)');

GO 

USE global_gdp;
GO

IF OBJECT_ID('dbo.GDP_Excel_Input','V') IS NOT NULL
    DROP VIEW dbo.GDP_Excel_Input;
GO

CREATE VIEW dbo.GDP_Excel_Input AS
SELECT
    a.Country,
    TRY_CONVERT(int, a.Year_No) AS Year_No,
    TRY_CONVERT(float, REPLACE(REPLACE(a.GDP_Value,'"',''), ',', '')) AS GDP_Value,
    TRY_CONVERT(float, REPLACE(REPLACE(b.GDP_Per_Capita,'"',''), ',', '')) AS GDP_Per_Capita
FROM
(
    SELECT
        Country,
        [Time] AS Year_No,
        [Value] AS GDP_Value
    FROM dbo.Raw_Data_GDP
    WHERE Indicator = 'GDP (current US$)'
) a
LEFT JOIN
(
    SELECT
        Country,
        [Time] AS Year_No,
        [Value] AS GDP_Per_Capita
    FROM dbo.Raw_Data_GDP
    WHERE Indicator = 'GDP per capita (current US$)'
) b
ON a.Country = b.Country
AND a.Year_No = b.Year_No;
GO

SELECT TOP (20) *
FROM dbo.GDP_Excel_Input
ORDER BY Country, Year_No;


GO
USE global_gdp;
GO

IF OBJECT_ID('dbo.usp_Refresh_Global_GDP','P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Refresh_Global_GDP;
GO

CREATE PROCEDURE dbo.usp_Refresh_Global_GDP
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.Raw_Data_GDP;

    BULK INSERT dbo.Raw_Data_GDP
    FROM 'C:\Temp\global_gdp_data.csv'
    WITH
    (
        FORMAT = 'CSV',
        FIRSTROW = 1,
        FIELDQUOTE = '"',
        ROWTERMINATOR = '0x0d0a'
    );
END;
GO

EXEC dbo.usp_Refresh_Global_GDP;

SELECT COUNT(*) AS RowsLoaded FROM dbo.Raw_Data_GDP;