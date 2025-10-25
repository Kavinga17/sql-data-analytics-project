Use DataWarehouseAnalytics

---wich catergories contribute for the most of the Sales
;with categories_Contribution AS (
select  p.category,
sum(s.sales_amount) as salesAmount
from [gold.fact_sales] s
left join [gold.dim_products] p 
ON s.product_key=p.product_key
group BY (p.Category)
)

select category,
salesAmount,
sum(salesAmount) over() as Overall_Sales,
Concat(ROUND (Cast (salesAmount AS float)/sum(salesAmount) over () * 100,3), '%') AS Precentage_of_Total
from categories_Contribution
