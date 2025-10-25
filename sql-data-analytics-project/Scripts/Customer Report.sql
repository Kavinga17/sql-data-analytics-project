/*
===============================================================================
Customer Report
===============================================================================

Purpose:
    - This report consolidates key customer metrics and behaviors.

Highlights:
    1. Gathers essential customer and transaction details.
    2. Segments customers into categories (VIP, Regular, New) based on 
       lifespan and total spending.
    3. Aggregates customer-level metrics:
       - total orders
       - total sales
       - total quantity purchased
       - total products purchased
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last order)
       - average order value
       - average monthly spend

===============================================================================
*/

USE DataWarehouseAnalytics;
-- ✅ Add semicolon above

WITH CustomerMetrics AS (
    SELECT
        c.customer_key,
        c.birthdate,

        COUNT(DISTINCT s.order_number) AS total_orders,  -- Ensure column name is correct
        SUM(s.sales_amount) AS total_sales,
        SUM(s.quantity) AS total_quantity,
        COUNT(DISTINCT s.product_key) AS total_products,

        MIN(s.order_date) AS first_order_date,
        MAX(s.order_date) AS last_order_date
    FROM [gold.fact_sales] s
    LEFT JOIN [gold.dim_customers] c
        ON s.customer_key = c.customer_key
    GROUP BY 
        c.customer_key, c.birthdate
),

FinalReport AS (
    SELECT
        customer_key,
        birthdate,
        -- ✅ Calculate age
        DATEDIFF(YEAR, birthdate, GETDATE()) AS age,

        total_orders,
        total_sales,
        total_quantity,
        total_products,
        first_order_date,
        last_order_date,

        -- Lifespan in months
        DATEDIFF(MONTH, first_order_date, last_order_date) + 1 AS lifespan,

        -- Recency since last order
        DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

        -- KPIs
        CASE WHEN total_orders > 0 THEN total_sales * 1.0 / total_orders 
             ELSE 0 END AS average_order_value,

        CASE WHEN (DATEDIFF(MONTH, first_order_date, last_order_date) + 1) > 0 
             THEN total_sales * 1.0 / (DATEDIFF(MONTH, first_order_date, last_order_date) + 1)
             ELSE 0 END AS average_monthly_spend
    FROM CustomerMetrics
)

SELECT
    *,
    -- ✅ Age Group Classification
    CASE 
        WHEN age BETWEEN 18 AND 30 THEN 'Young Adult'
        WHEN age BETWEEN 31 AND 50 THEN 'Adult'
        WHEN age > 50 THEN 'Senior'
        ELSE 'Below 18'
    END AS age_group,

    -- Existing customer segmentation
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New Customer'
    END AS customer_segment

FROM FinalReport
ORDER BY total_sales DESC;
