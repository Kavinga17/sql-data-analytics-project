Use DataWarehouseAnalytics

select * from [gold.fact_sales]


select year(order_date),sum(sales_amount)  AS 'TOLAL SALES AMOUNT',
count (DISTINCT customer_key) AS 'Toatal customers'
,count(quantity)
from [gold.fact_sales]
where order_date IS NOT NULL
group by year(order_date)
order by year(order_date);






