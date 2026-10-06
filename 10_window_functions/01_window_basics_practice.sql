-- Window Functions Basics practice (~40 min)
-- Database: SalesDB
-- Before you submit, check 4 things:
--   1) Are all the columns the task asks for in the result?
--   2) Is any column used with / or AVG an INT? If so, cast it to DECIMAL first.
--   3) Are you grouping or sorting by a real date, not by text?
--   4) Does each alias describe its value?
USE SalesDB;

/* ============ Part 1: OVER() and PARTITION BY (~15 min) ============ */

-- Task 1: Show orderid, orderdate, sales and the total sales of ALL orders on every row.
select
	orderid,
	orderdate,
	sales,
	sum(sales) over() as total_sales
from sales.orders;

-- Task 2: Show orderid, productid, sales and the total sales of that order's product on every row.
select
	orderid,
	productid,
	sales,
	sum(sales) over(partition by productid) as product_total_sales
from sales.orders;

-- Task 3: Write the product totals from Task 2 with GROUP BY instead.
-- Comment: how many rows does each query return, and why are they different?
select
	productid,
	count(*) as nr_of_rows,
	sum(sales) as total_sales
from sales.orders
group by productid;
-- Window query returns 1 row per order, GROUP BY returns 1 row per product.

-- Task 4: Show orderid, productid, sales and the order's share of its product's total sales in percent,
-- rounded to 2 decimals. (Example: 20 out of 100 -> 20.00)
select
	orderid,
	productid,
	sales,
	cast((cast(sales as decimal(10, 2)) * 100 / sum(cast(sales as decimal(10, 2))) 
	over(partition by productid)) as decimal(5,2)) as pct_of_product_sales
from sales.orders;

-- Task 5: Show orderid, productid, orderstatus, sales and the total sales
-- for each combination of product and orderstatus.
select
	orderid,
	productid,
	orderstatus,
	sales,
	sum(sales) over(partition by productid, orderstatus) as product_status_total_sales
from sales.orders;

-- Task 6: Show orderid, customerid, sales, and in the same query:
-- the customer's number of orders and the customer's total sales.
select
	orderid,
	customerid,
	sales,
	count(orderid) over(partition by customerid) as nr_of_orders,
	sum(sales) over(partition by customerid) as total_sales
from sales.orders;

/* ============ Part 2: ORDER BY inside OVER (~10 min) ============ */

-- Task 7: Show orderid, orderdate, sales and a running total of sales ordered by orderdate.
select
	orderid,
	orderdate,
	sales,
	sum(sales) over(order by orderdate rows between unbounded preceding and current row) as running_total_sales
from sales.orders;

-- Task 8: Show orderid, productid, orderdate, sales and a running total of sales
-- for each product separately, ordered by orderdate.
select
	orderid,
	productid,
	orderdate,
	sales,
	sum(sales) over(partition by productid order by orderdate) as product_running_total
from sales.orders;

/* ============ Part 3: Frame (~10 min, do after the Frame lesson) ============ */

-- Task 9: Ordered by orderdate, show orderid, sales and the sum of the current order's sales
-- plus the next order's sales.
select
	orderid,
	sales,
	sum(sales) 
	over(order by orderdate rows between current row and 1 following) as sales_with_next
from sales.orders;

-- Task 10: Ordered by orderdate, show orderid, sales and the average sales
-- of the current order and the 2 orders before it (a moving average). Cast before AVG.
select
	orderid,
	sales,
	cast(avg(cast(sales as decimal(10,2)))
	over(order by orderdate rows between 2 preceding and current row) as decimal(5,2)) as moving_avg_sales
from sales.orders;

/* ============ Part 4: Rules (~5 min) ============ */

-- Task 11 (answer as a comment): Why does this fail, and how would you get the result?
-- SELECT orderid, sales
-- FROM sales.Orders
-- WHERE SUM(sales) OVER (PARTITION BY productid) > 100;
-- We can use Window functions only in select and order by
-- Calculate the SUM in a subquery, then filter with WHERE in the outer query

/* ============ Bonus ============ */

-- Bonus: Show orders whose sales are above the average sales of their product.
-- Hint: put the window calculation inside FROM ( ... ) like you did in CASE Task 13.
select
	orderid,
	sales,
	avg_sales as product_avg_sales
from (SELECT orderid, sales,
	cast(avg(cast(sales as decimal(10,2))) OVER (PARTITION BY productid) as decimal(5,2)) as avg_sales
FROM sales.Orders) as data
where avg_sales < sales;
