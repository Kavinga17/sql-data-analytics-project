---group customers into three segmants Based on their Spending Behaviour

USE DataWarehouseAnalytics;

WITH CustomerSales AS (
    SELECT 
        c.customer_key,
        SUM(s.sales_amount) AS total_spending,
        MIN(s.order_date) AS first_order_date,
        MAX(s.order_date) AS last_order_date
    FROM [gold.fact_sales] s
    LEFT JOIN [gold.dim_customers] c
        ON s.customer_key = c.customer_key
    GROUP BY c.customer_key
),
CustomerLifespan AS (
    SELECT
        customer_key,
        total_spending,
        first_order_date,
        last_order_date,
        DATEDIFF(MONTH, first_order_date, last_order_date) + 1 AS lifespan
    FROM CustomerSales
)
SELECT
    customer_key,
    total_spending,
    first_order_date,
    last_order_date,
    lifespan,
    CASE 
        WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
        ELSE 'New Customer'
    END AS CustomerSegment
FROM CustomerLifespan
ORDER BY total_spending DESC;
