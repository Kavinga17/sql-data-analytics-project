USE DataWarehouseAnalytics
-- Analyze the Performance
;WITH Product_Analysis AS (
    SELECT 
        YEAR(s.order_date) AS Order_Year,
        p.product_name,
        SUM(s.sales_amount) AS Current_Sales
    FROM [gold.fact_sales] s
    LEFT JOIN [gold.dim_products] p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY YEAR(s.order_date), p.product_name
)
SELECT 
    Order_Year,
    product_name,
    Current_Sales,
    AVG(Current_Sales) OVER (PARTITION BY product_name) AS Average_Current_Sales,
    Current_Sales - AVG(Current_Sales) OVER (PARTITION BY product_name) AS Difference,
    CASE 
        WHEN Current_Sales - AVG(Current_Sales) OVER (PARTITION BY product_name) > 0 THEN 'ABOVE AVG'
        WHEN Current_Sales - AVG(Current_Sales) OVER (PARTITION BY product_name) < 0 THEN 'BELOW AVG'
        ELSE 'EQUAL AVG'
    END AS AVG_CHANGE,

    LAG(Current_sales) OVER (PARTITION BY product_name ORDER BY Order_Year) AS PY_SALES,
    (Current_Sales - LAG(Current_sales) OVER (PARTITION BY product_name ORDER BY Order_Year)) AS PY_Difference,

    CASE
        WHEN LAG(Current_sales) OVER (PARTITION BY product_name ORDER BY Order_Year) IS NULL THEN 'NO PRIOR DATA'
        WHEN Current_Sales > LAG(Current_sales) OVER (PARTITION BY product_name ORDER BY Order_Year) THEN 'INCREASE'
        WHEN Current_Sales < LAG(Current_sales) OVER (PARTITION BY product_name ORDER BY Order_Year) THEN 'DECREASE'
        ELSE 'NO CHANGE'
    END AS PY_Change_Status

FROM Product_Analysis
ORDER BY Order_Year, product_name;
