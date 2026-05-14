-- VIEW SAMPLE DATA
SELECT *
FROM BRIGHT.CAR.SALES
LIMIT 10;

------------------------------------------------------------------------------------------------
-- GENERAL CHECKS

SELECT MIN(YEAR) AS MIN_YEAR
FROM BRIGHT.CAR.SALES;

SELECT MAX(YEAR) AS MAX_YEAR
FROM BRIGHT.CAR.SALES;

SELECT DISTINCT MAKE
FROM BRIGHT.CAR.SALES;

SELECT DISTINCT MODEL
FROM BRIGHT.CAR.SALES;

SELECT DISTINCT TRIM
FROM BRIGHT.CAR.SALES;

SELECT DISTINCT STATE
FROM BRIGHT.CAR.SALES;

------------------------------------------------------------------------------------------------
-- CLEAN DATA + CREATE NEW TABLE

CREATE OR REPLACE TABLE BRIGHT.CAR.CLEAN_SALES AS
SELECT
    YEAR,
    VIN,
    STATE,
    CONDITION,
    ODOMETER,

    CAST(MMR AS DOUBLE) AS COST_PRICE,

    COALESCE(MAKE, 'None') AS MAKE,
    COALESCE(MODEL, 'None') AS MODEL,
    COALESCE(TRIM, 'None') AS TRIM,
    COALESCE(BODY, 'None') AS BODY,
    COALESCE(TRANSMISSION, 'None') AS TRANSMISSION,
    COALESCE(COLOR, 'None') AS COLOR,
    COALESCE(INTERIOR, 'None') AS INTERIOR,
    COALESCE(SELLER, 'None') AS SELLER,

    CAST(REGEXP_REPLACE(SELLINGPRICE, ',', '') AS DOUBLE) AS SELLING_PRICE,

    TO_TIMESTAMP(SALEDATE, 'EEE MMM dd yyyy HH:mm:ss') AS SALE_DATE

FROM BRIGHT.CAR.SALES;

------------------------------------------------------------------------------------------------
-- SALES SUMMARY WITH REVENUE + PROFIT MARGIN

SELECT
    YEAR,
    MAKE,
    MODEL,

    COUNT(*) AS UNITS_SOLD,

    SUM(COST_PRICE) AS TOTAL_COST,

    SUM(SELLING_PRICE) AS TOTAL_REVENUE,

    ROUND(
        (
            SUM(SELLING_PRICE) - SUM(COST_PRICE)
        ) / NULLIF(SUM(SELLING_PRICE), 0) * 100,
        2
    ) AS PROFIT_MARGIN,

    CASE
        WHEN ROUND(
            (
                SUM(SELLING_PRICE) - SUM(COST_PRICE)
            ) / NULLIF(SUM(SELLING_PRICE), 0) * 100,
            2
        ) BETWEEN 0 AND 24.99
            THEN 'Low Margin'

        WHEN ROUND(
            (
                SUM(SELLING_PRICE) - SUM(COST_PRICE)
            ) / NULLIF(SUM(SELLING_PRICE), 0) * 100,
            2
        ) BETWEEN 25 AND 49.99
            THEN 'Medium Margin'

        WHEN ROUND(
            (
                SUM(SELLING_PRICE) - SUM(COST_PRICE)
            ) / NULLIF(SUM(SELLING_PRICE), 0) * 100,
            2
        ) >= 50
            THEN 'High Margin'

        ELSE 'Negative Margin'
    END AS PERFORMANCE_TIER

FROM BRIGHT.CAR.CLEAN_SALES
GROUP BY YEAR, MAKE, MODEL
ORDER BY PROFIT_MARGIN DESC;

------------------------------------------------------------------------------------------------
-- REVENUE BY CAR MAKE AND MODEL

SELECT
    MAKE,
    MODEL,
    SUM(SELLING_PRICE) AS TOTAL_REVENUE
FROM BRIGHT.CAR.CLEAN_SALES
GROUP BY MAKE, MODEL
ORDER BY TOTAL_REVENUE DESC;

------------------------------------------------------------------------------------------------
-- SALES DISTRIBUTION BY YEAR AND TRANSMISSION

SELECT
    YEAR,
    TRANSMISSION,
    COUNT(*) AS UNITS_SOLD,
    SUM(SELLING_PRICE) AS TOTAL_REVENUE
FROM BRIGHT.CAR.CLEAN_SALES
GROUP BY YEAR, TRANSMISSION
ORDER BY YEAR;

------------------------------------------------------------------------------------------------
-- REGIONAL PERFORMANCE

SELECT
    STATE,
    SUM(SELLING_PRICE) AS TOTAL_REVENUE
FROM BRIGHT.CAR.CLEAN_SALES
GROUP BY STATE
ORDER BY TOTAL_REVENUE DESC;

------------------------------------------------------------------------------------------------
-- AVERAGE SELLING PRICE TREND OVER TIME

SELECT
    SALE_DATE,
    AVG(SELLING_PRICE) AS AVG_SELLING_PRICE
FROM BRIGHT.CAR.CLEAN_SALES
GROUP BY SALE_DATE
ORDER BY SALE_DATE ASC;

------------------------------------------------------------------------------------------------
-- EXTRACT DATE PARTS

SELECT
    SALE_DATE,

    DATE_FORMAT(SALE_DATE, 'EEEE') AS DAY_NAME,
    DATE_FORMAT(SALE_DATE, 'MMMM') AS MONTH_NAME,

    DAY(SALE_DATE) AS DAY_NUMBER,
    MONTH(SALE_DATE) AS MONTH_NUMBER,
    YEAR(SALE_DATE) AS YEAR_NUMBER,

    DATE_FORMAT(SALE_DATE, 'HH:mm:ss') AS TIME_ONLY

FROM BRIGHT.CAR.CLEAN_SALES;