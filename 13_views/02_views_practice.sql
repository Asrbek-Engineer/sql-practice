-- Views practice (~45 min)
-- Database: SalesDB
-- Before each query, write the columns the task asks for as a comment.
-- Mark each task: -- ✓ (sure) or -- ? (not sure)
-- Before you submit, check 6 things:
--   1) Are all the columns the task asks for in the result?  (re-read the task, word by word)
--   2) Is any column used with / or AVG an INT? If so, cast it to DECIMAL first. (SUM of an INT is also an INT)
--   3) Are you grouping or sorting by a real date, not by text or month number?
--   4) Does each alias describe its value?
--   5) Did you look at 1-2 result rows and check them by eye?
--   6) Did you apply every feedback rule to the whole file?
-- View rules: put GO before and after every CREATE VIEW; make each script re-runnable.
USE SalesDB;
GO

/* ============ Part 1: Create and use views (~15 min) ============ */

-- Task 1: Create the view sales.v_customer_summary with one row per customer (ALL customers):
-- customerid, full name, country, number of orders, total sales and last order date.
-- Customers without orders show 0 orders and 0 sales.
-- The script must run twice without errors (drop the view first if it exists).
-- 1st way
--if objedt_id('sales.v_customer_summary', 'v') is not null
--	drop sales.v_customer_summary
--go
--create view sales.v_customer_summary as
--with cte_latest_order_date as
--(
--	select
--		customerid,
--		first_value(orderdate) over(partition by customerid order by orderdate desc) as latest_order_date,
--		row_number() over(partition by customerid order by orderdate) as nr_row
--	from sales.orders
--)
--, cte_orders_summary as
--(
--	select
--		o.customerid,
--		count(o.customerid) as nr_of_orders,
--		sum(sales) as total_sales,
--		clod.latest_order_date
--	from sales.orders as o
--	left join cte_latest_order_date as clod
--		on clod.customerid = o.customerid
--	where clod.nr_row = 1
--	group by o.customerid, clod.latest_order_date
--)
--select
--	c.customerid,
--	concat(coalesce(c.firstname, ''), ' ', coalesce(c.lastname, '')) as full_name,
--	coalesce(ctoc.nr_of_orders, 0) as nr_of_orders,
--	coalesce(ctoc.total_sales, 0) as total_sales,
--	coalesce(cast(ctoc.latest_order_date as varchar(10)), 'No date') as latest_order_date
--from sales.customers as c
--left join cte_orders_summary as ctoc
--	on ctoc.CustomerID = c.CustomerID
--go
--select * from sales.v_customer_summary

-- 2nd way
if object_id('sales.v_customer_summary', 'v') is not null
	drop view sales.v_customer_summary;
go

create view sales.v_customer_summary as
select
	c.customerid,
	concat(coalesce(c.firstname, ''), ' ', coalesce(c.lastname, '')) as full_name,
	c.country,
	count(o.orderid) as nr_of_orders,
	coalesce(sum(o.sales), 0) as total_sales,
	max(o.orderdate) as last_order_date
from sales.customers as c
left join sales.orders as o
	on o.customerid = c.customerid
group by
	c.customerid,
	c.firstname,
	c.lastname,
	c.country;
go

select * from sales.v_customer_summary;
-- Task 2: Using ONLY the view from Task 1 (no base tables), show the 3 customers with the highest total sales.
-- 1st way
with cte_3highest_total_sales as
(
	select
		customerid,
		row_number() over(order by total_sales desc) as rank_nr
	from sales.v_customer_summary
)
select 
	vcs.* 
from sales.v_customer_summary as vcs
left join cte_3highest_total_sales as c3h
	on c3h.customerid = vcs.customerid
where c3h.rank_nr <= 3
order by c3h.rank_nr;

-- 2nd way
select 
	top 3 *
from sales.v_customer_summary
order by total_sales desc;

-- Task 3 (trap): Try to create a view that has ORDER BY total_sales DESC inside it.
-- Comment: what error do you get, and why does SQL Server not allow it?
-- Comment: where should the sorting be written instead?
-- error: The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, 
-- and common table expressions, unless TOP, OFFSET or FOR XML is also specified.
-- in order to relational database theory any tables and set of datas initially unordered set of rows, views or ctes are virtual tables which means
-- it is not logically true if some (table*) initially ordered
-- instead we can use order by offset or top with order by or outside of view when we call
go
create view some_view as 
select
	sum(sales) as total_sales
