/* =========================================================
   PowerBean Sales & Shipment Analytics – SQL Analysis
   ========================================================= */

/* ---------------------------------------------------------
   1. OVERALL KPI METRICS
--------------------------------------------------------- */

-- Total Sales Revenue
SELECT SUM(sales) AS total_sales
FROM shipment_data;

-- Total Boxes Shipped
SELECT SUM(boxes) AS total_boxes
FROM shipment_data;

-- Total Shipments
SELECT COUNT(*) AS total_shipments
FROM shipment_data;


/* ---------------------------------------------------------
   2. MONTHLY SALES TREND
--------------------------------------------------------- */

-- Monthly Sales Aggregation
SELECT 
    DATE_FORMAT(order_date, '%Y-%m-01') AS month,
    SUM(sales) AS monthly_sales
FROM shipment_data
GROUP BY month
ORDER BY month;


/* ---------------------------------------------------------
   3. MONTH-OVER-MONTH (MoM) SALES GROWTH
--------------------------------------------------------- */

WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m-01') AS month,
        SUM(sales) AS total_sales
    FROM shipment_data
    GROUP BY month
)

SELECT 
    month,
    total_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY month)) 
        / LAG(total_sales) OVER (ORDER BY month) * 100, 
    2) AS mom_growth_pct
FROM monthly_sales;


/* ---------------------------------------------------------
   4. SALES PERFORMANCE BY SALESPERSON
--------------------------------------------------------- */

-- Total Sales & Boxes by Salesperson
SELECT 
    sales_person,
    SUM(sales) AS total_sales,
    SUM(boxes) AS total_boxes
FROM shipment_data
GROUP BY sales_person
ORDER BY total_sales DESC;

-- Rank Salespersons by Revenue
SELECT 
    sales_person,
    SUM(sales) AS total_sales,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM shipment_data
GROUP BY sales_person;


/* ---------------------------------------------------------
   5. PRODUCT PERFORMANCE ANALYSIS
--------------------------------------------------------- */

-- Revenue & Boxes by Product
SELECT 
    product,
    SUM(sales) AS total_sales,
    SUM(boxes) AS total_boxes
FROM shipment_data
GROUP BY product
ORDER BY total_sales DESC;


/* ---------------------------------------------------------
   6. GEOGRAPHY PERFORMANCE ANALYSIS
--------------------------------------------------------- */

-- Revenue by Geography
SELECT 
    geography,
    SUM(sales) AS total_sales,
    SUM(boxes) AS total_boxes
FROM shipment_data
GROUP BY geography
ORDER BY total_sales DESC;


/* ---------------------------------------------------------
   7. SHIPMENT SIZE DISTRIBUTION (BOX SEGMENTATION)
--------------------------------------------------------- */

SELECT 
    CASE 
        WHEN boxes BETWEEN 0 AND 100 THEN '0-100'
        WHEN boxes BETWEEN 101 AND 300 THEN '101-300'
        WHEN boxes BETWEEN 301 AND 600 THEN '301-600'
        ELSE '600+'
    END AS box_range,
    COUNT(*) AS shipment_count,
    SUM(sales) AS total_sales
FROM shipment_data
GROUP BY box_range
ORDER BY box_range;


/* ---------------------------------------------------------
   8. TOP 5 PRODUCTS PER GEOGRAPHY
--------------------------------------------------------- */

SELECT *
FROM (
    SELECT 
        geography,
        product,
        SUM(sales) AS total_sales,
        RANK() OVER (PARTITION BY geography ORDER BY SUM(sales) DESC) AS rank_in_region
    FROM shipment_data
    GROUP BY geography, product
) ranked
WHERE rank_in_region <= 5;


/* ---------------------------------------------------------
   9. DAILY SALES ANALYSIS
--------------------------------------------------------- */

-- Highest Revenue Day
SELECT 
    order_date,
    SUM(sales) AS daily_sales
FROM shipment_data
GROUP BY order_date
ORDER BY daily_sales DESC
LIMIT 1;


/* ---------------------------------------------------------
   10. IDENTIFY LOW PERFORMING SALESPERSONS
--------------------------------------------------------- */

SELECT 
    sales_person,
    SUM(sales) AS total_sales
FROM shipment_data
GROUP BY sales_person
HAVING SUM(sales) < (
    SELECT AVG(total_sales)
    FROM (
        SELECT SUM(sales) AS total_sales
        FROM shipment_data
        GROUP BY sales_person
    ) avg_table
)
ORDER BY total_sales;
