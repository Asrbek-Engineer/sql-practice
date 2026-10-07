-- Window Aggregate Functions practice (~50 min)
-- Database: SalesDB
-- Before you submit, check 6 things:
--   1) Are all the columns the task asks for in the result?
--   2) Is any column used with / or AVG an INT? If so, cast it to DECIMAL first.
--   3) Are you grouping or sorting by a real date, not by text or month number?
--   4) Does each alias describe its value?
--   5) Did you look at 1-2 result rows and check them by eye?
--   6) Did you apply every feedback rule to the whole file?
USE SalesDB;

/* ============ Part 1: COUNT (~10 min) ============ */

-- Task 1: Show orderid, customerid, orderstatus and the number of orders that have the same orderstatus.
select
	orderid,
	customerid,
	orderstatus,
	count(*) over(partition by orderstatus) as nr_of_orders
from sales.orders;

-- Task 2: Show each customer's firstname, country, the number of customers in the same country,
-- and the number of customers in the same country who have a score.
-- Comment: why can the two numbers be different?
select
	firstname,
	country,
	score,
	count(country) over(partition by country) as customers_by_country,
	count(score) over(partition by country) as customers_by_country_score
from sales.customers
-- because there is a Null value in score

-- Task 3: In sales.OrdersArchive, show the FULL rows (all columns) of every orderid that appears more than once.
select
*
from (
	select 
	*,
	count(*) over(partition by orderid) as orders_count
	from sales.ordersarchive
)t 
where orders_count > 1;

/* ============ Part 2: SUM (~10 min) ============ */

-- Task 4: Show orderid, customerid, sales, the customer's total sales,
-- and the order's share of the customer's total sales in percent (DECIMAL, 2 decimals).
select
	orderid,
	customerid,
	sales,
	sum(sales) over(partition by customerid) customer_total_sales,
	cast(round(100 * cast(sales as decimal(10,2)) / sum(sales) over(partition by customerid), 2) as decimal(5, 2)) as orders_share_percent
from sales.orders;

-- Task 5: From sales.Products, show product, category, price, the total price of its category,
-- and the product's share of the category total in percent (DECIMAL, 2 decimals).
select
	product,
	category,
	price,
	sum(price) over(partition by category) as category_total_price,
	cast(round(100 * cast(price as decimal(10,2)) / sum(price) over(partition by category), 2) as decimal(5, 2)) as products_share_percent
from sales.products;

/* ============ Part 3: AVG (~10 min) ============ */

-- Task 6: Show orderid, productid, sales, the average sales of its product (2 decimals),
-- and how much the order's sales are above or below that average.
select
	*,
	sales - avg_sales_by_product as above_or_below
from (
	select
		orderid,
		productid,
		sales,
		cast(avg(cast(sales as decimal(10, 2))) over(partition by productid) as decimal(10, 2)) avg_sales_by_product
	from sales.orders
)t;

-- Task 7: Show customers whose score is above the average score of all customers.
-- Decide whether a missing score should count as 0. Comment on what you chose and why.
select
*
from (
	select
		*,
		cast(avg(cast(score as decimal(10, 2))) over() as decimal(10, 2)) avg_score
	from sales.customers
)t
where score > avg_score;
-- With 0, the average drops, so more customers look above average. A missing score is unknown, not zero

/* ============ Part 4: MIN and MAX (~10 min) ============ */

-- Task 8: Show orderid, customerid, orderdate, the customer's first order date, the customer's last order date,
-- and how many days passed between the customer's first order and this order.
select
	orderid,
	customerid,
	orderdate,
	min(orderdate) over(partition by customerid) as first_order_date,
	max(orderdate) over(partition by customerid) as last_order_date,
	datediff(day, min(orderdate) over(partition by customerid), orderdate) as days_passed
from sales.orders;

-- Task 9: Show the most expensive product in each category (sales.Products).
select
	*
from(
	select 
		*,
		max(price) over(partition by category) as highest_price
	from sales.products
)t
where price = highest_price


/* ============ Part 5: Running and rolling (~10 min) ============ */

-- Task 10: Show orderid, customerid, orderdate, sales and a running total of sales for each customer,
-- ordered by orderdate. Write the frame explicitly.
select
	orderid,
	customerid,
	orderdate,
	sales,
	sum(sales) over(partition by customerid order by orderdate, orderid rows between unbounded preceding and current row) as explicit_total_sales_by_orderdate
from sales.orders;

-- Task 11 (trap): Run these two columns side by side:
--   SUM(sales) OVER (ORDER BY DATEPART(month, orderdate))
--   SUM(sales) OVER (ORDER BY DATEPART(month, orderdate) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
-- Comment: why are the values different for orders in the same month?
-- Comment: what would go wrong if the table had orders from two different years?
select
 SUM(sales) OVER (ORDER BY DATEPART(month, orderdate)) as range_running_total,
 SUM(sales) OVER (ORDER BY DATEPART(month, orderdate) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as rows_running_total
from sales.orders;
-- the first line of code shows summary of all orderdate sales month by month and duplicates
-- while the rest code show summary of sales row by row like initially sum gets 0, sum += sum + sales and shows
-- if table had two different years result will be wrong because DATEPART(month, orderdate) only gets month

-- Task 12: Ordered by orderdate, show orderid, orderdate, sales and the average sales
-- of the current order and the 2 orders before it (DECIMAL, 2 decimals).
select
	orderid,
	orderdate,
	sales,
	cast(avg(cast(sales as decimal(10, 2))) over(order by orderdate, orderid rows between 2 preceding and current row) as decimal(10, 2)) as avg_sales_by_date
from sales.orders;

/* ============ Bonus ============ */

-- Bonus: Show one row per month (use DATETRUNC) with the month's total sales
-- and a running total of monthly sales across months.
-- Hint: a window function can run on top of GROUP BY: SUM(SUM(sales)) OVER (...)
select
	datetrunc(month, orderdate) as order_month,
	sum(sales) as monthly_sales,
	sum(sum(sales)) over(order by datetrunc(month, orderdate)) as running_total_sales
from sales.orders
group by datetrunc(month, orderdate);