from sales.orders
group by customerid
order by total_sales desc offset 0 rows;
go

select * from some_view;


/* ============ Part 2: Views with calculations (~15 min) ============ */

-- Task 4: Create the view sales.v_product_performance:
-- product, category, total quantity, total sales,
-- and the product's share of its category's total sales in percent (DECIMAL, 2 decimals).
go
create view sales.v_product_performance as
with cte_product_summary as
(
	select
		p.product,
		p.category,
		coalesce(sum(o.quantity), 0) as total_quantity,
		coalesce(sum(sales), 0) as total_sales
	from sales.products as p
	left join sales.orders as o
		on o.productid = p.productid
	group by 
		p.product,
		p.category
)
select
	*,
	cast(100.0 * cast(cps.total_sales as decimal(10, 2)) / sum(nullif(cps.total_sales, 0)) over(partition by cps.category) as decimal(10, 2)) as product_share
from cte_product_summary as cps;
go

select * from sales.v_product_performance;

-- Task 5: Change sales.v_monthly_summary with CREATE OR ALTER VIEW:
-- keep all its columns and add the average sales per order (DECIMAL, 2 decimals).
go
create or alter view sales.v_monthly_summary as
select
	datetrunc(month, orderdate) as order_month,
	sum(sales) as total_sales,
	count(orderid) as total_orders,
	sum(quantity) as total_quantity,
	cast(cast(sum(sales) as decimal(10, 2)) / nullif(count(orderid), 0.0) as decimal(10, 2)) as avg_sales_per_order
from sales.orders
group by datetrunc(month, orderdate);
go

select * from sales.v_monthly_summary;

/* ============ Part 3: NULL trap and theory (~15 min) ============ */

-- Task 6: Count the rows in sales.v_order_details, in sales.v_order_details_eu,
-- and the rows of sales.v_order_details where customer_country = 'USA'.
-- Comment: do the numbers add up? What would happen to an order whose customer has a NULL country?
-- Then write the WHERE condition that keeps such orders in the EU view.
-- 1st way
select
	count(v.orderid) as orders_count,
	count(veu.orderid) as eu_orders_count,
	count(v1.orderid) as usa_orders_count
from sales.v_order_details as v
full join sales.v_order_details_eu as veu
	on v.orderid = veu.orderid
full join 
(
	select
		orderid 
	from sales.v_order_details 
	where customer_country = 'USA'
) as v1
	on v1.orderid = v.orderid;

-- 2nd way
SELECT
    (select count(*) from sales.v_order_details) as orders_count,
    (select count(*) from sales.v_order_details_eu) as eu_orders_count,
    (select count(*) from sales.v_order_details where customer_country <> 'USA' or customer_country is null) as other_orders_count;

-- if customer country has null then automatically ignores
-- if null countries also need then:
-- where customer_country IN ('Germany', 'France', 'UK', ...) or customer_country is null

-- Task 7 (answer as a comment):
-- a) Does a view store data? If a new order is inserted into sales.Orders, does the view show it? Why?
-- b) Name two differences between a view and a CTE.
-- c) Name two real reasons a company would give analysts views instead of access to the base tables.
-- answers:
-- a) view do not store data so new data will show immediately as soon as it added
-- b) view can be used multiple queries while cte used only query, view keeps persisted as object cte for only once request 
-- c) security reasons, because company decides who gonna get what data in order to safety 
-- and usability reasons, because views mostly looks compact and easy to use
/* ============ Bonus ============ */

-- Bonus: Create the view sales.v_employees_public for colleagues outside HR:
-- employeeid, full name, department and manager's full name. No salary, no birthdate, no gender.
go
create view sales.v_employees_public as
select
	e.employeeid,
	coalesce(e.firstname, '') + ' ' + coalesce(e.lastname, '') as full_name,
	e.department,
	coalesce(m.firstname, '') + ' ' + coalesce(m.lastname, '') as manager_full_name
from sales.employees as e
left join sales.employees as m
	on m.employeeid = e.managerid;
go

select * from sales.v_employees_public;
