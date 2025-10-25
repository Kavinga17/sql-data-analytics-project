 --- find out cumalative Total sales Amount in month Wise
 ---(Window Function)

 use DataWarehouseAnalytics

SELECT 
    [Order Month],
    [Sum of the SalesAmount],
    SUM([Sum of the SalesAmount]) OVER (ORDER BY [Order Month]) AS running_total_sales,
    avg([Average of the sales Amount]) OVER (ORDER BY [Order Month]) AS Runnig_Total_Avg
FROM 
(
    SELECT 
        MONTH(order_date) AS [Order Month], 
        SUM(sales_amount) AS [Sum of the SalesAmount],
        avg (sales_amount) AS [Average of the sales Amount]
    FROM [gold.fact_sales]
    WHERE MONTH(order_date) IS NOT NULL
    GROUP BY MONTH(order_date)
) t;

