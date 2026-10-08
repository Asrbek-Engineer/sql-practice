-- rank the orders based on their sales from highes to lowest
select
	orderid,
	productid,
	sales,
	row_number() over(order by sales desc) as sales_rank_row,
	rank() over(order by sales desc) as sales_rank_rank,
	dense_rank() over(order by sales desc) as sales_rank_dense_rank
from sales.orders

-- find the top highest sales for each product
select
*
from (
	select
		orderid,
		productid,
		sales,
		row_number() over(partition by productid order by sales desc) as rank_by_product
	from sales.orders
)t
where rank_by_product = 1

-- find the lowest 2 customers based on their total sales
select
*
from (
	select
		productid,
		sum(sales) as total_sales,
		row_number() over(order by sum(sales)) as rank_customers
	from sales.orders
	group by productid
)t
where rank_customers <= 2

-- identify duplicate rows in the table 'orders archive'
-- and return a clean result without any duplicates
select
*
from (
	select
		row_number() over(partition by orderid order by creationtime desc) rn,
		*
	from sales.ordersarchive
)t
where rn = 1

-- find the products that fall within the highest 40% of the prices
select
	*,
	concat(dist_rank * 100, '%') as dist_rank_percent
from (
	select
		product,
		price,
		cume_dist() over(order by price desc) as dist_rank
	from sales.products
)t

-- NTILE(N)
select
	orderid,
	sales,
	ntile(4) over(order by sales desc) four_bucket,
	ntile(3) over(order by sales desc) three_bucket,
	ntile(2) over(order by sales desc) two_bucket,
	ntile(1) over(order by sales desc) one_bucket
from sales.orders

-- segment all orders into 3 categories: high medium and low sales
select
	*,
	case
		when buckets = 1 then 'High'
		when buckets = 2 then 'Medium'
		when buckets = 3 then 'Mow'
	end sales_segmentations
from (
	select
		orderid,
		sales,
		ntile(3) over(order by sales desc) buckets
	from sales.orders
)t

-- in order to export the data, divide orders into 2 groups
select
	ntile(2) over(order by orderid) buckets,
	*
from sales.orders
