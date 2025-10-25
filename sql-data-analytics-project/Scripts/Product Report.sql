/*
===============================================================================
Product Report
===============================================================================

Purpose:
    - Provides insights into product performance and customer purchasing behavior.

Metrics calculated per Product:
    1. total_orders         → Number of orders the product appears in
    2. total_sales          → Total revenue generated
    3. total_quantity       → Total units sold
    4. unique_customers     → Number of different customers who bought the product
    5. first_order_date     → Date product first sold
    6. last_order_date      → Date product last sold
    7. lifespan_months      → Active selling duration in months
    8. avg_selling_price    → Average price per unit sold
    9. avg_monthly_sales    → Revenue / lifespan
    10. product_segment     → Best Seller / Mid Seller / Low Seller

===============================================================================
*/

USE DataWarehouseAnalytics;
GO

;WITH ProductMetrics AS (
    SELECT
        p.product_key,
        p.product_name,
        p.category,

        COUNT(DISTINCT s.order_number) AS total_orders,
        SUM(s.sales_amount) AS total_sales,
        SUM(s.quantity) AS total_quantity,
        COUNT(DISTINCT s.customer_key) AS unique_customers,

        MIN(s.order_date) AS first_order_date,
        MAX(s.order_date) AS last_order_date
    FROM [gold.fact_sales] s
    LEFT JOIN [gold.dim_products] p
        ON s.product_key = p.product_key
    GROUP BY 
        p.product_key, p.product_name, p.category
),

FinalProductReport AS (
    SELECT
        product_key,
        product_name,
        category,

        total_orders,
        total_sales,
        total_quantity,
        unique_customers,
        first_order_date,
        last_order_date,

        -- ✅ Product Active Duration (Months)
        DATEDIFF(MONTH, first_order_date, last_order_date) + 1 AS lifespan_months,

        -- ✅ Average Selling Price Per Unit
        CASE WHEN total_quantity > 0 
             THEN total_sales * 1.0 / total_quantity 
             ELSE 0 END AS avg_selling_price,

        -- ✅ Average Monthly Revenue
        CASE WHEN (DATEDIFF(MONTH, first_order_date, last_order_date) + 1) > 0
             THEN total_sales * 1.0 / (DATEDIFF(MONTH, first_order_date, last_order_date) + 1)
             ELSE 0 END AS avg_monthly_sales
    FROM ProductMetrics
)

SELECT
    *,
    -- ✅ Product Performance Segmenting
    CASE 
        WHEN total_sales > 10000 THEN 'Best Seller'
        WHEN total_sales BETWEEN 3000 AND 10000 THEN 'Mid Seller'
        ELSE 'Low Seller'
    END AS product_segment

FROM FinalProductReport
ORDER BY total_sales DESC;
