-- Window Ranking Functions practice + review (~60 min)
-- Database: SalesDB
-- NEW HABIT: before each query, write the expected columns as a comment, e.g.
--   -- columns: orderid, productid, sales, sales_rank
-- Before you submit, check 6 things:
--   1) Are all the columns the task asks for in the result?
--   2) Is any column used with / or AVG an INT? If so, cast it to DECIMAL first.
--   3) Are you grouping or sorting by a real date, not by text or month number?
--   4) Does each alias describe its value?
--   5) Did you look at 1-2 result rows and check them by eye?
--   6) Did you apply every feedback rule to the whole file?
USE SalesDB;

/* ============ Review 1: CASE retest (15 min, NO notes) ============ */

-- R1: Show product, price and a price_level column:
-- 'Cheap' if price is under 15, 'Medium' if 15-25, 'Expensive' if over 25.
select
	product,
	price,
	case
		when price < 15 then 'Cheap'
		when price <= 25 then 'Medium'
		else 'Expensive'
	end as price_level
from sales.products;

-- R2: Show customerid and a score_label column:
-- the score as text, or 'No score' when the score is missing.
select
	customerid,
	case 
		when score is null then 'No score'
		else cast(score as varchar(10))
	end as score_label
from sales.customers;

-- R3 (trap): This query never returns 'missing'. Explain why as a comment, then fix it.
-- SELECT customerid, score,
--     CASE score WHEN NULL THEN 'missing' ELSE 'ok' END AS score_status
-- FROM sales.Customers;
SELECT customerid, score,
   CASE WHEN score is NULL THEN 'missing' ELSE 'ok' END AS score_status
FROM sales.Customers;
-- Is Null when we are checking nulls
-- Short CASE compares with =, and NULL = NULL is UNKNOWN, so it never matches

/* ============ Review 2: Window Aggregate (10 min) ============ */

-- A1: Show orderid, productid, sales, the product's total sales,
-- and the order's share of the product's total sales in percent (DECIMAL, 2 decimals).
select
	orderid,
	productid,
	sales,
	sum(sales) over(partition by productid) as product_total_sales,
	cast(100 * cast(sales as decimal(10, 2)) / sum(cast(sales as decimal(10, 2))) over(partition by productid) as decimal(5,2)) as product_total_sales_percent
from sales.orders

-- A2: Show orderid, productid, orderdate, sales and a running total of sales for each product,
-- ordered by orderdate (write the frame and a tie-breaker).
select
	orderid,
	productid,
	orderdate,
	sales,
	sum(sales) over(partition by productid order by orderdate, orderid rows between unbounded preceding and current row) as running_total_sales
from sales.orders;

/* ============ Part 1: ROW_NUMBER, RANK, DENSE_RANK (~15 min) ============ */

-- Task 1: Show orderid, sales and three ranks of the orders by sales (highest first):
-- ROW_NUMBER, RANK and DENSE_RANK side by side.
-- Comment: on which rows do the three columns differ, and why?
select
	orderid,
	sales,
	row_number() over(order by sales desc) as row_number_r,
	rank() over(order by sales desc) as rank_r,
	dense_rank() over(order by sales desc) as dense_rank_r
from sales.orders;
-- row_number() returns unique value which shows numbers incrementally order by order
-- rank() if there is duplicate shows first number until duplicate will over 
-- in the background it counts duplicates and adds it to first duplicate 
-- dense_rank() if there is duplicates shows first number until duplicate will over
-- but do not count and considers duplicates then shows next number

-- Task 2: Show the single highest-sales order for each product (one row per product).
select
	*
from (
	select
		*,
		row_number() over(partition by productid order by sales desc) product_highest_sales
	from sales.orders
)t
where product_highest_sales = 1;

-- Task 3: Show the 2 customers with the lowest total sales.
-- Hint: GROUP BY customer first, then rank.
select 
	*
from (
	select
		customerid,
		sum(sales) as customer_total_sales,
		row_number() over(order by sum(sales)) as total_sales_rank
	from sales.orders
	group by customerid
)t
where total_sales_rank <= 2;

-- Task 4: Show the order with the SECOND highest sales value across all orders.
-- If two orders share the highest value, the next different value counts as second.
select
	orderid,
	sales
from (
	select 
		orderid,
		sales,
		dense_rank() over(order by sales desc) as highest_value_rank
	from sales.orders
)t
where highest_value_rank = 2;

/* ============ Part 2: Real data engineering use cases (~15 min) ============ */

-- Task 5: sales.OrdersArchive has several versions of the same orderid.
-- Keep only the latest version of each orderid (latest creationtime). Show all columns.
select
	*
from (
	select
		*,
		row_number() over(partition by orderid order by creationtime desc) order_number
	from sales.ordersarchive
)t
where order_number = 1;

-- Task 6: Give every row of sales.OrdersArchive a unique number (a surrogate key),
-- ordered by orderid and then creationtime.
select
	*,
	row_number() over(order by orderid, creationtime) order_number
from sales.ordersarchive;

-- Task 7 (answer as a comment): Why is this invalid, and how do you fix it?
-- SELECT * FROM sales.Orders
-- WHERE ROW_NUMBER() OVER (PARTITION BY productid ORDER BY sales DESC) = 1;
-- we only can use window functions in select or order by otherwise it goes wrong
-- used subquery in order to fix it
select
	*
from (
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY productid ORDER BY sales DESC) as highest_product_sales
	FROM sales.Orders
)t
where highest_product_sales = 1;
	
/* ============ Part 3: NTILE, CUME_DIST, PERCENT_RANK (~15 min) ============ */

-- Task 8: Split the orders into 3 groups by sales (highest first) with NTILE,
-- and label the groups 'High', 'Medium', 'Low' with CASE.
select
	*,
	case number_group 
		when 1 then 'High'
		when 2 then 'Medium'
		when 3 then 'Low'
	end as label_group
from (
	select
		*,
		ntile(3) over(order by sales desc) as number_group
	from sales.orders
)t;

-- Task 9: Rank customers by score inside each country with DENSE_RANK (highest score first).
-- Comment: where do customers with a missing score end up, and why?
select
	*,
	dense_rank() over(partition by country order by score desc) as country_score
from sales.customers;
-- customers whose score is null automatically takes last place from orders especially descending order 
-- because is in SQL SERVER Null considered lowest value so in asc it takes first and in desc takes last place
-- Task 10: Show the products whose price is in the top 40% (use CUME_DIST, highest price first).
-- Show product, price and the CUME_DIST value as a percentage (DECIMAL, 2 decimals).
select
	product,
	price,
	cast(100 * price_percent as decimal(5,2)) as product_price_percent
from (
	select
		product,
		price,
		cume_dist() over(order by price desc) as price_percent
	from sales.products
)t
where 100 * price_percent <= 40;

/* ============ Bonus ============ */

-- Bonus: For each customer, show the date of their SECOND order.
-- Customers with only one order should not appear.

select
	customerid,
	orderdate
from (
	select
		*,
		row_number() over(partition by customerid order by orderdate) customer_row_number
	from sales.orders
)t
where customer_row_number = 2;