-- CTAS + Temp tables practice (~30 min)
-- Database: SalesDB
-- Before you submit, check 3 things:
--   1) Columns: is every column the task asks for in the result?  (write "-- columns: ..." before each query)
--   2) Division: before every / or AVG, is the column an INT? If so, CAST it first.
--   3) Full run: run the WHOLE file once from top to bottom (F5). It must run twice without errors.
USE SalesDB;
GO

/* ============ Part 1: CTAS (~12 min) ============ */

-- Task 1: Create the table sales.customer_sales_snapshot with one row per customer (ALL customers):
-- customerid, country, number of orders, total sales and snapshot_date (today's date, DATE type).
-- The script must run twice without errors.
-- columns: customerid, country, nr_of_orders, total_sales, snapshot_date
if object_id('sales.customer_sales_snapshot', 'U') is not null
	drop table sales.customer_sales_snapshot;
go

select
	c.customerid,
	c.country,
	count(o.orderid) as nr_of_orders,
	coalesce(sum(sales), 0) as total_sales,
	cast(getdate() as date) as snapshot_date
into sales.customer_sales_snapshot
from sales.customers as c
left join sales.orders as o
	on o.customerid = c.customerid
group by c.customerid, c.country;

select
	customerid,
	country,
	nr_of_orders,
	total_sales,
	snapshot_date
from sales.customer_sales_snapshot
go
-- Task 2: Rebuild the lesson's sales.monthly_orders correctly:
-- one row per month as a real date (DATETRUNC), number of orders and total sales, sorted by month when you select it.
-- columns: real_date, nr_of_orders, total_sales
if object_id('sales.monthly_orders', 'U') is not null
	drop table sales.monthly_orders;
go

select
	datetrunc(month, orderdate) as order_month,
	count(orderid) as nr_of_orders,
	coalesce(sum(sales), 0) as total_sales
into sales.monthly_orders
from sales.orders
group by datetrunc(month, orderdate)
go

select
	order_month,
	nr_of_orders,
	total_sales
from sales.monthly_orders
order by order_month
go

-- Task 3 (answer as a comment):
-- a) A new order is inserted into sales.Orders. Which one shows it: sales.v_customer_summary (the view) or
--    sales.customer_sales_snapshot (the CTAS table)? Why?
-- b) How do you bring the CTAS table up to date?
-- a) sales.v_customer_summary (the view) virtual table shows new order up to dates multi queries
-- because it directly connected to the table
-- b) by executing code query again so it can up to date

/* ============ Part 2: Temp tables (~10 min) ============ */

-- Task 4 (staging workflow, like a small ETL):
-- Step 1: copy sales.Orders into the temp table #orders_stage.
-- Step 2: delete the 'Shipped' orders from #orders_stage.
-- Step 3: from #orders_stage, show orderstatus, the number of orders and total sales per orderstatus.
-- Comment: why is it safe to DELETE here, but dangerous to run the same DELETE on sales.Orders?
-- because deleting in temporary tables change nothing it only lives in session time
-- while deleting from sales.orders table is permament losing data
-- columns: orderstatus, nr_of_orders, total_sales
if object_id('tempdb..#orders_stage', 'U') is not null
	drop table #orders_stage;
go
-- Step 1
select
	*
into #orders_stage
from sales.orders;
go
-- Step 2
delete from #orders_stage
where orderstatus = 'Shipped';
go
-- Step 3
select
	orderstatus,
	count(orderid) as nr_of_orders,
	sum(sales) as total_sales
from #orders_stage
group by orderstatus;
go

/* ============ Part 3: Choose the right tool (~8 min) ============ */

-- Task 5 (answer as a comment): complete the table (one short line each).
--             | stores data?   | lives how long?       | use it when...
-- CTE         |      no        |      in one query     |	needs solution in query
-- View        |      no        |      permament        |	usefull it can help to use up to dating datas
-- Temp table  |      yes       |      session time     |	modify and compact data in order to purpose but in a short time
-- CTAS table  |      yes       |      permament        |	if views are slowing sometimes then it is time to use ctas


/* ============ Cleanup ============ */
-- Drop the practice tables you created (sales.monthly_orders, sales.customer_sales_snapshot) so the database stays clean.
if object_id('sales.monthly_orders', 'U') is not null
	drop table sales.monthly_orders;
go

if object_id('sales.customer_sales_snapshot', 'U') is not null
	drop table sales.customer_sales_snapshot;
go